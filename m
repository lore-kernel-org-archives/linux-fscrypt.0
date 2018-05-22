Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process callback parameters
Date: Tue, 22 May 2018 21:31:05 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-8-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This commit introduces a new parameter to mpage_readpage[s]()
functions. This parameter contains pointers to functions that can be
used to decrypt data read from the backing device. These are stored in
the fscrypt_ctx structure and one of these functions is invoked after
the read operation is completed.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/block_dev.c                  |   5 +-
 fs/buffer.c                     | 298 ++++++++++++++++++++++++----------------
 fs/crypto/bio.c                 |  95 ++++++++++++-
 fs/crypto/crypto.c              |   2 +
 fs/ext2/inode.c                 |   4 +-
 fs/ext4/Makefile                |   2 +-
 fs/ext4/inode.c                 |  13 +-
 fs/ext4/readpage.c              | 294 ---------------------------------------
 fs/fat/inode.c                  |   4 +-
 fs/isofs/inode.c                |   5 +-
 fs/mpage.c                      |  48 +++++--
 fs/xfs/xfs_aops.c               |   4 +-
 include/linux/buffer_head.h     |   2 +-
 include/linux/fs.h              |   4 +
 include/linux/fscrypt_notsupp.h |  37 ++++-
 include/linux/fscrypt_supp.h    |  13 +-
 include/linux/mpage.h           |   6 +-
 17 files changed, 392 insertions(+), 444 deletions(-)
 delete mode 100644 fs/ext4/readpage.c

diff --git a/fs/block_dev.c b/fs/block_dev.c
index b549666..254af9a 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -568,13 +568,14 @@ static int blkdev_writepage(struct page *page, struct writeback_control *wbc)
 
 static int blkdev_readpage(struct file * file, struct page * page)
 {
-	return block_read_full_page(page, blkdev_get_block);
+	return block_read_full_page(page, blkdev_get_block, NULL);
 }
 
 static int blkdev_readpages(struct file *file, struct address_space *mapping,
 			struct list_head *pages, unsigned nr_pages)
 {
-	return mpage_readpages(mapping, pages, nr_pages, blkdev_get_block);
+	return mpage_readpages(mapping, pages, nr_pages, blkdev_get_block,
+			NULL);
 }
 
 static int blkdev_write_begin(struct file *file, struct address_space *mapping,
diff --git a/fs/buffer.c b/fs/buffer.c
index fda7926..978a8b7 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -45,8 +45,12 @@
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
 #include <linux/pagevec.h>
+#include <linux/fs.h>
 #include <trace/events/block.h>
 
+#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
+#include <linux/fscrypt.h>
+
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 static int submit_bh_wbc(int op, int op_flags, struct buffer_head *bh,
 			 enum rw_hint hint, struct writeback_control *wbc);
@@ -2197,6 +2201,172 @@ int block_is_partially_uptodate(struct page *page, unsigned long from,
 }
 EXPORT_SYMBOL(block_is_partially_uptodate);
 
+static void end_bio_bh_io_sync(struct bio *bio)
+{
+	post_process_read_t *post_process;
+	struct fscrypt_ctx *ctx;
+	struct buffer_head *bh;
+
+	if (fscrypt_bio_encrypted(bio)) {
+		ctx = bio->bi_private;
+		post_process = fscrypt_get_post_process(ctx);
+
+		if (bio->bi_status || post_process->process_block == NULL) {
+			bh = fscrypt_get_bh(ctx);
+			fscrypt_release_ctx(ctx);
+		} else {
+			fscrypt_enqueue_decrypt_bio(ctx, bio,
+						post_process->process_block);
+			return;
+		}
+	} else {
+		bh = bio->bi_private;
+	}
+
+	if (unlikely(bio_flagged(bio, BIO_QUIET)))
+		set_bit(BH_Quiet, &bh->b_state);
+
+	bh->b_end_io(bh, !bio->bi_status);
+	bio_put(bio);
+}
+
+/*
+ * This allows us to do IO even on the odd last sectors
+ * of a device, even if the block size is some multiple
+ * of the physical sector size.
+ *
+ * We'll just truncate the bio to the size of the device,
+ * and clear the end of the buffer head manually.
+ *
+ * Truly out-of-range accesses will turn into actual IO
+ * errors, this only handles the "we need to be able to
+ * do IO at the final sector" case.
+ */
+void guard_bio_eod(int op, struct bio *bio)
+{
+	sector_t maxsector;
+	struct bio_vec *bvec = bio_last_bvec_all(bio);
+	unsigned truncated_bytes;
+	struct hd_struct *part;
+
+	rcu_read_lock();
+	part = __disk_get_part(bio->bi_disk, bio->bi_partno);
+	if (part)
+		maxsector = part_nr_sects_read(part);
+	else
+		maxsector = get_capacity(bio->bi_disk);
+	rcu_read_unlock();
+
+	if (!maxsector)
+		return;
+
+	/*
+	 * If the *whole* IO is past the end of the device,
+	 * let it through, and the IO layer will turn it into
+	 * an EIO.
+	 */
+	if (unlikely(bio->bi_iter.bi_sector >= maxsector))
+		return;
+
+	maxsector -= bio->bi_iter.bi_sector;
+	if (likely((bio->bi_iter.bi_size >> 9) <= maxsector))
+		return;
+
+	/* Uhhuh. We've got a bio that straddles the device size! */
+	truncated_bytes = bio->bi_iter.bi_size - (maxsector << 9);
+
+	/* Truncate the bio.. */
+	bio->bi_iter.bi_size -= truncated_bytes;
+	bvec->bv_len -= truncated_bytes;
+
+	/* ..and clear the end of the buffer for reads */
+	if (op == REQ_OP_READ) {
+		zero_user(bvec->bv_page, bvec->bv_offset + bvec->bv_len,
+				truncated_bytes);
+	}
+}
+
+struct bio *create_bh_bio(int op, int op_flags, struct buffer_head *bh,
+			enum rw_hint write_hint,
+			post_process_read_t *post_process)
+{
+	struct address_space *mapping;
+	struct fscrypt_ctx *ctx = NULL;
+	struct inode *inode;
+	struct page *page;
+	struct bio *bio;
+
+	BUG_ON(!buffer_locked(bh));
+	BUG_ON(!buffer_mapped(bh));
+	BUG_ON(!bh->b_end_io);
+	BUG_ON(buffer_delay(bh));
+	BUG_ON(buffer_unwritten(bh));
+
+	/*
+	 * Only clear out a write error when rewriting
+	 */
+	if (test_set_buffer_req(bh) && (op == REQ_OP_WRITE))
+		clear_buffer_write_io_error(bh);
+
+	page = bh->b_page;
+
+	if (op == REQ_OP_READ) {
+		mapping = page_mapping(page);
+		if (mapping && !PageSwapCache(page)) {
+			inode = mapping->host;
+			if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
+				ctx = fscrypt_get_ctx(inode, GFP_NOFS);
+				BUG_ON(!ctx);
+				fscrypt_set_bh(ctx, bh);
+				if (post_process)
+					fscrypt_set_post_process(ctx,
+								post_process);
+			}
+		}
+	}
+
+	/*
+	 * from here on down, it's all bio -- do the initial mapping,
+	 * submit_bio -> generic_make_request may further map this bio around
+	 */
+	bio = bio_alloc(GFP_NOIO, 1);
+
+	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
+	bio_set_dev(bio, bh->b_bdev);
+	bio->bi_write_hint = write_hint;
+
+	bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
+	BUG_ON(bio->bi_iter.bi_size != bh->b_size);
+
+	bio->bi_end_io = end_bio_bh_io_sync;
+
+	if (ctx)
+		bio->bi_private = ctx;
+	else
+		bio->bi_private = bh;
+
+	/* Take care of bh's that straddle the end of the device */
+	guard_bio_eod(op, bio);
+
+	if (buffer_meta(bh))
+		op_flags |= REQ_META;
+	if (buffer_prio(bh))
+		op_flags |= REQ_PRIO;
+	bio_set_op_attrs(bio, op, op_flags);
+
+	return bio;
+}
+
+static int submit_bh_post_process(int op, int op_flags, struct buffer_head *bh,
+		post_process_read_t *post_process)
+{
+	struct bio *bio;
+
+	bio = create_bh_bio(op, op_flags, bh, 0, post_process);
+	submit_bio(bio);
+	return 0;
+}
+
 /*
  * Generic "read page" function for block devices that have the normal
  * get_block functionality. This is most of the block device filesystems.
@@ -2204,7 +2374,8 @@ EXPORT_SYMBOL(block_is_partially_uptodate);
  * set/clear_buffer_uptodate() functions propagate buffer state into the
  * page struct once IO has completed.
  */
