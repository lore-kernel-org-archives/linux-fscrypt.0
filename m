Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 09/11] fscrypt: new helper function - fscrypt_prepare_rename()
Date: Mon,  9 Oct 2017 12:15:42 -0700
Message-Id: <20171009191544.43656-10-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to rename a file into a
possibly encrypted directory.  It handles loading the encryption keys
for the source and target directories if needed, and it handles
enforcing that if the target directory (and the source directory for a
cross-rename) is encrypted, then the file being moved into the directory
has the same encryption policy as its containing directory.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 30 ++++++++++++++++++++++++++++++
 include/linux/fscrypt.h         | 33 +++++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  9 +++++++++
 include/linux/fscrypt_supp.h    |  5 +++++
 4 files changed, 77 insertions(+)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 8b90217320dd..822cb78f9b45 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -62,3 +62,33 @@ int __fscrypt_prepare_link(struct inode *inode, struct inode *dir)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__fscrypt_prepare_link);
+
+int __fscrypt_prepare_rename(struct inode *old_dir, struct dentry *old_dentry,
+			     struct inode *new_dir, struct dentry *new_dentry,
+			     unsigned int flags)
+{
+	int err;
+
+	err = fscrypt_require_key(old_dir);
+	if (err)
+		return err;
+
+	err = fscrypt_require_key(new_dir);
+	if (err)
+		return err;
+
+	if (old_dir != new_dir) {
+		if (IS_ENCRYPTED(new_dir) &&
+		    !fscrypt_has_permitted_context(new_dir,
+						   d_inode(old_dentry)))
+			return -EPERM;
+
+		if ((flags & RENAME_EXCHANGE) &&
+		    IS_ENCRYPTED(old_dir) &&
+		    !fscrypt_has_permitted_context(old_dir,
+						   d_inode(new_dentry)))
+			return -EPERM;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_prepare_rename);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 9c9a53f99327..c422367baed9 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -204,4 +204,37 @@ static inline int fscrypt_prepare_link(struct dentry *old_dentry,
 	return 0;
 }
 
+/**
+ * fscrypt_prepare_rename - prepare for a rename between possibly-encrypted directories
+ * @old_dir: source directory
+ * @old_dentry: dentry for source file
+ * @new_dir: target directory
+ * @new_dentry: dentry for target location (may be negative unless exchanging)
+ * @flags: rename flags (we care at least about %RENAME_EXCHANGE)
+ *
+ * Prepare for ->rename() where the source and/or target directories may be
+ * encrypted.  A new link can only be added to an encrypted directory if the
+ * directory's encryption key is available --- since otherwise we'd have no way
+ * to encrypt the filename.  A rename to an existing name, on the other hand,
+ * *is* cryptographically possible without the key.  However, we take the more
+ * conservative approach and just forbid all no-key renames.
+ *
+ * We also verify that the rename will not violate the constraint that all files
+ * in an encrypted directory tree use the same encryption policy.
+ *
+ * Return: 0 on success, -ENOKEY if an encryption key is missing, -EPERM if the
+ * rename would cause inconsistent encryption policies, or another -errno code.
+ */
+static inline int fscrypt_prepare_rename(struct inode *old_dir,
+					 struct dentry *old_dentry,
+					 struct inode *new_dir,
+					 struct dentry *new_dentry,
+					 unsigned int flags)
+{
+	if (IS_ENCRYPTED(old_dir) || IS_ENCRYPTED(new_dir))
+		return __fscrypt_prepare_rename(old_dir, old_dentry,
+						new_dir, new_dentry, flags);
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index d7d1039eb6b5..6af378d8126e 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -192,4 +192,13 @@ static inline int __fscrypt_prepare_link(struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
+static inline int __fscrypt_prepare_rename(struct inode *old_dir,
+					   struct dentry *old_dentry,
+					   struct inode *new_dir,
+					   struct dentry *new_dentry,
+					   unsigned int flags)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 80706283da75..40f35073145f 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -146,5 +146,10 @@ extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 /* hooks.c */
 extern int fscrypt_file_open(struct inode *inode, struct file *filp);
 extern int __fscrypt_prepare_link(struct inode *inode, struct inode *dir);
+extern int __fscrypt_prepare_rename(struct inode *old_dir,
+				    struct dentry *old_dentry,
+				    struct inode *new_dir,
+				    struct dentry *new_dentry,
+				    unsigned int flags);
 
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.2.920.gcf0c67979c-goog
