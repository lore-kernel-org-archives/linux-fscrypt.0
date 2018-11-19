Return-Path: <SRS0=2Xim=N6=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [PATCH 1/7] ext4: use IS_ENCRYPTED() to check encryption status
Date: Mon, 19 Nov 2018 10:53:18 +0530
In-Reply-To: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181119052324.31456-2-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers@kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

This commit removes the ext4 specific ext4_encrypted_inode() and makes
use of the generic IS_ENCRYPTED() macro to check for the encryption
status of an inode.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/dir.c         |  8 ++++----
 fs/ext4/ext4.h        |  5 -----
 fs/ext4/ext4_jbd2.h   |  2 +-
 fs/ext4/extents.c     |  4 ++--
 fs/ext4/ialloc.c      |  2 +-
 fs/ext4/inode.c       | 14 +++++++-------
 fs/ext4/move_extent.c |  3 +--
 fs/ext4/namei.c       |  8 ++++----
 fs/ext4/page-io.c     |  2 +-
 fs/ext4/readpage.c    |  2 +-
 10 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index f93f9881ec18..fb7a64ea5679 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -111,7 +111,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 	int dir_has_error = 0;
 	struct fscrypt_str fstr = FSTR_INIT(NULL, 0);
 
-	if (ext4_encrypted_inode(inode)) {
+	if (IS_ENCRYPTED(inode)) {
 		err = fscrypt_get_encryption_info(inode);
 		if (err && err != -ENOKEY)
 			return err;
@@ -138,7 +138,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 			return err;
 	}
 
-	if (ext4_encrypted_inode(inode)) {
+	if (IS_ENCRYPTED(inode)) {
 		err = fscrypt_fname_alloc_buffer(inode, EXT4_NAME_LEN, &fstr);
 		if (err < 0)
 			return err;
@@ -245,7 +245,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 			offset += ext4_rec_len_from_disk(de->rec_len,
 					sb->s_blocksize);
 			if (le32_to_cpu(de->inode)) {
-				if (!ext4_encrypted_inode(inode)) {
+				if (!IS_ENCRYPTED(inode)) {
 					if (!dir_emit(ctx, de->name,
 					    de->name_len,
 					    le32_to_cpu(de->inode),
@@ -613,7 +613,7 @@ static int ext4_dx_readdir(struct file *file, struct dir_context *ctx)
 
 static int ext4_dir_open(struct inode * inode, struct file * filp)
 {
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return fscrypt_get_encryption_info(inode) ? -EACCES : 0;
 	return 0;
 }
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 80957f9d3cbe..2ae6ab88f218 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2297,11 +2297,6 @@ extern unsigned ext4_free_clusters_after_init(struct super_block *sb,
 					      struct ext4_group_desc *gdp);
 ext4_fsblk_t ext4_inode_to_goal_block(struct inode *);
 
-static inline bool ext4_encrypted_inode(struct inode *inode)
-{
-	return ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT);
-}
-
 static inline bool ext4_verity_inode(struct inode *inode)
 {
 #ifdef CONFIG_EXT4_FS_VERITY
diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
index 15b6dd733780..a1ac7e9245ec 100644
--- a/fs/ext4/ext4_jbd2.h
+++ b/fs/ext4/ext4_jbd2.h
@@ -411,7 +411,7 @@ static inline int ext4_inode_journal_mode(struct inode *inode)
 	    (ext4_test_inode_flag(inode, EXT4_INODE_JOURNAL_DATA) &&
 	    !test_opt(inode->i_sb, DELALLOC))) {
 		/* We do not support data journalling for encrypted data */
-		if (S_ISREG(inode->i_mode) && ext4_encrypted_inode(inode))
+		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode))
 			return EXT4_INODE_ORDERED_DATA_MODE;  /* ordered */
 		return EXT4_INODE_JOURNAL_DATA_MODE;	/* journal data */
 	}
diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index 240b6dea5441..79d986dbf5af 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -3631,7 +3631,7 @@ static int ext4_ext_convert_to_initialized(handle_t *handle,
 		max_zeroout = sbi->s_extent_max_zeroout_kb >>
 			(inode->i_sb->s_blocksize_bits - 10);
 
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		max_zeroout = 0;
 
 	/*
@@ -4818,7 +4818,7 @@ long ext4_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	 * leave it disabled for encrypted inodes for now.  This is a
 	 * bug we should fix....
 	 */
-	if (ext4_encrypted_inode(inode) &&
+	if (IS_ENCRYPTED(inode) &&
 	    (mode & (FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_INSERT_RANGE |
 		     FALLOC_FL_ZERO_RANGE)))
 		return -EOPNOTSUPP;
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 2addcb8730e1..3002f110eb4f 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -771,7 +771,7 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
 	if (unlikely(ext4_forced_shutdown(sbi)))
 		return ERR_PTR(-EIO);
 
-	if ((ext4_encrypted_inode(dir) || DUMMY_ENCRYPTION_ENABLED(sbi)) &&
+	if ((IS_ENCRYPTED(dir) || DUMMY_ENCRYPTION_ENABLED(sbi)) &&
 	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) &&
 	    !(i_flags & EXT4_EA_INODE_FL)) {
 		err = fscrypt_get_encryption_info(dir);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d7019f5dca6f..725777772f32 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -415,7 +415,7 @@ int ext4_issue_zeroout(struct inode *inode, ext4_lblk_t lblk, ext4_fsblk_t pblk,
 {
 	int ret;
 
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return fscrypt_zeroout_range(inode, lblk, pblk, len);
 
 	ret = sb_issue_zeroout(inode->i_sb, pblk, len, GFP_NOFS);
@@ -1217,7 +1217,7 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 		    (block_start < from || block_end > to)) {
 			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
 			*wait_bh++ = bh;
-			decrypt = ext4_encrypted_inode(inode) &&
+			decrypt = IS_ENCRYPTED(inode) &&
 				S_ISREG(inode->i_mode);
 		}
 	}
@@ -3880,7 +3880,7 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	ssize_t ret;
 
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		return 0;
 #endif
 
@@ -4068,7 +4068,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		if (!buffer_uptodate(bh))
 			goto unlock;
 		if (S_ISREG(inode->i_mode) &&
-		    ext4_encrypted_inode(inode)) {
+		    IS_ENCRYPTED(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
 			BUG_ON(blocksize != PAGE_SIZE);
@@ -4144,7 +4144,7 @@ static int ext4_block_truncate_page(handle_t *handle,
 	struct inode *inode = mapping->host;
 
 	/* If we are processing an encrypted inode during orphan list handling */
-	if (ext4_encrypted_inode(inode) && !fscrypt_has_encryption_key(inode))
+	if (IS_ENCRYPTED(inode) && !fscrypt_has_encryption_key(inode))
 		return 0;
 
 	blocksize = inode->i_sb->s_blocksize;
@@ -4724,7 +4724,7 @@ static bool ext4_should_use_dax(struct inode *inode)
 		return false;
 	if (ext4_has_inline_data(inode))
 		return false;
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return false;
 	if (ext4_verity_inode(inode))
 		return false;
@@ -5050,7 +5050,7 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 			ret = -EFSCORRUPTED;
 			goto bad_inode;
 		}
-		if (ext4_encrypted_inode(inode)) {
+		if (IS_ENCRYPTED(inode)) {
 			inode->i_op = &ext4_encrypted_symlink_inode_operations;
 			ext4_set_aops(inode);
 		} else if (ext4_inode_is_fast_symlink(inode)) {
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 2f5be02fc6f6..1083a9f3f16a 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -592,8 +592,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 		return -EOPNOTSUPP;
 	}
 
-	if (ext4_encrypted_inode(orig_inode) ||
-	    ext4_encrypted_inode(donor_inode)) {
+	if (IS_ENCRYPTED(orig_inode) || IS_ENCRYPTED(donor_inode)) {
 		ext4_msg(orig_inode->i_sb, KERN_ERR,
 			 "Online defrag not supported for encrypted files");
 		return -EOPNOTSUPP;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 67a38532032a..0de60207a963 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -620,7 +620,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 
 				name  = de->name;
 				len = de->name_len;
-				if (ext4_encrypted_inode(dir))
+				if (IS_ENCRYPTED(dir))
 					res = fscrypt_get_encryption_info(dir);
 				if (res) {
 					printk(KERN_WARNING "Error setting up"
@@ -985,7 +985,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 					   EXT4_DIR_REC_LEN(0));
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 	/* Check if the directory is encrypted */
-	if (ext4_encrypted_inode(dir)) {
+	if (IS_ENCRYPTED(dir)) {
 		err = fscrypt_get_encryption_info(dir);
 		if (err < 0) {
 			brelse(bh);
@@ -1014,7 +1014,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 			continue;
 		if (de->inode == 0)
 			continue;
-		if (!ext4_encrypted_inode(dir)) {
+		if (!IS_ENCRYPTED(dir)) {
 			tmp_str.name = de->name;
 			tmp_str.len = de->name_len;
 			err = ext4_htree_store_dirent(dir_file,
@@ -1577,7 +1577,7 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
 					 ino);
 			return ERR_PTR(-EFSCORRUPTED);
 		}
-		if (!IS_ERR(inode) && ext4_encrypted_inode(dir) &&
+		if (!IS_ERR(inode) && IS_ENCRYPTED(dir) &&
 		    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
 		    !fscrypt_has_permitted_context(dir, inode)) {
 			ext4_warning(inode->i_sb,
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 2aa62d58d8dd..008c20b58f98 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -477,7 +477,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	bh = head = page_buffers(page);
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) &&
 	    nr_to_submit) {
 		gfp_t gfp_flags = GFP_NOFS;
 
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index d3dd1ff745db..45e707fb9749 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -156,7 +156,7 @@ static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 	unsigned int post_read_steps = 0;
 	struct bio_post_read_ctx *ctx = NULL;
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
 #ifdef CONFIG_EXT4_FS_VERITY
 	if (inode->i_verity_info != NULL &&
-- 
2.19.1
