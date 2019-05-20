Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Mon, 20 May 2019 09:29:43 -0700
Message-Id: <20190520162952.156212-6-ebiggers@kernel.org>
In-Reply-To: <20190520162952.156212-1-ebiggers@kernel.org>
References: <20190520162952.156212-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 05/14] fscrypt: introduce
 fscrypt_encrypt_block_inplace()
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
Cc: linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Chandan Rajendra <chandan@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_encrypt_page() behaves very differently depending on whether the
filesystem set FS_CFLG_OWN_PAGES in its fscrypt_operations.  This makes
the function difficult to understand and document.  It also makes it so
that all callers have to provide inode and lblk_num, when fscrypt could
determine these itself for pagecache pages.

Therefore, move the FS_CFLG_OWN_PAGES behavior into a new function
fscrypt_encrypt_block_inplace().

This is in preparation for allowing encryption on ext4 filesystems with
blocksize != PAGE_SIZE.

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c      | 50 +++++++++++++++++++++++++----------------
 fs/ubifs/crypto.c       | 12 +++++-----
 include/linux/fscrypt.h | 13 +++++++++++
 3 files changed, 50 insertions(+), 25 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 9cda0147fca95..6877b7c6165de 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -199,8 +199,7 @@ int fscrypt_crypt_block(const struct inode *inode, fscrypt_direction_t rw,
 /**
  * fscypt_encrypt_page() - Encrypts a page
  * @inode:     The inode for which the encryption should take place
- * @page:      The page to encrypt. Must be locked for bounce-page
- *             encryption.
+ * @page:      The page to encrypt. Must be locked.
  * @len:       Length of data to encrypt in @page and encrypted
  *             data in returned page.
  * @offs:      Offset of data within @page and returned
@@ -210,10 +209,9 @@ int fscrypt_crypt_block(const struct inode *inode, fscrypt_direction_t rw,
  *             previously written data.
  * @gfp_flags: The gfp flag for memory allocation
  *
- * Encrypts @page.  If the filesystem set FS_CFLG_OWN_PAGES, then the data is
- * encrypted in-place and @page is returned.  Else, a bounce page is allocated,
- * the data is encrypted into the bounce page, and the bounce page is returned.
- * The caller is responsible for calling fscrypt_free_bounce_page().
+ * Encrypts @page.  A bounce page is allocated, the data is encrypted into the
+ * bounce page, and the bounce page is returned.  The caller is responsible for
+ * calling fscrypt_free_bounce_page().
  *
  * Return: A page containing the encrypted data on success, else an ERR_PTR()
  */
@@ -224,24 +222,12 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 				u64 lblk_num, gfp_t gfp_flags)
 
 {
-	struct page *ciphertext_page = page;
+	struct page *ciphertext_page;
 	int err;
 
-	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
-		/* with inplace-encryption we just encrypt the page */
-		err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, page,
-					  ciphertext_page, len, offs,
-					  gfp_flags);
-		if (err)
-			return ERR_PTR(err);
-
-		return ciphertext_page;
-	}
-
 	if (WARN_ON_ONCE(!PageLocked(page)))
 		return ERR_PTR(-EINVAL);
 
-	/* The encryption operation will require a bounce page. */
 	ciphertext_page = fscrypt_alloc_bounce_page(gfp_flags);
 	if (!ciphertext_page)
 		return ERR_PTR(-ENOMEM);
@@ -258,6 +244,32 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 }
 EXPORT_SYMBOL(fscrypt_encrypt_page);
 
+/**
+ * fscrypt_encrypt_block_inplace() - Encrypt a filesystem block in-place
+ * @inode:     The inode to which this block belongs
+ * @page:      The page containing the block to encrypt
+ * @len:       Size of block to encrypt.  Doesn't need to be a multiple of the
+ *		fs block size, but must be a multiple of FS_CRYPTO_BLOCK_SIZE.
+ * @offs:      Byte offset within @page at which the block to encrypt begins
+ * @lblk_num:  Filesystem logical block number of the block, i.e. the 0-based
+ *		number of the block within the file
+ * @gfp_flags: Memory allocation flags
+ *
+ * Encrypt a possibly-compressed filesystem block that is located in an
+ * arbitrary page, not necessarily in the original pagecache page.  The @inode
+ * and @lblk_num must be specified, as they can't be determined from @page.
+ *
+ * Return: 0 on success; -errno on failure
+ */
+int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
+				  unsigned int len, unsigned int offs,
+				  u64 lblk_num, gfp_t gfp_flags)
+{
+	return fscrypt_crypt_block(inode, FS_ENCRYPT, lblk_num, page, page,
+				   len, offs, gfp_flags);
+}
+EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
+
 /**
  * fscrypt_decrypt_page() - Decrypts a page in-place
  * @inode:     The corresponding inode for the page to decrypt.
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 4aaedf2d7f442..032efdad2e668 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -29,8 +29,8 @@ int ubifs_encrypt(const struct inode *inode, struct ubifs_data_node *dn,
 {
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 	void *p = &dn->data;
-	struct page *ret;
 	unsigned int pad_len = round_up(in_len, UBIFS_CIPHER_BLOCK_SIZE);
+	int err;
 
 	ubifs_assert(c, pad_len <= *out_len);
 	dn->compr_size = cpu_to_le16(in_len);
@@ -39,11 +39,11 @@ int ubifs_encrypt(const struct inode *inode, struct ubifs_data_node *dn,
 	if (pad_len != in_len)
 		memset(p + in_len, 0, pad_len - in_len);
 
-	ret = fscrypt_encrypt_page(inode, virt_to_page(&dn->data), pad_len,
-			offset_in_page(&dn->data), block, GFP_NOFS);
-	if (IS_ERR(ret)) {
-		ubifs_err(c, "fscrypt_encrypt_page failed: %ld", PTR_ERR(ret));
-		return PTR_ERR(ret);
+	err = fscrypt_encrypt_block_inplace(inode, virt_to_page(p), pad_len,
+					    offset_in_page(p), block, GFP_NOFS);
+	if (err) {
+		ubifs_err(c, "fscrypt_encrypt_block_inplace() failed: %d", err);
+		return err;
 	}
 	*out_len = pad_len;
 
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 1c7287f146a98..a9b2d26e615d5 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -106,6 +106,10 @@ extern void fscrypt_release_ctx(struct fscrypt_ctx *);
 extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
 						unsigned int, unsigned int,
 						u64, gfp_t);
+extern int fscrypt_encrypt_block_inplace(const struct inode *inode,
+					 struct page *page, unsigned int len,
+					 unsigned int offs, u64 lblk_num,
+					 gfp_t gfp_flags);
 extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
 				unsigned int, u64);
 
@@ -293,6 +297,15 @@ static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline int fscrypt_encrypt_block_inplace(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs, u64 lblk_num,
+						gfp_t gfp_flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int fscrypt_decrypt_page(const struct inode *inode,
 				       struct page *page,
 				       unsigned int len, unsigned int offs,
-- 
2.21.0.1020.gf2820cf01a-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
