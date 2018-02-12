Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 08/11] Enable reading encrypted files in blocksize less than pagesize setup
Date: Mon, 12 Feb 2018 15:13:44 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-9-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

This commit moves ext4/readpage.c to crypto/readpage.c and adds new
functionality to enable reading encrypted files in blocksize less than
pagesize setup.

Ext4 now uses the new fscrypt API when CONFIG_EXT4_FS_ENCRYPTION is
enabled. Otherwise it invokes mpage_readpage[s]() functions.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/Makefile              |   2 +-
 fs/crypto/bio.c                 |  18 +-
 fs/crypto/fscrypt_private.h     |   3 +
 fs/crypto/readpage.c            | 461 ++++++++++++++++++++++++++++++++++++++++
 fs/ext4/Makefile                |   2 +-
 fs/ext4/ext4.h                  |   5 -
 fs/ext4/inode.c                 |  13 +-
 fs/ext4/readpage.c              | 294 -------------------------
 include/linux/fscrypt.h         |   1 +
 include/linux/fscrypt_notsupp.h |   3 +-
 include/linux/fscrypt_supp.h    |   9 +-
 11 files changed, 502 insertions(+), 309 deletions(-)
 create mode 100644 fs/crypto/readpage.c
 delete mode 100644 fs/ext4/readpage.c

diff --git a/fs/crypto/Makefile b/fs/crypto/Makefile
index cb49698..84400e9 100644
--- a/fs/crypto/Makefile
+++ b/fs/crypto/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_FS_ENCRYPTION)	+= fscrypto.o
 
 fscrypto-y := crypto.o fname.o hooks.o keyinfo.o policy.o
-fscrypto-$(CONFIG_BLOCK) += bio.o
+fscrypto-$(CONFIG_BLOCK) += bio.o readpage.o
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 4d0d14f..265cba3 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -70,9 +70,23 @@ static void completion_pages(struct work_struct *work)
 	bio_put(bio);
 }
 
