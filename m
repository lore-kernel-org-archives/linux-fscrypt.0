Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 14/24] f2fs: switch to fscrypt ->symlink() helper functions
Date: Fri, 15 Dec 2017 09:42:15 -0800
Message-Id: <20171215174225.31583-15-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 66 ++++++++++++++-------------------------------------------
 1 file changed, 16 insertions(+), 50 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 28bdf8828e73..5b114844806c 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -496,27 +496,16 @@ static int f2fs_symlink(struct inode *dir, struct dentry *dentry,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(dir);
 	struct inode *inode;
 	size_t len = strlen(symname);
-	struct fscrypt_str disk_link = FSTR_INIT((char *)symname, len + 1);
-	struct fscrypt_symlink_data *sd = NULL;
+	struct fscrypt_str disk_link;
 	int err;
 
 	if (unlikely(f2fs_cp_error(sbi)))
 		return -EIO;
 
-	if (f2fs_encrypted_inode(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err)
-			return err;
-
-		if (!fscrypt_has_encryption_key(dir))
-			return -ENOKEY;
-
-		disk_link.len = (fscrypt_fname_encrypted_size(dir, len) +
-				sizeof(struct fscrypt_symlink_data));
-	}
-
-	if (disk_link.len > dir->i_sb->s_blocksize)
-		return -ENAMETOOLONG;
+	err = fscrypt_prepare_symlink(dir, symname, len, dir->i_sb->s_blocksize,
+				      &disk_link);
+	if (err)
+		return err;
 
 	err = dquot_initialize(dir);
 	if (err)
@@ -526,7 +515,7 @@ static int f2fs_symlink(struct inode *dir, struct dentry *dentry,
 	if (IS_ERR(inode))
 		return PTR_ERR(inode);
 
-	if (f2fs_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		inode->i_op = &f2fs_encrypted_symlink_inode_operations;
 	else
 		inode->i_op = &f2fs_symlink_inode_operations;
@@ -536,38 +525,13 @@ static int f2fs_symlink(struct inode *dir, struct dentry *dentry,
 	f2fs_lock_op(sbi);
 	err = f2fs_add_link(dentry, inode);
 	if (err)
-		goto out;
+		goto out_handle_failed_inode;
 	f2fs_unlock_op(sbi);
 	alloc_nid_done(sbi, inode->i_ino);
 
-	if (f2fs_encrypted_inode(inode)) {
-		struct qstr istr = QSTR_INIT(symname, len);
-		struct fscrypt_str ostr;
-
-		sd = kzalloc(disk_link.len, GFP_NOFS);
-		if (!sd) {
-			err = -ENOMEM;
-			goto err_out;
-		}
-
-		err = fscrypt_get_encryption_info(inode);
-		if (err)
-			goto err_out;
-
-		if (!fscrypt_has_encryption_key(inode)) {
-			err = -ENOKEY;
-			goto err_out;
-		}
-
-		ostr.name = sd->encrypted_path;
-		ostr.len = disk_link.len;
-		err = fscrypt_fname_usr_to_disk(inode, &istr, &ostr);
-		if (err)
-			goto err_out;
-
-		sd->len = cpu_to_le16(ostr.len);
-		disk_link.name = (char *)sd;
-	}
+	err = fscrypt_encrypt_symlink(inode, symname, len, &disk_link);
+	if (err)
+		goto err_out;
 
 	err = page_symlink(inode, disk_link.name, disk_link.len);
 
@@ -594,12 +558,14 @@ static int f2fs_symlink(struct inode *dir, struct dentry *dentry,
 		f2fs_unlink(dir, dentry);
 	}
 
-	kfree(sd);
-
 	f2fs_balance_fs(sbi, true);
-	return err;
-out:
+	goto out_free_encrypted_link;
+
+out_handle_failed_inode:
 	handle_failed_inode(inode);
+out_free_encrypted_link:
+	if (disk_link.name != (unsigned char *)symname)
+		kfree(disk_link.name);
 	return err;
 }
 
-- 
2.15.1
