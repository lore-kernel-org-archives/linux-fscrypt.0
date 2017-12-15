Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 10/24] fscrypt: new helper functions for ->symlink()
Date: Fri, 15 Dec 2017 09:42:11 -0800
Message-Id: <20171215174225.31583-11-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, filesystems supporting fscrypt need to implement some tricky
logic when creating encrypted symlinks, including handling a peculiar
on-disk format (struct fscrypt_symlink_data) and correctly calculating
the size of the encrypted symlink.  Introduce helper functions to make
things a bit easier:

- fscrypt_prepare_symlink() computes and validates the size the symlink
  target will require on-disk.
- fscrypt_encrypt_symlink() creates the encrypted target if needed.

The new helpers actually fix some subtle bugs.  First, when checking
whether the symlink target was too long, filesystems didn't account for
the fact that the NUL padding is meant to be truncated if it would cause
the maximum length to be exceeded, as is done for filenames in
directories.  Consequently users would receive ENAMETOOLONG when
creating symlinks close to what is supposed to be the maximum length.
For example, with EXT4 with a 4K block size, the maximum symlink target
length in an encrypted directory is supposed to be 4093 bytes (in
comparison to 4095 in an unencrypted directory), but in
FS_POLICY_FLAGS_PAD_32-mode only up to 4064 bytes were accepted.

Second, symlink targets of "." and ".." were not being encrypted, even
though they should be, as these names are special in *directory entries*
but not in symlink targets.  Fortunately, we can fix this simply by
starting to encrypt them, as old kernels already accept them in
encrypted form.

Third, the output string length the filesystems were providing when
doing the actual encryption was incorrect, as it was forgotten to
exclude 'sizeof(struct fscrypt_symlink_data)'.  Fortunately though, this
bug didn't make a difference.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c               |  8 ++--
 fs/crypto/fscrypt_private.h     |  4 ++
 fs/crypto/hooks.c               | 86 +++++++++++++++++++++++++++++++++++++++++
 include/linux/fscrypt.h         | 64 ++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h | 16 ++++++++
 include/linux/fscrypt_supp.h    |  6 +++
 6 files changed, 181 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 52d4dbe1e8e7..62f13d533439 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -34,8 +34,8 @@ static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
  *
  * Return: 0 on success, -errno on failure
  */
-static int fname_encrypt(struct inode *inode,
-			const struct qstr *iname, struct fscrypt_str *oname)
+int fname_encrypt(struct inode *inode,
+		  const struct qstr *iname, struct fscrypt_str *oname)
 {
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
@@ -56,9 +56,11 @@ static int fname_encrypt(struct inode *inode,
 	 * Copy the filename to the output buffer for encrypting in-place and
 	 * pad it with the needed number of NUL bytes.
 	 */
+	if (WARN_ON(oname->len < iname->len))
+		return -ENOBUFS;
 	cryptlen = max_t(unsigned int, iname->len, FS_CRYPTO_BLOCK_SIZE);
 	cryptlen = round_up(cryptlen, padding);
-	cryptlen = min(cryptlen, lim);
+	cryptlen = min3(cryptlen, lim, oname->len);
 	memcpy(oname->name, iname->name, iname->len);
 	memset(oname->name + iname->len, 0, cryptlen - iname->len);
 
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 2b848e7c92f0..6995bca5006b 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -98,6 +98,10 @@ extern int fscrypt_do_page_crypto(const struct inode *inode,
 extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
 
+/* fname.c */
+extern int fname_encrypt(struct inode *inode,
+			 const struct qstr *iname, struct fscrypt_str *oname);
+
 /* keyinfo.c */
 extern void __exit fscrypt_essiv_cleanup(void);
 
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 9f5fb2eb9cf7..483e87d40f03 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -110,3 +110,89 @@ int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__fscrypt_prepare_lookup);
+
+int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
+			      unsigned int max_len,
+			      struct fscrypt_str *disk_link)
+{
+	int err;
+
+	/*
+	 * To calculate the size of the encrypted symlink target we need to know
+	 * the amount of NUL padding, which is determined by the flags set in
+	 * the encryption policy which will be inherited from the directory.
+	 * The easiest way to get access to this is to just load the directory's
+	 * fscrypt_info, since we'll need it to create the dir_entry anyway.
+	 */
+	err = fscrypt_require_key(dir);
+	if (err)
+		return err;
+
+	/*
+	 * Calculate the size of the encrypted symlink and verify it won't
+	 * exceed max_len.  Note that for historical reasons, encrypted symlink
+	 * targets are prefixed with the ciphertext length, despite this
+	 * actually being redundant with i_size.  This decreases by 2 bytes the
+	 * longest symlink target we can accept.
+	 *
+	 * We could recover 1 byte by not counting a null terminator, but
+	 * counting it (even though it is meaningless for ciphertext) is simpler
+	 * for now since filesystems will assume it is there and subtract it.
+	 */
+	if (sizeof(struct fscrypt_symlink_data) + len > max_len)
+		return -ENAMETOOLONG;
+	disk_link->len = min_t(unsigned int,
+			       sizeof(struct fscrypt_symlink_data) +
+					fscrypt_fname_encrypted_size(dir, len),
+			       max_len);
+	disk_link->name = NULL;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_prepare_symlink);
+
+int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
+			      unsigned int len, struct fscrypt_str *disk_link)
+{
+	int err;
+	struct qstr iname = { .name = target, .len = len };
+	struct fscrypt_symlink_data *sd;
+	unsigned int ciphertext_len;
+	struct fscrypt_str oname;
+
+	err = fscrypt_require_key(inode);
+	if (err)
+		return err;
+
+	if (disk_link->name) {
+		/* filesystem-provided buffer */
+		sd = (struct fscrypt_symlink_data *)disk_link->name;
+	} else {
+		sd = kmalloc(disk_link->len, GFP_NOFS);
+		if (!sd)
+			return -ENOMEM;
+	}
+	ciphertext_len = disk_link->len - sizeof(*sd);
+	sd->len = cpu_to_le16(ciphertext_len);
+
+	oname.name = sd->encrypted_path;
+	oname.len = ciphertext_len;
+	err = fname_encrypt(inode, &iname, &oname);
+	if (err) {
+		if (!disk_link->name)
+			kfree(sd);
+		return err;
+	}
+	BUG_ON(oname.len != ciphertext_len);
+
+	/*
+	 * Null-terminating the ciphertext doesn't make sense, but we still
+	 * count the null terminator in the length, so we might as well
+	 * initialize it just in case the filesystem writes it out.
+	 */
+	sd->encrypted_path[ciphertext_len] = '\0';
+
+	if (!disk_link->name)
+		disk_link->name = (unsigned char *)sd;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_encrypt_symlink);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 071ebabfc287..6a678d0e956a 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -196,4 +196,68 @@ static inline int fscrypt_prepare_setattr(struct dentry *dentry,
 	return 0;
 }
 
