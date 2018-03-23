Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 09/14] fscrypt: make fscrypt_operations.max_namelen an integer
Date: Fri, 23 Mar 2018 12:23:53 -0700
Message-Id: <20180323192358.95691-10-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now ->max_namelen() is only called to limit the filename length when
adding NUL padding, and only for real filenames -- not symlink targets.
It also didn't give the correct length for symlink targets anyway since
it forgot to subtract 'sizeof(struct fscrypt_symlink_data)'.

Thus, change ->max_namelen from a function to a simple 'unsigned int'
that gives the filesystem's maximum filename length.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c            |  2 +-
 fs/ext4/super.c              |  8 +-------
 fs/f2fs/super.c              |  8 +-------
 fs/ubifs/crypto.c            | 10 +---------
 include/linux/fscrypt_supp.h |  2 +-
 5 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index c4eb3a235ae4..39091fc31e98 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -334,7 +334,7 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 
 	if (dir->i_crypt_info) {
 		if (!fscrypt_fname_encrypted_size(dir, iname->len,
-						  dir->i_sb->s_cop->max_namelen(dir),
+						  dir->i_sb->s_cop->max_namelen,
 						  &fname->crypto_buf.len))
 			return -ENAMETOOLONG;
 		fname->crypto_buf.name = kmalloc(fname->crypto_buf.len,
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 39bf464c35f1..63242840b1af 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1235,19 +1235,13 @@ static bool ext4_dummy_context(struct inode *inode)
 	return DUMMY_ENCRYPTION_ENABLED(EXT4_SB(inode->i_sb));
 }
 
-static unsigned ext4_max_namelen(struct inode *inode)
-{
-	return S_ISLNK(inode->i_mode) ? inode->i_sb->s_blocksize :
-		EXT4_NAME_LEN;
-}
-
 static const struct fscrypt_operations ext4_cryptops = {
 	.key_prefix		= "ext4:",
 	.get_context		= ext4_get_context,
 	.set_context		= ext4_set_context,
 	.dummy_context		= ext4_dummy_context,
 	.empty_dir		= ext4_empty_dir,
-	.max_namelen		= ext4_max_namelen,
+	.max_namelen		= EXT4_NAME_LEN,
 };
 #endif
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 8173ae688814..d4c9d580d32f 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1802,18 +1802,12 @@ static int f2fs_set_context(struct inode *inode, const void *ctx, size_t len,
 				ctx, len, fs_data, XATTR_CREATE);
 }
 
-static unsigned f2fs_max_namelen(struct inode *inode)
-{
-	return S_ISLNK(inode->i_mode) ?
-			inode->i_sb->s_blocksize : F2FS_NAME_LEN;
-}
-
 static const struct fscrypt_operations f2fs_cryptops = {
 	.key_prefix	= "f2fs:",
 	.get_context	= f2fs_get_context,
 	.set_context	= f2fs_set_context,
 	.empty_dir	= f2fs_empty_dir,
-	.max_namelen	= f2fs_max_namelen,
+	.max_namelen	= F2FS_NAME_LEN,
 };
 #endif
 
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 616a688f5d8f..55c508fe8131 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -24,14 +24,6 @@ static bool ubifs_crypt_empty_dir(struct inode *inode)
 	return ubifs_check_dir_empty(inode) == 0;
 }
 
-static unsigned int ubifs_crypt_max_namelen(struct inode *inode)
-{
-	if (S_ISLNK(inode->i_mode))
-		return UBIFS_MAX_INO_DATA;
-	else
-		return UBIFS_MAX_NLEN;
-}
-
 int ubifs_encrypt(const struct inode *inode, struct ubifs_data_node *dn,
 		  unsigned int in_len, unsigned int *out_len, int block)
 {
@@ -89,5 +81,5 @@ const struct fscrypt_operations ubifs_crypt_operations = {
 	.get_context		= ubifs_crypt_get_context,
 	.set_context		= ubifs_crypt_set_context,
 	.empty_dir		= ubifs_crypt_empty_dir,
-	.max_namelen		= ubifs_crypt_max_namelen,
+	.max_namelen		= UBIFS_MAX_NLEN,
 };
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index c9c2cc26bc62..5080cb1bec4c 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -29,7 +29,7 @@ struct fscrypt_operations {
 	int (*set_context)(struct inode *, const void *, size_t, void *);
 	bool (*dummy_context)(struct inode *);
 	bool (*empty_dir)(struct inode *);
-	unsigned (*max_namelen)(struct inode *);
+	unsigned int max_namelen;
 };
 
 struct fscrypt_ctx {
-- 
2.17.0.rc0.231.g781580f067-goog
