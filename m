Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 17/24] ubifs: switch to fscrypt ->symlink() helper functions
Date: Fri, 15 Dec 2017 09:42:18 -0800
Message-Id: <20171215174225.31583-18-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 55 ++++++++++++-------------------------------------------
 1 file changed, 12 insertions(+), 43 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index ef820f803176..518c10255881 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1149,38 +1149,24 @@ static int ubifs_symlink(struct inode *dir, struct dentry *dentry,
 	struct ubifs_info *c = dir->i_sb->s_fs_info;
 	int err, len = strlen(symname);
 	int sz_change = CALC_DENT_SIZE(len);
-	struct fscrypt_str disk_link = FSTR_INIT((char *)symname, len + 1);
-	struct fscrypt_symlink_data *sd = NULL;
+	struct fscrypt_str disk_link;
 	struct ubifs_budget_req req = { .new_ino = 1, .new_dent = 1,
 					.new_ino_d = ALIGN(len, 8),
 					.dirtied_ino = 1 };
 	struct fscrypt_name nm;
 
-	if (ubifs_crypt_is_encrypted(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err)
-			goto out_budg;
-
-		if (!fscrypt_has_encryption_key(dir)) {
-			err = -EPERM;
-			goto out_budg;
-		}
+	dbg_gen("dent '%pd', target '%s' in dir ino %lu", dentry,
+		symname, dir->i_ino);
 
-		disk_link.len = (fscrypt_fname_encrypted_size(dir, len) +
-				sizeof(struct fscrypt_symlink_data));
-	}
+	err = fscrypt_prepare_symlink(dir, symname, len, UBIFS_MAX_INO_DATA,
+				      &disk_link);
+	if (err)
+		return err;
 
 	/*
 	 * Budget request settings: new inode, new direntry and changing parent
 	 * directory inode.
 	 */
-
-	dbg_gen("dent '%pd', target '%s' in dir ino %lu", dentry,
-		symname, dir->i_ino);
-
-	if (disk_link.len > UBIFS_MAX_INO_DATA)
-		return -ENAMETOOLONG;
-
 	err = ubifs_budget_space(c, &req);
 	if (err)
 		return err;
@@ -1202,36 +1188,20 @@ static int ubifs_symlink(struct inode *dir, struct dentry *dentry,
 		goto out_inode;
 	}
 
-	if (ubifs_crypt_is_encrypted(dir)) {
-		struct qstr istr = QSTR_INIT(symname, len);
-		struct fscrypt_str ostr;
-
-		sd = kzalloc(disk_link.len, GFP_NOFS);
-		if (!sd) {
-			err = -ENOMEM;
-			goto out_inode;
-		}
-
-		ostr.name = sd->encrypted_path;
-		ostr.len = disk_link.len;
-
-		err = fscrypt_fname_usr_to_disk(inode, &istr, &ostr);
+	if (IS_ENCRYPTED(inode)) {
+		disk_link.name = ui->data; /* encrypt directly into ui->data */
+		err = fscrypt_encrypt_symlink(inode, symname, len, &disk_link);
 		if (err)
 			goto out_inode;
-
-		sd->len = cpu_to_le16(ostr.len);
-		disk_link.name = (char *)sd;
 	} else {
+		memcpy(ui->data, disk_link.name, disk_link.len);
 		inode->i_link = ui->data;
 	}
 
-	memcpy(ui->data, disk_link.name, disk_link.len);
-	((char *)ui->data)[disk_link.len - 1] = '\0';
-
 	/*
 	 * The terminating zero byte is not written to the flash media and it
 	 * is put just to make later in-memory string processing simpler. Thus,
-	 * data length is @len, not @len + %1.
+	 * data length is @disk_link.len - 1, not @disk_link.len.
 	 */
 	ui->data_len = disk_link.len - 1;
 	inode->i_size = ubifs_inode(inode)->ui_size = disk_link.len - 1;
@@ -1265,7 +1235,6 @@ static int ubifs_symlink(struct inode *dir, struct dentry *dentry,
 	fscrypt_free_filename(&nm);
 out_budg:
 	ubifs_release_budget(c, &req);
-	kfree(sd);
 	return err;
 }
 
-- 
2.15.1
