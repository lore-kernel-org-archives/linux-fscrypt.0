Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Mon, 20 May 2019 09:29:46 -0700
Message-Id: <20190520162952.156212-9-ebiggers@kernel.org>
In-Reply-To: <20190520162952.156212-1-ebiggers@kernel.org>
References: <20190520162952.156212-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 08/14] fscrypt: introduce
 fscrypt_decrypt_block_inplace()
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

Currently fscrypt_decrypt_page() does one of two logically distinct
things depending on whether FS_CFLG_OWN_PAGES is set in the filesystem's
fscrypt_operations: decrypt a pagecache page in-place, or decrypt a
filesystem block in-place in any page.  Currently these happen to share
the same implementation, but this conflates the notion of blocks and
pages.  It also makes it so that all callers have to provide inode and
lblk_num, when fscrypt could determine these itself for pagecache pages.

Therefore, move the FS_CFLG_OWN_PAGES behavior into a new function
fscrypt_decrypt_block_inplace().  This mirrors
fscrypt_encrypt_block_inplace().

This is in preparation for allowing encryption on ext4 filesystems with
blocksize != PAGE_SIZE.

Reviewed-by: Chandan Rajendra <chandan@linux.ibm.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c      | 31 +++++++++++++++++++++++++++----
 fs/ubifs/crypto.c       |  7 ++++---
 include/linux/fscrypt.h | 11 +++++++++++
 3 files changed, 42 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 7bdb985126d97..2e6fb5e4f7a7f 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -284,8 +284,7 @@ EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
 /**
  * fscrypt_decrypt_page() - Decrypts a page in-place
  * @inode:     The corresponding inode for the page to decrypt.
- * @page:      The page to decrypt. Must be locked in case
- *             it is a writeback page (FS_CFLG_OWN_PAGES unset).
+ * @page:      The page to decrypt. Must be locked.
  * @len:       Number of bytes in @page to be decrypted.
  * @offs:      Start of data in @page.
  * @lblk_num:  Logical block number.
@@ -299,8 +298,7 @@ EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
 int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 			unsigned int len, unsigned int offs, u64 lblk_num)
 {
-	if (WARN_ON_ONCE(!PageLocked(page) &&
-			 !(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES)))
+	if (WARN_ON_ONCE(!PageLocked(page)))
 		return -EINVAL;
 
 	return fscrypt_crypt_block(inode, FS_DECRYPT, lblk_num, page, page,
@@ -308,6 +306,31 @@ int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 }
 EXPORT_SYMBOL(fscrypt_decrypt_page);
 
+/**
+ * fscrypt_decrypt_block_inplace() - Decrypt a filesystem block in-place
+ * @inode:     The inode to which this block belongs
+ * @page:      The page containing the block to decrypt
+ * @len:       Size of block to decrypt.  Doesn't need to be a multiple of the
+ *		fs block size, but must be a multiple of FS_CRYPTO_BLOCK_SIZE.
+ * @offs:      Byte offset within @page at which the block to decrypt begins
+ * @lblk_num:  Filesystem logical block number of the block, i.e. the 0-based
+ *		number of the block within the file
+ *
+ * Decrypt a possibly-compressed filesystem block that is located in an
+ * arbitrary page, not necessarily in the original pagecache page.  The @inode
+ * and @lblk_num must be specified, as they can't be determined from @page.
+ *
+ * Return: 0 on success; -errno on failure
+ */
+int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
+				  unsigned int len, unsigned int offs,
+				  u64 lblk_num)
+{
+	return fscrypt_crypt_block(inode, FS_DECRYPT, lblk_num, page, page,
+				   len, offs, GFP_NOFS);
+}
+EXPORT_SYMBOL(fscrypt_decrypt_block_inplace);
+
 /*
  * Validate dentries in encrypted directories to make sure we aren't potentially
  * caching stale dentries after a key has been added.
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 032efdad2e668..22be7aeb96c4f 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -64,10 +64,11 @@ int ubifs_decrypt(const struct inode *inode, struct ubifs_data_node *dn,
 	}
 
 	ubifs_assert(c, dlen <= UBIFS_BLOCK_SIZE);
-	err = fscrypt_decrypt_page(inode, virt_to_page(&dn->data), dlen,
-			offset_in_page(&dn->data), block);
+	err = fscrypt_decrypt_block_inplace(inode, virt_to_page(&dn->data),
+					    dlen, offset_in_page(&dn->data),
+					    block);
 	if (err) {
-		ubifs_err(c, "fscrypt_decrypt_page failed: %i", err);
+		ubifs_err(c, "fscrypt_decrypt_block_inplace() failed: %d", err);
 		return err;
 	}
 	*out_len = clen;
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index c7e16bd16a6c2..315affc99b050 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -114,6 +114,9 @@ extern int fscrypt_encrypt_block_inplace(const struct inode *inode,
 					 gfp_t gfp_flags);
 extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
 				unsigned int, u64);
+extern int fscrypt_decrypt_block_inplace(const struct inode *inode,
+					 struct page *page, unsigned int len,
+					 unsigned int offs, u64 lblk_num);
 
 static inline bool fscrypt_is_bounce_page(struct page *page)
 {
@@ -315,6 +318,14 @@ static inline int fscrypt_decrypt_page(const struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
+static inline int fscrypt_decrypt_block_inplace(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs, u64 lblk_num)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline bool fscrypt_is_bounce_page(struct page *page)
 {
 	return false;
-- 
2.21.0.1020.gf2820cf01a-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