-int block_read_full_page(struct page *page, get_block_t *get_block)
+int block_read_full_page(struct page *page, get_block_t *get_block,
+			post_process_read_t *post_process)
 {
 	struct inode *inode = page->mapping->host;
 	sector_t iblock, lblock;
@@ -2284,7 +2455,8 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 		if (buffer_uptodate(bh))
 			end_buffer_async_read(bh, 1);
 		else
-			submit_bh(REQ_OP_READ, 0, bh);
+			submit_bh_post_process(REQ_OP_READ, 0, bh,
+					post_process);
 	}
 	return 0;
 }
@@ -2959,124 +3131,12 @@ sector_t generic_block_bmap(struct address_space *mapping, sector_t block,
 }
 EXPORT_SYMBOL(generic_block_bmap);
 
-static void end_bio_bh_io_sync(struct bio *bio)
-{
-	struct buffer_head *bh = bio->bi_private;
-
-	if (unlikely(bio_flagged(bio, BIO_QUIET)))
-		set_bit(BH_Quiet, &bh->b_state);
-
-	bh->b_end_io(bh, !bio->bi_status);
-	bio_put(bio);
-}
-
-/*
- * This allows us to do IO even on the odd last sectors
- * of a device, even if the block size is some multiple
- * of the physical sector size.
- *
- * We'll just truncate the bio to the size of the device,
- * and clear the end of the buffer head manually.
- *
- * Truly out-of-range accesses will turn into actual IO
- * errors, this only handles the "we need to be able to
- * do IO at the final sector" case.
- */
-void guard_bio_eod(int op, struct bio *bio)
-{
-	sector_t maxsector;
-	struct bio_vec *bvec = bio_last_bvec_all(bio);
-	unsigned truncated_bytes;
-	struct hd_struct *part;
-
-	rcu_read_lock();
-	part = __disk_get_part(bio->bi_disk, bio->bi_partno);
-	if (part)
-		maxsector = part_nr_sects_read(part);
-	else
-		maxsector = get_capacity(bio->bi_disk);
-	rcu_read_unlock();
-
-	if (!maxsector)
-		return;
-
-	/*
-	 * If the *whole* IO is past the end of the device,
-	 * let it through, and the IO layer will turn it into
-	 * an EIO.
-	 */
-	if (unlikely(bio->bi_iter.bi_sector >= maxsector))
-		return;
-
-	maxsector -= bio->bi_iter.bi_sector;
-	if (likely((bio->bi_iter.bi_size >> 9) <= maxsector))
-		return;
-
-	/* Uhhuh. We've got a bio that straddles the device size! */
-	truncated_bytes = bio->bi_iter.bi_size - (maxsector << 9);
-
-	/* Truncate the bio.. */
-	bio->bi_iter.bi_size -= truncated_bytes;
-	bvec->bv_len -= truncated_bytes;
-
-	/* ..and clear the end of the buffer for reads */
-	if (op == REQ_OP_READ) {
-		zero_user(bvec->bv_page, bvec->bv_offset + bvec->bv_len,
-				truncated_bytes);
-	}
-}
-
-struct bio *create_bh_bio(int op, int op_flags, struct buffer_head *bh,
-                          enum rw_hint write_hint)
-{
-	struct bio *bio;
-
-	BUG_ON(!buffer_locked(bh));
-	BUG_ON(!buffer_mapped(bh));
-	BUG_ON(!bh->b_end_io);
-	BUG_ON(buffer_delay(bh));
-	BUG_ON(buffer_unwritten(bh));
-
-	/*
-	 * Only clear out a write error when rewriting
-	 */
-	if (test_set_buffer_req(bh) && (op == REQ_OP_WRITE))
-		clear_buffer_write_io_error(bh);
-
-	/*
-	 * from here on down, it's all bio -- do the initial mapping,
-	 * submit_bio -> generic_make_request may further map this bio around
-	 */
-	bio = bio_alloc(GFP_NOIO, 1);
-
-	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
-	bio_set_dev(bio, bh->b_bdev);
-	bio->bi_write_hint = write_hint;
-
-	bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
-	BUG_ON(bio->bi_iter.bi_size != bh->b_size);
-
-	bio->bi_end_io = end_bio_bh_io_sync;
-	bio->bi_private = bh;
-
-	/* Take care of bh's that straddle the end of the device */
-	guard_bio_eod(op, bio);
-
-	if (buffer_meta(bh))
-		op_flags |= REQ_META;
-	if (buffer_prio(bh))
-		op_flags |= REQ_PRIO;
-	bio_set_op_attrs(bio, op, op_flags);
-
-	return bio;
-}
-
 static int submit_bh_wbc(int op, int op_flags, struct buffer_head *bh,
 			 enum rw_hint write_hint, struct writeback_control *wbc)
 {
 	struct bio *bio;
 
-	bio = create_bh_bio(op, op_flags, bh, write_hint);
+	bio = create_bh_bio(op, op_flags, bh, write_hint, NULL);
 
 	if (wbc) {
 		wbc_init_bio(wbc, bio);
@@ -3092,7 +3152,7 @@ int submit_bh_blkcg_css(int op, int op_flags, struct buffer_head *bh,
 {
 	struct bio *bio;
 
-	bio = create_bh_bio(op, op_flags, bh, 0);
+	bio = create_bh_bio(op, op_flags, bh, 0, NULL);
 	bio_associate_blkcg(bio, blkcg_css);
 	submit_bio(bio);
 	return 0;
@@ -3101,11 +3161,7 @@ EXPORT_SYMBOL(submit_bh_blkcg_css);
 
 int submit_bh(int op, int op_flags, struct buffer_head *bh)
 {
-	struct bio *bio;
-
-	bio = create_bh_bio(op, op_flags, bh, 0);
-	submit_bio(bio);
-	return 0;
+	return submit_bh_post_process(op, op_flags, bh, NULL);
 }
 EXPORT_SYMBOL(submit_bh);
 
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 32288c3..aba22f7 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -24,6 +24,7 @@
 #include <linux/module.h>
 #include <linux/bio.h>
 #include <linux/namei.h>
+#include <linux/buffer_head.h>
 #include "fscrypt_private.h"
 
 static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
@@ -59,7 +60,7 @@ void fscrypt_decrypt_bio(struct bio *bio)
 }
 EXPORT_SYMBOL(fscrypt_decrypt_bio);
 
-static void completion_pages(struct work_struct *work)
+void fscrypt_complete_pages(struct work_struct *work)
 {
 	struct fscrypt_ctx *ctx =
 		container_of(work, struct fscrypt_ctx, r.work);
@@ -69,15 +70,103 @@ static void completion_pages(struct work_struct *work)
 	fscrypt_release_ctx(ctx);
 	bio_put(bio);
 }
+EXPORT_SYMBOL(fscrypt_complete_pages);
 
-void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx, struct bio *bio)
+void fscrypt_complete_block(struct work_struct *work)
 {
-	INIT_WORK(&ctx->r.work, completion_pages);
+	struct fscrypt_ctx *ctx =
+		container_of(work, struct fscrypt_ctx, r.work);
+	struct buffer_head *bh;
+	struct bio *bio;
+	struct bio_vec *bv;
+	struct page *page;
+	struct inode *inode;
+	u64 blk_nr;
+	int ret;
+
+	bio = ctx->r.bio;
+	WARN_ON(bio->bi_vcnt != 1);
+
+	bv = bio->bi_io_vec;
+	page = bv->bv_page;
+	inode = page->mapping->host;
+
+	WARN_ON(bv->bv_len != i_blocksize(inode));
+
+	blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
+	blk_nr += bv->bv_offset >> inode->i_blkbits;
+
+	bh = ctx->r.bh;
+
+	ret = fscrypt_decrypt_page(inode, page, bv->bv_len,
+				bv->bv_offset, blk_nr);
+
+	bh->b_end_io(bh, !ret);
+
+	fscrypt_release_ctx(ctx);
+	bio_put(bio);
+}
+EXPORT_SYMBOL(fscrypt_complete_block);
+
+bool fscrypt_bio_encrypted(struct bio *bio)
+{
+	struct address_space *mapping;
+	struct inode *inode;
+	struct page *page;
+
+	if (bio_op(bio) == REQ_OP_READ && bio->bi_vcnt) {
+		page = bio->bi_io_vec->bv_page;
+
+		if (!PageSwapCache(page)) {
+			mapping = page_mapping(page);
+			if (mapping) {
+				inode = mapping->host;
+
+				if (IS_ENCRYPTED(inode) &&
+					S_ISREG(inode->i_mode))
+					return true;
+			}
+		}
+	}
+
+	return false;
+}
+EXPORT_SYMBOL(fscrypt_bio_encrypted);
+
+void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx, struct bio *bio,
+			void (*process_bio)(struct work_struct *))
+{
+	BUG_ON(!process_bio);
+	INIT_WORK(&ctx->r.work, process_bio);
 	ctx->r.bio = bio;
 	fscrypt_enqueue_decrypt_work(&ctx->r.work);
 }
 EXPORT_SYMBOL(fscrypt_enqueue_decrypt_bio);
 
+post_process_read_t *fscrypt_get_post_process(struct fscrypt_ctx *ctx)
+{
+	return &(ctx->r.post_process);
+}
+EXPORT_SYMBOL(fscrypt_get_post_process);
+
+void fscrypt_set_post_process(struct fscrypt_ctx *ctx,
+			post_process_read_t *post_process)
+{
+	ctx->r.post_process = *post_process;
+}
+
+struct buffer_head *fscrypt_get_bh(struct fscrypt_ctx *ctx)
+{
+	return ctx->r.bh;
+}
+EXPORT_SYMBOL(fscrypt_get_bh);
+
+void fscrypt_set_bh(struct fscrypt_ctx *ctx, struct buffer_head *bh)
+{
+	ctx->r.bh = bh;
+}
+EXPORT_SYMBOL(fscrypt_set_bh);
+
 void fscrypt_pullback_bio_page(struct page **page, bool restore)
 {
 	struct fscrypt_ctx *ctx;
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 27509b1..2148651 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -127,6 +127,8 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
 		ctx->flags |= FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
 	} else {
 		ctx->flags &= ~FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
+		ctx->r.post_process.process_block = NULL;
+		ctx->r.post_process.process_pages = NULL;
 	}
 	ctx->flags &= ~FS_CTX_HAS_BOUNCE_BUFFER_FL;
 	return ctx;
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 1329b69..0a91f87 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -869,14 +869,14 @@ static int ext2_writepage(struct page *page, struct writeback_control *wbc)
 
 static int ext2_readpage(struct file *file, struct page *page)
 {
-	return mpage_readpage(page, ext2_get_block);
+	return mpage_readpage(page, ext2_get_block, NULL);
 }
 
 static int
 ext2_readpages(struct file *file, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
-	return mpage_readpages(mapping, pages, nr_pages, ext2_get_block);
+	return mpage_readpages(mapping, pages, nr_pages, ext2_get_block, NULL);
 }
 
 static int
diff --git a/fs/ext4/Makefile b/fs/ext4/Makefile
index 8fdfcd3..7c38803 100644
--- a/fs/ext4/Makefile
+++ b/fs/ext4/Makefile
@@ -8,7 +8,7 @@ obj-$(CONFIG_EXT4_FS) += ext4.o
 ext4-y	:= balloc.o bitmap.o block_validity.o dir.o ext4_jbd2.o extents.o \
 		extents_status.o file.o fsmap.o fsync.o hash.o ialloc.o \
 		indirect.o inline.o inode.o ioctl.o mballoc.o migrate.o \
-		mmp.o move_extent.o namei.o page-io.o readpage.o resize.o \
+		mmp.o move_extent.o namei.o page-io.o resize.o \
 		super.o symlink.o sysfs.o xattr.o xattr_trusted.o xattr_user.o
 
 ext4-$(CONFIG_EXT4_FS_POSIX_ACL)	+= acl.o
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index fbc89d9..5ae3c7b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3337,6 +3337,10 @@ static int ext4_readpage(struct file *file, struct page *page)
 {
 	int ret = -EAGAIN;
 	struct inode *inode = page->mapping->host;
+	post_process_read_t post_process = {
+		.process_block = fscrypt_complete_block,
+		.process_pages = fscrypt_complete_pages,
+	};
 
 	trace_ext4_readpage(page);
 
@@ -3344,7 +3348,7 @@ static int ext4_readpage(struct file *file, struct page *page)
 		ret = ext4_readpage_inline(inode, page);
 
 	if (ret == -EAGAIN)
-		return ext4_mpage_readpages(page->mapping, NULL, page, 1);
+		return mpage_readpage(page, ext4_get_block, &post_process);
 
 	return ret;
 }
@@ -3354,12 +3358,17 @@ ext4_readpages(struct file *file, struct address_space *mapping,
 		struct list_head *pages, unsigned nr_pages)
 {
 	struct inode *inode = mapping->host;
+	post_process_read_t post_process = {
+		.process_block = fscrypt_complete_block,
+		.process_pages = fscrypt_complete_pages,
+	};
 
 	/* If the file has inline data, no need to do readpages. */
 	if (ext4_has_inline_data(inode))
 		return 0;
 
-	return ext4_mpage_readpages(mapping, pages, NULL, nr_pages);
+	return mpage_readpages(mapping, pages, nr_pages, ext4_get_block,
+			&post_process);
 }
 
 static void ext4_invalidatepage(struct page *page, unsigned int offset,
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
deleted file mode 100644
index 19b87a8..0000000
--- a/fs/ext4/readpage.c
+++ /dev/null
@@ -1,294 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * linux/fs/ext4/readpage.c
- *
- * Copyright (C) 2002, Linus Torvalds.
- * Copyright (C) 2015, Google, Inc.
- *
- * This was originally taken from fs/mpage.c
- *
- * The intent is the ext4_mpage_readpages() function here is intended
- * to replace mpage_readpages() in the general case, not just for
- * encrypted files.  It has some limitations (see below), where it
- * will fall back to read_block_full_page(), but these limitations
- * should only be hit when page_size != block_size.
- *
- * This will allow us to attach a callback function to support ext4
- * encryption.
- *
- * If anything unusual happens, such as:
- *
- * - encountering a page which has buffers
- * - encountering a page which has a non-hole after a hole
- * - encountering a page with non-contiguous blocks
- *
- * then this code just gives up and calls the buffer_head-based read function.
- * It does handle a page which has holes at the end - that is a common case:
- * the end-of-file on blocksize < PAGE_SIZE setups.
- *
- */
-
-#include <linux/kernel.h>
-#include <linux/export.h>
-#include <linux/mm.h>
-#include <linux/kdev_t.h>
-#include <linux/gfp.h>
-#include <linux/bio.h>
-#include <linux/fs.h>
-#include <linux/buffer_head.h>
-#include <linux/blkdev.h>
-#include <linux/highmem.h>
-#include <linux/prefetch.h>
-#include <linux/mpage.h>
-#include <linux/writeback.h>
-#include <linux/backing-dev.h>
-#include <linux/pagevec.h>
-#include <linux/cleancache.h>
-
-#include "ext4.h"
-
-static inline bool ext4_bio_encrypted(struct bio *bio)
-{
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
-	return unlikely(bio->bi_private != NULL);
-#else
-	return false;
-#endif
-}
-
-/*
- * I/O completion handler for multipage BIOs.
- *
- * The mpage code never puts partial pages into a BIO (except for end-of-file).
- * If a page does not map to a contiguous run of blocks then it simply falls
- * back to block_read_full_page().
- *
- * Why is this?  If a page's completion depends on a number of different BIOs
- * which can complete in any order (or at the same time) then determining the
- * status of that page is hard.  See end_buffer_async_read() for the details.
- * There is no point in duplicating all that complexity.
- */
-static void mpage_end_io(struct bio *bio)
-{
-	struct bio_vec *bv;
-	int i;
-
-	if (ext4_bio_encrypted(bio)) {
-		if (bio->bi_status) {
-			fscrypt_release_ctx(bio->bi_private);
-		} else {
-			fscrypt_enqueue_decrypt_bio(bio->bi_private, bio);
-			return;
-		}
-	}
-	bio_for_each_segment_all(bv, bio, i) {
-		struct page *page = bv->bv_page;
-
-		if (!bio->bi_status) {
-			SetPageUptodate(page);
-		} else {
-			ClearPageUptodate(page);
-			SetPageError(page);
-		}
-		unlock_page(page);
-	}
-
-	bio_put(bio);
-}
-
-int ext4_mpage_readpages(struct address_space *mapping,
-			 struct list_head *pages, struct page *page,
-			 unsigned nr_pages)
-{
-	struct bio *bio = NULL;
-	sector_t last_block_in_bio = 0;
-
-	struct inode *inode = mapping->host;
-	const unsigned blkbits = inode->i_blkbits;
-	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
-	const unsigned blocksize = 1 << blkbits;
-	sector_t block_in_file;
-	sector_t last_block;
-	sector_t last_block_in_file;
-	sector_t blocks[MAX_BUF_PER_PAGE];
-	unsigned page_block;
-	struct block_device *bdev = inode->i_sb->s_bdev;
-	int length;
-	unsigned relative_block = 0;
-	struct ext4_map_blocks map;
-
-	map.m_pblk = 0;
-	map.m_lblk = 0;
-	map.m_len = 0;
-	map.m_flags = 0;
-
-	for (; nr_pages; nr_pages--) {
-		int fully_mapped = 1;
-		unsigned first_hole = blocks_per_page;
-
-		prefetchw(&page->flags);
-		if (pages) {
-			page = list_entry(pages->prev, struct page, lru);
-			list_del(&page->lru);
-			if (add_to_page_cache_lru(page, mapping, page->index,
-				  readahead_gfp_mask(mapping)))
-				goto next_page;
-		}
-
-		if (page_has_buffers(page))
-			goto confused;
-
-		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
-		last_block = block_in_file + nr_pages * blocks_per_page;
-		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
-		if (last_block > last_block_in_file)
-			last_block = last_block_in_file;
-		page_block = 0;
-
-		/*
-		 * Map blocks using the previous result first.
-		 */
-		if ((map.m_flags & EXT4_MAP_MAPPED) &&
-		    block_in_file > map.m_lblk &&
-		    block_in_file < (map.m_lblk + map.m_len)) {
-			unsigned map_offset = block_in_file - map.m_lblk;
-			unsigned last = map.m_len - map_offset;
-
-			for (relative_block = 0; ; relative_block++) {
-				if (relative_block == last) {
-					/* needed? */
-					map.m_flags &= ~EXT4_MAP_MAPPED;
-					break;
-				}
-				if (page_block == blocks_per_page)
-					break;
-				blocks[page_block] = map.m_pblk + map_offset +
-					relative_block;
-				page_block++;
-				block_in_file++;
-			}
-		}
-
-		/*
-		 * Then do more ext4_map_blocks() calls until we are
-		 * done with this page.
-		 */
-		while (page_block < blocks_per_page) {
-			if (block_in_file < last_block) {
-				map.m_lblk = block_in_file;
-				map.m_len = last_block - block_in_file;
-
-				if (ext4_map_blocks(NULL, inode, &map, 0) < 0) {
-				set_error_page:
-					SetPageError(page);
-					zero_user_segment(page, 0,
-							  PAGE_SIZE);
-					unlock_page(page);
-					goto next_page;
-				}
-			}
-			if ((map.m_flags & EXT4_MAP_MAPPED) == 0) {
-				fully_mapped = 0;
-				if (first_hole == blocks_per_page)
-					first_hole = page_block;
-				page_block++;
-				block_in_file++;
-				continue;
-			}
-			if (first_hole != blocks_per_page)
-				goto confused;		/* hole -> non-hole */
-
-			/* Contiguous blocks? */
-			if (page_block && blocks[page_block-1] != map.m_pblk-1)
-				goto confused;
-			for (relative_block = 0; ; relative_block++) {
-				if (relative_block == map.m_len) {
-					/* needed? */
-					map.m_flags &= ~EXT4_MAP_MAPPED;
-					break;
-				} else if (page_block == blocks_per_page)
-					break;
-				blocks[page_block] = map.m_pblk+relative_block;
-				page_block++;
-				block_in_file++;
-			}
-		}
-		if (first_hole != blocks_per_page) {
-			zero_user_segment(page, first_hole << blkbits,
-					  PAGE_SIZE);
-			if (first_hole == 0) {
-				SetPageUptodate(page);
-				unlock_page(page);
-				goto next_page;
-			}
-		} else if (fully_mapped) {
-			SetPageMappedToDisk(page);
-		}
-		if (fully_mapped && blocks_per_page == 1 &&
-		    !PageUptodate(page) && cleancache_get_page(page) == 0) {
-			SetPageUptodate(page);
-			goto confused;
-		}
-
-		/*
-		 * This page will go to BIO.  Do we need to send this
-		 * BIO off first?
-		 */
-		if (bio && (last_block_in_bio != blocks[0] - 1)) {
-		submit_and_realloc:
-			submit_bio(bio);
-			bio = NULL;
-		}
-		if (bio == NULL) {
-			struct fscrypt_ctx *ctx = NULL;
-
-			if (ext4_encrypted_inode(inode) &&
-			    S_ISREG(inode->i_mode)) {
-				ctx = fscrypt_get_ctx(inode, GFP_NOFS);
-				if (IS_ERR(ctx))
-					goto set_error_page;
-			}
-			bio = bio_alloc(GFP_KERNEL,
-				min_t(int, nr_pages, BIO_MAX_PAGES));
-			if (!bio) {
-				if (ctx)
-					fscrypt_release_ctx(ctx);
-				goto set_error_page;
-			}
-			bio_set_dev(bio, bdev);
-			bio->bi_iter.bi_sector = blocks[0] << (blkbits - 9);
-			bio->bi_end_io = mpage_end_io;
-			bio->bi_private = ctx;
-			bio_set_op_attrs(bio, REQ_OP_READ, 0);
-		}
-
-		length = first_hole << blkbits;
-		if (bio_add_page(bio, page, length, 0) < length)
-			goto submit_and_realloc;
-
-		if (((map.m_flags & EXT4_MAP_BOUNDARY) &&
-		     (relative_block == map.m_len)) ||
-		    (first_hole != blocks_per_page)) {
-			submit_bio(bio);
-			bio = NULL;
-		} else
-			last_block_in_bio = blocks[blocks_per_page - 1];
-		goto next_page;
-	confused:
-		if (bio) {
-			submit_bio(bio);
-			bio = NULL;
-		}
-		if (!PageUptodate(page))
-			block_read_full_page(page, ext4_get_block);
-		else
-			unlock_page(page);
-	next_page:
-		if (pages)
-			put_page(page);
-	}
-	BUG_ON(pages && !list_empty(pages));
-	if (bio)
-		submit_bio(bio);
-	return 0;
-}
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index ffbbf05..ee1ddc4f 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -194,13 +194,13 @@ static int fat_writepages(struct address_space *mapping,
 
 static int fat_readpage(struct file *file, struct page *page)
 {
-	return mpage_readpage(page, fat_get_block);
+	return mpage_readpage(page, fat_get_block, NULL);
 }
 
 static int fat_readpages(struct file *file, struct address_space *mapping,
 			 struct list_head *pages, unsigned nr_pages)
 {
-	return mpage_readpages(mapping, pages, nr_pages, fat_get_block);
+	return mpage_readpages(mapping, pages, nr_pages, fat_get_block, NULL);
 }
 
 static void fat_write_failed(struct address_space *mapping, loff_t to)
diff --git a/fs/isofs/inode.c b/fs/isofs/inode.c
index ec3fba7..60df56f 100644
--- a/fs/isofs/inode.c
+++ b/fs/isofs/inode.c
@@ -1173,13 +1173,14 @@ struct buffer_head *isofs_bread(struct inode *inode, sector_t block)
 
 static int isofs_readpage(struct file *file, struct page *page)
 {
-	return mpage_readpage(page, isofs_get_block);
+	return mpage_readpage(page, isofs_get_block, NULL);
 }
 
 static int isofs_readpages(struct file *file, struct address_space *mapping,
 			struct list_head *pages, unsigned nr_pages)
 {
-	return mpage_readpages(mapping, pages, nr_pages, isofs_get_block);
+	return mpage_readpages(mapping, pages, nr_pages, isofs_get_block,
+			NULL);
 }
 
 static sector_t _isofs_bmap(struct address_space *mapping, sector_t block)
diff --git a/fs/mpage.c b/fs/mpage.c
index b7e7f57..c88fdd4 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -30,6 +30,8 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
+#include <linux/fscrypt.h>
 #include "internal.h"
 
 /*
@@ -46,9 +48,24 @@
  */
 static void mpage_end_io(struct bio *bio)
 {
+	post_process_read_t *post_process;
+	struct fscrypt_ctx *ctx;
 	struct bio_vec *bv;
 	int i;
 
+	if (fscrypt_bio_encrypted(bio)) {
+		ctx = bio->bi_private;
+		post_process = fscrypt_get_post_process(ctx);
+
+		if (bio->bi_status || post_process->process_pages == NULL) {
+			fscrypt_release_ctx(ctx);
+		} else {
+			fscrypt_enqueue_decrypt_bio(ctx, bio,
+						post_process->process_pages);
+			return;
+		}
+	}
+
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
 		page_endio(page, op_is_write(bio_op(bio)),
@@ -146,7 +163,7 @@ static struct bio *
 do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 		sector_t *last_block_in_bio, struct buffer_head *map_bh,
 		unsigned long *first_logical_block, get_block_t get_block,
-		gfp_t gfp)
+		post_process_read_t *post_process, gfp_t gfp)
 {
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
@@ -278,15 +295,26 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 
 alloc_new:
 	if (bio == NULL) {
-		if (first_hole == blocks_per_page) {
+		struct fscrypt_ctx *ctx = NULL;
+
+		if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
+			ctx = fscrypt_get_ctx(inode, gfp & GFP_KERNEL);
+			if (IS_ERR(ctx))
+				goto confused;
+			fscrypt_set_post_process(ctx, post_process);
+		} else if (first_hole == blocks_per_page) {
 			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
 								page))
 				goto out;
 		}
 		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				min_t(int, nr_pages, BIO_MAX_PAGES), gfp);
-		if (bio == NULL)
+		if (bio == NULL) {
+			if (ctx)
+				fscrypt_release_ctx(ctx);
 			goto confused;
+		}
+		bio->bi_private = ctx;
 	}
 
 	length = first_hole << blkbits;
@@ -309,7 +337,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	if (bio)
 		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);
 	if (!PageUptodate(page))
