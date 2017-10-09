Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 11/11] fscrypt: new helper function - fscrypt_prepare_setattr()
Date: Mon,  9 Oct 2017 12:15:44 -0700
Message-Id: <20171009191544.43656-12-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function for filesystems to call when processing
->setattr() on a possibly-encrypted inode.  It handles enforcing that an
encrypted file can only be truncated if its encryption key is available.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 2327859c8cd2..53437bfdfcbc 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -265,4 +265,29 @@ static inline int fscrypt_prepare_lookup(struct inode *dir,
 	return 0;
 }
 
+/**
+ * fscrypt_prepare_setattr - prepare to change a possibly-encrypted inode's attributes
+ * @dentry: dentry through which the inode is being changed
+ * @attr: attributes to change
+ *
+ * Prepare for ->setattr() on a possibly-encrypted inode.  On an encrypted file,
+ * most attribute changes are allowed even without the encryption key.  However,
+ * without the encryption key we do have to forbid truncates.  This is needed
+ * because the size being truncated to may not be a multiple of the filesystem
+ * block size, and in that case we'd have to decrypt the final block, zero the
+ * portion past i_size, and re-encrypt it.  (We *could* allow truncating to a
+ * filesystem block boundary, but it's simpler to just forbid all truncates ---
+ * and we already forbid all other contents modifications without the key.)
+ *
+ * Return: 0 on success, -ENOKEY if the key is missing, or another -errno code
+ * if a problem occurred while setting up the encryption key.
+ */
+static inline int fscrypt_prepare_setattr(struct dentry *dentry,
+					  struct iattr *attr)
+{
+	if (attr->ia_valid & ATTR_SIZE)
+		return fscrypt_require_key(d_inode(dentry));
+	return 0;
+}
+
 #endif	/* _LINUX_FSCRYPT_H */
-- 
2.14.2.920.gcf0c67979c-goog
