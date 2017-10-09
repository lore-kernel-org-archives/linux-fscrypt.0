Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 08/11] fscrypt: new helper function - fscrypt_prepare_link()
Date: Mon,  9 Oct 2017 12:15:41 -0700
Message-Id: <20171009191544.43656-9-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to link an inode into a
possibly-encrypted directory.  It handles setting up the target
directory's encryption key, then verifying that the link won't violate
the constraint that all files in an encrypted directory tree use the
same encryption policy.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 15 +++++++++++++++
 include/linux/fscrypt.h         | 27 +++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  6 ++++++
 include/linux/fscrypt_supp.h    |  1 +
 4 files changed, 49 insertions(+)

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
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index b3e2a5f93415..9c9a53f99327 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -177,4 +177,31 @@ static inline int fscrypt_require_key(struct inode *inode)
 	return 0;
 }
 
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
 #endif	/* _LINUX_FSCRYPT_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 162da6517ac4..d7d1039eb6b5 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -186,4 +186,10 @@ static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+static inline int __fscrypt_prepare_link(struct inode *inode,
+					 struct inode *dir)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index fd2f6decaee4..80706283da75 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -145,5 +145,6 @@ extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 
 /* hooks.c */
 extern int fscrypt_file_open(struct inode *inode, struct file *filp);
+extern int __fscrypt_prepare_link(struct inode *inode, struct inode *dir);
 
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.2.920.gcf0c67979c-goog
