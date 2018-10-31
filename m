Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/2] fscrypt: Remove filesystem specific build config option
Date: Wed, 31 Oct 2018 10:30:04 +0530
Message-Id: <20181031050005.17770-1-chandan@linux.vnet.ibm.com>
To: tytso@mit.edu, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

As a first step to avoid copy-pasting common code across filesystems
which implement fscrypt, this commit removes filesystem specific build
config option (e.g. CONFIG_EXT4_FS_ENCRYPTION) and replaces it with a
build option (i.e. CONFIG_FS_ENCRYPTION) whose value affects all the
filesystems making use of fscrypt.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
PS: Similar changes are required for F2FS and I will be addressing them in the
next version of this patchset.

The patches are based on Eric Biggers' FS verity patchset. The git
tree can found at
"https://github.com/chandanr/linux.git common-build-config".

 fs/crypto/Kconfig               |   2 +-
 fs/ext4/Kconfig                 |  15 --
 fs/ext4/dir.c                   |  10 +-
 fs/ext4/ext4.h                  |  12 +-
 fs/ext4/ext4_jbd2.h             |   2 +-
 fs/ext4/extents.c               |   4 +-
 fs/ext4/ialloc.c                |   2 +-
 fs/ext4/inode.c                 |  22 +--
 fs/ext4/move_extent.c           |   3 +-
 fs/ext4/namei.c                 |  18 +-
 fs/ext4/page-io.c               |   8 +-
 fs/ext4/readpage.c              |   8 +-
 fs/ext4/super.c                 |   6 +-
 fs/ext4/sysfs.c                 |   4 +-
 include/linux/fscrypt.h         | 416 +++++++++++++++++++++++++++++++++++++++-
 include/linux/fscrypt_notsupp.h | 231 ----------------------
 include/linux/fscrypt_supp.h    | 204 --------------------
 17 files changed, 454 insertions(+), 513 deletions(-)
 delete mode 100644 include/linux/fscrypt_notsupp.h
 delete mode 100644 include/linux/fscrypt_supp.h

diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index 02b7d91..6e9ae56 100644
--- a/fs/crypto/Kconfig
+++ b/fs/crypto/Kconfig
@@ -1,5 +1,5 @@
 config FS_ENCRYPTION
-	tristate "FS Encryption (Per-file encryption)"
+	bool "FS Encryption (Per-file encryption)"
 	select CRYPTO
 	select CRYPTO_AES
 	select CRYPTO_CBC
diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index 5a76125..e1002bb 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -96,21 +96,6 @@ config EXT4_FS_SECURITY
 	  If you are not using a security module that requires using
 	  extended attributes for file security labels, say N.
 
-config EXT4_ENCRYPTION
-	bool "Ext4 Encryption"
-	depends on EXT4_FS
-	select FS_ENCRYPTION
-	help
-	  Enable encryption of ext4 files and directories.  This
-	  feature is similar to ecryptfs, but it is more memory
-	  efficient since it avoids caching the encrypted and
-	  decrypted pages in the page cache.
-
-config EXT4_FS_ENCRYPTION
-	bool
-	default y
-	depends on EXT4_ENCRYPTION
-
 config EXT4_FS_VERITY
 	bool "Ext4 Verity"
 	depends on EXT4_FS
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index e2902d3..98630390 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -113,7 +113,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 	int dir_has_error = 0;
 	struct fscrypt_str fstr = FSTR_INIT(NULL, 0);
 