-void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx, struct bio *bio)
+bool fscrypt_bio_encrypted(struct bio *bio)
 {
-	INIT_WORK(&ctx->r.work, completion_pages);
+	if (bio->bi_vcnt) {
+		struct inode *inode = bio->bi_io_vec->bv_page->mapping->host;
+
+		if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
+			return true;
+	}
+
+	return false;
+}
+
+void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx, struct bio *bio,
+			void (*process_bio)(struct work_struct *))
+{
+	INIT_WORK(&ctx->r.work,
+		process_bio ? process_bio : completion_pages);
 	ctx->r.bio = bio;
 	queue_work(fscrypt_read_workqueue, &ctx->r.work);
 }
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 9821e97..63e2b10 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -71,6 +71,9 @@ typedef enum {
 #define FS_CTX_REQUIRES_FREE_ENCRYPT_FL		0x00000001
 #define FS_CTX_HAS_BOUNCE_BUFFER_FL		0x00000002
 
+/* bio.c */
+extern bool fscrypt_bio_encrypted(struct bio *bio);
+
 /* crypto.c */
 extern int fscrypt_initialize(unsigned int cop_flags);
 extern struct workqueue_struct *fscrypt_read_workqueue;
diff --git a/fs/crypto/readpage.c b/fs/crypto/readpage.c
new file mode 100644
index 0000000..7372173
--- /dev/null
+++ b/fs/crypto/readpage.c
@@ -0,0 +1,461 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * linux/fs/crypto/readpage.c
+ *
+ * Copyright (C) 2002, Linus Torvalds.
+ * Copyright (C) 2015, Google, Inc.
+ *
+ * This was originally taken from fs/ext4/readpage.c which in turn was
+ * taken from fs/mpage.c
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/mm.h>
+#include <linux/kdev_t.h>
+#include <linux/gfp.h>
+#include <linux/bio.h>
+#include <linux/fs.h>
+#include <linux/buffer_head.h>
+#include <linux/blkdev.h>
+#include <linux/highmem.h>
+#include <linux/prefetch.h>
+#include <linux/mpage.h>
+#include <linux/writeback.h>
+#include <linux/backing-dev.h>
+#include <linux/pagevec.h>
+#include <linux/cleancache.h>
+
+#include "fscrypt_private.h"
+
+static void fscrypt_complete_block(struct work_struct *work)
+{
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
+	BUG_ON(bio->bi_vcnt != 1);
+
+	bv = bio->bi_io_vec;
+	page = bv->bv_page;
+	inode = page->mapping->host;
+
+	BUG_ON(bv->bv_len != i_blocksize(inode));
+
+	blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
+	blk_nr += bv->bv_offset >> inode->i_blkbits;
+
+	bh = ctx->r.bh;
+
+	ret = fscrypt_decrypt_block(inode, page, bv->bv_len,
+				bv->bv_offset, blk_nr);
+
+	end_buffer_async_read(bh, !ret);
+
+	fscrypt_release_ctx(ctx);
+	bio_put(bio);
+}
+
+static void fscrypt_block_end_io(struct bio *bio)
+{
+	struct buffer_head *bh;
+
+	if (fscrypt_bio_encrypted(bio)) {
+		struct fscrypt_ctx *ctx = bio->bi_private;
+
+		bh = ctx->r.bh;
+
+		if (bio->bi_status) {
+			fscrypt_release_ctx(ctx);
+		} else {
+			fscrypt_decrypt_bio_blocks(ctx, bio,
+						fscrypt_complete_block);
+			return;
+		}
+	} else {
+		bh = bio->bi_private;
+	}
+
+	end_buffer_async_read(bh, !bio->bi_status);
+}
+
+/*
+ * I/O completion handler for multipage BIOs.
+ *
+ * The mpage code never puts partial pages into a BIO (except for end-of-file).
+ * If a page does not map to a contiguous run of blocks then it simply falls
+ * back to block_read_full_page().
+ *
+ * Why is this?  If a page's completion depends on a number of different BIOs
+ * which can complete in any order (or at the same time) then determining the
+ * status of that page is hard.  See end_buffer_async_read() for the details.
+ * There is no point in duplicating all that complexity.
+ */
+static void fscrypt_mpage_end_io(struct bio *bio)
+{
+	struct bio_vec *bv;
+	int i;
+
+	if (fscrypt_bio_encrypted(bio)) {
+		if (bio->bi_status) {
+			fscrypt_release_ctx(bio->bi_private);
+		} else {
+			fscrypt_decrypt_bio_blocks(bio->bi_private, bio, NULL);
+			return;
+		}
+	}
+	bio_for_each_segment_all(bv, bio, i) {
+		struct page *page = bv->bv_page;
+
+		if (!bio->bi_status) {
+			SetPageUptodate(page);
+		} else {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		}
+		unlock_page(page);
+	}
+
+	bio_put(bio);
+}
+
+static int fscrypt_block_read_full_page(struct page *page, get_block_t *get_block)
+{
+	struct inode *inode = page->mapping->host;
+	struct fscrypt_ctx *ctx;
+	struct bio *bio;
+	sector_t iblock, lblock;
+	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	unsigned int blocksize, bbits;
+	int nr, i;
+	int fully_mapped = 1;
+	int ret;
+
+	head = create_page_buffers(page, inode, 0);
+	blocksize = head->b_size;
+	bbits = inode->i_blkbits;
+
+	iblock = (sector_t)page->index << (PAGE_SHIFT - bbits);
+	lblock = (i_size_read(inode)+blocksize-1) >> bbits;
+	bh = head;
+	nr = 0;
+	i = 0;
+
+	do {
+		if (buffer_uptodate(bh))
+			continue;
+
+		if (!buffer_mapped(bh)) {
+			int err = 0;
+
+			fully_mapped = 0;
+			if (iblock < lblock) {
+				WARN_ON(bh->b_size != blocksize);
+				err = get_block(inode, iblock, bh, 0);
+				if (err)
+					SetPageError(page);
+			}
+			if (!buffer_mapped(bh)) {
+				zero_user(page, i << bbits, blocksize);
+				if (!err)
+					set_buffer_uptodate(bh);
+				continue;
+			}
+			/*
+			 * get_block() might have updated the buffer
+			 * synchronously
+			 */
+			if (buffer_uptodate(bh))
+				continue;
+		}
+		arr[nr++] = bh;
+	} while (i++, iblock++, (bh = bh->b_this_page) != head);
+
+	if (fully_mapped)
+		SetPageMappedToDisk(page);
+
+	if (!nr) {
+		/*
+		 * All buffers are uptodate - we can set the page uptodate
+		 * as well. But not if ext4_get_block() returned an error.
+		 */
+		if (!PageError(page))
+			SetPageUptodate(page);
+		unlock_page(page);
+		return 0;
+	}
+
+	/* Stage two: lock the buffers */
+	for (i = 0; i < nr; i++) {
+		bh = arr[i];
+		lock_buffer(bh);
+		set_buffer_async_read(bh);
+	}
+
+	/*
+	 * Stage 3: start the IO.  Check for uptodateness
+	 * inside the buffer lock in case another process reading
+	 * the underlying blockdev brought it uptodate (the sct fix).
+	 */
+	for (i = 0; i < nr; i++) {
+		ctx = NULL;
+		bh = arr[i];
+
+		if (buffer_uptodate(bh)) {
+			end_buffer_async_read(bh, 1);
+			continue;
+		}
+
+		if (IS_ENCRYPTED(inode)
+			&& S_ISREG(inode->i_mode)) {
+			ctx = fscrypt_get_ctx(inode, GFP_NOFS);
+			if (IS_ERR(ctx)) {
+			set_page_error:
+				zero_user_segment(page, bh_offset(bh),
+						  blocksize);
+				end_buffer_async_read(bh, 0);
+				continue;
+			}
+			ctx->r.bh = bh;
+		}
+
+		bio = bio_alloc(GFP_NOIO, 1);
+		if (!bio) {
+			if (ctx)
+				fscrypt_release_ctx(ctx);
+			goto set_page_error;
+		}
+
+		bio->bi_iter.bi_sector = bh->b_blocknr * (blocksize >> 9);
+		bio_set_dev(bio, bh->b_bdev);
+		bio->bi_write_hint = 0;
+
+		ret = bio_add_page(bio, bh->b_page, blocksize, bh_offset(bh));
+		BUG_ON(bio->bi_iter.bi_size != blocksize);
+
+		bio->bi_end_io = fscrypt_block_end_io;
+		if (ctx)
+			bio->bi_private = ctx;
+		else
+			bio->bi_private = bh;
+		bio_set_op_attrs(bio, REQ_OP_READ, 0);
+
+		submit_bio(bio);
+	}
+
+	return 0;
+}
+
+int fscrypt_mpage_readpages(struct address_space *mapping,
+		struct list_head *pages, struct page *page,
+		unsigned nr_pages, get_block_t get_block)
+{
+	struct bio *bio = NULL;
+	sector_t last_block_in_bio = 0;
+
+	struct inode *inode = mapping->host;
+	const unsigned blkbits = inode->i_blkbits;
+	const unsigned blocks_per_page = PAGE_SIZE >> blkbits;
+	const unsigned blocksize = 1 << blkbits;
+	sector_t block_in_file;
+	sector_t last_block;
+	sector_t last_block_in_file;
+	sector_t blocks[MAX_BUF_PER_PAGE];
+	unsigned page_block;
+	struct block_device *bdev = inode->i_sb->s_bdev;
+	int length;
+	unsigned relative_block = 0;
+	struct buffer_head map_bh;
+	unsigned int nblocks;
+	unsigned long first_logical_block = 0;
+
+	map_bh.b_state = 0;
+	map_bh.b_size = 0;
+
+	for (; nr_pages; nr_pages--) {
+		int fully_mapped = 1;
+		unsigned first_hole = blocks_per_page;
+
+		prefetchw(&page->flags);
+		if (pages) {
+			page = list_entry(pages->prev, struct page, lru);
+			list_del(&page->lru);
+			if (add_to_page_cache_lru(page, mapping, page->index,
+				  readahead_gfp_mask(mapping)))
+				goto next_page;
+		}
+
+		if (page_has_buffers(page))
+			goto confused;
+
+		block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
+		last_block = block_in_file + nr_pages * blocks_per_page;
+		last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
+		if (last_block > last_block_in_file)
+			last_block = last_block_in_file;
+		page_block = 0;
+
+		/*
+		 * Map blocks using the previous result first.
+		 */
+		nblocks = map_bh.b_size >> blkbits;
+		if (buffer_mapped(&map_bh) &&
+		    block_in_file > first_logical_block &&
+		    block_in_file < (first_logical_block + nblocks)) {
+			unsigned map_offset = block_in_file - first_logical_block;
+			unsigned last = nblocks - map_offset;
+
+			for (relative_block = 0; ; relative_block++) {
+				if (relative_block == last) {
+					/* needed? */
+					clear_buffer_mapped(&map_bh);
+					break;
+				}
+				if (page_block == blocks_per_page)
+					break;
+				blocks[page_block] = map_bh.b_blocknr + map_offset +
+					relative_block;
+				page_block++;
+				block_in_file++;
+			}
+		}
+
+		/*
+		 * Then do more get_blocks() calls until we are
+		 * done with this page.
+		 */
+		while (page_block < blocks_per_page) {
+			if (block_in_file < last_block) {
+				/*
+				 * map.m_lblk = block_in_file;
+				 * map.m_len = last_block - block_in_file;
+				 */
+				map_bh.b_state = 0;
+				map_bh.b_size = (last_block - block_in_file) << blkbits;
+
+				if (get_block(inode, block_in_file, &map_bh, 0)) {
+				set_error_page:
+					SetPageError(page);
+					zero_user_segment(page, 0,
+							  PAGE_SIZE);
+					unlock_page(page);
+					goto next_page;
+				}
+				first_logical_block = block_in_file;
+			}
+
+			if (!buffer_mapped(&map_bh)) {
+				fully_mapped = 0;
+				if (first_hole == blocks_per_page)
+					first_hole = page_block;
+				page_block++;
+				block_in_file++;
+				continue;
+			}
+			if (first_hole != blocks_per_page)
+				goto confused;		/* hole -> non-hole */
+
+			/* Contiguous blocks? */
+			if (page_block && blocks[page_block-1] != map_bh.b_blocknr-1)
+				goto confused;
+			nblocks = map_bh.b_size >> blkbits;
+			for (relative_block = 0; ; relative_block++) {
+				if (relative_block == nblocks) {
+					/* needed? */
+					clear_buffer_mapped(&map_bh);
+					break;
+				} else if (page_block == blocks_per_page)
+					break;
+				blocks[page_block] = map_bh.b_blocknr+relative_block;
+				page_block++;
+				block_in_file++;
+			}
+		}
+		if (first_hole != blocks_per_page) {
+			zero_user_segment(page, first_hole << blkbits,
+					  PAGE_SIZE);
+			if (first_hole == 0) {
+				SetPageUptodate(page);
+				unlock_page(page);
+				goto next_page;
+			}
+		} else if (fully_mapped) {
+			SetPageMappedToDisk(page);
+		}
+		if (fully_mapped && blocks_per_page == 1 &&
+		    !PageUptodate(page) && cleancache_get_page(page) == 0) {
+			SetPageUptodate(page);
+			goto confused;
+		}
+
+		/*
+		 * This page will go to BIO.  Do we need to send this
+		 * BIO off first?
+		 */
+		if (bio && (last_block_in_bio != blocks[0] - 1)) {
+		submit_and_realloc:
+			submit_bio(bio);
+			bio = NULL;
+		}
+		if (bio == NULL) {
+			struct fscrypt_ctx *ctx = NULL;
+			if (IS_ENCRYPTED(inode) &&
+			    S_ISREG(inode->i_mode)) {
+				ctx = fscrypt_get_ctx(inode, GFP_NOFS);
+				if (IS_ERR(ctx))
+					goto set_error_page;
+			}
+			bio = bio_alloc(GFP_KERNEL,
+				min_t(int, nr_pages, BIO_MAX_PAGES));
+			if (!bio) {
+				if (ctx)
+					fscrypt_release_ctx(ctx);
+				goto set_error_page;
+			}
+			bio_set_dev(bio, bdev);
+			bio->bi_iter.bi_sector = blocks[0] << (blkbits - 9);
+			bio->bi_end_io = fscrypt_mpage_end_io;
+			bio->bi_private = ctx;
+			bio_set_op_attrs(bio, REQ_OP_READ, 0);
+		}
+
+		length = first_hole << blkbits;
+		if (bio_add_page(bio, page, length, 0) < length)
+			goto submit_and_realloc;
+
+		relative_block = block_in_file - first_logical_block;
+		if ((buffer_boundary(&map_bh) && relative_block == nblocks) ||
+			(first_hole != blocks_per_page)) {
+			submit_bio(bio);
+			bio = NULL;
+		} else {
+			last_block_in_bio = blocks[blocks_per_page - 1];
+		}
+		goto next_page;
+	confused:
+		if (bio) {
+			submit_bio(bio);
+			bio = NULL;
+		}
+		if (!PageUptodate(page))
+			fscrypt_block_read_full_page(page, get_block);
+		else
+			unlock_page(page);
+	next_page:
+		if (pages)
+			put_page(page);
+	}
+	BUG_ON(pages && !list_empty(pages));
+	if (bio)
+		submit_bio(bio);
+	return 0;
+}
+EXPORT_SYMBOL(fscrypt_mpage_readpages);
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
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 4e091eae..98c1b83 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -3053,11 +3053,6 @@ static inline void ext4_set_de_type(struct super_block *sb,
 		de->file_type = ext4_type_by_mode[(mode & S_IFMT)>>S_SHIFT];
 }
 
-/* readpages.c */
-extern int ext4_mpage_readpages(struct address_space *mapping,
-				struct list_head *pages, struct page *page,
-				unsigned nr_pages);
-
 /* symlink.c */
 extern const struct inode_operations ext4_encrypted_symlink_inode_operations;
 extern const struct inode_operations ext4_symlink_inode_operations;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index aac0e04..66b768c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3342,7 +3342,11 @@ static int ext4_readpage(struct file *file, struct page *page)
 		ret = ext4_readpage_inline(inode, page);
 
 	if (ret == -EAGAIN)
-		return ext4_mpage_readpages(page->mapping, NULL, page, 1);
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
+		return fscrypt_mpage_readpages(page->mapping, NULL, page, 1, ext4_get_block);
+#else
+		return mpage_readpage(page, ext4_get_block);
+#endif
 
 	return ret;
 }
