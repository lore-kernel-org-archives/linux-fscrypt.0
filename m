Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Wed,  1 May 2019 15:45:05 -0700
Message-Id: <20190501224515.43059-4-ebiggers@kernel.org>
In-Reply-To: <20190501224515.43059-1-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH 03/13] fscrypt: rename fscrypt_do_page_crypto()
 to fscrypt_crypt_block()
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Chandan Rajendra <chandan@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_do_page_crypto() only does a single encryption or decryption
operation, with a single logical block number (single IV).  So it
actually operates on a filesystem block, not a "page" per se.  To
reflect this, rename it to fscrypt_crypt_block().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c             |  6 +++---
 fs/crypto/crypto.c          | 24 ++++++++++++------------
 fs/crypto/fscrypt_private.h | 11 +++++------
 3 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 548ec6bb569cf..bcab8822217b0 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -84,9 +84,9 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		return -ENOMEM;
 
 	while (len--) {
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk,
-					     ZERO_PAGE(0), ciphertext_page,
-					     PAGE_SIZE, 0, GFP_NOFS);
+		err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk,
+					  ZERO_PAGE(0), ciphertext_page,
+					  PAGE_SIZE, 0, GFP_NOFS);
 		if (err)
 			goto errout;
 
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index ebfa13cfecb7d..e6802d7aca3c7 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -147,10 +147,11 @@ void fscrypt_generate_iv(union fscrypt_iv *iv, u64 lblk_num,
 		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv->raw, iv->raw);
 }
 
-int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
-			   u64 lblk_num, struct page *src_page,
-			   struct page *dest_page, unsigned int len,
-			   unsigned int offs, gfp_t gfp_flags)
+/* Encrypt or decrypt a single filesystem block of file contents */
+int fscrypt_crypt_block(const struct inode *inode, fscrypt_direction_t rw,
+			u64 lblk_num, struct page *src_page,
+			struct page *dest_page, unsigned int len,
+			unsigned int offs, gfp_t gfp_flags)
 {
 	union fscrypt_iv iv;
 	struct skcipher_request *req = NULL;
@@ -227,9 +228,9 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 
 	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
 		/* with inplace-encryption we just encrypt the page */
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num, page,
-					     ciphertext_page, len, offs,
-					     gfp_flags);
+		err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, page,
+					  ciphertext_page, len, offs,
+					  gfp_flags);
 		if (err)
 			return ERR_PTR(err);
 
@@ -243,9 +244,8 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 	if (!ciphertext_page)
 		return ERR_PTR(-ENOMEM);
 
-	err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
-				     page, ciphertext_page, len, offs,
-				     gfp_flags);
+	err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, page,
+				  ciphertext_page, len, offs, gfp_flags);
 	if (err) {
 		fscrypt_free_bounce_page(ciphertext_page);
 		return ERR_PTR(err);
@@ -277,8 +277,8 @@ int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 	if (!(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES))
 		BUG_ON(!PageLocked(page));
 
-	return fscrypt_do_page_crypto(inode, FS_DECRYPT, lblk_num, page, page,
-				      len, offs, GFP_NOFS);
+	return fscrypt_crypt_block(inode, FS_DECRYPT, lblk_num, page, page,
+				   len, offs, GFP_NOFS);
 }
 EXPORT_SYMBOL(fscrypt_decrypt_page);
 
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a5a5486979ff7..8565536feb2b8 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -117,12 +117,11 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
 extern int fscrypt_initialize(unsigned int cop_flags);
-extern int fscrypt_do_page_crypto(const struct inode *inode,
-				  fscrypt_direction_t rw, u64 lblk_num,
-				  struct page *src_page,
-				  struct page *dest_page,
-				  unsigned int len, unsigned int offs,
-				  gfp_t gfp_flags);
+extern int fscrypt_crypt_block(const struct inode *inode,
+			       fscrypt_direction_t rw, u64 lblk_num,
+			       struct page *src_page, struct page *dest_page,
+			       unsigned int len, unsigned int offs,
+			       gfp_t gfp_flags);
 extern struct page *fscrypt_alloc_bounce_page(gfp_t gfp_flags);
 extern const struct dentry_operations fscrypt_d_ops;
 
-- 
2.21.0.593.g511ec345e18-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
