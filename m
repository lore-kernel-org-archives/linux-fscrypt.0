Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 08/12] fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
Date: Tue, 22 May 2018 21:31:06 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-9-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

For block size < page size, a page can have more than one block mapped
and the range of blocks to be zeroed out by fscrypt_zeroout_range() can
span more than one block. Hence this commit adds code to encrypt all
zeroed out blocks of a page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/bio.c | 36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index aba22f7..d8904c0 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -193,10 +193,11 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 {
 	struct fscrypt_ctx *ctx;
 	struct page *ciphertext_page = NULL;
+	unsigned int page_nr_blks;
+	unsigned int offset;
 	struct bio *bio;
 	int ret, err = 0;
-
-	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
+	int i;
 
 	ctx = fscrypt_get_ctx(inode, GFP_NOFS);
 	if (IS_ERR(ctx))
@@ -208,12 +209,22 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		goto errout;
 	}
 
-	while (len--) {
-		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk,
-					     ZERO_PAGE(0), ciphertext_page,
-					     PAGE_SIZE, 0, GFP_NOFS);
-		if (err)
-			goto errout;
+	page_nr_blks = 1 << (PAGE_SHIFT - inode->i_blkbits);
+
+	while (len) {
+		page_nr_blks = min_t(unsigned int, page_nr_blks, len);
+		offset = 0;
+
+		for (i = 0; i < page_nr_blks; i++) {
+			err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk,
+						ZERO_PAGE(0), ciphertext_page,
+						inode->i_sb->s_blocksize,
+						offset, GFP_NOFS);
+			if (err)
+				goto errout;
+			lblk++;
+			offset += inode->i_sb->s_blocksize;
+		}
 
 		bio = bio_alloc(GFP_NOWAIT, 1);
 		if (!bio) {
@@ -224,9 +235,8 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		bio->bi_iter.bi_sector =
 			pblk << (inode->i_sb->s_blocksize_bits - 9);
 		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
-		ret = bio_add_page(bio, ciphertext_page,
-					inode->i_sb->s_blocksize, 0);
-		if (ret != inode->i_sb->s_blocksize) {
+		ret = bio_add_page(bio, ciphertext_page, offset, 0);
+		if (ret != offset) {
 			/* should never happen! */
 			WARN_ON(1);
 			bio_put(bio);
@@ -239,8 +249,8 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		bio_put(bio);
 		if (err)
 			goto errout;
-		lblk++;
-		pblk++;
+		pblk += page_nr_blks;
+		len -= page_nr_blks;
 	}
 	err = 0;
 errout:
-- 
2.9.5
