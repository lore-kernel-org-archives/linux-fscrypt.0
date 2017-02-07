Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2] fscrypt: constify struct fscrypt_operations
Date: Tue,  7 Feb 2017 12:42:10 -0800
Message-Id: <20170207204210.25971-1-ebiggers3@gmail.com>
In-Reply-To: <20170123201646.GA3417@gmail.com>
References: <20170123201646.GA3417@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

[v2: fix conflict with .key_prefix change]

Signed-off-by: Eric Biggers <ebiggers@google.com>
Reviewed-by: Richard Weinberger <richard@nod.at>
---
 fs/ext4/super.c   | 4 ++--
 fs/f2fs/super.c   | 4 ++--
 fs/ubifs/crypto.c | 2 +-
 fs/ubifs/super.c  | 2 +-
 fs/ubifs/ubifs.h  | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 9d15a6293124..20539c2cd6d8 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1173,7 +1173,7 @@ static unsigned ext4_max_namelen(struct inode *inode)
 		EXT4_NAME_LEN;
 }
 
-static struct fscrypt_operations ext4_cryptops = {
+static const struct fscrypt_operations ext4_cryptops = {
 	.key_prefix		= "ext4:",
 	.get_context		= ext4_get_context,
 	.prepare_context	= ext4_prepare_context,
@@ -1184,7 +1184,7 @@ static struct fscrypt_operations ext4_cryptops = {
 	.max_namelen		= ext4_max_namelen,
 };
 #else
-static struct fscrypt_operations ext4_cryptops = {
+static const struct fscrypt_operations ext4_cryptops = {
 	.is_encrypted		= ext4_encrypted_inode,
 };
 #endif
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 739192d95e71..24f40197eb00 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1170,7 +1170,7 @@ static unsigned f2fs_max_namelen(struct inode *inode)
 			inode->i_sb->s_blocksize : F2FS_NAME_LEN;
 }
 
-static struct fscrypt_operations f2fs_cryptops = {
+static const struct fscrypt_operations f2fs_cryptops = {
 	.key_prefix	= "f2fs:",
 	.get_context	= f2fs_get_context,
 	.set_context	= f2fs_set_context,
@@ -1179,7 +1179,7 @@ static struct fscrypt_operations f2fs_cryptops = {
 	.max_namelen	= f2fs_max_namelen,
 };
 #else
-static struct fscrypt_operations f2fs_cryptops = {
+static const struct fscrypt_operations f2fs_cryptops = {
 	.is_encrypted	= f2fs_encrypted_inode,
 };
 #endif
diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 6335abcf98df..382ed428cfd2 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -77,7 +77,7 @@ int ubifs_decrypt(const struct inode *inode, struct ubifs_data_node *dn,
 	return 0;
 }
 
-struct fscrypt_operations ubifs_crypt_operations = {
+const struct fscrypt_operations ubifs_crypt_operations = {
 	.flags			= FS_CFLG_OWN_PAGES,
 	.key_prefix		= "ubifs:",
 	.get_context		= ubifs_crypt_get_context,
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index e08aa04fc835..b73811bd7676 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2000,7 +2000,7 @@ static struct ubifs_info *alloc_ubifs_info(struct ubi_volume_desc *ubi)
 }
 
 #ifndef CONFIG_UBIFS_FS_ENCRYPTION
-struct fscrypt_operations ubifs_crypt_operations = {
+const struct fscrypt_operations ubifs_crypt_operations = {
 	.is_encrypted		= __ubifs_crypt_is_encrypted,
 };
 #endif
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index d9df379bacc6..f0c86f076535 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1824,7 +1824,7 @@ int ubifs_decrypt(const struct inode *inode, struct ubifs_data_node *dn,
 		  unsigned int *out_len, int block);
 #endif
 
-extern struct fscrypt_operations ubifs_crypt_operations;
+extern const struct fscrypt_operations ubifs_crypt_operations;
 
 static inline bool __ubifs_crypt_is_encrypted(struct inode *inode)
 {
-- 
2.11.0.483.g087da7b7c-goog
