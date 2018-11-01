Return-Path: <SRS0=DPN/=NM=vger.kernel.org=linux-integrity-owner@kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 11/12] ext4: add fs-verity read support
Date: Thu,  1 Nov 2018 15:52:29 -0700
Message-Id: <20181101225230.88058-12-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-integrity-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Make ext4_mpage_readpages() verify data as it is read from fs-verity
files, using the helper functions from fs/verity/.

To be compatible with fscrypt, like in the corresponding f2fs patch this
required refactoring the decryption workflow into a generic "post-read
processing" workflow, which can do decryption, verification, or both.

Co-developed-by: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/ext4.h     |   2 +
 fs/ext4/inode.c    |   3 +
 fs/ext4/readpage.c | 209 ++++++++++++++++++++++++++++++++++++++-------
 fs/ext4/super.c    |   9 +-
 4 files changed, 191 insertions(+), 32 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index e5475a629ed80..80957f9d3cbef 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -3101,6 +3101,8 @@ static inline void ext4_set_de_type(struct super_block *sb,
 extern int ext4_mpage_readpages(struct address_space *mapping,
 				struct list_head *pages, struct page *page,
 				unsigned nr_pages, bool is_readahead);
+extern int __init ext4_init_post_read_processing(void);
+extern void ext4_exit_post_read_processing(void);
 
 /* symlink.c */
 extern const struct inode_operations ext4_encrypted_symlink_inode_operations;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c624c83bbad26..d7019f5dca6f1 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3884,6 +3884,9 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		return 0;
 #endif
 
+	if (ext4_verity_inode(inode))
+		return 0;
+
 	/*
 	 * If we are doing data journalling we don't support O_DIRECT
 	 */
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index f461d75ac049f..d3dd1ff745db8 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -47,6 +47,11 @@
 
 #include "ext4.h"
 
+#define NUM_PREALLOC_POST_READ_CTXS	128
+
+static struct kmem_cache *bio_post_read_ctx_cache;
+static mempool_t *bio_post_read_ctx_pool;
+
 static inline bool ext4_bio_encrypted(struct bio *bio)
 {
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
@@ -56,6 +61,124 @@ static inline bool ext4_bio_encrypted(struct bio *bio)
 #endif
 }
 
+/* postprocessing steps for read bios */
+enum bio_post_read_step {
+	STEP_INITIAL = 0,
+	STEP_DECRYPT,
+	STEP_VERITY,
+};
+
+struct bio_post_read_ctx {
+	struct bio *bio;
+	struct work_struct work;
+	unsigned int cur_step;
+	unsigned int enabled_steps;
+};
+
+static void __read_end_io(struct bio *bio)
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
+		mempool_free(bio->bi_private, bio_post_read_ctx_pool);
+	bio_put(bio);
+}
+
+static void bio_post_read_processing(struct bio_post_read_ctx *ctx);
+
+static void decrypt_work(struct work_struct *work)
+{
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
+
+	fscrypt_decrypt_bio(ctx->bio);
+
+	bio_post_read_processing(ctx);
+}
+
+static void verity_work(struct work_struct *work)
+{
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
+
+	fsverity_verify_bio(ctx->bio);
+
+	bio_post_read_processing(ctx);
+}
+
+static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
+{
+	/*
+	 * We use different work queues for decryption and for verity because
+	 * verity may require reading metadata pages that need decryption, and
+	 * we shouldn't recurse to the same workqueue.
+	 */
+	switch (++ctx->cur_step) {
+	case STEP_DECRYPT:
+		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
+			INIT_WORK(&ctx->work, decrypt_work);
+			fscrypt_enqueue_decrypt_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
+	case STEP_VERITY:
+		if (ctx->enabled_steps & (1 << STEP_VERITY)) {
+			INIT_WORK(&ctx->work, verity_work);
+			fsverity_enqueue_verify_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
+	default:
+		__read_end_io(ctx->bio);
+	}
+}
+
+static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
+						       struct bio *bio,
+						       pgoff_t index)
+{
+	unsigned int post_read_steps = 0;
+	struct bio_post_read_ctx *ctx = NULL;
+
+	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+		post_read_steps |= 1 << STEP_DECRYPT;
+#ifdef CONFIG_EXT4_FS_VERITY
+	if (inode->i_verity_info != NULL &&
+	    (index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
+		post_read_steps |= 1 << STEP_VERITY;
+#endif
+	if (post_read_steps) {
+		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
+		if (!ctx)
+			return ERR_PTR(-ENOMEM);
+		ctx->bio = bio;
+		ctx->enabled_steps = post_read_steps;
+		bio->bi_private = ctx;
+	}
+	return ctx;
+}
+
+static bool bio_post_read_required(struct bio *bio)
+{
+	return bio->bi_private && !bio->bi_status;
+}
+
 /*
  * I/O completion handler for multipage BIOs.
  *
@@ -70,30 +193,31 @@ static inline bool ext4_bio_encrypted(struct bio *bio)
  */
 static void mpage_end_io(struct bio *bio)
 {
-	struct bio_vec *bv;
-	int i;
+	if (bio_post_read_required(bio)) {
+		struct bio_post_read_ctx *ctx = bio->bi_private;
 
-	if (ext4_bio_encrypted(bio)) {
-		if (bio->bi_status) {
-			fscrypt_release_ctx(bio->bi_private);
-		} else {
-			fscrypt_enqueue_decrypt_bio(bio->bi_private, bio);
-			return;
-		}
+		ctx->cur_step = STEP_INITIAL;
+		bio_post_read_processing(ctx);
+		return;
 	}
-	bio_for_each_segment_all(bv, bio, i) {
-		struct page *page = bv->bv_page;
+	__read_end_io(bio);
+}
 
-		if (!bio->bi_status) {
-			SetPageUptodate(page);
-		} else {
-			ClearPageUptodate(page);
-			SetPageError(page);
-		}
-		unlock_page(page);
+static inline loff_t ext4_readpage_limit(struct inode *inode)
+{
+#ifdef CONFIG_EXT4_FS_VERITY
+	if (ext4_verity_inode(inode)) {
+		if (inode->i_verity_info)
+			/* limit to end of metadata region */
+			return fsverity_full_i_size(inode);
+		/*
+		 * fsverity_info is currently being set up and no user reads are
+		 * allowed yet.  It's easiest to just not enforce a limit yet.
+		 */
+		return inode->i_sb->s_maxbytes;
 	}
-
-	bio_put(bio);
+#endif
+	return i_size_read(inode);
 }
 
 int ext4_mpage_readpages(struct address_space *mapping,
@@ -140,7 +264,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 
 		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 		last_block = block_in_file + nr_pages * blocks_per_page;
-		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
+		last_block_in_file = (ext4_readpage_limit(inode) +
+				      blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
 			last_block = last_block_in_file;
 		page_block = 0;
@@ -217,6 +342,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			zero_user_segment(page, first_hole << blkbits,
 					  PAGE_SIZE);
 			if (first_hole == 0) {
+				if (!fsverity_check_hole(inode, page))
+					goto set_error_page;
 				SetPageUptodate(page);
 				unlock_page(page);
 				goto next_page;
@@ -240,19 +367,15 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			bio = NULL;
 		}
 		if (bio == NULL) {
-			struct fscrypt_ctx *ctx = NULL;
+			struct bio_post_read_ctx *ctx;
 
-			if (ext4_encrypted_inode(inode) &&
-			    S_ISREG(inode->i_mode)) {
-				ctx = fscrypt_get_ctx(inode, GFP_NOFS);
-				if (IS_ERR(ctx))
-					goto set_error_page;
-			}
 			bio = bio_alloc(GFP_KERNEL,
 				min_t(int, nr_pages, BIO_MAX_PAGES));
-			if (!bio) {
-				if (ctx)
-					fscrypt_release_ctx(ctx);
+			if (!bio)
+				goto set_error_page;
+			ctx = get_bio_post_read_ctx(inode, bio, page->index);
+			if (IS_ERR(ctx)) {
+				bio_put(bio);
 				goto set_error_page;
 			}
 			bio_set_dev(bio, bdev);
@@ -293,3 +416,27 @@ int ext4_mpage_readpages(struct address_space *mapping,
 		submit_bio(bio);
 	return 0;
 }
+
+int __init ext4_init_post_read_processing(void)
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
+void ext4_exit_post_read_processing(void)
+{
+	mempool_destroy(bio_post_read_ctx_pool);
+	kmem_cache_destroy(bio_post_read_ctx_cache);
+}
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index c4a66b64ea604..fb4e060f28ecb 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -6070,6 +6070,10 @@ static int __init ext4_init_fs(void)
 		return err;
 
 	err = ext4_init_pending();
+	if (err)
+		goto out7;
+
+	err = ext4_init_post_read_processing();
 	if (err)
 		goto out6;
 
@@ -6111,8 +6115,10 @@ static int __init ext4_init_fs(void)
 out4:
 	ext4_exit_pageio();
 out5:
-	ext4_exit_pending();
+	ext4_exit_post_read_processing();
 out6:
+	ext4_exit_pending();
+out7:
 	ext4_exit_es();
 
 	return err;
@@ -6129,6 +6135,7 @@ static void __exit ext4_exit_fs(void)
 	ext4_exit_sysfs();
 	ext4_exit_system_zone();
 	ext4_exit_pageio();
+	ext4_exit_post_read_processing();
 	ext4_exit_es();
 	ext4_exit_pending();
 }
-- 
2.19.1.568.g152ad8e336-goog
