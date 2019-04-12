Return-Path: <SRS0=XRRt=SO=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 08/14] Add decryption support for sub-pagesized blocks
Date: Fri, 12 Apr 2019 22:40:35 +0530
In-Reply-To: <20190412171041.31995-1-chandan@linux.ibm.com>
References: <20190412171041.31995-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190412171041.31995-9-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

To support decryption of sub-pagesized blocks this commit adds code to,
1. Track buffer head in "struct post_read_ctx".
2. Pass buffer head argument to all "post read" processing functions.
3. In the corresponding endio, loop across all the blocks mapped by the
   page, decrypting each block in turn.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/buffer.c                       | 82 +++++++++++++++++++++++--------
 fs/crypto/bio.c                   | 48 ++++++++++++------
 fs/crypto/crypto.c                | 19 ++++++-
 fs/f2fs/data.c                    |  2 +-
 fs/mpage.c                        |  2 +-
 fs/post_read_process.c            | 53 +++++++++++++-------
 include/linux/buffer_head.h       |  1 +
 include/linux/post_read_process.h |  5 +-
 8 files changed, 151 insertions(+), 61 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index ce357602f471..6ed1637e785d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -45,6 +45,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/pagevec.h>
 #include <linux/sched/mm.h>
+#include <linux/post_read_process.h>
 #include <trace/events/block.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
@@ -245,11 +246,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	return ret;
 }
 
-/*
- * I/O completion handler for block_read_full_page() - pages
- * which come unlocked at the end of I/O.
- */
-static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
+void end_buffer_page_read(struct buffer_head *bh)
 {
 	unsigned long flags;
 	struct buffer_head *first;
@@ -257,17 +254,7 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	struct page *page;
 	int page_uptodate = 1;
 
-	BUG_ON(!buffer_async_read(bh));
-
 	page = bh->b_page;
-	if (uptodate) {
-		set_buffer_uptodate(bh);
-	} else {
-		clear_buffer_uptodate(bh);
-		buffer_io_error(bh, ", async page read");
-		SetPageError(page);
-	}
-
 	/*
 	 * Be _very_ careful from here on. Bad things can happen if
 	 * two buffer heads end IO at almost the same time and both
@@ -305,6 +292,45 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	local_irq_restore(flags);
 	return;
 }
+EXPORT_SYMBOL(end_buffer_page_read);
+
+/*
+ * I/O completion handler for block_read_full_page() - pages
+ * which come unlocked at the end of I/O.
+ */
+static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
+{
+	struct page *page;
+
+	BUG_ON(!buffer_async_read(bh));
+
+	if (uptodate && bh->b_private) {
+		struct post_read_ctx *ctx = bh->b_private;
+
+		post_read_processing(ctx);
+		return;
+	}
+
+	if (bh->b_private) {
+		struct post_read_ctx *ctx = bh->b_private;
+
+		WARN_ON(uptodate);
+		put_post_read_ctx(ctx);
+	}
+
+	page = bh->b_page;
+	if (uptodate) {
+		set_buffer_uptodate(bh);
+	} else {
+		clear_buffer_uptodate(bh);
+		buffer_io_error(bh, ", async page read");
+		SetPageError(page);
+	}
+
+	end_buffer_page_read(bh);
+
+	return;
+}
 
 /*
  * Completion handler for block_write_full_page() - pages which are unlocked
@@ -2220,7 +2246,11 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 {
 	struct inode *inode = page->mapping->host;
 	sector_t iblock, lblock;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head;
+	struct {
+		sector_t blk_nr;
+		struct buffer_head *bh;
+	} arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize, bbits;
 	int nr, i;
 	int fully_mapped = 1;
@@ -2262,7 +2292,9 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 			if (buffer_uptodate(bh))
 				continue;
 		}
-		arr[nr++] = bh;
+		arr[nr].blk_nr = iblock;
+		arr[nr].bh = bh;
+		++nr;
 	} while (i++, iblock++, (bh = bh->b_this_page) != head);
 
 	if (fully_mapped)
@@ -2281,7 +2313,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 
 	/* Stage two: lock the buffers */
 	for (i = 0; i < nr; i++) {
-		bh = arr[i];
+		bh = arr[i].bh;
 		lock_buffer(bh);
 		mark_buffer_async_read(bh);
 	}
@@ -2292,11 +2324,19 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	 * the underlying blockdev brought it uptodate (the sct fix).
 	 */
 	for (i = 0; i < nr; i++) {
-		bh = arr[i];
-		if (buffer_uptodate(bh))
+		struct post_read_ctx *ctx;
+
+		bh = arr[i].bh;
+		if (buffer_uptodate(bh)) {
 			end_buffer_async_read(bh, 1);
-		else
+		} else {
+			ctx = get_post_read_ctx(inode, NULL, bh, arr[i].blk_nr);
+			if (WARN_ON(IS_ERR(ctx))) {
+				end_buffer_async_read(bh, 0);
+				continue;
+			}
 			submit_bh(REQ_OP_READ, 0, bh);
+		}
 	}
 	return 0;
 }
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index bab48dfa3765..83de1e46f546 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -24,44 +24,60 @@
 #include <linux/module.h>
 #include <linux/bio.h>
 #include <linux/namei.h>
