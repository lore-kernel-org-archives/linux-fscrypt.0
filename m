Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([85.220.165.71]:36157 "EHLO
        metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730422AbfCZHwo (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 26 Mar 2019 03:52:44 -0400
From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 2/2] ubifs: Remove ifdefs around CONFIG_UBIFS_ATIME_SUPPORT
Date: Tue, 26 Mar 2019 08:52:32 +0100
Message-Id: <20190326075232.11717-3-s.hauer@pengutronix.de>
In-Reply-To: <20190326075232.11717-1-s.hauer@pengutronix.de>
References: <20190326075232.11717-1-s.hauer@pengutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: Richard Weinberger <richard@nod.at>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, kernel@pengutronix.de, Sascha Hauer <s.hauer@pengutronix.de>
List-ID: <linux-fscrypt@vger.kernel.org>

ifdefs reduce readability and compile coverage. This removes the ifdefs
around CONFIG_UBIFS_ATIME_SUPPORT by replacing them with IS_ENABLED()
where applicable. The fs layer would fall back to generic_update_time()
when .update_time doesn't exist. We do this fallback explicitly now.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 fs/ubifs/dir.c   |  2 --
 fs/ubifs/file.c  | 16 +++++++---------
 fs/ubifs/super.c | 16 ++++++++--------
 fs/ubifs/ubifs.h |  2 --
 4 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 5767b373a8ff..cb286fd075fc 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1652,9 +1652,7 @@ const struct inode_operations ubifs_dir_inode_operations = {
 #ifdef CONFIG_UBIFS_FS_XATTR
 	.listxattr   = ubifs_listxattr,
 #endif
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
 	.update_time = ubifs_update_time,
-#endif
 	.tmpfile     = ubifs_tmpfile,
 };
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 5d2ffb1a45fc..512e7d9c60cd 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1375,7 +1375,6 @@ static inline int mctime_update_needed(const struct inode *inode,
 	return 0;
 }
 
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
 /**
  * ubifs_update_time - update time of inode.
  * @inode: inode to update
@@ -1392,6 +1391,9 @@ int ubifs_update_time(struct inode *inode, struct timespec64 *time,
 	int iflags = I_DIRTY_TIME;
 	int err, release;
 
+	if (!IS_ENABLED(CONFIG_UBIFS_ATIME_SUPPORT))
+		return generic_update_time(inode, time, flags);
+
 	err = ubifs_budget_space(c, &req);
 	if (err)
 		return err;
@@ -1414,7 +1416,6 @@ int ubifs_update_time(struct inode *inode, struct timespec64 *time,
 		ubifs_release_budget(c, &req);
 	return 0;
 }
-#endif
 
 /**
  * update_mctime - update mtime and ctime of an inode.
@@ -1623,9 +1624,10 @@ static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	if (err)
 		return err;
 	vma->vm_ops = &ubifs_file_vm_ops;
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
-	file_accessed(file);
-#endif
+
+	if (IS_ENABLED(CONFIG_UBIFS_ATIME_SUPPORT))
+		file_accessed(file);
+
 	return 0;
 }
 
@@ -1663,9 +1665,7 @@ const struct inode_operations ubifs_file_inode_operations = {
 #ifdef CONFIG_UBIFS_FS_XATTR
 	.listxattr   = ubifs_listxattr,
 #endif
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
 	.update_time = ubifs_update_time,
-#endif
 };
 
 const struct inode_operations ubifs_symlink_inode_operations = {
@@ -1675,9 +1675,7 @@ const struct inode_operations ubifs_symlink_inode_operations = {
 #ifdef CONFIG_UBIFS_FS_XATTR
 	.listxattr   = ubifs_listxattr,
 #endif
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
 	.update_time = ubifs_update_time,
-#endif
 };
 
 const struct file_operations ubifs_file_operations = {
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index e6da7fc0e2a4..2c647d66e48e 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -129,9 +129,10 @@ struct inode *ubifs_iget(struct super_block *sb, unsigned long inum)
 		goto out_ino;
 
 	inode->i_flags |= S_NOCMTIME;
-#ifndef CONFIG_UBIFS_ATIME_SUPPORT
-	inode->i_flags |= S_NOATIME;
-#endif
+
+	if (!IS_ENABLED(CONFIG_UBIFS_ATIME_SUPPORT))
+		inode->i_flags |= S_NOATIME;
+
 	set_nlink(inode, le32_to_cpu(ino->nlink));
 	i_uid_write(inode, le32_to_cpu(ino->uid));
 	i_gid_write(inode, le32_to_cpu(ino->gid));
@@ -2248,11 +2249,10 @@ static struct dentry *ubifs_mount(struct file_system_type *fs_type, int flags,
 			goto out_deact;
 		/* We do not support atime */
 		sb->s_flags |= SB_ACTIVE;
-#ifndef CONFIG_UBIFS_ATIME_SUPPORT
-		sb->s_flags |= SB_NOATIME;
-#else
-		ubifs_msg(c, "full atime support is enabled.");
-#endif
+		if (IS_ENABLED(CONFIG_UBIFS_ATIME_SUPPORT))
+			ubifs_msg(c, "full atime support is enabled.");
+		else
+			sb->s_flags |= SB_NOATIME;
 	}
 
 	/* 'fill_super()' opens ubi again so we must close it here */
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 1ae12900e01d..69dfd64d3d00 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1996,9 +1996,7 @@ int ubifs_calc_dark(const struct ubifs_info *c, int spc);
 /* file.c */
 int ubifs_fsync(struct file *file, loff_t start, loff_t end, int datasync);
 int ubifs_setattr(struct dentry *dentry, struct iattr *attr);
-#ifdef CONFIG_UBIFS_ATIME_SUPPORT
 int ubifs_update_time(struct inode *inode, struct timespec64 *time, int flags);
-#endif
 
 /* dir.c */
 struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
-- 
2.20.1
