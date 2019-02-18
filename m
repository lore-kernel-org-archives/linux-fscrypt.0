Return-Path: <SRS0=THX2=QZ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 04/10] Consolidate "post read processing" into a new file
Date: Mon, 18 Feb 2019 15:34:27 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190218100433.20048-5-chandan@linux.ibm.com>
To: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

The post read processing code is used by both Ext4 and F2FS. Hence to
remove duplicity, this commit moves the code into
include/linux/post_read_process.h and fs/post_read_process.c.

The corresponding decrypt and verity "work" functions have been moved
inside fscrypt and fsverity sources. With these in place, the post
processing code now has to just invoke enqueue functions provided by
fscrypt and fsverity.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/Makefile                       |   3 +-
 fs/crypto/bio.c                   |  21 ++--
 fs/crypto/crypto.c                |   1 +
 fs/crypto/fscrypt_private.h       |   3 +
 fs/ext4/ext4.h                    |   2 -
 fs/ext4/readpage.c                | 153 +-----------------------------
 fs/ext4/super.c                   |   9 +-
 fs/post_read_process.c            | 127 +++++++++++++++++++++++++
 fs/verity/verify.c                |  12 +++
 include/linux/fscrypt.h           |  11 ---
 include/linux/post_read_process.h |  21 ++++
 11 files changed, 176 insertions(+), 187 deletions(-)
 create mode 100644 fs/post_read_process.c
 create mode 100644 include/linux/post_read_process.h

diff --git a/fs/Makefile b/fs/Makefile
index 10b37f651ffd..5f6c0cba102b 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -12,7 +12,8 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o d_path.o \
-		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
+		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
+		post_read_process.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0959044c5cee..a659a76c05e4 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -24,6 +24,8 @@
 #include <linux/module.h>
 #include <linux/bio.h>
 #include <linux/namei.h>
+#include <linux/post_read_process.h>
+
 #include "fscrypt_private.h"
 
 static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
@@ -53,24 +55,15 @@ void fscrypt_decrypt_bio(struct bio *bio)
 }
 EXPORT_SYMBOL(fscrypt_decrypt_bio);
 
-static void completion_pages(struct work_struct *work)
+void fscrypt_decrypt_work(struct work_struct *work)
 {
-	struct fscrypt_ctx *ctx =
-		container_of(work, struct fscrypt_ctx, r.work);
-	struct bio *bio = ctx->r.bio;
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
 
-	__fscrypt_decrypt_bio(bio, true);
-	fscrypt_release_ctx(ctx);
-	bio_put(bio);
-}
+	fscrypt_decrypt_bio(ctx->bio);
 
-void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx, struct bio *bio)
-{
-	INIT_WORK(&ctx->r.work, completion_pages);
-	ctx->r.bio = bio;
-	fscrypt_enqueue_decrypt_work(&ctx->r.work);
+	bio_post_read_processing(ctx);
 }
-EXPORT_SYMBOL(fscrypt_enqueue_decrypt_bio);
 
 void fscrypt_pullback_bio_page(struct page **page, bool restore)
 {
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 4dc788e3bc96..36d599784e5a 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -53,6 +53,7 @@ struct kmem_cache *fscrypt_info_cachep;
 
 void fscrypt_enqueue_decrypt_work(struct work_struct *work)
 {
+	INIT_WORK(work, fscrypt_decrypt_work);
 	queue_work(fscrypt_read_workqueue, work);
 }
 EXPORT_SYMBOL(fscrypt_enqueue_decrypt_work);
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 7da276159593..412a3bcf9efd 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -114,6 +114,9 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 	return false;
 }
 
