Return-Path: <SRS0=XRRt=SO=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 05/14] fs/mpage.c: Integrate post read processing
Date: Fri, 12 Apr 2019 22:40:32 +0530
In-Reply-To: <20190412171041.31995-1-chandan@linux.ibm.com>
References: <20190412171041.31995-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190412171041.31995-6-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

This commit adds code to make do_mpage_readpage() to be "post read
processing" aware i.e. for files requiring decryption/verification,
do_mpage_readpage() now allocates a context structure and assigns the
corresponding pointer to bio->bi_private. At endio time, a non-zero
bio->bi_private indicates that after the read operation is performed, the
bio's payload needs to be processed further before handing over the data
to user space.

The context structure is used for tracking the state machine associated
with post read processing.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/mpage.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 3f19da75178b..b1fe1afa626e 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -30,6 +30,10 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#include <linux/fsverity.h>
+#if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
+#include <linux/post_read_process.h>
+#endif
 #include "internal.h"
 
 /*
@@ -50,6 +54,20 @@ static void mpage_end_io(struct bio *bio)
 	int i;
 	struct bvec_iter_all iter_all;
 
+#if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
+	if (!bio->bi_status && bio->bi_private) {
+		struct bio_post_read_ctx *ctx;
+
+		ctx = bio->bi_private;
+
+		bio_post_read_processing(ctx);
+		return;
+	}
+
+	if (bio->bi_private)
+		put_bio_post_read_ctx((struct bio_post_read_ctx *)(bio->bi_private));
+#endif
+
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		struct page *page = bv->bv_page;
 		page_endio(page, bio_op(bio),
@@ -189,7 +207,13 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 
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
@@ -277,6 +301,10 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
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
@@ -299,7 +327,11 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 
 alloc_new:
 	if (args->bio == NULL) {
-		if (first_hole == blocks_per_page) {
+#if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
+		struct bio_post_read_ctx *ctx;
+#endif
+		if (first_hole == blocks_per_page
+			&& !(IS_ENCRYPTED(inode) || IS_VERITY(inode))) {
 			if (!bdev_read_page(bdev, blocks[0] << (blkbits - 9),
 								page))
 				goto out;
@@ -310,6 +342,15 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 					gfp);
 		if (args->bio == NULL)
 			goto confused;
+
+#if defined(CONFIG_FS_ENCRYPTION) || defined(CONFIG_FS_VERITY)
+		ctx = get_bio_post_read_ctx(inode, args->bio, page->index);
+		if (IS_ERR(ctx)) {
+			bio_put(args->bio);
+			args->bio = NULL;
+			goto confused;
+		}
+#endif
 	}
 
 	length = first_hole << blkbits;
-- 
2.19.1
