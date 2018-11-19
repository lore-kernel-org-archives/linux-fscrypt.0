Return-Path: <SRS0=2Xim=N6=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [PATCH 5/7] ext4: use IS_VERITY() to check inode's fsverity status
Date: Mon, 19 Nov 2018 10:53:22 +0530
In-Reply-To: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181119052324.31456-6-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers@kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

This commit now uses IS_VERITY() macro to check if fsverity is
enabled on an inode.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/ext4.h     |  9 ---------
 fs/ext4/file.c     |  2 +-
 fs/ext4/inode.c    | 10 ++++++----
 fs/ext4/readpage.c |  2 +-
 4 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index db21df885186..64bf9fb7ef18 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2296,15 +2296,6 @@ extern unsigned ext4_free_clusters_after_init(struct super_block *sb,
 					      struct ext4_group_desc *gdp);
 ext4_fsblk_t ext4_inode_to_goal_block(struct inode *);
 
-static inline bool ext4_verity_inode(struct inode *inode)
-{
-#ifdef CONFIG_EXT4_FS_VERITY
-	return ext4_test_inode_flag(inode, EXT4_INODE_VERITY);
-#else
-	return false;
-#endif
-}
-
 #ifdef CONFIG_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index cb4b69ef01a2..30fbd663354f 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -444,7 +444,7 @@ static int ext4_file_open(struct inode * inode, struct file * filp)
 	if (ret)
 		return ret;
 
-	if (ext4_verity_inode(inode)) {
+	if (IS_VERITY(inode)) {
 		ret = fsverity_file_open(inode, filp);
 		if (ret)
 			return ret;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index ae6794649817..3786740b73fa 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3884,7 +3884,7 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		return 0;
 #endif
 
-	if (ext4_verity_inode(inode))
+	if (IS_VERITY(inode))
 		return 0;
 
 	/*
@@ -4726,7 +4726,7 @@ static bool ext4_should_use_dax(struct inode *inode)
 		return false;
 	if (IS_ENCRYPTED(inode))
 		return false;
-	if (ext4_verity_inode(inode))
+	if (IS_VERITY(inode))
 		return false;
 	return true;
 }
@@ -4750,9 +4750,11 @@ void ext4_set_inode_flags(struct inode *inode)
 		new_fl |= S_DAX;
 	if (flags & EXT4_ENCRYPT_FL)
 		new_fl |= S_ENCRYPTED;
+	if (flags & EXT4_VERITY_FL)
+		new_fl |= S_VERITY;
 	inode_set_flags(inode, new_fl,
 			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX|
-			S_ENCRYPTED);
+			S_ENCRYPTED|S_VERITY);
 }
 
 static blkcnt_t ext4_inode_blocks(struct ext4_inode *raw_inode,
@@ -5510,7 +5512,7 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (error)
 		return error;
 
-	if (ext4_verity_inode(inode)) {
+	if (IS_VERITY(inode)) {
 		error = fsverity_prepare_setattr(dentry, attr);
 		if (error)
 			return error;
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 7252f0a60cdb..2c037df629dd 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -206,7 +206,7 @@ static void mpage_end_io(struct bio *bio)
 static inline loff_t ext4_readpage_limit(struct inode *inode)
 {
 #ifdef CONFIG_EXT4_FS_VERITY
-	if (ext4_verity_inode(inode)) {
+	if (IS_VERITY(inode)) {
 		if (inode->i_verity_info)
 			/* limit to end of metadata region */
 			return fsverity_full_i_size(inode);
-- 
2.19.1
