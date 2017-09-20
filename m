Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 13/25] ext4: switch to fscrypt_prepare_rename()
Date: Wed, 20 Sep 2017 15:45:53 -0700
Message-Id: <20170920224605.22030-14-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 33 +++++++--------------------------
 1 file changed, 7 insertions(+), 26 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index b2058500f1dc..b2fbc2b87bcf 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -3516,12 +3516,6 @@ static int ext4_rename(struct inode *old_dir, struct dentry *old_dentry,
 			EXT4_I(old_dentry->d_inode)->i_projid)))
 		return -EXDEV;
 
-	if ((ext4_encrypted_inode(old_dir) &&
-	     !fscrypt_has_encryption_key(old_dir)) ||
-	    (ext4_encrypted_inode(new_dir) &&
-	     !fscrypt_has_encryption_key(new_dir)))
-		return -ENOKEY;
-
 	retval = dquot_initialize(old.dir);
 	if (retval)
 		return retval;
@@ -3550,13 +3544,6 @@ static int ext4_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (!old.bh || le32_to_cpu(old.de->inode) != old.inode->i_ino)
 		goto end_rename;
 
-	if ((old.dir != new.dir) &&
-	    ext4_encrypted_inode(new.dir) &&
-	    !fscrypt_has_permitted_context(new.dir, old.inode)) {
-		retval = -EPERM;
-		goto end_rename;
-	}
-
 	new.bh = ext4_find_entry(new.dir, &new.dentry->d_name,
 				 &new.de, &new.inlined);
 	if (IS_ERR(new.bh)) {
@@ -3722,19 +3709,6 @@ static int ext4_cross_rename(struct inode *old_dir, struct dentry *old_dentry,
 	int retval;
 	struct timespec ctime;
 
-	if ((ext4_encrypted_inode(old_dir) &&
-	     !fscrypt_has_encryption_key(old_dir)) ||
-	    (ext4_encrypted_inode(new_dir) &&
-	     !fscrypt_has_encryption_key(new_dir)))
-		return -ENOKEY;
-
-	if ((ext4_encrypted_inode(old_dir) ||
-	     ext4_encrypted_inode(new_dir)) &&
-	    (old_dir != new_dir) &&
-	    (!fscrypt_has_permitted_context(new_dir, old.inode) ||
-	     !fscrypt_has_permitted_context(old_dir, new.inode)))
-		return -EPERM;
-
 	if ((ext4_test_inode_flag(new_dir, EXT4_INODE_PROJINHERIT) &&
 	     !projid_eq(EXT4_I(new_dir)->i_projid,
 			EXT4_I(old_dentry->d_inode)->i_projid)) ||
@@ -3861,12 +3835,19 @@ static int ext4_rename2(struct inode *old_dir, struct dentry *old_dentry,
 			struct inode *new_dir, struct dentry *new_dentry,
 			unsigned int flags)
 {
+	int err;
+
 	if (unlikely(ext4_forced_shutdown(EXT4_SB(old_dir->i_sb))))
 		return -EIO;
 
 	if (flags & ~(RENAME_NOREPLACE | RENAME_EXCHANGE | RENAME_WHITEOUT))
 		return -EINVAL;
 
+	err = fscrypt_prepare_rename(old_dir, old_dentry, new_dir, new_dentry,
+				     flags);
+	if (err)
+		return err;
+
 	if (flags & RENAME_EXCHANGE) {
 		return ext4_cross_rename(old_dir, old_dentry,
 					 new_dir, new_dentry);
-- 
2.14.1.821.g8fa685d3b7-goog
