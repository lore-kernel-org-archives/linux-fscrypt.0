Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 08/25] fscrypt: new helper function - fscrypt_prepare_rename()
Date: Wed, 20 Sep 2017 15:45:48 -0700
Message-Id: <20170920224605.22030-9-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to rename a file into a
possibly encrypted directory.  It handles loading the encryption keys
for the source and target directories if needed, and it handles
enforcing that if the target directory (and the source directory for a
cross-rename) is encrypted, then the file being moved into the directory
has the same encryption policy as its containing directory.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 30 ++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h | 11 +++++++++++
 include/linux/fscrypt_supp.h    | 39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 80 insertions(+)

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
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 2cb400440be3..a88a2959cd8c 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -198,4 +198,15 @@ static inline int fscrypt_prepare_link(struct dentry *old_dentry,
 	return 0;
 }
 
+static inline int fscrypt_prepare_rename(struct inode *old_dir,
+					 struct dentry *old_dentry,
+					 struct inode *new_dir,
+					 struct dentry *new_dentry,
+					 unsigned int flags)
+{
+	if (IS_ENCRYPTED(old_dir) || IS_ENCRYPTED(new_dir))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index ebc0cc41aaf9..fa062d41b39a 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -201,4 +201,43 @@ static inline int fscrypt_prepare_link(struct dentry *old_dentry,
 	return 0;
 }
 
+extern int __fscrypt_prepare_rename(struct inode *old_dir,
+				    struct dentry *old_dentry,
+				    struct inode *new_dir,
+				    struct dentry *new_dentry,
+				    unsigned int flags);
+
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
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.1.821.g8fa685d3b7-goog
