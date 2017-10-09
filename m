Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 10/11] fscrypt: new helper function - fscrypt_prepare_lookup()
Date: Mon,  9 Oct 2017 12:15:43 -0700
Message-Id: <20171009191544.43656-11-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to look up the given dentry
in the given directory.  If the directory is encrypted, it handles
loading the directory's encryption key, setting the dentry's ->d_op to
fscrypt_d_ops, and setting DCACHE_ENCRYPTED_WITH_KEY if the directory's
encryption key is available.

Note: once all filesystems switch over to this, we'll be able to move
fscrypt_d_ops and fscrypt_set_encrypted_dentry() to fscrypt_private.h.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 18 ++++++++++++++++++
 include/linux/fscrypt.h         | 28 ++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  6 ++++++
 include/linux/fscrypt_supp.h    |  1 +
 4 files changed, 53 insertions(+)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 822cb78f9b45..9f5fb2eb9cf7 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -92,3 +92,21 @@ int __fscrypt_prepare_rename(struct inode *old_dir, struct dentry *old_dentry,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__fscrypt_prepare_rename);
+
+int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry)
+{
+	int err = fscrypt_get_encryption_info(dir);
+
+	if (err)
+		return err;
+
+	if (fscrypt_has_encryption_key(dir)) {
+		spin_lock(&dentry->d_lock);
+		dentry->d_flags |= DCACHE_ENCRYPTED_WITH_KEY;
+		spin_unlock(&dentry->d_lock);
+	}
+
+	d_set_d_op(dentry, &fscrypt_d_ops);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_prepare_lookup);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index c422367baed9..2327859c8cd2 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -237,4 +237,32 @@ static inline int fscrypt_prepare_rename(struct inode *old_dir,
 	return 0;
 }
 
+/**
+ * fscrypt_prepare_lookup - prepare to lookup a name in a possibly-encrypted directory
+ * @dir: directory being searched
+ * @dentry: filename being looked up
+ * @flags: lookup flags
+ *
+ * Prepare for ->lookup() in a directory which may be encrypted.  Lookups can be
+ * done with or without the directory's encryption key; without the key,
+ * filenames are presented in encrypted form.  Therefore, we'll try to set up
+ * the directory's encryption key, but even without it the lookup can continue.
+ *
+ * To allow invalidating stale dentries if the directory's encryption key is
+ * added later, we also install a custom ->d_revalidate() method and use the
+ * DCACHE_ENCRYPTED_WITH_KEY flag to indicate whether a given dentry is a
+ * plaintext name (flag set) or a ciphertext name (flag cleared).
+ *
+ * Return: 0 on success, -errno if a problem occurred while setting up the
+ * encryption key
+ */
+static inline int fscrypt_prepare_lookup(struct inode *dir,
+					 struct dentry *dentry,
+					 unsigned int flags)
+{
+	if (IS_ENCRYPTED(dir))
+		return __fscrypt_prepare_lookup(dir, dentry);
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 6af378d8126e..c4c6bf2c390e 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -201,4 +201,10 @@ static inline int __fscrypt_prepare_rename(struct inode *old_dir,
 	return -EOPNOTSUPP;
 }
 
+static inline int __fscrypt_prepare_lookup(struct inode *dir,
+					   struct dentry *dentry)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 40f35073145f..2db5e9706f60 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -151,5 +151,6 @@ extern int __fscrypt_prepare_rename(struct inode *old_dir,
 				    struct inode *new_dir,
 				    struct dentry *new_dentry,
 				    unsigned int flags);
+extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
 
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.2.920.gcf0c67979c-goog
