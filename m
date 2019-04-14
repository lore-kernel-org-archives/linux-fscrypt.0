Return-Path: <SRS0=kYvk=SQ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH V2 11/14] fscrypt_encrypt_page: Loop across all blocks mapped by a page range
Date: Sun, 14 Apr 2019 17:08:01 +0530
In-Reply-To: <20190414113804.26769-1-chandan@linux.ibm.com>
References: <20190414113804.26769-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190414113804.26769-12-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

For subpage-sized blocks, this commit now encrypts all blocks mapped by
a page range.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/crypto/crypto.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 4f0d832cae71..84d11d8eb7e3 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -242,18 +242,26 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 {
 	struct fscrypt_ctx *ctx;
 	struct page *ciphertext_page = page;
+	int i, page_nr_blks;
 	int err;
 
 	BUG_ON(len % FS_CRYPTO_BLOCK_SIZE != 0);
 
+	page_nr_blks = len >> inode->i_blkbits;
+
 	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
 		/* with inplace-encryption we just encrypt the page */
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num, page,
-					     ciphertext_page, len, offs,
-					     gfp_flags);
-		if (err)
-			return ERR_PTR(err);
-
+		for (i = 0; i < page_nr_blks; i++) {
+			err = fscrypt_do_page_crypto(inode, FS_ENCRYPT,
+						lblk_num, page,
+						ciphertext_page,
+						i_blocksize(inode), offs,
+						gfp_flags);
+			if (err)
+				return ERR_PTR(err);
+			++lblk_num;
+			offs += i_blocksize(inode);
+		}
 		return ciphertext_page;
 	}
 
@@ -269,12 +277,17 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 		goto errout;
 
 	ctx->control_page = page;
-	err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
-				     page, ciphertext_page, len, offs,
-				     gfp_flags);
-	if (err) {
-		ciphertext_page = ERR_PTR(err);
-		goto errout;
+
+	for (i = 0; i < page_nr_blks; i++) {
+		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
+					page, ciphertext_page, i_blocksize(inode), offs,
+					gfp_flags);
+		if (err) {
+			ciphertext_page = ERR_PTR(err);
+			goto errout;
+		}
+		++lblk_num;
+		offs += i_blocksize(inode);
 	}
 	SetPagePrivate(ciphertext_page);
 	set_page_private(ciphertext_page, (unsigned long)ctx);
-- 
2.19.1
