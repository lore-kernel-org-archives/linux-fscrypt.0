Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: remove unnecessary checks for NULL operations
Date: Tue,  4 Apr 2017 14:39:41 -0700
Message-Id: <20170404213941.113427-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The functions in fs/crypto/*.c are only called by filesystems configured
with encryption support.  Since the ->get_context(), ->set_context(),
and ->empty_dir() operations are always provided in that case (and must
be, otherwise there would be no way to get/set encryption policies, or
in the case of ->get_context() even access encrypted files at all),
there is no need to check for these operations being NULL and we can
remove these unneeded checks.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c |  3 ---
 fs/crypto/policy.c  | 11 +----------
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 8cdfddce2b34..179e578b875b 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -183,9 +183,6 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (res)
 		return res;
 
-	if (!inode->i_sb->s_cop->get_context)
-		return -EOPNOTSUPP;
-
 	res = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
 	if (res < 0) {
 		if (!fscrypt_dummy_context_enabled(inode) ||
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 4908906d54d5..d71ec3780d0c 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -34,9 +34,6 @@ static int create_encryption_context_from_policy(struct inode *inode,
 {
 	struct fscrypt_context ctx;
 
-	if (!inode->i_sb->s_cop->set_context)
-		return -EOPNOTSUPP;
-
 	ctx.format = FS_ENCRYPTION_CONTEXT_FORMAT_V1;
 	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
 					FS_KEY_DESCRIPTOR_SIZE);
@@ -87,8 +84,6 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 	if (ret == -ENODATA) {
 		if (!S_ISDIR(inode->i_mode))
 			ret = -ENOTDIR;
-		else if (!inode->i_sb->s_cop->empty_dir)
-			ret = -EOPNOTSUPP;
 		else if (!inode->i_sb->s_cop->empty_dir(inode))
 			ret = -ENOTEMPTY;
 		else
@@ -118,8 +113,7 @@ int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
 	struct fscrypt_policy policy;
 	int res;
 
-	if (!inode->i_sb->s_cop->get_context ||
-			!inode->i_sb->s_cop->is_encrypted(inode))
+	if (!inode->i_sb->s_cop->is_encrypted(inode))
 		return -ENODATA;
 
 	res = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
@@ -202,9 +196,6 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
 	struct fscrypt_info *ci;
 	int res;
 
-	if (!parent->i_sb->s_cop->set_context)
-		return -EOPNOTSUPP;
-
 	res = fscrypt_get_encryption_info(parent);
 	if (res < 0)
 		return res;
-- 
2.12.2.715.g7642488e1d-goog
