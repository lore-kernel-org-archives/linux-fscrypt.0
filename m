Return-Path: <SRS0=I4Qa=WM=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Date: Fri, 16 Aug 2019 11:48:01 +0530
In-Reply-To: <20190816061804.14840-1-chandan@linux.ibm.com>
References: <20190816061804.14840-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190816061804.14840-6-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, chandanrmail@gmail.com, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

F2FS has a copy of "post read processing" code using which encrypted
file data is decrypted. This commit replaces it to make use of the
generic read_callbacks facility.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/f2fs/data.c  | 109 ++++--------------------------------------------
 fs/f2fs/f2fs.h  |   2 -
 fs/f2fs/super.c |   9 +---
 3 files changed, 11 insertions(+), 109 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 757f050c650a..3cf1eca2ece9 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -18,6 +18,7 @@
 #include <linux/uio.h>
 #include <linux/cleancache.h>
 #include <linux/sched/signal.h>
+#include <linux/read_callbacks.h>
 
 #include "f2fs.h"
 #include "node.h"
@@ -25,11 +26,6 @@
 #include "trace.h"
 #include <trace/events/f2fs.h>
 
-#define NUM_PREALLOC_POST_READ_CTXS	128
-
-static struct kmem_cache *bio_post_read_ctx_cache;
-static mempool_t *bio_post_read_ctx_pool;
-
 static bool __is_cp_guaranteed(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
@@ -69,19 +65,6 @@ static enum count_type __read_io_type(struct page *page)
 	return F2FS_RD_DATA;
 }
 
-/* postprocessing steps for read bios */
-enum bio_post_read_step {
-	STEP_INITIAL = 0,
-	STEP_DECRYPT,
-};
-
-struct bio_post_read_ctx {
-	struct bio *bio;
-	struct work_struct work;
-	unsigned int cur_step;
-	unsigned int enabled_steps;
-};
-
 static void __read_end_io(struct bio *bio)
 {
 	struct page *page;
@@ -93,7 +76,7 @@ static void __read_end_io(struct bio *bio)
 		page = bv->bv_page;
 
 		/* PG_error was set if any post_read step failed */
-		if (bio->bi_status || PageError(page)) {
+		if (bio->bi_status || read_callbacks_failed(page)) {
 			ClearPageUptodate(page);
 			/* will re-read again later */
 			ClearPageError(page);
@@ -103,42 +86,8 @@ static void __read_end_io(struct bio *bio)
 		dec_page_count(F2FS_P_SB(page), __read_io_type(page));
 		unlock_page(page);
 	}
-	if (bio->bi_private)
-		mempool_free(bio->bi_private, bio_post_read_ctx_pool);
-	bio_put(bio);
-}
 
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
-static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
-{
-	switch (++ctx->cur_step) {
-	case STEP_DECRYPT:
-		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
-			INIT_WORK(&ctx->work, decrypt_work);
-			fscrypt_enqueue_decrypt_work(&ctx->work);
-			return;
-		}
-		ctx->cur_step++;
-		/* fall-through */
-	default:
-		__read_end_io(ctx->bio);
-	}
-}
-
-static bool f2fs_bio_post_read_required(struct bio *bio)
-{
-	return bio->bi_private && !bio->bi_status;
+	bio_put(bio);
 }
 
 static void f2fs_read_end_io(struct bio *bio)
@@ -149,15 +98,7 @@ static void f2fs_read_end_io(struct bio *bio)
 		bio->bi_status = BLK_STS_IOERR;
 	}
 
-	if (f2fs_bio_post_read_required(bio)) {
-		struct bio_post_read_ctx *ctx = bio->bi_private;
-
-		ctx->cur_step = STEP_INITIAL;
-		bio_post_read_processing(ctx);
-		return;
-	}
-
-	__read_end_io(bio);
+	read_callbacks_endio_bio(bio, __read_end_io);
 }
 
 static void f2fs_write_end_io(struct bio *bio)
@@ -556,8 +497,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 {
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct bio *bio;
-	struct bio_post_read_ctx *ctx;
-	unsigned int post_read_steps = 0;
+	int err;
 
 	if (!f2fs_is_valid_blkaddr(sbi, blkaddr, DATA_GENERIC))
 		return ERR_PTR(-EFAULT);
@@ -569,17 +509,10 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 	bio->bi_end_io = f2fs_read_end_io;
 	bio_set_op_attrs(bio, REQ_OP_READ, op_flag);
 
-	if (f2fs_encrypted_file(inode))
-		post_read_steps |= 1 << STEP_DECRYPT;
-	if (post_read_steps) {
-		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
-		if (!ctx) {
-			bio_put(bio);
-			return ERR_PTR(-ENOMEM);
-		}
-		ctx->bio = bio;
-		ctx->enabled_steps = post_read_steps;
-		bio->bi_private = ctx;
+	err = read_callbacks_setup_bio(inode, bio);
+	if (err) {
+		bio_put(bio);
+		return ERR_PTR(err);
 	}
 
 	return bio;
@@ -2860,27 +2793,3 @@ void f2fs_clear_page_cache_dirty_tag(struct page *page)
 						PAGECACHE_TAG_DIRTY);
 	xa_unlock_irqrestore(&mapping->i_pages, flags);
 }
-
-int __init f2fs_init_post_read_processing(void)
-{
-	bio_post_read_ctx_cache = KMEM_CACHE(bio_post_read_ctx, 0);
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
-void __exit f2fs_destroy_post_read_processing(void)
-{
-	mempool_destroy(bio_post_read_ctx_pool);
-	kmem_cache_destroy(bio_post_read_ctx_cache);
-}
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 87f75ebd2fd6..cea79321b794 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -3125,8 +3125,6 @@ void f2fs_destroy_checkpoint_caches(void);
 /*
  * data.c
  */
-int f2fs_init_post_read_processing(void);
-void f2fs_destroy_post_read_processing(void);
 void f2fs_submit_merged_write(struct f2fs_sb_info *sbi, enum page_type type);
 void f2fs_submit_merged_write_cond(struct f2fs_sb_info *sbi,
 				struct inode *inode, struct page *page,
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 11b3a039a188..d7bbb4f1fdb3 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -3597,15 +3597,11 @@ static int __init init_f2fs_fs(void)
 	err = register_filesystem(&f2fs_fs_type);
 	if (err)
 		goto free_shrinker;
+
 	f2fs_create_root_stats();
-	err = f2fs_init_post_read_processing();
-	if (err)
-		goto free_root_stats;
+
 	return 0;
 
-free_root_stats:
-	f2fs_destroy_root_stats();
-	unregister_filesystem(&f2fs_fs_type);
 free_shrinker:
 	unregister_shrinker(&f2fs_shrinker_info);
 free_sysfs:
@@ -3626,7 +3622,6 @@ static int __init init_f2fs_fs(void)
 
 static void __exit exit_f2fs_fs(void)
 {
-	f2fs_destroy_post_read_processing();
 	f2fs_destroy_root_stats();
 	unregister_filesystem(&f2fs_fs_type);
 	unregister_shrinker(&f2fs_shrinker_info);
-- 
2.19.1
