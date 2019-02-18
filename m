Return-Path: <SRS0=THX2=QZ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 09/10] fs/mpage.c: Integrate post read processing
Date: Mon, 18 Feb 2019 15:34:32 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190218100433.20048-10-chandan@linux.ibm.com>
To: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

This commit adds code to make do_mpage_readpage() to be "post read
processing" aware i.e. for files requiring decryption/verification,
do_mpage_readpage() now allocates a context structure and marks the bio
with a flag to indicate that after read operation is performed, the
bio's payload needs to be processed further before handing over the data
to user space.

The context structure is used for tracking the state machine associated
with post read processing.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/mpage.c | 77 +++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 59 insertions(+), 18 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index c820dc9bebab..09f0491e6260 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -30,6 +30,8 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#include <linux/fsverity.h>
+#include <linux/post_read_process.h>
 #include "internal.h"
 
 /*
@@ -49,6 +51,13 @@ static void mpage_end_io(struct bio *bio)
 	struct bio_vec *bv;
 	int i;
 
+	if (bio_post_read_required(bio)) {
+		struct bio_post_read_ctx *ctx = bio->bi_private;
+
+		bio_post_read_processing(ctx);
+		return;
+	}
+
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
 		page_endio(page, bio_op(bio),
@@ -142,6 +151,7 @@ struct mpage_readpage_args {
 	struct buffer_head map_bh;
 	unsigned long first_logical_block;
 	get_block_t *get_block;
+	int op_flags;
 };
 
 /*
@@ -170,25 +180,22 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 	struct block_device *bdev = NULL;
 	int length;
 	int fully_mapped = 1;
-	int op_flags;
 	unsigned nblocks;
 	unsigned relative_block;
 	gfp_t gfp;
 
-	if (args->is_readahead) {
-		op_flags = REQ_RAHEAD;
-		gfp = readahead_gfp_mask(page->mapping);
-	} else {
-		op_flags = 0;
-		gfp = mapping_gfp_constraint(page->mapping, GFP_KERNEL);
-	}
-
 	if (page_has_buffers(page))
 		goto confused;
 
 	block_in_file = (sector_t)page->index << (PAGE_SHIFT - blkbits);
 	last_block = block_in_file + args->nr_pages * blocks_per_page;
-	last_block_in_file = (i_size_read(inode) + blocksize - 1) >> blkbits;
+#ifdef CONFIG_FS_VERITY
+	if (IS_VERITY(inode) && inode->i_sb->s_vop->readpage_limit)
+		last_block_in_file = inode->i_sb->s_vop->readpage_limit(inode);
+	else
+#endif
+		last_block_in_file = (i_size_read(inode) + blocksize - 1)
+			>> blkbits;
 	if (last_block > last_block_in_file)
 		last_block = last_block_in_file;
 	page_block = 0;
@@ -276,6 +283,10 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 	if (first_hole != blocks_per_page) {
 		zero_user_segment(page, first_hole << blkbits, PAGE_SIZE);
 		if (first_hole == 0) {
+#ifdef CONFIG_FS_VERITY
+			if (IS_VERITY(inode) && inode->i_sb->s_vop->check_hole)
+				inode->i_sb->s_vop->check_hole(inode, page);
+#endif
 			SetPageUptodate(page);
 			unlock_page(page);
 			goto out;
@@ -294,26 +305,54 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 	 * This page will go to BIO.  Do we need to send this BIO off first?
 	 */
 	if (args->bio && (args->last_block_in_bio != blocks[0] - 1))
-		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
+		args->bio = mpage_bio_submit(REQ_OP_READ, args->op_flags,
+					args->bio);
 
 alloc_new:
 	if (args->bio == NULL) {
-		if (first_hole == blocks_per_page) {
+		struct bio_post_read_ctx *ctx;
+
+		if (first_hole == blocks_per_page
+			&& !(IS_ENCRYPTED(inode) || IS_VERITY(inode))) {
 			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
 								page))
 				goto out;
 		}
+
+		args->op_flags = 0;
+
+		if (args->is_readahead) {
+			args->op_flags = REQ_RAHEAD;
+			gfp = readahead_gfp_mask(page->mapping);
+		} else {
+			gfp = mapping_gfp_constraint(page->mapping, GFP_KERNEL);
+		}
+
 		args->bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 					min_t(int, args->nr_pages,
 					      BIO_MAX_PAGES),
 					gfp);
-		if (args->bio == NULL)
+		if (args->bio == NULL) {
+			args->op_flags = 0;
 			goto confused;
+		}
+
+		ctx = get_bio_post_read_ctx(inode, args->bio, page->index);
+		if (IS_ERR(ctx)) {
+			args->op_flags = 0;
+			bio_put(args->bio);
+			args->bio = NULL;
+			goto confused;
+		}
+
+		if (ctx)
+			args->op_flags |= REQ_POST_READ_PROC;
 	}
 
 	length = first_hole << blkbits;
 	if (bio_add_page(args->bio, page, length, 0) < length) {
-		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
+		args->bio = mpage_bio_submit(REQ_OP_READ, args->op_flags,
+					args->bio);
 		goto alloc_new;
 	}
 
@@ -321,7 +360,8 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 	nblocks = map_bh->b_size >> blkbits;
 	if ((buffer_boundary(map_bh) && relative_block == nblocks) ||
 	    (first_hole != blocks_per_page))
-		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
+		args->bio = mpage_bio_submit(REQ_OP_READ, args->op_flags,
+					args->bio);
 	else
 		args->last_block_in_bio = blocks[blocks_per_page - 1];
 out:
@@ -329,7 +369,8 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 
 confused:
 	if (args->bio)
-		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
+		args->bio = mpage_bio_submit(REQ_OP_READ, args->op_flags,
+					args->bio);
 	if (!PageUptodate(page))
 		block_read_full_page(page, args->get_block);
 	else
@@ -407,7 +448,7 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 	}
 	BUG_ON(!list_empty(pages));
 	if (args.bio)
-		mpage_bio_submit(REQ_OP_READ, REQ_RAHEAD, args.bio);
+		mpage_bio_submit(REQ_OP_READ, args.op_flags, args.bio);
 	return 0;
 }
 EXPORT_SYMBOL(mpage_readpages);
@@ -425,7 +466,7 @@ int mpage_readpage(struct page *page, get_block_t get_block)
 
 	args.bio = do_mpage_readpage(&args);
 	if (args.bio)
-		mpage_bio_submit(REQ_OP_READ, 0, args.bio);
+		mpage_bio_submit(REQ_OP_READ, args.op_flags, args.bio);
 	return 0;
 }
 EXPORT_SYMBOL(mpage_readpage);
-- 
2.19.1
