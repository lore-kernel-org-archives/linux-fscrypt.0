Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 12/24] ext4: switch to fscrypt ->symlink() helper functions
Date: Fri, 15 Dec 2017 09:42:13 -0800
Message-Id: <20171215174225.31583-13-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 58 +++++++++++++++------------------------------------------
 1 file changed, 15 insertions(+), 43 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 798b3ac680db..e291bb90a233 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -3052,39 +3052,19 @@ static int ext4_symlink(struct inode *dir,
 	struct inode *inode;
 	int err, len = strlen(symname);
 	int credits;
-	bool encryption_required;
 	struct fscrypt_str disk_link;
-	struct fscrypt_symlink_data *sd = NULL;
 
 	if (unlikely(ext4_forced_shutdown(EXT4_SB(dir->i_sb))))
 		return -EIO;
 
-	disk_link.len = len + 1;
-	disk_link.name = (char *) symname;
-
-	encryption_required = (ext4_encrypted_inode(dir) ||
-			       DUMMY_ENCRYPTION_ENABLED(EXT4_SB(dir->i_sb)));
-	if (encryption_required) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err)
-			return err;
-		if (!fscrypt_has_encryption_key(dir))
-			return -ENOKEY;
-		disk_link.len = (fscrypt_fname_encrypted_size(dir, len) +
-				 sizeof(struct fscrypt_symlink_data));
-		sd = kzalloc(disk_link.len, GFP_KERNEL);
-		if (!sd)
-			return -ENOMEM;
-	}
-
-	if (disk_link.len > dir->i_sb->s_blocksize) {
-		err = -ENAMETOOLONG;
-		goto err_free_sd;
-	}
+	err = fscrypt_prepare_symlink(dir, symname, len, dir->i_sb->s_blocksize,
+				      &disk_link);
+	if (err)
+		return err;
 
 	err = dquot_initialize(dir);
 	if (err)
-		goto err_free_sd;
+		return err;
 
 	if ((disk_link.len > EXT4_N_BLOCKS * 4)) {
 		/*
@@ -3113,27 +3093,18 @@ static int ext4_symlink(struct inode *dir,
 	if (IS_ERR(inode)) {
 		if (handle)
 			ext4_journal_stop(handle);
-		err = PTR_ERR(inode);
-		goto err_free_sd;
+		return PTR_ERR(inode);
 	}
 
-	if (encryption_required) {
-		struct qstr istr;
-		struct fscrypt_str ostr =
-			FSTR_INIT(sd->encrypted_path, disk_link.len);
-
-		istr.name = (const unsigned char *) symname;
-		istr.len = len;
-		err = fscrypt_fname_usr_to_disk(inode, &istr, &ostr);
+	if (IS_ENCRYPTED(inode)) {
+		err = fscrypt_encrypt_symlink(inode, symname, len, &disk_link);
 		if (err)
 			goto err_drop_inode;
-		sd->len = cpu_to_le16(ostr.len);
-		disk_link.name = (char *) sd;
 		inode->i_op = &ext4_encrypted_symlink_inode_operations;
 	}
 
 	if ((disk_link.len > EXT4_N_BLOCKS * 4)) {
-		if (!encryption_required)
+		if (!IS_ENCRYPTED(inode))
 			inode->i_op = &ext4_symlink_inode_operations;
 		inode_nohighmem(inode);
 		ext4_set_aops(inode);
@@ -3175,7 +3146,7 @@ static int ext4_symlink(struct inode *dir,
 	} else {
 		/* clear the extent format for fast symlink */
 		ext4_clear_inode_flag(inode, EXT4_INODE_EXTENTS);
-		if (!encryption_required) {
+		if (!IS_ENCRYPTED(inode)) {
 			inode->i_op = &ext4_fast_symlink_inode_operations;
 			inode->i_link = (char *)&EXT4_I(inode)->i_data;
 		}
@@ -3190,16 +3161,17 @@ static int ext4_symlink(struct inode *dir,
 
 	if (handle)
 		ext4_journal_stop(handle);
-	kfree(sd);
-	return err;
+	goto out_free_encrypted_link;
+
 err_drop_inode:
 	if (handle)
 		ext4_journal_stop(handle);
 	clear_nlink(inode);
 	unlock_new_inode(inode);
 	iput(inode);
-err_free_sd:
-	kfree(sd);
+out_free_encrypted_link:
+	if (disk_link.name != (unsigned char *)symname)
+		kfree(disk_link.name);
 	return err;
 }
 
-- 
2.15.1
