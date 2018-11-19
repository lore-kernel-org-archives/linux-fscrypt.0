Return-Path: <SRS0=2Xim=N6=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [PATCH 3/7] fscrypt: Remove filesystem specific build config option
Date: Mon, 19 Nov 2018 10:53:20 +0530
In-Reply-To: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181119052324.31456-4-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers@kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

In order to have a common code base for fscrypt "post read" processing
for all filesystems which support encryption, this commit removes
filesystem specific build config option (e.g. CONFIG_EXT4_FS_ENCRYPTION)
and replaces it with a build option (i.e. CONFIG_FS_ENCRYPTION) whose
value affects all the filesystems making use of fscrypt.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/Kconfig               |   2 +-
 fs/ext4/Kconfig                 |  15 --
 fs/ext4/dir.c                   |   2 -
 fs/ext4/ext4.h                  |   7 +-
 fs/ext4/inode.c                 |   8 +-
 fs/ext4/ioctl.c                 |   4 +-
 fs/ext4/namei.c                 |  10 +-
 fs/ext4/page-io.c               |   6 +-
 fs/ext4/readpage.c              |   2 +-
 fs/ext4/super.c                 |   6 +-
 fs/ext4/sysfs.c                 |   4 +-
 fs/f2fs/Kconfig                 |  11 -
 fs/f2fs/f2fs.h                  |   7 +-
 fs/f2fs/super.c                 |   8 +-
 fs/f2fs/sysfs.c                 |   4 +-
 include/linux/fscrypt.h         | 416 +++++++++++++++++++++++++++++++-
 include/linux/fscrypt_notsupp.h | 231 ------------------
 include/linux/fscrypt_supp.h    | 204 ----------------
 18 files changed, 441 insertions(+), 506 deletions(-)
 delete mode 100644 include/linux/fscrypt_notsupp.h
 delete mode 100644 include/linux/fscrypt_supp.h

diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index 02b7d91c9231..6e9ae566a8fc 100644
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
index 5a76125ac0f8..e1002bbf35bf 100644
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
index fb7a64ea5679..0ccd51f72048 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -283,9 +283,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 done:
 	err = 0;
 errout:
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
 	fscrypt_fname_free_buffer(&fstr);
-#endif
 	brelse(bh);
 	return err;
 }
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 2ae6ab88f218..db21df885186 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -40,7 +40,6 @@
 #include <linux/compat.h>
 #endif
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
 #define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
