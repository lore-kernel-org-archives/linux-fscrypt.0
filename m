Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 02/12] Rename fscrypt_do_page_crypto to fscrypt_do_block_crypto
Date: Tue, 22 May 2018 21:31:00 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-3-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

fscrypt_do_page_crypto() encrypts one filesystem block rather than a
memory page. Hence this commit renames the function appropriately.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/bio.c             | 2 +-
 fs/crypto/crypto.c          | 8 ++++----
 fs/crypto/fscrypt_private.h | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0959044..778b826 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -114,7 +114,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 	}
 
 	while (len--) {
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk,
+		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk,
 					     ZERO_PAGE(0), ciphertext_page,
 					     PAGE_SIZE, 0, GFP_NOFS);
 		if (err)
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 0758d32..fac445d 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -133,7 +133,7 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
 }
 EXPORT_SYMBOL(fscrypt_get_ctx);
 
-int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
+int fscrypt_do_block_crypto(const struct inode *inode, fscrypt_direction_t rw,
 			   u64 lblk_num, struct page *src_page,
 			   struct page *dest_page, unsigned int len,
 			   unsigned int offs, gfp_t gfp_flags)
@@ -248,7 +248,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 
 	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
 		/* with inplace-encryption we just encrypt the page */
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num, page,
+		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num, page,
 					     ciphertext_page, len, offs,
 					     gfp_flags);
 		if (err)
@@ -269,7 +269,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 		goto errout;
 
 	ctx->w.control_page = page;
-	err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
+	err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num,
 				     page, ciphertext_page, len, offs,
 				     gfp_flags);
 	if (err) {
@@ -308,7 +308,7 @@ int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 	if (!(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES))
 		BUG_ON(!PageLocked(page));
 
-	return fscrypt_do_page_crypto(inode, FS_DECRYPT, lblk_num, page, page,
+	return fscrypt_do_block_crypto(inode, FS_DECRYPT, lblk_num, page, page,
 				      len, offs, GFP_NOFS);
 }
 EXPORT_SYMBOL(fscrypt_decrypt_page);
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 4012558..71ac753 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -97,7 +97,7 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
 extern int fscrypt_initialize(unsigned int cop_flags);
-extern int fscrypt_do_page_crypto(const struct inode *inode,
+extern int fscrypt_do_block_crypto(const struct inode *inode,
 				  fscrypt_direction_t rw, u64 lblk_num,
 				  struct page *src_page,
 				  struct page *dest_page,
-- 
2.9.5
