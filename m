Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Chandan Rajendra <chandan@linux.ibm.com>
Date: Mon, 18 Feb 2019 15:34:24 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Message-Id: <20190218100433.20048-2-chandan@linux.ibm.com>
Subject: [f2fs-dev] [RFC PATCH 01/10] ext4: use IS_ENCRYPTED() to check
 encryption status
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: tytso@mit.edu, ebiggers@kernel.org, Chandan Rajendra <chandan@linux.ibm.com>, adilger.kernel@dilger.ca, jaegeuk@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This commit removes the ext4 specific ext4_encrypted_inode() and makes
use of the generic IS_ENCRYPTED() macro to check for the encryption
status of an inode.

Reviewed-by: Eric Biggers <ebiggers@google.com>
Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/ext4/dir.c         |  8 ++++----
 fs/ext4/ext4.h        |  5 -----
 fs/ext4/ext4_jbd2.h   |  2 +-
 fs/ext4/extents.c     |  4 ++--
 fs/ext4/ialloc.c      |  2 +-
 fs/ext4/inode.c       | 16 +++++++---------
 fs/ext4/move_extent.c |  3 +--
 fs/ext4/namei.c       |  8 ++++----
 fs/ext4/page-io.c     |  3 +--
 fs/ext4/readpage.c    |  2 +-
 10 files changed, 22 insertions(+), 31 deletions(-)

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
index 5323ba097b03..216efeac53ea 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2286,11 +2286,6 @@ extern unsigned ext4_free_clusters_after_init(struct super_block *sb,
 					      struct ext4_group_desc *gdp);
 ext4_fsblk_t ext4_inode_to_goal_block(struct inode *);
 
-static inline bool ext4_encrypted_inode(struct inode *inode)
-{
-	return ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT);
-}
-
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
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
index 7ff14a1adba3..f3e17a8c84b4 100644
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
index 6c21df83425d..1dcf44a865cb 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -415,7 +415,7 @@ int ext4_issue_zeroout(struct inode *inode, ext4_lblk_t lblk, ext4_fsblk_t pblk,
 {
 	int ret;
 
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return fscrypt_zeroout_range(inode, lblk, pblk, len);
 
 	ret = sb_issue_zeroout(inode->i_sb, pblk, len, GFP_NOFS);
@@ -1217,8 +1217,7 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 		    (block_start < from || block_end > to)) {
 			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
 			*wait_bh++ = bh;
-			decrypt = ext4_encrypted_inode(inode) &&
-				S_ISREG(inode->i_mode);
+			decrypt = IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode);
 		}
 	}
 	/*
@@ -3881,7 +3880,7 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	ssize_t ret;
 
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		return 0;
 #endif
 
@@ -4068,8 +4067,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		/* Uhhuh. Read error. Complain and punt. */
 		if (!buffer_uptodate(bh))
 			goto unlock;
-		if (S_ISREG(inode->i_mode) &&
-		    ext4_encrypted_inode(inode)) {
+		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
 			BUG_ON(blocksize != PAGE_SIZE);
@@ -4145,7 +4143,7 @@ static int ext4_block_truncate_page(handle_t *handle,
 	struct inode *inode = mapping->host;
 
 	/* If we are processing an encrypted inode during orphan list handling */
-	if (ext4_encrypted_inode(inode) && !fscrypt_has_encryption_key(inode))
+	if (IS_ENCRYPTED(inode) && !fscrypt_has_encryption_key(inode))
 		return 0;
 
 	blocksize = inode->i_sb->s_blocksize;
@@ -4725,7 +4723,7 @@ static bool ext4_should_use_dax(struct inode *inode)
 		return false;
 	if (ext4_has_inline_data(inode))
 		return false;
-	if (ext4_encrypted_inode(inode))
+	if (ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT))
 		return false;
 	if (ext4_test_inode_flag(inode, EXT4_INODE_VERITY))
 		return false;
@@ -5079,7 +5077,7 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
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
index 2b928eb07fa2..be6cb69beb12 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -621,7 +621,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 
 				name  = de->name;
 				len = de->name_len;
-				if (ext4_encrypted_inode(dir))
+				if (IS_ENCRYPTED(dir))
 					res = fscrypt_get_encryption_info(dir);
 				if (res) {
 					printk(KERN_WARNING "Error setting up"
@@ -986,7 +986,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 					   EXT4_DIR_REC_LEN(0));
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 	/* Check if the directory is encrypted */
-	if (ext4_encrypted_inode(dir)) {
+	if (IS_ENCRYPTED(dir)) {
 		err = fscrypt_get_encryption_info(dir);
 		if (err < 0) {
 			brelse(bh);
@@ -1015,7 +1015,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 			continue;
 		if (de->inode == 0)
 			continue;
-		if (!ext4_encrypted_inode(dir)) {
+		if (!IS_ENCRYPTED(dir)) {
 			tmp_str.name = de->name;
 			tmp_str.len = de->name_len;
 			err = ext4_htree_store_dirent(dir_file,
@@ -1578,7 +1578,7 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
 					 ino);
 			return ERR_PTR(-EFSCORRUPTED);
 		}
-		if (!IS_ERR(inode) && ext4_encrypted_inode(dir) &&
+		if (!IS_ERR(inode) && IS_ENCRYPTED(dir) &&
 		    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
 		    !fscrypt_has_permitted_context(dir, inode)) {
 			ext4_warning(inode->i_sb,
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 2aa62d58d8dd..c398b55da854 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -477,8 +477,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	bh = head = page_buffers(page);
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
-	    nr_to_submit) {
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) && nr_to_submit) {
 		gfp_t gfp_flags = GFP_NOFS;
 
 	retry_encrypt:
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 6a163bfdc95d..92488df87135 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -156,7 +156,7 @@ static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 	unsigned int post_read_steps = 0;
 	struct bio_post_read_ctx *ctx = NULL;
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
 #ifdef CONFIG_FS_VERITY
 	if (inode->i_verity_info != NULL &&
-- 
2.19.1



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
