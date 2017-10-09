Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 07/11] fscrypt: new helper function - fscrypt_file_open()
Date: Mon,  9 Oct 2017 12:15:40 -0700
Message-Id: <20171009191544.43656-8-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a helper function which prepares to open a regular file which may be
encrypted.  It handles setting up the file's encryption key, then
checking that the file's encryption policy matches that of its parent
directory (if the parent directory is encrypted).  It may be set as the
->open() method or it can be called from another ->open() method.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/Makefile              |  2 +-
 fs/crypto/hooks.c               | 49 +++++++++++++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  9 ++++++++
 include/linux/fscrypt_supp.h    |  3 +++
 4 files changed, 62 insertions(+), 1 deletion(-)
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
index 7b390e356f7f..162da6517ac4 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -177,4 +177,13 @@ static inline int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 	return -EOPNOTSUPP;
 }
 
+/* hooks.c */
+
+static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
+{
+	if (IS_ENCRYPTED(inode))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 5a90e5ef4687..fd2f6decaee4 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -143,4 +143,7 @@ extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
 
+/* hooks.c */
+extern int fscrypt_file_open(struct inode *inode, struct file *filp);
+
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.2.920.gcf0c67979c-goog