@@ -3356,8 +3360,11 @@ ext4_readpages(struct file *file, struct address_space *mapping,
 	/* If the file has inline data, no need to do readpages. */
 	if (ext4_has_inline_data(inode))
 		return 0;
-
-	return ext4_mpage_readpages(mapping, pages, NULL, nr_pages);
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
+	return fscrypt_mpage_readpages(mapping, pages, NULL, nr_pages, ext4_get_block);
+#else
+	return mpage_readpages(mapping, pages, nr_pages, ext4_get_block);
+#endif
 }
 
 static void ext4_invalidatepage(struct page *page, unsigned int offset,
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
deleted file mode 100644
index 8b2789f..0000000
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
-			fscrypt_decrypt_bio_blocks(bio->bi_private, bio);
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
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 08b4b40..98c51eb 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -34,6 +34,7 @@ struct fscrypt_ctx {
 		} w;
 		struct {
 			struct bio *bio;
+			struct buffer_head *bh;
 			struct work_struct work;
 		} r;
 		struct list_head free_list;	/* Free list */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index d726b53..aeb6b6d 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -162,7 +162,8 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 
 /* bio.c */
 static inline void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx,
-					     struct bio *bio)
+					    struct bio *bio,
+					    void (*process_bio)(struct work_struct *))
 {
 	return;
 }
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 7720e4a..b4c5231 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -139,7 +139,10 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 }
 
 /* bio.c */
-extern void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *, struct bio *);
+
+extern void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx, struct bio *bio,
+				      void (*process_bio)(struct work_struct *));
+extern bool fscrypt_bio_encrypted(struct bio *bio);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
@@ -153,5 +156,7 @@ extern int __fscrypt_prepare_rename(struct inode *old_dir,
 				    struct dentry *new_dentry,
 				    unsigned int flags);
 extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
-
+extern int fscrypt_mpage_readpages(struct address_space *mapping,
+				struct list_head *pages, struct page *page,
+				unsigned nr_pages, get_block_t get_block);
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.9.5