-	        block_read_full_page(page, get_block);
+		block_read_full_page(page, get_block, post_process);
 	else
 		unlock_page(page);
 	goto out;
@@ -361,7 +389,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
  */
 int
 mpage_readpages(struct address_space *mapping, struct list_head *pages,
-				unsigned nr_pages, get_block_t get_block)
+		unsigned nr_pages, get_block_t get_block,
+		post_process_read_t *post_process)
 {
 	struct bio *bio = NULL;
 	unsigned page_idx;
@@ -384,7 +413,8 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 					nr_pages - page_idx,
 					&last_block_in_bio, &map_bh,
 					&first_logical_block,
-					get_block, gfp);
+					get_block, post_process,
+					gfp);
 		}
 		put_page(page);
 	}
@@ -398,7 +428,8 @@ EXPORT_SYMBOL(mpage_readpages);
 /*
  * This isn't called much at all
  */
-int mpage_readpage(struct page *page, get_block_t get_block)
+int mpage_readpage(struct page *page, get_block_t get_block,
+		post_process_read_t *post_process)
 {
 	struct bio *bio = NULL;
 	sector_t last_block_in_bio = 0;
@@ -409,7 +440,8 @@ int mpage_readpage(struct page *page, get_block_t get_block)
 	map_bh.b_state = 0;
 	map_bh.b_size = 0;
 	bio = do_mpage_readpage(bio, page, 1, &last_block_in_bio,
-			&map_bh, &first_logical_block, get_block, gfp);
+				&map_bh, &first_logical_block, get_block,
+				post_process, gfp);
 	if (bio)
 		mpage_bio_submit(REQ_OP_READ, 0, bio);
 	return 0;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 0ab824f..74591b8 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1405,7 +1405,7 @@ xfs_vm_readpage(
 	struct page		*page)
 {
 	trace_xfs_vm_readpage(page->mapping->host, 1);
-	return mpage_readpage(page, xfs_get_blocks);
+	return mpage_readpage(page, xfs_get_blocks, NULL);
 }
 
 STATIC int
