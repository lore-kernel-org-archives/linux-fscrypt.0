Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 04/11] fscrypt: remove ->is_encrypted()
Date: Mon,  9 Oct 2017 12:15:37 -0700
Message-Id: <20171009191544.43656-5-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now that all callers of fscrypt_operations.is_encrypted() have been
switched to IS_ENCRYPTED(), remove ->is_encrypted().

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/super.c         | 2 --
 fs/f2fs/super.c         | 2 --
 fs/ubifs/crypto.c       | 1 -
 fs/ubifs/super.c        | 1 -
 fs/ubifs/ubifs.h        | 9 ++-------
 include/linux/fscrypt.h | 1 -
 6 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index dcfb19539871..bc63cdf194e3 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1241,13 +1241,11 @@ static const struct fscrypt_operations ext4_cryptops = {
 	.get_context		= ext4_get_context,
 	.set_context		= ext4_set_context,
 	.dummy_context		= ext4_dummy_context,
-	.is_encrypted		= ext4_encrypted_inode,
 	.empty_dir		= ext4_empty_dir,
 	.max_namelen		= ext4_max_namelen,
 };
 #else
 static const struct fscrypt_operations ext4_cryptops = {
-	.is_encrypted		= ext4_encrypted_inode,
 };
 #endif
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 89f61eb3d167..1cb41f711ab8 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1594,13 +1594,11 @@ static const struct fscrypt_operations f2fs_cryptops = {
 	.key_prefix	= "f2fs:",
 	.get_context	= f2fs_get_context,
 	.set_context	= f2fs_set_context,
-	.is_encrypted	= f2fs_encrypted_inode,
 	.empty_dir	= f2fs_empty_dir,
 	.max_namelen	= f2fs_max_namelen,
 };
 #else
 static const struct fscrypt_operations f2fs_cryptops = {
-	.is_encrypted	= f2fs_encrypted_inode,
 };
 #endif
 
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 114ba455bac3..8880fa7733d8 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -87,7 +87,6 @@ const struct fscrypt_operations ubifs_crypt_operations = {
 	.key_prefix		= "ubifs:",
 	.get_context		= ubifs_crypt_get_context,
 	.set_context		= ubifs_crypt_set_context,
-	.is_encrypted		= __ubifs_crypt_is_encrypted,
 	.empty_dir		= ubifs_crypt_empty_dir,
 	.max_namelen		= ubifs_crypt_max_namelen,
 };
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 5496b17b959c..adaca6088836 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2009,7 +2009,6 @@ static struct ubifs_info *alloc_ubifs_info(struct ubi_volume_desc *ubi)
 
 #ifndef CONFIG_UBIFS_FS_ENCRYPTION
 const struct fscrypt_operations ubifs_crypt_operations = {
-	.is_encrypted		= __ubifs_crypt_is_encrypted,
 };
 #endif
 
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 6a346d4af98f..63c7468147eb 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1834,18 +1834,13 @@ int ubifs_decrypt(const struct inode *inode, struct ubifs_data_node *dn,
 
 extern const struct fscrypt_operations ubifs_crypt_operations;
 
-static inline bool __ubifs_crypt_is_encrypted(struct inode *inode)
+static inline bool ubifs_crypt_is_encrypted(const struct inode *inode)
 {
-	struct ubifs_inode *ui = ubifs_inode(inode);
+	const struct ubifs_inode *ui = ubifs_inode(inode);
 
 	return ui->flags & UBIFS_CRYPT_FL;
 }
 
-static inline bool ubifs_crypt_is_encrypted(const struct inode *inode)
-{
-	return __ubifs_crypt_is_encrypted((struct inode *)inode);
-}
-
 /* Normal UBIFS messages */
 __printf(2, 3)
 void ubifs_msg(const struct ubifs_info *c, const char *fmt, ...);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index bfc962e62078..d58e6a90cfe4 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -81,7 +81,6 @@ struct fscrypt_operations {
 	int (*get_context)(struct inode *, void *, size_t);
 	int (*set_context)(struct inode *, const void *, size_t, void *);
 	bool (*dummy_context)(struct inode *);
-	bool (*is_encrypted)(struct inode *);
 	bool (*empty_dir)(struct inode *);
 	unsigned (*max_namelen)(struct inode *);
 };
-- 
2.14.2.920.gcf0c67979c-goog
