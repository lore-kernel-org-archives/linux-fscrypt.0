Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 18/25] f2fs: switch to fscrypt_prepare_rename()
Date: Wed, 20 Sep 2017 15:45:58 -0700
Message-Id: <20170920224605.22030-19-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 31 +++++++------------------------
 1 file changed, 7 insertions(+), 24 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index cf4e4294e450..80bcf2185fd8 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -742,18 +742,6 @@ static int f2fs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	bool is_old_inline = f2fs_has_inline_dentry(old_dir);
 	int err = -ENOENT;
 
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
@@ -935,18 +923,6 @@ static int f2fs_cross_rename(struct inode *old_dir, struct dentry *old_dentry,
 	int old_nlink = 0, new_nlink = 0;
 	int err = -ENOENT;
 
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
@@ -1086,9 +1062,16 @@ static int f2fs_rename2(struct inode *old_dir, struct dentry *old_dentry,
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
2.14.1.821.g8fa685d3b7-goog