+#include <linux/buffer_head.h>
 #include <linux/post_read_process.h>
 
 #include "fscrypt_private.h"
 
-static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
+static void fscrypt_decrypt(struct bio *bio, struct buffer_head *bh)
 {
+	struct inode *inode;
+	struct page *page;
 	struct bio_vec *bv;
+	sector_t blk_nr;
+	int ret;
 	int i;
 	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		struct page *page = bv->bv_page;
-		int ret = fscrypt_decrypt_page(page->mapping->host, page,
-				PAGE_SIZE, 0, page->index);
+	WARN_ON(!bh && !bio);
 
+	if (bh) {
+		page = bh->b_page;
+		inode = page->mapping->host;
+
+		blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
+		blk_nr += (bh_offset(bh) >> inode->i_blkbits);
+
+		ret = fscrypt_decrypt_page(inode, page, i_blocksize(inode),
+					bh_offset(bh), blk_nr);
 		if (ret) {
 			WARN_ON_ONCE(1);
 			SetPageError(page);
-		} else if (done) {
-			SetPageUptodate(page);
 		}
-		if (done)
-			unlock_page(page);
+	} else if (bio) {
+		bio_for_each_segment_all(bv, bio, i, iter_all) {
+			struct page *page = bv->bv_page;
+			struct inode *inode = page->mapping->host;
+			const unsigned int blkbits = inode->i_blkbits;
+			u64 page_blk = page->index << (PAGE_SHIFT - blkbits);
+			u64 blk = page_blk + (bv->bv_offset >> blkbits);
+			int ret = fscrypt_decrypt_page(page->mapping->host,
+						page, bv->bv_len,
+						bv->bv_offset, blk);
+			if (ret) {
+				WARN_ON_ONCE(1);
+				SetPageError(page);
+			}
+		}
 	}
 }
 
