Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 23/24] fscrypt: fix up fscrypt_fname_encrypted_size() for internal use
Date: Fri, 15 Dec 2017 09:42:24 -0800
Message-Id: <20171215174225.31583-24-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Filesystems don't need fscrypt_fname_encrypted_size() anymore, so
unexport it and move it to fscrypt_private.h.

We also never calculate the encrypted size of a filename without having
the fscrypt_info present since it is needed to know the amount of
NUL-padding which is determined by the encryption policy, and also we
will always truncate the NUL-padding to the maximum filename length.
Therefore, also make fscrypt_fname_encrypted_size() assume that the
fscrypt_info is present, and make it truncate the returned length to the
specified max_len.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c               | 31 +++++++++++++++----------------
 fs/crypto/fscrypt_private.h     |  3 +++
 fs/crypto/hooks.c               | 10 +++++-----
 include/linux/fscrypt_notsupp.h |  8 --------
 include/linux/fscrypt_supp.h    |  1 -
 5 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 44ddd094b7c5..e33f3d3c5ade 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -191,17 +191,20 @@ static int digest_decode(const char *src, int len, char *dst)
 	return cp - dst;
 }
 
-u32 fscrypt_fname_encrypted_size(const struct inode *inode, u32 ilen)
+bool fscrypt_fname_encrypted_size(const struct inode *inode, u32 orig_len,
+				  u32 max_len, u32 *encrypted_len_ret)
 {
-	int padding = 32;
-	struct fscrypt_info *ci = inode->i_crypt_info;
-
-	if (ci)
-		padding = 4 << (ci->ci_flags & FS_POLICY_FLAGS_PAD_MASK);
-	ilen = max(ilen, (u32)FS_CRYPTO_BLOCK_SIZE);
-	return round_up(ilen, padding);
+	int padding = 4 << (inode->i_crypt_info->ci_flags &
+			    FS_POLICY_FLAGS_PAD_MASK);
+	u32 encrypted_len;
+
+	if (orig_len > max_len)
+		return false;
+	encrypted_len = max(orig_len, (u32)FS_CRYPTO_BLOCK_SIZE);
+	encrypted_len = round_up(encrypted_len, padding);
+	*encrypted_len_ret = min(encrypted_len, max_len);
+	return true;
 }
-EXPORT_SYMBOL(fscrypt_fname_encrypted_size);
 
 /**
  * fscrypt_fname_alloc_buffer - allocate a buffer for presented filenames
@@ -342,14 +345,10 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 		return ret;
 
 	if (dir->i_crypt_info) {
-		unsigned int max_len = dir->i_sb->s_cop->max_namelen(dir);
-
-		if (iname->len > max_len)
+		if (!fscrypt_fname_encrypted_size(dir, iname->len,
+						  dir->i_sb->s_cop->max_namelen(dir),
+						  &fname->crypto_buf.len))
 			return -ENAMETOOLONG;
-
-		fname->crypto_buf.len =
-			min(fscrypt_fname_encrypted_size(dir, iname->len),
-			    max_len);
 		fname->crypto_buf.name = kmalloc(fname->crypto_buf.len,
 						 GFP_NOFS);
 		if (!fname->crypto_buf.name)
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 053917587200..ad6722bae8b7 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -110,6 +110,9 @@ extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 /* fname.c */
 extern int fname_encrypt(struct inode *inode, const struct qstr *iname,
 			 u8 *out, unsigned int olen);
+extern bool fscrypt_fname_encrypted_size(const struct inode *inode,
+					 u32 orig_len, u32 max_len,
+					 u32 *encrypted_len_ret);
 
 /* keyinfo.c */
 extern void __exit fscrypt_essiv_cleanup(void);
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index ff20cacdea94..3e84d92215a1 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -139,12 +139,12 @@ int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
 	 * counting it (even though it is meaningless for ciphertext) is simpler
 	 * for now since filesystems will assume it is there and subtract it.
 	 */
-	if (sizeof(struct fscrypt_symlink_data) + len > max_len)
+	if (!fscrypt_fname_encrypted_size(dir, len,
+					  max_len - sizeof(struct fscrypt_symlink_data),
+					  &disk_link->len))
 		return -ENAMETOOLONG;
-	disk_link->len = min_t(unsigned int,
-			       sizeof(struct fscrypt_symlink_data) +
-					fscrypt_fname_encrypted_size(dir, len),
-			       max_len);
+	disk_link->len += sizeof(struct fscrypt_symlink_data);
+
 	disk_link->name = NULL;
 	return 0;
 }
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index c9592e307df5..342eb97e0476 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -131,14 +131,6 @@ static inline void fscrypt_free_filename(struct fscrypt_name *fname)
 	return;
 }
 
-static inline u32 fscrypt_fname_encrypted_size(const struct inode *inode,
-					       u32 ilen)
-{
-	/* never happens */
-	WARN_ON(1);
-	return 0;
-}
-
 static inline int fscrypt_fname_alloc_buffer(const struct inode *inode,
 					     u32 max_encrypted_len,
 					     struct fscrypt_str *crypto_str)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index e00191deb0d6..2dd5767c77b0 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -107,7 +107,6 @@ static inline void fscrypt_free_filename(struct fscrypt_name *fname)
 	kfree(fname->crypto_buf.name);
 }
 
-extern u32 fscrypt_fname_encrypted_size(const struct inode *, u32);
 extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
 				struct fscrypt_str *);
 extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
-- 
2.15.1