@@ -1416,7 +1416,7 @@ xfs_vm_readpages(
 	unsigned		nr_pages)
 {
 	trace_xfs_vm_readpages(mapping->host, nr_pages);
-	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
+	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks, NULL);
 }
 
 /*
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index c2fbd97..3718c20 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -224,7 +224,7 @@ int block_write_full_page(struct page *page, get_block_t *get_block,
 int __block_write_full_page(struct inode *inode, struct page *page,
 			get_block_t *get_block, struct writeback_control *wbc,
 			bh_end_io_t *handler);
-int block_read_full_page(struct page*, get_block_t*);
+int block_read_full_page(struct page*, get_block_t*, post_process_read_t*);
 int block_is_partially_uptodate(struct page *page, unsigned long from,
 				unsigned long count);
 int block_write_begin(struct address_space *mapping, loff_t pos, unsigned len,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0eedf74..40e3537 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -83,6 +83,10 @@ typedef int (get_block_t)(struct inode *inode, sector_t iblock,
 			struct buffer_head *bh_result, int create);
 typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 			ssize_t bytes, void *private);
+typedef struct post_process_read {
+	void (*process_block)(struct work_struct *);
+	void (*process_pages)(struct work_struct *);
+} post_process_read_t;
 
 #define MAY_EXEC		0x00000001
 #define MAY_WRITE		0x00000002
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 9770be37..ceac8c8 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -168,9 +168,44 @@ static inline void fscrypt_decrypt_bio(struct bio *bio)
 {
 }
 
+static inline void fscrypt_complete_block(struct work_struct *work)
+{
+}
+
+static inline void fscrypt_complete_pages(struct work_struct *work)
+{
+}
+
 static inline void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					       struct bio *bio)
+					struct bio *bio,
+					void (*process_bio)(struct work_struct *))
+{
+}
+
+static inline bool fscrypt_bio_encrypted(struct bio *bio)
+{
+	return false;
+}
+
+static inline post_process_read_t *
+fscrypt_get_post_process(struct fscrypt_ctx *ctx)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void
+fscrypt_set_post_process(struct fscrypt_ctx *ctx, post_process_read_t *post_process)
+{
+}
+
+static inline void
+fscrypt_set_bh(struct fscrypt_ctx *ctx, struct buffer_head *bh)
+{
+}
+
+static inline struct buffer_head *fscrypt_get_bh(struct fscrypt_ctx *ctx)
 {
+	return ERR_PTR(-EOPNOTSUPP);
 }
 
 static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 2c9a86a..b946eca 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -39,8 +39,10 @@ struct fscrypt_ctx {
 			struct page *control_page;	/* Original page  */
 		} w;
 		struct {
+			struct buffer_head *bh;
 			struct bio *bio;
 			struct work_struct work;
+			post_process_read_t post_process;
 		} r;
 		struct list_head free_list;	/* Free list */
 	};
