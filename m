Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 06/25] fscrypt: new helper function - fscrypt_file_open()
Date: Wed, 20 Sep 2017 15:45:46 -0700
Message-Id: <20170920224605.22030-7-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a helper function which prepares to open a regular file which may be
encrypted.  It handles setting up the file's encryption key, then
checking that the file's encryption policy matches that of its parent
directory (if the parent directory is encrypted).  It may be set as the
->open() method or it can be called from another ->open() method.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/Makefile              |  2 +-
 fs/crypto/hooks.c               | 49 +++++++++++++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  7 ++++++
 include/linux/fscrypt_supp.h    |  2 ++
 4 files changed, 59 insertions(+), 1 deletion(-)
 create mode 100644 fs/crypto/hooks.c

diff --git a/fs/crypto/Makefile b/fs/crypto/Makefile
index 9f6607f17b53..cb496989a6b6 100644
--- a/fs/crypto/Makefile
+++ b/fs/crypto/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_FS_ENCRYPTION)	+= fscrypto.o
 
-fscrypto-y := crypto.o fname.o policy.o keyinfo.o
+fscrypto-y := crypto.o fname.o hooks.o keyinfo.o policy.o
 fscrypto-$(CONFIG_BLOCK) += bio.o
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
new file mode 100644
index 000000000000..069088e91ea9
--- /dev/null
+++ b/fs/crypto/hooks.c
@@ -0,0 +1,49 @@
+/*
+ * fs/crypto/hooks.c
+ *
+ * Encryption hooks for higher-level filesystem operations.
+ */
+
+#include <linux/ratelimit.h>
+#include "fscrypt_private.h"
+
+/**
+ * fscrypt_file_open - prepare to open a possibly-encrypted regular file
+ * @inode: the inode being opened
+ * @filp: the struct file being set up
+ *
+ * Currently, an encrypted regular file can only be opened if its encryption key
+ * is available; access to the raw encrypted contents is not supported.
+ * Therefore, we first set up the inode's encryption key (if not already done)
+ * and return an error if it's unavailable.
+ *
+ * We also verify that if the parent directory (from the path via which the file
+ * is being opened) is encrypted, then the inode being opened uses the same
+ * encryption policy.  This is needed as part of the enforcement that all files
+ * in an encrypted directory tree use the same encryption policy, as a
+ * protection against certain types of offline attacks.  Note that this check is
+ * needed even when opening an *unencrypted* file, since it's forbidden to have
+ * an unencrypted file in an encrypted directory.
+ *
+ * Return: 0 on success, -ENOKEY if the key is missing, or another -errno code
+ */
+int fscrypt_file_open(struct inode *inode, struct file *filp)
+{
+	int err;
+	struct dentry *dir;
+
+	err = fscrypt_require_key(inode);
+	if (err)
+		return err;
+
+	dir = dget_parent(file_dentry(filp));
+	if (IS_ENCRYPTED(d_inode(dir)) &&
+	    !fscrypt_has_permitted_context(d_inode(dir), inode)) {
+		pr_warn_ratelimited("fscrypt: inconsistent encryption contexts: %lu/%lu",
+				    d_inode(dir)->i_ino, inode->i_ino);
+		err = -EPERM;
+	}
+	dput(dir);
+	return err;
+}
+EXPORT_SYMBOL_GPL(fscrypt_file_open);
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 3cfc953fef71..99e8ee6f2ce4 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -182,4 +182,11 @@ static inline int fscrypt_require_key(struct inode *inode)
 	return 0;
 }
 
+static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
+{
+	if (IS_ENCRYPTED(inode))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index b6d4b5d303a3..521f15adf83c 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -170,4 +170,6 @@ static inline int fscrypt_require_key(struct inode *inode)
 	return 0;
 }
 
+extern int fscrypt_file_open(struct inode *inode, struct file *filp);
+
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.1.821.g8fa685d3b7-goog
