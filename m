Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 06/11] fscrypt: new helper function - fscrypt_require_key()
Date: Mon,  9 Oct 2017 12:15:39 -0700
Message-Id: <20171009191544.43656-7-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a helper function which checks if an inode is encrypted, and if so,
tries to set up its encryption key.  This is a pattern which is
duplicated in multiple places in each of ext4, f2fs, and ubifs --- for
example, when a regular file is asked to be opened or truncated.

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index d58e6a90cfe4..b3e2a5f93415 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -151,5 +151,30 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 #include <linux/fscrypt_notsupp.h>
 #endif /* __FS_HAS_ENCRYPTION */
 
+/**
+ * fscrypt_require_key - require an inode's encryption key
+ * @inode: the inode we need the key for
+ *
+ * If the inode is encrypted, set up its encryption key if not already done.
+ * Then require that the key be present and return -ENOKEY otherwise.
+ *
+ * No locks are needed, and the key will live as long as the struct inode --- so
+ * it won't go away from under you.
+ *
+ * Return: 0 on success, -ENOKEY if the key is missing, or another -errno code
+ * if a problem occurred while setting up the encryption key.
+ */
+static inline int fscrypt_require_key(struct inode *inode)
+{
+	if (IS_ENCRYPTED(inode)) {
+		int err = fscrypt_get_encryption_info(inode);
+
+		if (err)
+			return err;
+		if (!fscrypt_has_encryption_key(inode))
+			return -ENOKEY;
+	}
+	return 0;
+}
 
 #endif	/* _LINUX_FSCRYPT_H */
-- 
2.14.2.920.gcf0c67979c-goog