-	if (ext4_encrypted_inode(inode)) {
+	if (IS_ENCRYPTED(inode)) {
 		err = fscrypt_get_encryption_info(inode);
 		if (err && err != -ENOKEY)
 			return err;
@@ -140,7 +140,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 			return err;
 	}
 
-	if (ext4_encrypted_inode(inode)) {
+	if (IS_ENCRYPTED(inode)) {
 		err = fscrypt_fname_alloc_buffer(inode, EXT4_NAME_LEN, &fstr);
 		if (err < 0)
 			return err;
@@ -247,7 +247,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 			offset += ext4_rec_len_from_disk(de->rec_len,
 					sb->s_blocksize);
 			if (le32_to_cpu(de->inode)) {
-				if (!ext4_encrypted_inode(inode)) {
+				if (!IS_ENCRYPTED(inode)) {
 					if (!dir_emit(ctx, de->name,
 					    de->name_len,
 					    le32_to_cpu(de->inode),
@@ -285,9 +285,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 done:
 	err = 0;
 errout:
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
 	fscrypt_fname_free_buffer(&fstr);
-#endif
 	brelse(bh);
 	return err;
 }
@@ -615,7 +613,7 @@ static int ext4_dx_readdir(struct file *file, struct dir_context *ctx)
 
 static int ext4_dir_open(struct inode * inode, struct file * filp)
 {
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return fscrypt_get_encryption_info(inode) ? -EACCES : 0;
 	return 0;
 }
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index f8db4b8..8858a80 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -40,7 +40,6 @@
 #include <linux/compat.h>
 #endif
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
 #define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
@@ -1320,7 +1319,7 @@ struct ext4_super_block {
 #define EXT4_MF_FS_ABORTED		0x0002	/* Fatal error detected */
 #define EXT4_MF_TEST_DUMMY_ENCRYPTION	0x0004
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define DUMMY_ENCRYPTION_ENABLED(sbi) (unlikely((sbi)->s_mount_flags & \
 						EXT4_MF_TEST_DUMMY_ENCRYPTION))
 #else
@@ -2047,7 +2046,7 @@ struct ext4_filename {
 	const struct qstr *usr_fname;
 	struct fscrypt_str disk_name;
 	struct dx_hash_info hinfo;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	struct fscrypt_str crypto_buf;
 #endif
 };
@@ -2275,11 +2274,6 @@ extern unsigned ext4_free_clusters_after_init(struct super_block *sb,
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
@@ -2289,7 +2283,7 @@ static inline bool ext4_verity_inode(struct inode *inode)
 #endif
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
 			int lookup, struct ext4_filename *fname)
diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
index 15b6dd7..a1ac7e9 100644
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
index 8ce6fd5..96f79e5 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -3569,7 +3569,7 @@ static int ext4_ext_convert_to_initialized(handle_t *handle,
 		max_zeroout = sbi->s_extent_max_zeroout_kb >>
 			(inode->i_sb->s_blocksize_bits - 10);
 
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		max_zeroout = 0;
 
 	/*
@@ -4912,7 +4912,7 @@ long ext4_fallocate(struct file *file, int mode, loff_t offset, loff_t len)
 	 * leave it disabled for encrypted inodes for now.  This is a
 	 * bug we should fix....
 	 */
-	if (ext4_encrypted_inode(inode) &&
+	if (IS_ENCRYPTED(inode) &&
 	    (mode & (FALLOC_FL_COLLAPSE_RANGE | FALLOC_FL_INSERT_RANGE |
 		     FALLOC_FL_ZERO_RANGE)))
 		return -EOPNOTSUPP;
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index f336cbc6..07e4c78 100644
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
index cbee798..f9b9dd6 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -415,7 +415,7 @@ int ext4_issue_zeroout(struct inode *inode, ext4_lblk_t lblk, ext4_fsblk_t pblk,
 {
 	int ret;
 
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return fscrypt_zeroout_range(inode, lblk, pblk, len);
 
 	ret = sb_issue_zeroout(inode->i_sb, pblk, len, GFP_NOFS);
@@ -1150,7 +1150,7 @@ int do_journal_get_write_access(handle_t *handle,
 	return ret;
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				  get_block_t *get_block)
 {
@@ -1217,7 +1217,7 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 		    (block_start < from || block_end > to)) {
 			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
 			*wait_bh++ = bh;
-			decrypt = ext4_encrypted_inode(inode) &&
+			decrypt = IS_ENCRYPTED(inode) &&
 				S_ISREG(inode->i_mode);
 		}
 	}
@@ -1303,7 +1303,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	/* In case writeback began while the page was unlocked */
 	wait_for_stable_page(page);
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	if (ext4_should_dioread_nolock(inode))
 		ret = ext4_block_write_begin(page, pos, len,
 					     ext4_get_block_unwritten);
@@ -3074,7 +3074,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	/* In case writeback began while the page was unlocked */
 	wait_for_stable_page(page);
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ret = ext4_block_write_begin(page, pos, len,
 				     ext4_da_get_block_prep);
 #else
@@ -3843,8 +3843,8 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t offset = iocb->ki_pos;
 	ssize_t ret;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+#ifdef CONFIG_FS_ENCRYPTION
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		return 0;
 #endif
 
@@ -4031,7 +4031,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		if (!buffer_uptodate(bh))
 			goto unlock;
 		if (S_ISREG(inode->i_mode) &&
-		    ext4_encrypted_inode(inode)) {
+		    IS_ENCRYPTED(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
 			BUG_ON(blocksize != PAGE_SIZE);
@@ -4107,7 +4107,7 @@ static int ext4_block_truncate_page(handle_t *handle,
 	struct inode *inode = mapping->host;
 
 	/* If we are processing an encrypted inode during orphan list handling */
-	if (ext4_encrypted_inode(inode) && !fscrypt_has_encryption_key(inode))
+	if (IS_ENCRYPTED(inode) && !fscrypt_has_encryption_key(inode))
 		return 0;
 
 	blocksize = inode->i_sb->s_blocksize;
@@ -4652,7 +4652,7 @@ static bool ext4_should_use_dax(struct inode *inode)
 		return false;
 	if (ext4_has_inline_data(inode))
 		return false;
-	if (ext4_encrypted_inode(inode))
+	if (IS_ENCRYPTED(inode))
 		return false;
 	if (ext4_verity_inode(inode))
 		return false;
@@ -4980,7 +4980,7 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 			ret = -EFSCORRUPTED;
 			goto bad_inode;
 		}
-		if (ext4_encrypted_inode(inode)) {
+		if (IS_ENCRYPTED(inode)) {
 			inode->i_op = &ext4_encrypted_symlink_inode_operations;
 			ext4_set_aops(inode);
 		} else if (ext4_inode_is_fast_symlink(inode)) {
diff --git a/fs/ext4/move_extent.c b/fs/ext4/move_extent.c
index 8e17efd..86a75ee 100644
--- a/fs/ext4/move_extent.c
+++ b/fs/ext4/move_extent.c
@@ -590,8 +590,7 @@ ext4_move_extents(struct file *o_filp, struct file *d_filp, __u64 orig_blk,
 		return -EOPNOTSUPP;
 	}
 
-	if (ext4_encrypted_inode(orig_inode) ||
-	    ext4_encrypted_inode(donor_inode)) {
+	if (IS_ENCRYPTED(orig_inode) || IS_ENCRYPTED(donor_inode)) {
 		ext4_msg(orig_inode->i_sb, KERN_ERR,
 			 "Online defrag not supported for encrypted files");
 		return -EOPNOTSUPP;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 2a4c25c..dbfbaf6 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -611,7 +611,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 		{
 			if (show_names)
 			{
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 				int len;
 				char *name;
 				struct fscrypt_str fname_crypto_str =
@@ -620,7 +620,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 
 				name  = de->name;
 				len = de->name_len;
-				if (ext4_encrypted_inode(dir))
+				if (IS_ENCRYPTED(dir))
 					res = fscrypt_get_encryption_info(dir);
 				if (res) {
 					printk(KERN_WARNING "Error setting up"
@@ -983,9 +983,9 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	top = (struct ext4_dir_entry_2 *) ((char *) de +
 					   dir->i_sb->s_blocksize -
 					   EXT4_DIR_REC_LEN(0));
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
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
@@ -1046,7 +1046,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	}
 errout:
 	brelse(bh);
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	fscrypt_fname_free_buffer(&fname_crypto_str);
 #endif
 	return count;
@@ -1266,7 +1266,7 @@ static inline bool ext4_match(const struct ext4_filename *fname,
 
 	f.usr_fname = fname->usr_fname;
 	f.disk_name = fname->disk_name;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	f.crypto_buf = fname->crypto_buf;
 #endif
 	return fscrypt_match_name(&f, de->name, de->name_len);
@@ -1496,7 +1496,7 @@ static struct buffer_head * ext4_dx_find_entry(struct inode *dir,
 	ext4_lblk_t block;
 	int retval;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	*res_dir = NULL;
 #endif
 	frame = dx_probe(fname, dir, NULL, frames);
@@ -1576,7 +1576,7 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
 					 ino);
 			return ERR_PTR(-EFSCORRUPTED);
 		}
-		if (!IS_ERR(inode) && ext4_encrypted_inode(dir) &&
+		if (!IS_ERR(inode) && IS_ENCRYPTED(dir) &&
 		    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
 		    !fscrypt_has_permitted_context(dir, inode)) {
 			ext4_warning(inode->i_sb,
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index db75901..dfbb65b 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -66,7 +66,7 @@ static void ext4_finish_bio(struct bio *bio)
 
 	bio_for_each_segment_all(bvec, bio, i) {
 		struct page *page = bvec->bv_page;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		struct page *data_page = NULL;
 #endif
 		struct buffer_head *bh, *head;
@@ -78,7 +78,7 @@ static void ext4_finish_bio(struct bio *bio)
 		if (!page)
 			continue;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		if (!page->mapping) {
 			/* The bounce data pages are unmapped. */
 			data_page = page;
@@ -111,7 +111,7 @@ static void ext4_finish_bio(struct bio *bio)
 		bit_spin_unlock(BH_Uptodate_Lock, &head->b_state);
 		local_irq_restore(flags);
 		if (!under_io) {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 			if (data_page)
 				fscrypt_restore_control_page(data_page);
 #endif
@@ -477,7 +477,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	bh = head = page_buffers(page);
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) &&
 	    nr_to_submit) {
 		gfp_t gfp_flags = GFP_NOFS;
 
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 7750e22..6b987abd 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -54,7 +54,7 @@ static mempool_t *bio_post_read_ctx_pool;
 
 static inline bool ext4_bio_encrypted(struct bio *bio)
 {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	return unlikely(bio->bi_private != NULL);
 #else
 	return false;
@@ -156,9 +156,9 @@ static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 	unsigned int post_read_steps = 0;
 	struct bio_post_read_ctx *ctx = NULL;
 
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 	if (inode->i_verity_info != NULL &&
 	    (index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
 		post_read_steps |= 1 << STEP_VERITY;
@@ -205,7 +205,7 @@ static void mpage_end_io(struct bio *bio)
 
 static inline loff_t ext4_readpage_limit(struct inode *inode)
 {
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 	if (ext4_verity_inode(inode)) {
 		if (inode->i_verity_info)
 			/* limit to end of metadata region */
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 0a17f7c..059fab2 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1178,7 +1178,7 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
 	return try_to_free_buffers(page);
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int ext4_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	return ext4_xattr_get(inode, EXT4_XATTR_INDEX_ENCRYPTION,
@@ -1944,7 +1944,7 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		*journal_ioprio =
 			IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, arg);
 	} else if (token == Opt_test_dummy_encryption) {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		sbi->s_mount_flags |= EXT4_MF_TEST_DUMMY_ENCRYPTION;
 		ext4_msg(sb, KERN_WARNING,
 			 "Test dummy encryption mode enabled");
@@ -4179,7 +4179,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &ext4_sops;
 	sb->s_export_op = &ext4_export_ops;
 	sb->s_xattr = ext4_xattr_handlers;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 3f31753..d7f5d18 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -220,7 +220,7 @@ static struct attribute *ext4_attrs[] = {
 EXT4_ATTR_FEATURE(lazy_itable_init);
 EXT4_ATTR_FEATURE(batched_discard);
 EXT4_ATTR_FEATURE(meta_bg_resize);
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 EXT4_ATTR_FEATURE(encryption);
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
@@ -232,7 +232,7 @@ static struct attribute *ext4_feat_attrs[] = {
 	ATTR_LIST(lazy_itable_init),
 	ATTR_LIST(batched_discard),
 	ATTR_LIST(meta_bg_resize),
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 952ab97..6ba193c 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -2,9 +2,8 @@
 /*
  * fscrypt.h: declarations for per-file encryption
  *
- * Filesystems that implement per-file encryption include this header
- * file with the __FS_HAS_ENCRYPTION set according to whether that filesystem
- * is being built with encryption support or not.
+ * Filesystems that implement per-file encryption must include this header
+ * file.
  *
  * Copyright (C) 2015, Google, Inc.
  *
@@ -15,6 +14,8 @@
 #define _LINUX_FSCRYPT_H
 
 #include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
 
 #define FS_CRYPTO_BLOCK_SIZE		16
 
@@ -42,11 +43,410 @@ struct fscrypt_name {
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
 #define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
 
-#if __FS_HAS_ENCRYPTION
-#include <linux/fscrypt_supp.h>
-#else
-#include <linux/fscrypt_notsupp.h>
-#endif
+#ifdef CONFIG_FS_ENCRYPTION
+/*
+ * fscrypt superblock flags
+ */
+#define FS_CFLG_OWN_PAGES (1U << 1)
+
+/*
+ * crypto operations for filesystems
+ */
+struct fscrypt_operations {
+	unsigned int flags;
+	const char *key_prefix;
+	int (*get_context)(struct inode *, void *, size_t);
+	int (*set_context)(struct inode *, const void *, size_t, void *);
+	bool (*dummy_context)(struct inode *);
+	bool (*empty_dir)(struct inode *);
+	unsigned int max_namelen;
+};
+
+struct fscrypt_ctx {
+	union {
+		struct {
+			struct page *bounce_page;	/* Ciphertext page */
+			struct page *control_page;	/* Original page  */
+		} w;
+		struct {
+			struct bio *bio;
+			struct work_struct work;
+		} r;
+		struct list_head free_list;	/* Free list */
+	};
+	u8 flags;				/* Flags */
+};
+
+static inline bool fscrypt_has_encryption_key(const struct inode *inode)
+{
+	return (inode->i_crypt_info != NULL);
+}
+
+static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
+{
+	return inode->i_sb->s_cop->dummy_context &&
+		inode->i_sb->s_cop->dummy_context(inode);
+}
+
+/* crypto.c */
+extern void fscrypt_enqueue_decrypt_work(struct work_struct *);
+extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
+extern void fscrypt_release_ctx(struct fscrypt_ctx *);
+extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
+						unsigned int, unsigned int,
+						u64, gfp_t);
+extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
+				unsigned int, u64);
+
+static inline struct page *fscrypt_control_page(struct page *page)
+{
+	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
+}
+
+extern void fscrypt_restore_control_page(struct page *);
+
+/* policy.c */
+extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
+extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
+extern int fscrypt_has_permitted_context(struct inode *, struct inode *);
+extern int fscrypt_inherit_context(struct inode *, struct inode *,
+					void *, bool);
+/* keyinfo.c */
+extern int fscrypt_get_encryption_info(struct inode *);
+extern void fscrypt_put_encryption_info(struct inode *);
+
+/* fname.c */
+extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
+				int lookup, struct fscrypt_name *);
+
+static inline void fscrypt_free_filename(struct fscrypt_name *fname)
+{
+	kfree(fname->crypto_buf.name);
+}
+
+extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
+				struct fscrypt_str *);
+extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
+extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
+			const struct fscrypt_str *, struct fscrypt_str *);
+
+#define FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE	32
+
+/* Extracts the second-to-last ciphertext block; see explanation below */
+#define FSCRYPT_FNAME_DIGEST(name, len)	\
+	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1, \
+			     FS_CRYPTO_BLOCK_SIZE))
+
+#define FSCRYPT_FNAME_DIGEST_SIZE	FS_CRYPTO_BLOCK_SIZE
+
+/**
+ * fscrypt_digested_name - alternate identifier for an on-disk filename
+ *
+ * When userspace lists an encrypted directory without access to the key,
+ * filenames whose ciphertext is longer than FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE
+ * bytes are shown in this abbreviated form (base64-encoded) rather than as the
+ * full ciphertext (base64-encoded).  This is necessary to allow supporting
+ * filenames up to NAME_MAX bytes, since base64 encoding expands the length.
+ *
+ * To make it possible for filesystems to still find the correct directory entry
+ * despite not knowing the full on-disk name, we encode any filesystem-specific
+ * 'hash' and/or 'minor_hash' which the filesystem may need for its lookups,
+ * followed by the second-to-last ciphertext block of the filename.  Due to the
+ * use of the CBC-CTS encryption mode, the second-to-last ciphertext block
+ * depends on the full plaintext.  (Note that ciphertext stealing causes the
+ * last two blocks to appear "flipped".)  This makes accidental collisions very
+ * unlikely: just a 1 in 2^128 chance for two filenames to collide even if they
+ * share the same filesystem-specific hashes.
+ *
+ * However, this scheme isn't immune to intentional collisions, which can be
+ * created by anyone able to create arbitrary plaintext filenames and view them
+ * without the key.  Making the "digest" be a real cryptographic hash like
+ * SHA-256 over the full ciphertext would prevent this, although it would be
+ * less efficient and harder to implement, especially since the filesystem would
+ * need to calculate it for each directory entry examined during a search.
+ */
+struct fscrypt_digested_name {
+	u32 hash;
+	u32 minor_hash;
+	u8 digest[FSCRYPT_FNAME_DIGEST_SIZE];
+};
+
+/**
+ * fscrypt_match_name() - test whether the given name matches a directory entry
+ * @fname: the name being searched for
+ * @de_name: the name from the directory entry
+ * @de_name_len: the length of @de_name in bytes
+ *
+ * Normally @fname->disk_name will be set, and in that case we simply compare
+ * that to the name stored in the directory entry.  The only exception is that
+ * if we don't have the key for an encrypted directory and a filename in it is
+ * very long, then we won't have the full disk_name and we'll instead need to
+ * match against the fscrypt_digested_name.
+ *
+ * Return: %true if the name matches, otherwise %false.
+ */
+static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
+				      const u8 *de_name, u32 de_name_len)
+{
+	if (unlikely(!fname->disk_name.name)) {
+		const struct fscrypt_digested_name *n =
+			(const void *)fname->crypto_buf.name;
+		if (WARN_ON_ONCE(fname->usr_fname->name[0] != '_'))
+			return false;
+		if (de_name_len <= FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE)
+			return false;
+		return !memcmp(FSCRYPT_FNAME_DIGEST(de_name, de_name_len),
+			       n->digest, FSCRYPT_FNAME_DIGEST_SIZE);
+	}
+
+	if (de_name_len != fname->disk_name.len)
+		return false;
+	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
+}
+
+/* bio.c */
+extern void fscrypt_decrypt_bio(struct bio *);
+extern void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
+					struct bio *bio);
+extern void fscrypt_pullback_bio_page(struct page **, bool);
+extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
+				 unsigned int);
+
+/* hooks.c */
+extern int fscrypt_file_open(struct inode *inode, struct file *filp);
+extern int __fscrypt_prepare_link(struct inode *inode, struct inode *dir);
+extern int __fscrypt_prepare_rename(struct inode *old_dir,
+				    struct dentry *old_dentry,
+				    struct inode *new_dir,
+				    struct dentry *new_dentry,
+				    unsigned int flags);
+extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
+extern int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
+				     unsigned int max_len,
+				     struct fscrypt_str *disk_link);
+extern int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
+				     unsigned int len,
+				     struct fscrypt_str *disk_link);
+extern const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
+				       unsigned int max_size,
+				       struct delayed_call *done);
+#else  /* ! CONFIG_FS_ENCRYPTION */
+
+static inline bool fscrypt_has_encryption_key(const struct inode *inode)
+{
+	return false;
+}
+
+static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
+{
+	return false;
+}
+
+/* crypto.c */
+static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
+{
+}
+
+static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
+						  gfp_t gfp_flags)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
+{
+	return;
+}
+
+static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs,
+						u64 lblk_num, gfp_t gfp_flags)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline int fscrypt_decrypt_page(const struct inode *inode,
+				       struct page *page,
+				       unsigned int len, unsigned int offs,
+				       u64 lblk_num)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline struct page *fscrypt_control_page(struct page *page)
+{
+	WARN_ON_ONCE(1);
+	return ERR_PTR(-EINVAL);
+}
+
+static inline void fscrypt_restore_control_page(struct page *page)
+{
+	return;
+}
+
+/* policy.c */
+static inline int fscrypt_ioctl_set_policy(struct file *filp,
+					   const void __user *arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fscrypt_has_permitted_context(struct inode *parent,
+						struct inode *child)
+{
+	return 0;
+}
+
+static inline int fscrypt_inherit_context(struct inode *parent,
+					  struct inode *child,
+					  void *fs_data, bool preload)
+{
+	return -EOPNOTSUPP;
+}
+
+/* keyinfo.c */
+static inline int fscrypt_get_encryption_info(struct inode *inode)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void fscrypt_put_encryption_info(struct inode *inode)
+{
+	return;
+}
+
+ /* fname.c */
+static inline int fscrypt_setup_filename(struct inode *dir,
+					 const struct qstr *iname,
+					 int lookup, struct fscrypt_name *fname)
+{
+	if (IS_ENCRYPTED(dir))
+		return -EOPNOTSUPP;
+
+	memset(fname, 0, sizeof(struct fscrypt_name));
+	fname->usr_fname = iname;
+	fname->disk_name.name = (unsigned char *)iname->name;
+	fname->disk_name.len = iname->len;
+	return 0;
+}
+
+static inline void fscrypt_free_filename(struct fscrypt_name *fname)
+{
+	return;
+}
+
+static inline int fscrypt_fname_alloc_buffer(const struct inode *inode,
+					     u32 max_encrypted_len,
+					     struct fscrypt_str *crypto_str)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void fscrypt_fname_free_buffer(struct fscrypt_str *crypto_str)
+{
+	return;
+}
+
+static inline int fscrypt_fname_disk_to_usr(struct inode *inode,
+					    u32 hash, u32 minor_hash,
+					    const struct fscrypt_str *iname,
+					    struct fscrypt_str *oname)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
+				      const u8 *de_name, u32 de_name_len)
+{
+	/* Encryption support disabled; use standard comparison */
+	if (de_name_len != fname->disk_name.len)
+		return false;
+	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
+}
+
+/* bio.c */
+static inline void fscrypt_decrypt_bio(struct bio *bio)
+{
+}
+
+static inline void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
+					       struct bio *bio)
+{
+}
+
+static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
+{
+	return;
+}
+
+static inline int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
+					sector_t pblk, unsigned int len)
+{
+	return -EOPNOTSUPP;
+}
+
+/* hooks.c */
+
+static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
+{
+	if (IS_ENCRYPTED(inode))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static inline int __fscrypt_prepare_link(struct inode *inode,
+					 struct inode *dir)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int __fscrypt_prepare_rename(struct inode *old_dir,
+					   struct dentry *old_dentry,
+					   struct inode *new_dir,
+					   struct dentry *new_dentry,
+					   unsigned int flags)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int __fscrypt_prepare_lookup(struct inode *dir,
+					   struct dentry *dentry)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int __fscrypt_prepare_symlink(struct inode *dir,
+					    unsigned int len,
+					    unsigned int max_len,
+					    struct fscrypt_str *disk_link)
+{
+	return -EOPNOTSUPP;
+}
+
+
+static inline int __fscrypt_encrypt_symlink(struct inode *inode,
+					    const char *target,
+					    unsigned int len,
+					    struct fscrypt_str *disk_link)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline const char *fscrypt_get_symlink(struct inode *inode,
+					      const void *caddr,
+					      unsigned int max_size,
+					      struct delayed_call *done)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+#endif	/* ! CONFIG_FS_ENCRYPTION */
 
 /**
  * fscrypt_require_key - require an inode's encryption key
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
deleted file mode 100644
index ee8b43e..0000000
--- a/include/linux/fscrypt_notsupp.h
+++ /dev/null
@@ -1,231 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * fscrypt_notsupp.h
- *
- * This stubs out the fscrypt functions for filesystems configured without
- * encryption support.
- *
- * Do not include this file directly. Use fscrypt.h instead!
- */
-#ifndef _LINUX_FSCRYPT_H
-#error "Incorrect include of linux/fscrypt_notsupp.h!"
-#endif
-
-#ifndef _LINUX_FSCRYPT_NOTSUPP_H
-#define _LINUX_FSCRYPT_NOTSUPP_H
-
-static inline bool fscrypt_has_encryption_key(const struct inode *inode)
-{
-	return false;
-}
-
-static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-{
-	return false;
-}
-
-/* crypto.c */
-static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
-{
-}
-
-static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
-						  gfp_t gfp_flags)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
-{
-	return;
-}
-
-static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
-						struct page *page,
-						unsigned int len,
-						unsigned int offs,
-						u64 lblk_num, gfp_t gfp_flags)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline int fscrypt_decrypt_page(const struct inode *inode,
-				       struct page *page,
-				       unsigned int len, unsigned int offs,
-				       u64 lblk_num)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline struct page *fscrypt_control_page(struct page *page)
-{
-	WARN_ON_ONCE(1);
-	return ERR_PTR(-EINVAL);
-}
-
-static inline void fscrypt_restore_control_page(struct page *page)
-{
-	return;
-}
-
-/* policy.c */
-static inline int fscrypt_ioctl_set_policy(struct file *filp,
-					   const void __user *arg)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int fscrypt_has_permitted_context(struct inode *parent,
-						struct inode *child)
-{
-	return 0;
-}
-
-static inline int fscrypt_inherit_context(struct inode *parent,
-					  struct inode *child,
-					  void *fs_data, bool preload)
-{
-	return -EOPNOTSUPP;
-}
-
-/* keyinfo.c */
-static inline int fscrypt_get_encryption_info(struct inode *inode)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline void fscrypt_put_encryption_info(struct inode *inode)
-{
-	return;
-}
-
- /* fname.c */
-static inline int fscrypt_setup_filename(struct inode *dir,
-					 const struct qstr *iname,
-					 int lookup, struct fscrypt_name *fname)
-{
-	if (IS_ENCRYPTED(dir))
-		return -EOPNOTSUPP;
-
-	memset(fname, 0, sizeof(struct fscrypt_name));
-	fname->usr_fname = iname;
-	fname->disk_name.name = (unsigned char *)iname->name;
-	fname->disk_name.len = iname->len;
-	return 0;
-}
-
-static inline void fscrypt_free_filename(struct fscrypt_name *fname)
-{
-	return;
-}
-
-static inline int fscrypt_fname_alloc_buffer(const struct inode *inode,
-					     u32 max_encrypted_len,
-					     struct fscrypt_str *crypto_str)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline void fscrypt_fname_free_buffer(struct fscrypt_str *crypto_str)
-{
-	return;
-}
-
-static inline int fscrypt_fname_disk_to_usr(struct inode *inode,
-					    u32 hash, u32 minor_hash,
-					    const struct fscrypt_str *iname,
-					    struct fscrypt_str *oname)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
-				      const u8 *de_name, u32 de_name_len)
-{
-	/* Encryption support disabled; use standard comparison */
-	if (de_name_len != fname->disk_name.len)
-		return false;
-	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
-}
-
-/* bio.c */
-static inline void fscrypt_decrypt_bio(struct bio *bio)
-{
-}
-
-static inline void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					       struct bio *bio)
-{
-}
-
-static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
-{
-	return;
-}
-
-static inline int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
-					sector_t pblk, unsigned int len)
-{
-	return -EOPNOTSUPP;
-}
-
-/* hooks.c */
-
-static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
-{
-	if (IS_ENCRYPTED(inode))
-		return -EOPNOTSUPP;
-	return 0;
-}
-
-static inline int __fscrypt_prepare_link(struct inode *inode,
-					 struct inode *dir)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int __fscrypt_prepare_rename(struct inode *old_dir,
-					   struct dentry *old_dentry,
-					   struct inode *new_dir,
-					   struct dentry *new_dentry,
-					   unsigned int flags)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int __fscrypt_prepare_lookup(struct inode *dir,
-					   struct dentry *dentry)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int __fscrypt_prepare_symlink(struct inode *dir,
-					    unsigned int len,
-					    unsigned int max_len,
-					    struct fscrypt_str *disk_link)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int __fscrypt_encrypt_symlink(struct inode *inode,
-					    const char *target,
-					    unsigned int len,
-					    struct fscrypt_str *disk_link)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline const char *fscrypt_get_symlink(struct inode *inode,
-					      const void *caddr,
-					      unsigned int max_size,
-					      struct delayed_call *done)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-#endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
deleted file mode 100644
index 6456c6b..0000000
--- a/include/linux/fscrypt_supp.h
+++ /dev/null
@@ -1,204 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * fscrypt_supp.h
- *
- * Do not include this file directly. Use fscrypt.h instead!
- */
-#ifndef _LINUX_FSCRYPT_H
-#error "Incorrect include of linux/fscrypt_supp.h!"
-#endif
-
-#ifndef _LINUX_FSCRYPT_SUPP_H
-#define _LINUX_FSCRYPT_SUPP_H
-
-#include <linux/mm.h>
-#include <linux/slab.h>
-
-/*
- * fscrypt superblock flags
- */
-#define FS_CFLG_OWN_PAGES (1U << 1)
-
-/*
- * crypto operations for filesystems
- */
-struct fscrypt_operations {
-	unsigned int flags;
-	const char *key_prefix;
-	int (*get_context)(struct inode *, void *, size_t);
-	int (*set_context)(struct inode *, const void *, size_t, void *);
-	bool (*dummy_context)(struct inode *);
-	bool (*empty_dir)(struct inode *);
-	unsigned int max_namelen;
-};
-
-struct fscrypt_ctx {
-	union {
-		struct {
-			struct page *bounce_page;	/* Ciphertext page */
-			struct page *control_page;	/* Original page  */
-		} w;
-		struct {
-			struct bio *bio;
-			struct work_struct work;
-		} r;
-		struct list_head free_list;	/* Free list */
-	};
-	u8 flags;				/* Flags */
-};
-
-static inline bool fscrypt_has_encryption_key(const struct inode *inode)
-{
-	return (inode->i_crypt_info != NULL);
-}
-
-static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-{
-	return inode->i_sb->s_cop->dummy_context &&
-		inode->i_sb->s_cop->dummy_context(inode);
-}
-
-/* crypto.c */
-extern void fscrypt_enqueue_decrypt_work(struct work_struct *);
-extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
-extern void fscrypt_release_ctx(struct fscrypt_ctx *);
-extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
-						unsigned int, unsigned int,
-						u64, gfp_t);
-extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
-				unsigned int, u64);
-
-static inline struct page *fscrypt_control_page(struct page *page)
-{
-	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
-}
-
-extern void fscrypt_restore_control_page(struct page *);
-
-/* policy.c */
-extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
-extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
-extern int fscrypt_has_permitted_context(struct inode *, struct inode *);
-extern int fscrypt_inherit_context(struct inode *, struct inode *,
-					void *, bool);
-/* keyinfo.c */
-extern int fscrypt_get_encryption_info(struct inode *);
-extern void fscrypt_put_encryption_info(struct inode *);
-
-/* fname.c */
-extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
-				int lookup, struct fscrypt_name *);
-
-static inline void fscrypt_free_filename(struct fscrypt_name *fname)
-{
-	kfree(fname->crypto_buf.name);
-}
-
-extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
-				struct fscrypt_str *);
-extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
-extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
-			const struct fscrypt_str *, struct fscrypt_str *);
-
-#define FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE	32
-
-/* Extracts the second-to-last ciphertext block; see explanation below */
-#define FSCRYPT_FNAME_DIGEST(name, len)	\
-	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1, \
-			     FS_CRYPTO_BLOCK_SIZE))
-
-#define FSCRYPT_FNAME_DIGEST_SIZE	FS_CRYPTO_BLOCK_SIZE
-
-/**
- * fscrypt_digested_name - alternate identifier for an on-disk filename
- *
- * When userspace lists an encrypted directory without access to the key,
- * filenames whose ciphertext is longer than FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE
- * bytes are shown in this abbreviated form (base64-encoded) rather than as the
- * full ciphertext (base64-encoded).  This is necessary to allow supporting
- * filenames up to NAME_MAX bytes, since base64 encoding expands the length.
- *
- * To make it possible for filesystems to still find the correct directory entry
- * despite not knowing the full on-disk name, we encode any filesystem-specific
- * 'hash' and/or 'minor_hash' which the filesystem may need for its lookups,
- * followed by the second-to-last ciphertext block of the filename.  Due to the
- * use of the CBC-CTS encryption mode, the second-to-last ciphertext block
- * depends on the full plaintext.  (Note that ciphertext stealing causes the
- * last two blocks to appear "flipped".)  This makes accidental collisions very
- * unlikely: just a 1 in 2^128 chance for two filenames to collide even if they
- * share the same filesystem-specific hashes.
- *
- * However, this scheme isn't immune to intentional collisions, which can be
- * created by anyone able to create arbitrary plaintext filenames and view them
- * without the key.  Making the "digest" be a real cryptographic hash like
- * SHA-256 over the full ciphertext would prevent this, although it would be
- * less efficient and harder to implement, especially since the filesystem would
- * need to calculate it for each directory entry examined during a search.
- */
-struct fscrypt_digested_name {
-	u32 hash;
-	u32 minor_hash;
-	u8 digest[FSCRYPT_FNAME_DIGEST_SIZE];
-};
-
-/**
- * fscrypt_match_name() - test whether the given name matches a directory entry
- * @fname: the name being searched for
- * @de_name: the name from the directory entry
- * @de_name_len: the length of @de_name in bytes
- *
- * Normally @fname->disk_name will be set, and in that case we simply compare
- * that to the name stored in the directory entry.  The only exception is that
- * if we don't have the key for an encrypted directory and a filename in it is
- * very long, then we won't have the full disk_name and we'll instead need to
- * match against the fscrypt_digested_name.
- *
- * Return: %true if the name matches, otherwise %false.
- */
-static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
-				      const u8 *de_name, u32 de_name_len)
-{
-	if (unlikely(!fname->disk_name.name)) {
-		const struct fscrypt_digested_name *n =
-			(const void *)fname->crypto_buf.name;
-		if (WARN_ON_ONCE(fname->usr_fname->name[0] != '_'))
-			return false;
-		if (de_name_len <= FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE)
-			return false;
-		return !memcmp(FSCRYPT_FNAME_DIGEST(de_name, de_name_len),
-			       n->digest, FSCRYPT_FNAME_DIGEST_SIZE);
-	}
-
-	if (de_name_len != fname->disk_name.len)
-		return false;
-	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
-}
-
-/* bio.c */
-extern void fscrypt_decrypt_bio(struct bio *);
-extern void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
-					struct bio *bio);
-extern void fscrypt_pullback_bio_page(struct page **, bool);
-extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
-				 unsigned int);
-
-/* hooks.c */
-extern int fscrypt_file_open(struct inode *inode, struct file *filp);
-extern int __fscrypt_prepare_link(struct inode *inode, struct inode *dir);
-extern int __fscrypt_prepare_rename(struct inode *old_dir,
-				    struct dentry *old_dentry,
-				    struct inode *new_dir,
-				    struct dentry *new_dentry,
-				    unsigned int flags);
-extern int __fscrypt_prepare_lookup(struct inode *dir, struct dentry *dentry);
-extern int __fscrypt_prepare_symlink(struct inode *dir, unsigned int len,
-				     unsigned int max_len,
-				     struct fscrypt_str *disk_link);
-extern int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
-				     unsigned int len,
-				     struct fscrypt_str *disk_link);
-extern const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
-				       unsigned int max_size,
-				       struct delayed_call *done);
-
-#endif	/* _LINUX_FSCRYPT_SUPP_H */
-- 
2.9.5
