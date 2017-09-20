Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 09/25] fscrypt: new helper function - fscrypt_prepare_lookup()
Date: Wed, 20 Sep 2017 15:45:49 -0700
Message-Id: <20170920224605.22030-10-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function which prepares to look up the given dentry
in the given directory.  If the directory is encrypted, it handles
loading the directory's encryption key, setting the dentry's ->d_op to
fscrypt_d_ops, and setting DCACHE_ENCRYPTED_WITH_KEY if the directory's
encryption key is available.

Note: once all filesystems switch over to this, we'll be able to move
fscrypt_d_ops and fscrypt_set_encrypted_dentry() to fscrypt_private.h.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c               | 18 ++++++++++++++++++
 include/linux/fscrypt_notsupp.h |  9 +++++++++
 include/linux/fscrypt_supp.h    | 30 ++++++++++++++++++++++++++++++
 3 files changed, 57 insertions(+)

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
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index a88a2959cd8c..e9b437605f9c 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -209,4 +209,13 @@ static inline int fscrypt_prepare_rename(struct inode *old_dir,
 	return 0;
 }
 
+static inline int fscrypt_prepare_lookup(struct inode *dir,
+					 struct dentry *dentry,
+					 unsigned int flags)
+{
+	if (IS_ENCRYPTED(dir))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index fa062d41b39a..2b99bc01c59b 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -240,4 +240,34 @@ static inline int fscrypt_prepare_rename(struct inode *old_dir,
 	return 0;
 }
 
+extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
+
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
 #endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.14.1.821.g8fa685d3b7-goog
