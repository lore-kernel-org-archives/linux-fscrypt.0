Return-Path: <SRS0=har8=S2=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V1 07/14] Remove the term "bio" from post read processing
Date: Wed, 24 Apr 2019 10:07:23 +0530
In-Reply-To: <20190424043730.13683-1-chandan@linux.ibm.com>
References: <20190424043730.13683-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190424043730.13683-8-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

For block size < page size, apart from handling bios, post read
processing needs to handle buffer heads. Hence this commit removes the
term "bio" from the identifiers associated with post read processing.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/crypto/bio.c                   |  6 ++--
 fs/f2fs/data.c                    | 10 +++---
 fs/mpage.c                        | 10 +++---
 fs/post_read_process.c            | 56 +++++++++++++++----------------
 fs/verity/verify.c                |  6 ++--
 include/linux/post_read_process.h | 16 ++++-----
 6 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 3e40d65ae6a8..bab48dfa3765 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -58,12 +58,12 @@ EXPORT_SYMBOL(fscrypt_decrypt_bio);
 
 void fscrypt_decrypt_work(struct work_struct *work)
 {
-	struct bio_post_read_ctx *ctx =
-		container_of(work, struct bio_post_read_ctx, work);
+	struct post_read_ctx *ctx =
+		container_of(work, struct post_read_ctx, work);
 
 	fscrypt_decrypt_bio(ctx->bio);
 
-	bio_post_read_processing(ctx);
+	post_read_processing(ctx);
 }
 
 void fscrypt_pullback_bio_page(struct page **page, bool restore)
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 2f62244f6d24..f00f018bed27 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -89,10 +89,10 @@ static void __read_end_io(struct bio *bio)
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
 	if (bio->bi_private) {
-		struct bio_post_read_ctx *ctx;
+		struct post_read_ctx *ctx;
 
 		ctx = bio->bi_private;
-		put_bio_post_read_ctx(ctx);
+		put_post_read_ctx(ctx);
 	}
 #endif
 	bio_put(bio);
@@ -108,7 +108,7 @@ static void f2fs_read_end_io(struct bio *bio)
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
 	if (!bio->bi_status && bio->bi_private) {
-		bio_post_read_processing((struct bio_post_read_ctx *)(bio->bi_private));
+		post_read_processing((struct post_read_ctx *)(bio->bi_private));
 		return;
 	}
 #endif
@@ -514,7 +514,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct bio *bio;
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-	struct bio_post_read_ctx *ctx;
+	struct post_read_ctx *ctx;
 #endif
 	if (!f2fs_is_valid_blkaddr(sbi, blkaddr, DATA_GENERIC))
 		return ERR_PTR(-EFAULT);