+/* bio.c */
+void fscrypt_decrypt_work(struct work_struct *work);
+
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
 extern int fscrypt_initialize(unsigned int cop_flags);
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 0ffa84772667..c0245820bafe 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -3088,8 +3088,6 @@ static inline void ext4_set_de_type(struct super_block *sb,
 extern int ext4_mpage_readpages(struct address_space *mapping,
 				struct list_head *pages, struct page *page,
 				unsigned nr_pages, bool is_readahead);
-extern int __init ext4_init_post_read_processing(void);
-extern void ext4_exit_post_read_processing(void);
 
 /* symlink.c */
 extern const struct inode_operations ext4_encrypted_symlink_inode_operations;
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 93fbc15177a3..8943fc41fd33 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -44,14 +44,10 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#include <linux/post_read_process.h>
 
 #include "ext4.h"
 
-#define NUM_PREALLOC_POST_READ_CTXS	128
-
-static struct kmem_cache *bio_post_read_ctx_cache;
-static mempool_t *bio_post_read_ctx_pool;
-
 static inline bool ext4_bio_encrypted(struct bio *bio)
 {
 #ifdef CONFIG_FS_ENCRYPTION
@@ -61,124 +57,6 @@ static inline bool ext4_bio_encrypted(struct bio *bio)
 #endif
 }
 
-/* postprocessing steps for read bios */
-enum bio_post_read_step {
-	STEP_INITIAL = 0,
-	STEP_DECRYPT,
-	STEP_VERITY,
-};
-
-struct bio_post_read_ctx {
-	struct bio *bio;
-	struct work_struct work;
-	unsigned int cur_step;
-	unsigned int enabled_steps;
-};
-
-static void __read_end_io(struct bio *bio)
-{
-	struct page *page;
-	struct bio_vec *bv;
-	int i;
-
-	bio_for_each_segment_all(bv, bio, i) {
-		page = bv->bv_page;
-
-		/* PG_error was set if any post_read step failed */
-		if (bio->bi_status || PageError(page)) {
-			ClearPageUptodate(page);
-			SetPageError(page);
-		} else {
-			SetPageUptodate(page);
-		}
-		unlock_page(page);
-	}
-	if (bio->bi_private)
-		mempool_free(bio->bi_private, bio_post_read_ctx_pool);
-	bio_put(bio);
-}
-
-static void bio_post_read_processing(struct bio_post_read_ctx *ctx);
-
-static void decrypt_work(struct work_struct *work)
-{
-	struct bio_post_read_ctx *ctx =
-		container_of(work, struct bio_post_read_ctx, work);
-
-	fscrypt_decrypt_bio(ctx->bio);
-
-	bio_post_read_processing(ctx);
-}
-
-static void verity_work(struct work_struct *work)
-{
-	struct bio_post_read_ctx *ctx =
-		container_of(work, struct bio_post_read_ctx, work);
-
-	fsverity_verify_bio(ctx->bio);
-
-	bio_post_read_processing(ctx);
-}
-
-static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
-{
-	/*
-	 * We use different work queues for decryption and for verity because
-	 * verity may require reading metadata pages that need decryption, and
-	 * we shouldn't recurse to the same workqueue.
-	 */
-	switch (++ctx->cur_step) {
-	case STEP_DECRYPT:
-		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
-			INIT_WORK(&ctx->work, decrypt_work);
-			fscrypt_enqueue_decrypt_work(&ctx->work);
-			return;
-		}
-		ctx->cur_step++;
-		/* fall-through */
-	case STEP_VERITY:
-		if (ctx->enabled_steps & (1 << STEP_VERITY)) {
-			INIT_WORK(&ctx->work, verity_work);
-			fsverity_enqueue_verify_work(&ctx->work);
-			return;
-		}
-		ctx->cur_step++;
-		/* fall-through */
-	default:
-		__read_end_io(ctx->bio);
-	}
-}
-
-static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
-						       struct bio *bio,
-						       pgoff_t index)
-{
-	unsigned int post_read_steps = 0;
-	struct bio_post_read_ctx *ctx = NULL;
-
-	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
-		post_read_steps |= 1 << STEP_DECRYPT;
-#ifdef CONFIG_FS_VERITY
-	if (inode->i_verity_info != NULL &&
-	    (index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
-		post_read_steps |= 1 << STEP_VERITY;
-#endif
-	if (post_read_steps) {
-		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
-		if (!ctx)
-			return ERR_PTR(-ENOMEM);
-		ctx->bio = bio;
-		ctx->enabled_steps = post_read_steps;
-		bio->bi_private = ctx;
-	}
-	return ctx;
-}
-
-static bool bio_post_read_required(struct bio *bio)
-{
-	return bio->bi_private && !bio->bi_status;
-}
-
 /*
  * I/O completion handler for multipage BIOs.
  *
@@ -196,11 +74,10 @@ static void mpage_end_io(struct bio *bio)
 	if (bio_post_read_required(bio)) {
 		struct bio_post_read_ctx *ctx = bio->bi_private;
 
-		ctx->cur_step = STEP_INITIAL;
 		bio_post_read_processing(ctx);
 		return;
 	}
-	__read_end_io(bio);
+	end_bio_post_read_processing(bio);
 }
 
 static inline loff_t ext4_readpage_limit(struct inode *inode)
@@ -416,29 +293,3 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		submit_bio(bio);
 	return 0;
 }
-
-int __init ext4_init_post_read_processing(void)
-{
-	bio_post_read_ctx_cache =
-		kmem_cache_create("ext4_bio_post_read_ctx",
-				  sizeof(struct bio_post_read_ctx), 0, 0, NULL);
-	if (!bio_post_read_ctx_cache)
-		goto fail;
-	bio_post_read_ctx_pool =
-		mempool_create_slab_pool(NUM_PREALLOC_POST_READ_CTXS,
-					 bio_post_read_ctx_cache);
-	if (!bio_post_read_ctx_pool)
-		goto fail_free_cache;
-	return 0;
-
-fail_free_cache:
-	kmem_cache_destroy(bio_post_read_ctx_cache);
-fail:
-	return -ENOMEM;
-}
-
-void ext4_exit_post_read_processing(void)
-{
-	mempool_destroy(bio_post_read_ctx_pool);
-	kmem_cache_destroy(bio_post_read_ctx_cache);
-}
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 95a5d9fbbb9f..9314dddfbf34 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -6102,10 +6102,6 @@ static int __init ext4_init_fs(void)
 		return err;
 
 	err = ext4_init_pending();
-	if (err)
-		goto out7;
-
-	err = ext4_init_post_read_processing();
 	if (err)
 		goto out6;
 
@@ -6147,10 +6143,8 @@ static int __init ext4_init_fs(void)
 out4:
 	ext4_exit_pageio();
 out5:
-	ext4_exit_post_read_processing();
-out6:
 	ext4_exit_pending();
-out7:
+out6:
 	ext4_exit_es();
 
 	return err;
@@ -6167,7 +6161,6 @@ static void __exit ext4_exit_fs(void)
 	ext4_exit_sysfs();
 	ext4_exit_system_zone();
 	ext4_exit_pageio();
-	ext4_exit_post_read_processing();
 	ext4_exit_es();
 	ext4_exit_pending();
 }
diff --git a/fs/post_read_process.c b/fs/post_read_process.c
new file mode 100644
index 000000000000..9720eeff0160
--- /dev/null
+++ b/fs/post_read_process.c
@@ -0,0 +1,127 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/bio.h>
+#include <linux/fscrypt.h>
+#include <linux/fsverity.h>
+#include <linux/post_read_process.h>
+
+#define NUM_PREALLOC_POST_READ_CTXS	128
+
+static struct kmem_cache *bio_post_read_ctx_cache;
+static mempool_t *bio_post_read_ctx_pool;
+
+/* postprocessing steps for read bios */
+enum bio_post_read_step {
+	STEP_INITIAL = 0,
+	STEP_DECRYPT,
+	STEP_VERITY,
+};
+
+void end_bio_post_read_processing(struct bio *bio)
+{
+	struct page *page;
+	struct bio_vec *bv;
+	int i;
+
+	bio_for_each_segment_all(bv, bio, i) {
+		page = bv->bv_page;
+
+		/* PG_error was set if any post_read step failed */
+		if (bio->bi_status || PageError(page)) {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		} else {
+			SetPageUptodate(page);
+		}
+		unlock_page(page);
+	}
+	if (bio->bi_private)
+		put_bio_post_read_ctx(bio->bi_private);
+	bio_put(bio);
+}
+
+void bio_post_read_processing(struct bio_post_read_ctx *ctx)
+{
+	/*
+	 * We use different work queues for decryption and for verity because
+	 * verity may require reading metadata pages that need decryption, and
+	 * we shouldn't recurse to the same workqueue.
+	 */
+	switch (++ctx->cur_step) {
+	case STEP_DECRYPT:
+		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
+			fscrypt_enqueue_decrypt_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
+	case STEP_VERITY:
+		if (ctx->enabled_steps & (1 << STEP_VERITY)) {
+			fsverity_enqueue_verify_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
+	default:
+		end_bio_post_read_processing(ctx->bio);
+	}
+}
+
+struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
+						struct bio *bio,
+						pgoff_t index)
+{
+	unsigned int post_read_steps = 0;
+	struct bio_post_read_ctx *ctx = NULL;
+
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
+		post_read_steps |= 1 << STEP_DECRYPT;
+#ifdef CONFIG_FS_VERITY
+	if (inode->i_verity_info != NULL &&
+		(index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
+		post_read_steps |= 1 << STEP_VERITY;
+#endif
+	if (post_read_steps) {
+		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
+		if (!ctx)
+			return ERR_PTR(-ENOMEM);
+		ctx->bio = bio;
+		ctx->inode = inode;
+		ctx->enabled_steps = post_read_steps;
+		ctx->cur_step = STEP_INITIAL;
+		bio->bi_private = ctx;
+	}
+	return ctx;
+}
+
+void put_bio_post_read_ctx(struct bio_post_read_ctx *ctx)
+{
+	mempool_free(ctx, bio_post_read_ctx_pool);
+}
+
+bool bio_post_read_required(struct bio *bio)
+{
+	return bio->bi_private && !bio->bi_status;
+}
+
+static int __init bio_init_post_read_processing(void)
+{
+	bio_post_read_ctx_cache = KMEM_CACHE(bio_post_read_ctx, 0);
+	if (!bio_post_read_ctx_cache)
+		goto fail;
+	bio_post_read_ctx_pool =
+		mempool_create_slab_pool(NUM_PREALLOC_POST_READ_CTXS,
+					 bio_post_read_ctx_cache);
+	if (!bio_post_read_ctx_pool)
+		goto fail_free_cache;
+	return 0;
+
+fail_free_cache:
+	kmem_cache_destroy(bio_post_read_ctx_cache);
+fail:
+	return -ENOMEM;
+}
+
+fs_initcall(bio_init_post_read_processing);
diff --git a/fs/verity/verify.c b/fs/verity/verify.c
index fbfb68eff358..4f7cd2269e83 100644
--- a/fs/verity/verify.c
+++ b/fs/verity/verify.c
@@ -13,6 +13,7 @@
 #include <linux/pagemap.h>
 #include <linux/ratelimit.h>
 #include <linux/scatterlist.h>
+#include <linux/post_read_process.h>
 
 struct workqueue_struct *fsverity_read_workqueue;
 
@@ -283,6 +284,16 @@ void fsverity_verify_bio(struct bio *bio)
 EXPORT_SYMBOL_GPL(fsverity_verify_bio);
 #endif /* CONFIG_BLOCK */
 
+static void fsverity_verify_work(struct work_struct *work)
+{
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
+
+	fsverity_verify_bio(ctx->bio);
+
+	bio_post_read_processing(ctx);
+}
+
 /**
  * fsverity_enqueue_verify_work - enqueue work on the fs-verity workqueue
  *
@@ -290,6 +301,7 @@ EXPORT_SYMBOL_GPL(fsverity_verify_bio);
  */
 void fsverity_enqueue_verify_work(struct work_struct *work)
 {
+	INIT_WORK(work, fsverity_verify_work);
 	queue_work(fsverity_read_workqueue, work);
 }
 EXPORT_SYMBOL_GPL(fsverity_enqueue_verify_work);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 6ba193c23f37..13f70e22aff2 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -68,10 +68,6 @@ struct fscrypt_ctx {
 			struct page *bounce_page;	/* Ciphertext page */
 			struct page *control_page;	/* Original page  */
 		} w;
-		struct {
-			struct bio *bio;
-			struct work_struct work;
-		} r;
 		struct list_head free_list;	/* Free list */
 	};
 	u8 flags;				/* Flags */
@@ -206,8 +202,6 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 
 /* bio.c */
 extern void fscrypt_decrypt_bio(struct bio *);
-extern void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					struct bio *bio);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
@@ -376,11 +370,6 @@ static inline void fscrypt_decrypt_bio(struct bio *bio)
 {
 }
 
-static inline void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					       struct bio *bio)
-{
-}
-
 static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
 {
 	return;
diff --git a/include/linux/post_read_process.h b/include/linux/post_read_process.h
new file mode 100644
index 000000000000..09e52928f861
--- /dev/null
+++ b/include/linux/post_read_process.h
@@ -0,0 +1,21 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _POST_READ_PROCESS_H
+#define _POST_READ_PROCESS_H
+
+struct bio_post_read_ctx {
+	struct bio *bio;
+	struct inode *inode;
+	struct work_struct work;
+	unsigned int cur_step;
+	unsigned int enabled_steps;
+};
+
+void end_bio_post_read_processing(struct bio *bio);
+void bio_post_read_processing(struct bio_post_read_ctx *ctx);
+struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
+						struct bio *bio,
+						pgoff_t index);
+void put_bio_post_read_ctx(struct bio_post_read_ctx *ctx);
+bool bio_post_read_required(struct bio *bio);
+
+#endif	/* _POST_READ_PROCESS_H */
-- 
2.19.1