@@ -190,8 +192,17 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 
 /* bio.c */
 extern void fscrypt_decrypt_bio(struct bio *);
+extern void fscrypt_complete_pages(struct work_struct *work);
+extern void fscrypt_complete_block(struct work_struct *work);
 extern void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					struct bio *bio);
+					struct bio *bio,
+					void (*process_bio)(struct work_struct *));
+extern post_process_read_t *fscrypt_get_post_process(struct fscrypt_ctx *ctx);
+extern void fscrypt_set_post_process(struct fscrypt_ctx *ctx,
+				post_process_read_t *post_process);
+extern struct buffer_head *fscrypt_get_bh(struct fscrypt_ctx *ctx);
+extern void fscrypt_set_bh(struct fscrypt_ctx *ctx, struct buffer_head *bh);
+extern bool fscrypt_bio_encrypted(struct bio *bio);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
diff --git a/include/linux/mpage.h b/include/linux/mpage.h
index 001f1fc..da2526a 100644
--- a/include/linux/mpage.h
+++ b/include/linux/mpage.h
@@ -15,8 +15,10 @@
 struct writeback_control;
 
 int mpage_readpages(struct address_space *mapping, struct list_head *pages,
-				unsigned nr_pages, get_block_t get_block);
-int mpage_readpage(struct page *page, get_block_t get_block);
+		unsigned nr_pages, get_block_t get_block,
+		post_process_read_t *post_process);
+int mpage_readpage(struct page *page, get_block_t get_block,
+		post_process_read_t *post_process);
 int mpage_writepages(struct address_space *mapping,
 		struct writeback_control *wbc, get_block_t get_block);
 int mpage_writepage(struct page *page, get_block_t *get_block,
-- 
2.9.5