+/**
+ * fscrypt_prepare_symlink - prepare to create a possibly-encrypted symlink
+ * @dir: directory in which the symlink is being created
+ * @target: plaintext symlink target
+ * @len: length of @target excluding null terminator
+ * @max_len: space the filesystem has available to store the symlink target
+ * @disk_link: (out) the on-disk symlink target being prepared
+ *
+ * This function computes the size the symlink target will require on-disk,
+ * stores it in @disk_link->len, and validates it against @max_len.  An
+ * encrypted symlink may be longer than the original.
+ *
+ * Additionally, @disk_link->name is set to @target if the symlink will be
+ * unencrypted, but left NULL if the symlink will be encrypted.  For encrypted
+ * symlinks, the filesystem must call fscrypt_encrypt_symlink() to create the
+ * on-disk target later.  (The reason for the two-step process is that some
+ * filesystems need to know the size of the symlink target before creating the
+ * inode, e.g. to determine whether it will be a "fast" or "slow" symlink.)
+ *
+ * Return: 0 on success, -ENAMETOOLONG if the symlink target is too long,
+ * -ENOKEY if the encryption key is missing, or another -errno code if a problem
+ * occurred while setting up the encryption key.
+ */
+static inline int fscrypt_prepare_symlink(struct inode *dir,
+					  const char *target,
+					  unsigned int len,
+					  unsigned int max_len,
+					  struct fscrypt_str *disk_link)
+{
+	if (IS_ENCRYPTED(dir) || fscrypt_dummy_context_enabled(dir))
+		return __fscrypt_prepare_symlink(dir, len, max_len, disk_link);
+
+	disk_link->name = (unsigned char *)target;
+	disk_link->len = len + 1;
+	if (disk_link->len > max_len)
+		return -ENAMETOOLONG;
+	return 0;
+}
+
+/**
+ * fscrypt_encrypt_symlink - encrypt the symlink target if needed
+ * @inode: symlink inode
+ * @target: plaintext symlink target
+ * @len: length of @target excluding null terminator
+ * @disk_link: (in/out) the on-disk symlink target being prepared
+ *
+ * If the symlink target needs to be encrypted, then this function encrypts it
+ * into @disk_link->name.  fscrypt_prepare_symlink() must have been called
+ * previously to compute @disk_link->len.  If the filesystem did not allocate a
+ * buffer for @disk_link->name after calling fscrypt_prepare_link(), then one
+ * will be kmalloc()'ed and the filesystem will be responsible for freeing it.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+static inline int fscrypt_encrypt_symlink(struct inode *inode,
+					  const char *target,
+					  unsigned int len,
+					  struct fscrypt_str *disk_link)
+{
+	if (IS_ENCRYPTED(inode))
+		return __fscrypt_encrypt_symlink(inode, target, len, disk_link);
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 81e02201b215..02ec0aa894d8 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -223,4 +223,20 @@ static inline int __fscrypt_prepare_lookup(struct inode *dir,
 	return -EOPNOTSUPP;
 }
 
+static inline int __fscrypt_prepare_symlink(struct inode *dir,
+					    unsigned int len,
+					    unsigned int max_len,
+					    struct fscrypt_str *disk_link)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int __fscrypt_encrypt_symlink(struct inode *inode,
+					    const char *target,
+					    unsigned int len,
+					    struct fscrypt_str *disk_link)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 562a9bc04560..7e0b67ccd816 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -205,5 +205,11 @@ extern int __fscrypt_prepare_rename(struct inode *old_dir,
 				    struct dentry *new_dentry,
 				    unsigned int flags);
 extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
+extern int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
+				     unsigned int max_len,
+				     struct fscrypt_str *disk_link);
+extern int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
+				     unsigned int len,
+				     struct fscrypt_str *disk_link);
 
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.15.1