-void fscrypt_decrypt_bio(struct bio *bio)
-{
-	__fscrypt_decrypt_bio(bio, false);
-}
-EXPORT_SYMBOL(fscrypt_decrypt_bio);
-
 void fscrypt_decrypt_work(struct work_struct *work)
 {
 	struct post_read_ctx *ctx =
 		container_of(work, struct post_read_ctx, work);
 
-	fscrypt_decrypt_bio(ctx->bio);
+	fscrypt_decrypt(ctx->bio, ctx->bh);
 
 	post_read_processing(ctx);
 }
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index ffa9302a7351..4f0d832cae71 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -305,11 +305,26 @@ EXPORT_SYMBOL(fscrypt_encrypt_page);
 int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 			unsigned int len, unsigned int offs, u64 lblk_num)
 {
+	int i, page_nr_blks;
+	int err = 0;
+
 	if (!(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES))
 		BUG_ON(!PageLocked(page));
 
-	return fscrypt_do_page_crypto(inode, FS_DECRYPT, lblk_num, page, page,
-				      len, offs, GFP_NOFS);
+	page_nr_blks = len >> inode->i_blkbits;
+
+	for (i = 0; i < page_nr_blks; i++) {
+		err = fscrypt_do_page_crypto(inode, FS_DECRYPT, lblk_num,
+					page, page, i_blocksize(inode), offs,
+					GFP_NOFS);
+		if (err)
+			break;
+
+		++lblk_num;
+		offs += i_blocksize(inode);
+	}
+
+	return err;
 }
 EXPORT_SYMBOL(fscrypt_decrypt_page);
 
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index f00f018bed27..933b28d5809e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -527,7 +527,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 	bio_set_op_attrs(bio, REQ_OP_READ, op_flag);
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-	ctx = get_post_read_ctx(inode, bio, first_idx);
+	ctx = get_post_read_ctx(inode, bio, NULL, first_idx);
 	if (IS_ERR(ctx)) {
 		bio_put(bio);
 		return (struct bio *)ctx;
diff --git a/fs/mpage.c b/fs/mpage.c
index 3c0e484a1d2f..4f672889a947 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -344,7 +344,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 			goto confused;
 
 #if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
-		ctx = get_post_read_ctx(inode, args->bio, page->index);
+		ctx = get_post_read_ctx(inode, args->bio, NULL, page->index);
 		if (IS_ERR(ctx)) {
 			bio_put(args->bio);
 			args->bio = NULL;
diff --git a/fs/post_read_process.c b/fs/post_read_process.c
index f0ec1957a8b3..b633f3dda4bd 100644
--- a/fs/post_read_process.c
+++ b/fs/post_read_process.c
@@ -8,6 +8,7 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/bio.h>
+#include <linux/buffer_head.h>
 #include <linux/fscrypt.h>
 #include <linux/fsverity.h>
 #include <linux/post_read_process.h>
@@ -24,26 +25,41 @@ enum post_read_step {
 	STEP_VERITY,
 };
 
-void end_post_read_processing(struct bio *bio)
+void end_post_read_processing(struct bio *bio, struct buffer_head *bh)
 {
+	struct post_read_ctx *ctx;
 	struct page *page;
 	struct bio_vec *bv;
 	int i;
 	struct bvec_iter_all iter_all;
 
-	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		page = bv->bv_page;
+	if (bh) {
+		if (!PageError(bh->b_page))
+			set_buffer_uptodate(bh);
 
-		BUG_ON(bio->bi_status);
+		ctx = bh->b_private;
 
-		if (!PageError(page))
-			SetPageUptodate(page);
+		end_buffer_page_read(bh);
 
-		unlock_page(page);
+		put_post_read_ctx(ctx);
+	} else if (bio) {
+		bio_for_each_segment_all(bv, bio, i, iter_all) {
+			page = bv->bv_page;
+
+			WARN_ON(bio->bi_status);
+
+			if (!PageError(page))
+				SetPageUptodate(page);
+
+			unlock_page(page);
+		}
+		WARN_ON(!bio->bi_private);
+
+		ctx = bio->bi_private;
+		put_post_read_ctx(ctx);
+
+		bio_put(bio);
 	}
-	if (bio->bi_private)
-		put_post_read_ctx(bio->bi_private);
-	bio_put(bio);
 }
 EXPORT_SYMBOL(end_post_read_processing);
 
@@ -70,18 +86,21 @@ void post_read_processing(struct post_read_ctx *ctx)
 		ctx->cur_step++;
 		/* fall-through */
 	default:
-		end_post_read_processing(ctx->bio);
+		end_post_read_processing(ctx->bio, ctx->bh);
 	}
 }
 EXPORT_SYMBOL(post_read_processing);
 
 struct post_read_ctx *get_post_read_ctx(struct inode *inode,
 					struct bio *bio,
+					struct buffer_head *bh,
 					pgoff_t index)
 {
 	unsigned int post_read_steps = 0;
 	struct post_read_ctx *ctx = NULL;
 
+	WARN_ON(!bh && !bio);
+
 	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
 #ifdef CONFIG_FS_VERITY
@@ -95,11 +114,15 @@ struct post_read_ctx *get_post_read_ctx(struct inode *inode,
 		ctx = mempool_alloc(post_read_ctx_pool, GFP_NOFS);
 		if (!ctx)
 			return ERR_PTR(-ENOMEM);
+		ctx->bh = bh;
 		ctx->bio = bio;
 		ctx->inode = inode;
 		ctx->enabled_steps = post_read_steps;
 		ctx->cur_step = STEP_INITIAL;
-		bio->bi_private = ctx;
+		if (bio)
+			bio->bi_private = ctx;
+		else if (bh)
+			bh->b_private = ctx;
 	}
 	return ctx;
 }
@@ -111,12 +134,6 @@ void put_post_read_ctx(struct post_read_ctx *ctx)
 }
 EXPORT_SYMBOL(put_post_read_ctx);
 
-bool post_read_required(struct bio *bio)
-{
-	return bio->bi_private && !bio->bi_status;
-}
-EXPORT_SYMBOL(post_read_required);
-
 static int __init init_post_read_processing(void)
 {
 	post_read_ctx_cache = KMEM_CACHE(post_read_ctx, 0);
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 7b73ef7f902d..782ed6350dfc 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -165,6 +165,7 @@ void create_empty_buffers(struct page *, unsigned long,
 void end_buffer_read_sync(struct buffer_head *bh, int uptodate);
 void end_buffer_write_sync(struct buffer_head *bh, int uptodate);
 void end_buffer_async_write(struct buffer_head *bh, int uptodate);
+void end_buffer_page_read(struct buffer_head *bh);
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
diff --git a/include/linux/post_read_process.h b/include/linux/post_read_process.h
index 523bdecf9252..cb3e676aea64 100644
--- a/include/linux/post_read_process.h
+++ b/include/linux/post_read_process.h
@@ -3,6 +3,7 @@
 #define _POST_READ_PROCESS_H
 
 struct post_read_ctx {
+	struct buffer_head *bh;
 	struct bio *bio;
 	struct inode *inode;
 	struct work_struct work;
@@ -10,12 +11,12 @@ struct post_read_ctx {
 	unsigned int enabled_steps;
 };
 
-void end_post_read_processing(struct bio *bio);
+void end_post_read_processing(struct bio *bio, struct buffer_head *bh);
 void post_read_processing(struct post_read_ctx *ctx);
 struct post_read_ctx *get_post_read_ctx(struct inode *inode,
 					struct bio *bio,
+					struct buffer_head *bh,
 					pgoff_t index);
 void put_post_read_ctx(struct post_read_ctx *ctx);
-bool post_read_required(struct bio *bio);
 
 #endif	/* _POST_READ_PROCESS_H */
-- 
2.19.1
