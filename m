Return-Path: <SRS0=XRRt=SO=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 13/14] fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
Date: Fri, 12 Apr 2019 22:40:40 +0530
In-Reply-To: <20190412171041.31995-1-chandan@linux.ibm.com>
References: <20190412171041.31995-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190412171041.31995-14-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

For subpage-sized blocks, this commit adds code to encrypt all zeroed
out blocks mapped by a page.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/crypto/bio.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 83de1e46f546..2c6ce4218fd4 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -106,29 +106,23 @@ EXPORT_SYMBOL(fscrypt_pullback_bio_page);
 int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 				sector_t pblk, unsigned int len)
 {
-	struct fscrypt_ctx *ctx;
 	struct page *ciphertext_page = NULL;
 	struct bio *bio;
+	u64 total_bytes, page_bytes;
 	int ret, err = 0;
 
-	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
-
-	ctx = fscrypt_get_ctx(inode, GFP_NOFS);
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
+	total_bytes = len << inode->i_blkbits;
 
-	ciphertext_page = fscrypt_alloc_bounce_page(ctx, GFP_NOWAIT);
-	if (IS_ERR(ciphertext_page)) {
-		err = PTR_ERR(ciphertext_page);
-		goto errout;
-	}
+	while (total_bytes) {
+		page_bytes = min_t(u64, total_bytes, PAGE_SIZE);
 
-	while (len--) {
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk,
-					     ZERO_PAGE(0), ciphertext_page,
-					     PAGE_SIZE, 0, GFP_NOFS);
-		if (err)
+		ciphertext_page = fscrypt_encrypt_page(inode, ZERO_PAGE(0),
+						page_bytes, 0, lblk, GFP_NOFS);
+		if (IS_ERR(ciphertext_page)) {
+			err = PTR_ERR(ciphertext_page);
+			ciphertext_page = NULL;
 			goto errout;
+		}
 
 		bio = bio_alloc(GFP_NOWAIT, 1);
 		if (!bio) {
@@ -139,9 +133,8 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		bio->bi_iter.bi_sector =
 			pblk << (inode->i_sb->s_blocksize_bits - 9);
 		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
-		ret = bio_add_page(bio, ciphertext_page,
-					inode->i_sb->s_blocksize, 0);
-		if (ret != inode->i_sb->s_blocksize) {
+		ret = bio_add_page(bio, ciphertext_page, page_bytes, 0);
+		if (ret != page_bytes) {
 			/* should never happen! */
 			WARN_ON(1);
 			bio_put(bio);
@@ -154,12 +147,15 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		bio_put(bio);
 		if (err)
 			goto errout;
-		lblk++;
-		pblk++;
+
+		lblk += page_bytes >> inode->i_blkbits;
+		pblk += page_bytes >> inode->i_blkbits;
+		total_bytes -= page_bytes;
 	}
 	err = 0;
 errout:
-	fscrypt_release_ctx(ctx);
+	if (!IS_ERR_OR_NULL(ciphertext_page))
+		fscrypt_restore_control_page(ciphertext_page);
 	return err;
 }
 EXPORT_SYMBOL(fscrypt_zeroout_range);
-- 
2.19.1
