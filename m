Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 3/5] f2fs: switch to fscrypt_prepare_rename()
Date: Wed, 29 Nov 2017 12:35:30 -0800
Message-Id: <20171129203532.87729-4-ebiggers3@gmail.com>
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 31 +++++++------------------------
 1 file changed, 7 insertions(+), 24 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index dcf5c3a97059..e910d2ebe0c6 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -800,18 +800,6 @@ static int f2fs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (unlikely(f2fs_cp_error(sbi)))
 		return -EIO;
 
-	if ((f2fs_encrypted_inode(old_dir) &&
-			!fscrypt_has_encryption_key(old_dir)) ||
-			(f2fs_encrypted_inode(new_dir) &&
-			!fscrypt_has_encryption_key(new_dir)))
-		return -ENOKEY;
-
-	if ((old_dir != new_dir) && f2fs_encrypted_inode(new_dir) &&
-			!fscrypt_has_permitted_context(new_dir, old_inode)) {
-		err = -EPERM;
-		goto out;
-	}
-
 	if (is_inode_flag_set(new_dir, FI_PROJ_INHERIT) &&
 			(!projid_eq(F2FS_I(new_dir)->i_projid,
 			F2FS_I(old_dentry->d_inode)->i_projid)))
@@ -1002,18 +990,6 @@ static int f2fs_cross_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (unlikely(f2fs_cp_error(sbi)))
 		return -EIO;
 
-	if ((f2fs_encrypted_inode(old_dir) &&
-			!fscrypt_has_encryption_key(old_dir)) ||
-			(f2fs_encrypted_inode(new_dir) &&
-			!fscrypt_has_encryption_key(new_dir)))
-		return -ENOKEY;
-
-	if ((f2fs_encrypted_inode(old_dir) || f2fs_encrypted_inode(new_dir)) &&
-			(old_dir != new_dir) &&
-			(!fscrypt_has_permitted_context(new_dir, old_inode) ||
-			 !fscrypt_has_permitted_context(old_dir, new_inode)))
-		return -EPERM;
-
 	if ((is_inode_flag_set(new_dir, FI_PROJ_INHERIT) &&
 			!projid_eq(F2FS_I(new_dir)->i_projid,
 			F2FS_I(old_dentry->d_inode)->i_projid)) ||
@@ -1153,9 +1129,16 @@ static int f2fs_rename2(struct inode *old_dir, struct dentry *old_dentry,
 			struct inode *new_dir, struct dentry *new_dentry,
 			unsigned int flags)
 {
+	int err;
+
 	if (flags & ~(RENAME_NOREPLACE | RENAME_EXCHANGE | RENAME_WHITEOUT))
 		return -EINVAL;
 
+	err = fscrypt_prepare_rename(old_dir, old_dentry, new_dir, new_dentry,
+				     flags);
+	if (err)
+		return err;
+
 	if (flags & RENAME_EXCHANGE) {
 		return f2fs_cross_rename(old_dir, old_dentry,
 					 new_dir, new_dentry);
-- 
2.15.0.531.g2ccb3012c9-goog
