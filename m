Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 09/12] fscrypt_encrypt_page: Encrypt all blocks mapped by a page
Date: Tue, 22 May 2018 21:31:07 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-10-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This commit changes fscrypt_encrypt_page() to encrypt all the blocks
mapped by a page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/crypto.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 2148651..fd2ebe8 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -242,6 +242,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 				u64 lblk_num, gfp_t gfp_flags)
 
 {
+	unsigned int blocksize;
 	struct fscrypt_ctx *ctx;
 	struct page *ciphertext_page = page;
 	int err;
@@ -271,13 +272,21 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 		goto errout;
 
 	ctx->w.control_page = page;
-	err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num,
-				     page, ciphertext_page, len, offs,
-				     gfp_flags);
-	if (err) {
-		ciphertext_page = ERR_PTR(err);
-		goto errout;
+
+	blocksize = i_blocksize(inode);
+	while (offs < len) {
+		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num,
+					page, ciphertext_page, blocksize,
+					offs, gfp_flags);
+		if (err) {
+			ciphertext_page = ERR_PTR(err);
+			goto errout;
+		}
+
+		offs += blocksize;
+		++lblk_num;
 	}
+
 	SetPagePrivate(ciphertext_page);
 	set_page_private(ciphertext_page, (unsigned long)ctx);
 	lock_page(ciphertext_page);
-- 
2.9.5
