Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 11/24] fscrypt: new helper function - fscrypt_get_symlink()
Date: Fri, 15 Dec 2017 09:42:12 -0800
Message-Id: <20171215174225.31583-12-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Filesystems also have duplicate code to support ->get_link() on
encrypted symlinks.  Factor it out into a new function
fscrypt_get_symlink().  It takes in the contents of the encrypted
symlink on-disk and provides the target (decrypted or encoded) that
should be returned from ->get_link().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 73 +++++++++++++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  8 +++++
 include/linux/fscrypt_supp.h    |  3 ++
 3 files changed, 84 insertions(+)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 483e87d40f03..0f103a5cb1aa 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -196,3 +196,76 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__fscrypt_encrypt_symlink);
+
+/**
+ * fscrypt_get_symlink - get the target of an encrypted symlink
+ * @inode: the symlink inode
+ * @caddr: the on-disk contents of the symlink
+ * @max_size: size of @caddr buffer
+ * @done: if successful, will be set up to free the returned target
+ *
+ * If the symlink's encryption key is available, we decrypt its target.
+ * Otherwise, we encode its target for presentation.
+ *
+ * This may sleep, so the filesystem must have dropped out of RCU mode already.
+ *
+ * Return: the presentable symlink target or an ERR_PTR()
+ */
+const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
+				unsigned int max_size,
+				struct delayed_call *done)
+{
+	const struct fscrypt_symlink_data *sd;
+	struct fscrypt_str cstr, pstr;
+	int err;
+
+	/* This is for encrypted symlinks only */
+	if (WARN_ON(!IS_ENCRYPTED(inode)))
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * Try to set up the symlink's encryption key, but we can continue
+	 * regardless of whether the key is available or not.
+	 */
+	err = fscrypt_get_encryption_info(inode);
+	if (err)
+		return ERR_PTR(err);
+
+	/*
+	 * For historical reasons, encrypted symlink targets are prefixed with
+	 * the ciphertext length, even though this is redundant with i_size.
+	 */
+
+	if (max_size < sizeof(*sd))
+		return ERR_PTR(-EUCLEAN);
+	sd = caddr;
+	cstr.name = (unsigned char *)sd->encrypted_path;
+	cstr.len = le16_to_cpu(sd->len);
+
+	if (cstr.len == 0)
+		return ERR_PTR(-EUCLEAN);
+
+	if (cstr.len + sizeof(*sd) - 1 > max_size)
+		return ERR_PTR(-EUCLEAN);
+
+	err = fscrypt_fname_alloc_buffer(inode, cstr.len, &pstr);
+	if (err)
+		return ERR_PTR(err);
+
+	err = fscrypt_fname_disk_to_usr(inode, 0, 0, &cstr, &pstr);
+	if (err)
+		goto err_kfree;
+
+	err = -EUCLEAN;
+	if (pstr.name[0] == '\0')
+		goto err_kfree;
+
+	pstr.name[pstr.len] = '\0';
+	set_delayed_call(done, kfree_link, pstr.name);
+	return pstr.name;
+
+err_kfree:
+	kfree(pstr.name);
+	return ERR_PTR(err);
+}
+EXPORT_SYMBOL_GPL(fscrypt_get_symlink);
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 02ec0aa894d8..dd106640c6ea 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -239,4 +239,12 @@ static inline int __fscrypt_encrypt_symlink(struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
+static inline const char *fscrypt_get_symlink(struct inode *inode,
+					      const void *caddr,
+					      unsigned int max_size,
+					      struct delayed_call *done)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 7e0b67ccd816..dc2babf3f7d3 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -211,5 +211,8 @@ extern int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
 extern int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 				     unsigned int len,
 				     struct fscrypt_str *disk_link);
+extern const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
+				       unsigned int max_size,
+				       struct delayed_call *done);
 
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.15.1
