Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: eliminate ->prepare_context() operation
Date: Wed, 22 Feb 2017 13:25:14 -0800
Message-Id: <20170222212514.61919-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The only use of the ->prepare_context() fscrypt operation was to allow
ext4 to evict inline data from the inode before ->set_context().
However, there is no reason why this cannot be done as simply the first
step in ->set_context(), and in fact it makes more sense to do it that
way because then the policy modes and flags get validated before any
real work is done.  Therefore, merge ext4_prepare_context() into
ext4_set_context(), and remove ->prepare_context().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/policy.c             |  7 -------
 fs/ext4/super.c                | 10 ++++------
 include/linux/fscrypt_common.h |  1 -
 3 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 14b76da71269..4908906d54d5 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -33,17 +33,10 @@ static int create_encryption_context_from_policy(struct inode *inode,
 				const struct fscrypt_policy *policy)
 {
 	struct fscrypt_context ctx;
-	int res;
 
 	if (!inode->i_sb->s_cop->set_context)
 		return -EOPNOTSUPP;
 
-	if (inode->i_sb->s_cop->prepare_context) {
-		res = inode->i_sb->s_cop->prepare_context(inode);
-		if (res)
-			return res;
-	}
-
 	ctx.format = FS_ENCRYPTION_CONTEXT_FORMAT_V1;
 	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
 					FS_KEY_DESCRIPTOR_SIZE);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 2e03a0a88d92..a9448db1cf7e 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1120,17 +1120,16 @@ static int ext4_get_context(struct inode *inode, void *ctx, size_t len)
 				 EXT4_XATTR_NAME_ENCRYPTION_CONTEXT, ctx, len);
 }
 
-static int ext4_prepare_context(struct inode *inode)
-{
-	return ext4_convert_inline_data(inode);
-}
-
 static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 							void *fs_data)
 {
 	handle_t *handle = fs_data;
 	int res, res2, retries = 0;
 
+	res = ext4_convert_inline_data(inode);
+	if (res)
+		return res;
+
 	/*
 	 * If a journal handle was specified, then the encryption context is
 	 * being set on a new inode via inheritance and is part of a larger
@@ -1196,7 +1195,6 @@ static unsigned ext4_max_namelen(struct inode *inode)
 static const struct fscrypt_operations ext4_cryptops = {
 	.key_prefix		= "ext4:",
 	.get_context		= ext4_get_context,
-	.prepare_context	= ext4_prepare_context,
 	.set_context		= ext4_set_context,
 	.dummy_context		= ext4_dummy_context,
 	.is_encrypted		= ext4_encrypted_inode,
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 547f81592ba1..10c1abfbac6c 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -87,7 +87,6 @@ struct fscrypt_operations {
 	unsigned int flags;
 	const char *key_prefix;
 	int (*get_context)(struct inode *, void *, size_t);
-	int (*prepare_context)(struct inode *);
 	int (*set_context)(struct inode *, const void *, size_t, void *);
 	int (*dummy_context)(struct inode *);
 	bool (*is_encrypted)(struct inode *);
-- 
2.11.0.483.g087da7b7c-goog