@@ -1341,7 +1340,7 @@ struct ext4_super_block {
 #define EXT4_MF_FS_ABORTED		0x0002	/* Fatal error detected */
 #define EXT4_MF_TEST_DUMMY_ENCRYPTION	0x0004
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define DUMMY_ENCRYPTION_ENABLED(sbi) (unlikely((sbi)->s_mount_flags & \
 						EXT4_MF_TEST_DUMMY_ENCRYPTION))
 #else
@@ -2069,7 +2068,7 @@ struct ext4_filename {
 	const struct qstr *usr_fname;
 	struct fscrypt_str disk_name;
 	struct dx_hash_info hinfo;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	struct fscrypt_str crypto_buf;
 #endif
 };
@@ -2306,7 +2305,7 @@ static inline bool ext4_verity_inode(struct inode *inode)
 #endif
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
 			int lookup, struct ext4_filename *fname)
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 725777772f32..ae6794649817 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1150,7 +1150,7 @@ int do_journal_get_write_access(handle_t *handle,
 	return ret;
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 				  get_block_t *get_block)
 {
@@ -1303,7 +1303,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	/* In case writeback began while the page was unlocked */
 	wait_for_stable_page(page);
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	if (ext4_should_dioread_nolock(inode))
 		ret = ext4_block_write_begin(page, pos, len,
 					     ext4_get_block_unwritten);
@@ -3104,7 +3104,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	/* In case writeback began while the page was unlocked */
 	wait_for_stable_page(page);
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ret = ext4_block_write_begin(page, pos, len,
 				     ext4_da_get_block_prep);
 #else
@@ -3879,7 +3879,7 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t offset = iocb->ki_pos;
 	ssize_t ret;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		return 0;
 #endif
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 9bb6cc1ae8ce..892fb1925836 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -210,7 +210,7 @@ static long swap_inode_boot_loader(struct super_block *sb,
 	return err;
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int uuid_is_zero(__u8 u[16])
 {
 	int	i;
@@ -978,7 +978,7 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		return fscrypt_ioctl_set_policy(filp, (const void __user *)arg);
 
 	case EXT4_IOC_GET_ENCRYPTION_PWSALT: {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		int err, err2;
 		struct ext4_sb_info *sbi = EXT4_SB(sb);
 		handle_t *handle;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 0de60207a963..1e1a3c8c3a8b 100644
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
@@ -983,7 +983,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	top = (struct ext4_dir_entry_2 *) ((char *) de +
 					   dir->i_sb->s_blocksize -
 					   EXT4_DIR_REC_LEN(0));
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	/* Check if the directory is encrypted */
 	if (IS_ENCRYPTED(dir)) {
 		err = fscrypt_get_encryption_info(dir);
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
@@ -1497,7 +1497,7 @@ static struct buffer_head * ext4_dx_find_entry(struct inode *dir,
 	ext4_lblk_t block;
 	int retval;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	*res_dir = NULL;
 #endif
 	frame = dx_probe(fname, dir, NULL, frames);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 008c20b58f98..7d5f12be07ab 100644
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
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 45e707fb9749..7252f0a60cdb 100644
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
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index fb4e060f28ec..16fb483a6f4a 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1210,7 +1210,7 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
 	return try_to_free_buffers(page);
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int ext4_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	return ext4_xattr_get(inode, EXT4_XATTR_INDEX_ENCRYPTION,
@@ -1986,7 +1986,7 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		*journal_ioprio =
 			IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, arg);
 	} else if (token == Opt_test_dummy_encryption) {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		sbi->s_mount_flags |= EXT4_MF_TEST_DUMMY_ENCRYPTION;
 		ext4_msg(sb, KERN_WARNING,
 			 "Test dummy encryption mode enabled");
@@ -4231,7 +4231,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &ext4_sops;
 	sb->s_export_op = &ext4_export_ops;
 	sb->s_xattr = ext4_xattr_handlers;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 8e86087c2f03..8bc915452a38 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -224,7 +224,7 @@ static struct attribute *ext4_attrs[] = {
 EXT4_ATTR_FEATURE(lazy_itable_init);
 EXT4_ATTR_FEATURE(batched_discard);
 EXT4_ATTR_FEATURE(meta_bg_resize);
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 EXT4_ATTR_FEATURE(encryption);
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
@@ -236,7 +236,7 @@ static struct attribute *ext4_feat_attrs[] = {
 	ATTR_LIST(lazy_itable_init),
 	ATTR_LIST(batched_discard),
 	ATTR_LIST(meta_bg_resize),
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
 #ifdef CONFIG_EXT4_FS_VERITY
diff --git a/fs/f2fs/Kconfig b/fs/f2fs/Kconfig
index c8396c7220f2..ce60e480fec1 100644
--- a/fs/f2fs/Kconfig
+++ b/fs/f2fs/Kconfig
@@ -70,17 +70,6 @@ config F2FS_CHECK_FS
 
 	  If you want to improve the performance, say N.
 
-config F2FS_FS_ENCRYPTION
-	bool "F2FS Encryption"
-	depends on F2FS_FS
-	depends on F2FS_FS_XATTR
-	select FS_ENCRYPTION
-	help
-	  Enable encryption of f2fs files and directories.  This
-	  feature is similar to ecryptfs, but it is more memory
-	  efficient since it avoids caching the encrypted and
-	  decrypted pages in the page cache.
-
 config F2FS_FS_VERITY
 	bool "F2FS Verity"
 	depends on F2FS_FS
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index dadb5f468f20..ea8a5ffc4f1f 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -24,7 +24,6 @@
 #include <linux/quotaops.h>
 #include <crypto/hash.h>
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_F2FS_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
 #define __FS_HAS_VERITY IS_ENABLED(CONFIG_F2FS_FS_VERITY)
@@ -1145,7 +1144,7 @@ enum fsync_mode {
 	FSYNC_MODE_NOBARRIER,	/* fsync behaves nobarrier based on posix */
 };
 
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define DUMMY_ENCRYPTION_ENABLED(sbi) \
 			(unlikely(F2FS_OPTION(sbi).test_dummy_encryption))
 #else
@@ -3448,7 +3447,7 @@ static inline bool f2fs_encrypted_file(struct inode *inode)
 
 static inline void f2fs_set_encrypted_inode(struct inode *inode)
 {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	file_set_encrypt(inode);
 	f2fs_set_inode_flags(inode);
 #endif
@@ -3533,7 +3532,7 @@ static inline void set_opt_mode(struct f2fs_sb_info *sbi, unsigned int mt)
 
 static inline bool f2fs_may_encrypt(struct inode *inode)
 {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	umode_t mode = inode->i_mode;
 
 	return (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode));
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index adf38c1b6414..4287cf348d3c 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -757,7 +757,7 @@ static int parse_options(struct super_block *sb, char *options)
 			kfree(name);
 			break;
 		case Opt_test_dummy_encryption:
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 			if (!f2fs_sb_has_encrypt(sb)) {
 				f2fs_msg(sb, KERN_ERR, "Encrypt feature is off");
 				return -EINVAL;
@@ -1387,7 +1387,7 @@ static int f2fs_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",whint_mode=%s", "user-based");
 	else if (F2FS_OPTION(sbi).whint_mode == WHINT_MODE_FS)
 		seq_printf(seq, ",whint_mode=%s", "fs-based");
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	if (F2FS_OPTION(sbi).test_dummy_encryption)
 		seq_puts(seq, ",test_dummy_encryption");
 #endif
@@ -2154,7 +2154,7 @@ static const struct super_operations f2fs_sops = {
 	.remount_fs	= f2fs_remount,
 };
 
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int f2fs_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	return f2fs_getxattr(inode, F2FS_XATTR_INDEX_ENCRYPTION,
@@ -3143,7 +3143,7 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 #endif
 
 	sb->s_op = &f2fs_sops;
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &f2fs_cryptops;
 #endif
 #ifdef CONFIG_F2FS_FS_VERITY
diff --git a/fs/f2fs/sysfs.c b/fs/f2fs/sysfs.c
index 5599c9ac4426..737677655bc0 100644
--- a/fs/f2fs/sysfs.c
+++ b/fs/f2fs/sysfs.c
@@ -430,7 +430,7 @@ F2FS_GENERAL_RO_ATTR(lifetime_write_kbytes);
 F2FS_GENERAL_RO_ATTR(features);
 F2FS_GENERAL_RO_ATTR(current_reserved_blocks);
 
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 F2FS_FEATURE_RO_ATTR(encryption, FEAT_CRYPTO);
 #endif
 #ifdef CONFIG_BLK_DEV_ZONED
@@ -493,7 +493,7 @@ static struct attribute *f2fs_attrs[] = {
 };
 
 static struct attribute *f2fs_feat_attrs[] = {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
 #ifdef CONFIG_BLK_DEV_ZONED
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 952ab97af325..6ba193c23f37 100644
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
index ee8b43e4c15a..000000000000
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
index 6456c6b2005f..000000000000
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
2.19.1