@@ -527,7 +527,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 	bio_set_op_attrs(bio, REQ_OP_READ, op_flag);
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-	ctx = get_bio_post_read_ctx(inode, bio, first_idx);
+	ctx = get_post_read_ctx(inode, bio, first_idx);
 	if (IS_ERR(ctx)) {
 		bio_put(bio);
 		return (struct bio *)ctx;
diff --git a/fs/mpage.c b/fs/mpage.c
index 9c291d6ddab6..938f00984ba1 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -56,16 +56,16 @@ static void mpage_end_io(struct bio *bio)
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
 	if (!bio->bi_status && bio->bi_private) {
-		struct bio_post_read_ctx *ctx;
+		struct post_read_ctx *ctx;
 
 		ctx = bio->bi_private;
 
-		bio_post_read_processing(ctx);
+		post_read_processing(ctx);
 		return;
 	}
 
 	if (bio->bi_private)
-		put_bio_post_read_ctx((struct bio_post_read_ctx *)(bio->bi_private));
+		put_post_read_ctx((struct post_read_ctx *)(bio->bi_private));
 #endif
 
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
@@ -332,7 +332,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 alloc_new:
 	if (args->bio == NULL) {
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-		struct bio_post_read_ctx *ctx;
+		struct post_read_ctx *ctx;
 #endif
 		if (first_hole == blocks_per_page
 			&& !(IS_ENCRYPTED(inode) || IS_VERITY(inode))) {
@@ -348,7 +348,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 			goto confused;
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-		ctx = get_bio_post_read_ctx(inode, args->bio, page->index);
+		ctx = get_post_read_ctx(inode, args->bio, page->index);
 		if (IS_ERR(ctx)) {
 			bio_put(args->bio);
 			args->bio = NULL;
diff --git a/fs/post_read_process.c b/fs/post_read_process.c
index b60be77c7217..a9ea0dca23bc 100644
--- a/fs/post_read_process.c
+++ b/fs/post_read_process.c
@@ -14,17 +14,17 @@
 
 #define NUM_PREALLOC_POST_READ_CTXS	128
 
-static struct kmem_cache *bio_post_read_ctx_cache;
-static mempool_t *bio_post_read_ctx_pool;
+static struct kmem_cache *post_read_ctx_cache;
+static mempool_t *post_read_ctx_pool;
 
 /* postprocessing steps for read bios */
-enum bio_post_read_step {
+enum post_read_step {
 	STEP_INITIAL = 0,
 	STEP_DECRYPT,
 	STEP_VERITY,
 };
 
-void end_bio_post_read_processing(struct bio *bio)
+void end_post_read_processing(struct bio *bio)
 {
 	struct page *page;
 	struct bio_vec *bv;
@@ -42,12 +42,12 @@ void end_bio_post_read_processing(struct bio *bio)
 		unlock_page(page);
 	}
 	if (bio->bi_private)
-		put_bio_post_read_ctx(bio->bi_private);
+		put_post_read_ctx(bio->bi_private);
 	bio_put(bio);
 }
-EXPORT_SYMBOL(end_bio_post_read_processing);
+EXPORT_SYMBOL(end_post_read_processing);
 
-void bio_post_read_processing(struct bio_post_read_ctx *ctx)
+void post_read_processing(struct post_read_ctx *ctx)
 {
 	/*
 	 * We use different work queues for decryption and for verity because
@@ -70,17 +70,17 @@ void bio_post_read_processing(struct bio_post_read_ctx *ctx)
 		ctx->cur_step++;
 		/* fall-through */
 	default:
-		end_bio_post_read_processing(ctx->bio);
+		end_post_read_processing(ctx->bio);
 	}
 }
-EXPORT_SYMBOL(bio_post_read_processing);
+EXPORT_SYMBOL(post_read_processing);
 
-struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
-						struct bio *bio,
-						pgoff_t index)
+struct post_read_ctx *get_post_read_ctx(struct inode *inode,
+					struct bio *bio,
+					pgoff_t index)
 {
 	unsigned int post_read_steps = 0;
-	struct bio_post_read_ctx *ctx = NULL;
+	struct post_read_ctx *ctx = NULL;
 
 	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
@@ -92,7 +92,7 @@ struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 		post_read_steps |= 1 << STEP_VERITY;
 #endif
 	if (post_read_steps) {
-		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
+		ctx = mempool_alloc(post_read_ctx_pool, GFP_NOFS);
 		if (!ctx)
 			return ERR_PTR(-ENOMEM);
 		ctx->bio = bio;
@@ -103,36 +103,36 @@ struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 	}
 	return ctx;
 }
-EXPORT_SYMBOL(get_bio_post_read_ctx);
+EXPORT_SYMBOL(get_post_read_ctx);
 
-void put_bio_post_read_ctx(struct bio_post_read_ctx *ctx)
+void put_post_read_ctx(struct post_read_ctx *ctx)
 {
-	mempool_free(ctx, bio_post_read_ctx_pool);
+	mempool_free(ctx, post_read_ctx_pool);
 }
-EXPORT_SYMBOL(put_bio_post_read_ctx);
+EXPORT_SYMBOL(put_post_read_ctx);
 
-bool bio_post_read_required(struct bio *bio)
+bool post_read_required(struct bio *bio)
 {
 	return bio->bi_private && !bio->bi_status;
 }
-EXPORT_SYMBOL(bio_post_read_required);
+EXPORT_SYMBOL(post_read_required);
 
-static int __init bio_init_post_read_processing(void)
+static int __init init_post_read_processing(void)
 {
-	bio_post_read_ctx_cache = KMEM_CACHE(bio_post_read_ctx, 0);
-	if (!bio_post_read_ctx_cache)
+	post_read_ctx_cache = KMEM_CACHE(post_read_ctx, 0);
+	if (!post_read_ctx_cache)
 		goto fail;
-	bio_post_read_ctx_pool =
+	post_read_ctx_pool =
 		mempool_create_slab_pool(NUM_PREALLOC_POST_READ_CTXS,
-					 bio_post_read_ctx_cache);
-	if (!bio_post_read_ctx_pool)
+					 post_read_ctx_cache);
+	if (!post_read_ctx_pool)
 		goto fail_free_cache;
 	return 0;
 
 fail_free_cache:
-	kmem_cache_destroy(bio_post_read_ctx_cache);
+	kmem_cache_destroy(post_read_ctx_cache);
 fail:
 	return -ENOMEM;
 }
 
-fs_initcall(bio_init_post_read_processing);
+fs_initcall(init_post_read_processing);
diff --git a/fs/verity/verify.c b/fs/verity/verify.c
index f81d8ff847ec..6cb43c538a3c 100644
--- a/fs/verity/verify.c
+++ b/fs/verity/verify.c
@@ -287,12 +287,12 @@ EXPORT_SYMBOL_GPL(fsverity_verify_bio);
 
 static void fsverity_verify_work(struct work_struct *work)
 {
-	struct bio_post_read_ctx *ctx =
-		container_of(work, struct bio_post_read_ctx, work);
+	struct post_read_ctx *ctx =
+		container_of(work, struct post_read_ctx, work);
 
 	fsverity_verify_bio(ctx->bio);
 
-	bio_post_read_processing(ctx);
+	post_read_processing(ctx);
 }
 
 /**
diff --git a/include/linux/post_read_process.h b/include/linux/post_read_process.h
index 09e52928f861..523bdecf9252 100644
--- a/include/linux/post_read_process.h
+++ b/include/linux/post_read_process.h
@@ -2,7 +2,7 @@
 #ifndef _POST_READ_PROCESS_H
 #define _POST_READ_PROCESS_H
 
-struct bio_post_read_ctx {
+struct post_read_ctx {
 	struct bio *bio;
 	struct inode *inode;
 	struct work_struct work;
@@ -10,12 +10,12 @@ struct bio_post_read_ctx {
 	unsigned int enabled_steps;
 };
 
-void end_bio_post_read_processing(struct bio *bio);
-void bio_post_read_processing(struct bio_post_read_ctx *ctx);
-struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
-						struct bio *bio,
-						pgoff_t index);
-void put_bio_post_read_ctx(struct bio_post_read_ctx *ctx);
-bool bio_post_read_required(struct bio *bio);
+void end_post_read_processing(struct bio *bio);
+void post_read_processing(struct post_read_ctx *ctx);
+struct post_read_ctx *get_post_read_ctx(struct inode *inode,
+					struct bio *bio,
+					pgoff_t index);
+void put_post_read_ctx(struct post_read_ctx *ctx);
+bool post_read_required(struct bio *bio);
 
 #endif	/* _POST_READ_PROCESS_H */
-- 
2.19.1
