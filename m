Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 07/25] fscrypt: new helper function - fscrypt_prepare_link()
Date: Wed, 20 Sep 2017 15:45:47 -0700
Message-Id: <20170920224605.22030-8-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to link an inode into a
possibly-encrypted directory.  It handles setting up the target
directory's encryption key, then verifying that the link won't violate
the constraint that all files in an encrypted directory tree use the
same encryption policy.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 15 +++++++++++++++
 include/linux/fscrypt_notsupp.h |  9 +++++++++
 include/linux/fscrypt_supp.h    | 29 +++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 069088e91ea9..8b90217320dd 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -47,3 +47,18 @@ int fscrypt_file_open(struct inode *inode, struct file *filp)
 	return err;
 }
 EXPORT_SYMBOL_GPL(fscrypt_file_open);
+
+int __fscrypt_prepare_link(struct inode *inode, struct inode *dir)
+{
+	int err;
+
+	err = fscrypt_require_key(dir);
+	if (err)
+		return err;
+
+	if (!fscrypt_has_permitted_context(dir, inode))
+		return -EPERM;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_prepare_link);
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 99e8ee6f2ce4..2cb400440be3 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -189,4 +189,13 @@ static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+static inline int fscrypt_prepare_link(struct dentry *old_dentry,
+				       struct inode *dir,
+				       struct dentry *dentry)
+{
+	if (IS_ENCRYPTED(dir))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 521f15adf83c..ebc0cc41aaf9 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -172,4 +172,33 @@ static inline int fscrypt_require_key(struct inode *inode)
 
 extern int fscrypt_file_open(struct inode *inode, struct file *filp);
 
+extern int __fscrypt_prepare_link(struct inode *inode, struct inode *dir);
+
+/**
+ * fscrypt_prepare_link - prepare to link an inode into a possibly-encrypted directory
+ * @old_dentry: an existing dentry for the inode being linked
+ * @dir: the target directory
+ * @dentry: negative dentry for the target filename
+ *
+ * A new link can only be added to an encrypted directory if the directory's
+ * encryption key is available --- since otherwise we'd have no way to encrypt
+ * the filename.  Therefore, we first set up the directory's encryption key (if
+ * not already done) and return an error if it's unavailable.
+ *
+ * We also verify that the link will not violate the constraint that all files
+ * in an encrypted directory tree use the same encryption policy.
+ *
+ * Return: 0 on success, -ENOKEY if the directory's encryption key is missing,
+ * -EPERM if the link would result in an inconsistent encryption policy, or
+ * another -errno code.
+ */
+static inline int fscrypt_prepare_link(struct dentry *old_dentry,
+				       struct inode *dir,
+				       struct dentry *dentry)
+{
+	if (IS_ENCRYPTED(dir))
+		return __fscrypt_prepare_link(d_inode(old_dentry), dir);
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.1.821.g8fa685d3b7-goog
