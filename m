Return-Path: <SRS0=THX2=QZ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 03/10] fscrypt: remove filesystem specific build config option
Date: Mon, 18 Feb 2019 15:34:26 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190218100433.20048-4-chandan@linux.ibm.com>
To: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

From: Chandan Rajendra <chandan@linux.vnet.ibm.com>

In order to have a common code base for fscrypt "post read" processing
for all filesystems which support encryption, this commit removes
filesystem specific build config option (e.g. CONFIG_EXT4_FS_ENCRYPTION)
and replaces it with a build option (i.e. CONFIG_FS_ENCRYPTION) whose
value affects all the filesystems making use of fscrypt.

Reviewed-by: Eric Biggers <ebiggers@google.com>
Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 Documentation/filesystems/fscrypt.rst   |   4 +-
 arch/mips/configs/generic_defconfig     |   2 +-
 arch/nds32/configs/defconfig            |   2 +-
 arch/s390/configs/debug_defconfig       |   2 +-
 arch/s390/configs/performance_defconfig |   2 +-
 fs/crypto/Kconfig                       |   5 +-
 fs/crypto/fscrypt_private.h             |   1 -
 fs/ext4/Kconfig                         |  15 -
 fs/ext4/dir.c                           |   2 -
 fs/ext4/ext4.h                          |   7 +-
 fs/ext4/inode.c                         |   8 +-
 fs/ext4/ioctl.c                         |   4 +-
 fs/ext4/namei.c                         |  10 +-
 fs/ext4/page-io.c                       |   6 +-
 fs/ext4/readpage.c                      |   2 +-
 fs/ext4/super.c                         |   6 +-
 fs/ext4/sysfs.c                         |   4 +-
 fs/f2fs/Kconfig                         |  12 +-
 fs/f2fs/f2fs.h                          |   7 +-
 fs/f2fs/super.c                         |   8 +-
 fs/f2fs/sysfs.c                         |   4 +-
 fs/ubifs/Kconfig                        |  12 +-
 fs/ubifs/Makefile                       |   2 +-
 fs/ubifs/ioctl.c                        |   4 +-
 fs/ubifs/sb.c                           |   2 +-
 fs/ubifs/super.c                        |   2 +-
 fs/ubifs/ubifs.h                        |   5 +-
 include/linux/fs.h                      |   4 +-
 include/linux/fscrypt.h                 | 416 +++++++++++++++++++++++-
 include/linux/fscrypt_notsupp.h         | 231 -------------
 include/linux/fscrypt_supp.h            | 204 ------------
 31 files changed, 460 insertions(+), 535 deletions(-)
 delete mode 100644 include/linux/fscrypt_notsupp.h
 delete mode 100644 include/linux/fscrypt_supp.h

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 3a7b60521b94..43dd989e2a3f 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -343,9 +343,9 @@ FS_IOC_SET_ENCRYPTION_POLICY can fail with the following errors:
 - ``ENOTEMPTY``: the file is unencrypted and is a nonempty directory
 - ``ENOTTY``: this type of filesystem does not implement encryption
 - ``EOPNOTSUPP``: the kernel was not configured with encryption
-  support for this filesystem, or the filesystem superblock has not
+  support for filesystems, or the filesystem superblock has not
   had encryption enabled on it.  (For example, to use encryption on an
-  ext4 filesystem, CONFIG_EXT4_ENCRYPTION must be enabled in the
+  ext4 filesystem, CONFIG_FS_ENCRYPTION must be enabled in the
   kernel config, and the superblock must have had the "encrypt"
   feature flag enabled using ``tune2fs -O encrypt`` or ``mkfs.ext4 -O
   encrypt``.)
diff --git a/arch/mips/configs/generic_defconfig b/arch/mips/configs/generic_defconfig
index 7c138dab87df..5d80521e5d5a 100644
--- a/arch/mips/configs/generic_defconfig
+++ b/arch/mips/configs/generic_defconfig
@@ -59,7 +59,7 @@ CONFIG_HID_MONTEREY=y
 CONFIG_EXT4_FS=y
 CONFIG_EXT4_FS_POSIX_ACL=y
 CONFIG_EXT4_FS_SECURITY=y
-CONFIG_EXT4_ENCRYPTION=y
+CONFIG_FS_ENCRYPTION=y
 CONFIG_FANOTIFY=y
 CONFIG_FUSE_FS=y
 CONFIG_CUSE=y
diff --git a/arch/nds32/configs/defconfig b/arch/nds32/configs/defconfig
index 2546d8770785..65ce9259081b 100644
--- a/arch/nds32/configs/defconfig
+++ b/arch/nds32/configs/defconfig
@@ -74,7 +74,7 @@ CONFIG_GENERIC_PHY=y
 CONFIG_EXT4_FS=y
 CONFIG_EXT4_FS_POSIX_ACL=y
 CONFIG_EXT4_FS_SECURITY=y
-CONFIG_EXT4_ENCRYPTION=y
+CONFIG_FS_ENCRYPTION=y
 CONFIG_FUSE_FS=y
 CONFIG_MSDOS_FS=y
 CONFIG_VFAT_FS=y
diff --git a/arch/s390/configs/debug_defconfig b/arch/s390/configs/debug_defconfig
index c69cb04b7a59..9824c7bad9d4 100644
--- a/arch/s390/configs/debug_defconfig
+++ b/arch/s390/configs/debug_defconfig
@@ -500,7 +500,6 @@ CONFIG_S390_AP_IOMMU=y
 CONFIG_EXT4_FS=y
 CONFIG_EXT4_FS_POSIX_ACL=y
 CONFIG_EXT4_FS_SECURITY=y
-CONFIG_EXT4_ENCRYPTION=y
 CONFIG_JBD2_DEBUG=y
 CONFIG_JFS_FS=m
 CONFIG_JFS_POSIX_ACL=y
@@ -520,6 +519,7 @@ CONFIG_BTRFS_DEBUG=y
 CONFIG_NILFS2_FS=m
 CONFIG_FS_DAX=y
 CONFIG_EXPORTFS_BLOCK_OPS=y
+CONFIG_FS_ENCRYPTION=y
 CONFIG_FANOTIFY=y
 CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
 CONFIG_QUOTA_NETLINK_INTERFACE=y
diff --git a/arch/s390/configs/performance_defconfig b/arch/s390/configs/performance_defconfig
index 32f539dc9c19..4fcbe5792744 100644
--- a/arch/s390/configs/performance_defconfig
+++ b/arch/s390/configs/performance_defconfig
@@ -497,7 +497,6 @@ CONFIG_S390_AP_IOMMU=y
 CONFIG_EXT4_FS=y
 CONFIG_EXT4_FS_POSIX_ACL=y
 CONFIG_EXT4_FS_SECURITY=y
-CONFIG_EXT4_ENCRYPTION=y
 CONFIG_JBD2_DEBUG=y
 CONFIG_JFS_FS=m
 CONFIG_JFS_POSIX_ACL=y
@@ -515,6 +514,7 @@ CONFIG_BTRFS_FS_POSIX_ACL=y
 CONFIG_NILFS2_FS=m
 CONFIG_FS_DAX=y
 CONFIG_EXPORTFS_BLOCK_OPS=y
+CONFIG_FS_ENCRYPTION=y
 CONFIG_FANOTIFY=y
 CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
 CONFIG_QUOTA_NETLINK_INTERFACE=y
diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index 02b7d91c9231..9a639da0464f 100644
--- a/fs/crypto/Kconfig
+++ b/fs/crypto/Kconfig
@@ -1,5 +1,5 @@
 config FS_ENCRYPTION
-	tristate "FS Encryption (Per-file encryption)"
+	bool "FS Encryption (Per-file encryption)"
 	select CRYPTO
 	select CRYPTO_AES
 	select CRYPTO_CBC
@@ -13,4 +13,5 @@ config FS_ENCRYPTION
 	  Enable encryption of files and directories.  This
 	  feature is similar to ecryptfs, but it is more memory
 	  efficient since it avoids caching the encrypted and
-	  decrypted pages in the page cache.
+	  decrypted pages in the page cache.  Currently Ext4,
+	  F2FS and UBIFS make use of this feature.
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 7424f851eb5c..7da276159593 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -12,7 +12,6 @@
 #ifndef _FSCRYPT_PRIVATE_H
 #define _FSCRYPT_PRIVATE_H
 
-#define __FS_HAS_ENCRYPTION 1
 #include <linux/fscrypt.h>
 #include <crypto/hash.h>
 
diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index a453cc87082b..031e5a82d556 100644
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
 config EXT4_DEBUG
 	bool "EXT4 debugging support"
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
index 216efeac53ea..0ffa84772667 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -40,7 +40,6 @@
 #include <linux/compat.h>
 #endif
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 #include <linux/fsverity.h>
 
@@ -1330,7 +1329,7 @@ struct ext4_super_block {
 #define EXT4_MF_FS_ABORTED		0x0002	/* Fatal error detected */
 #define EXT4_MF_TEST_DUMMY_ENCRYPTION	0x0004
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define DUMMY_ENCRYPTION_ENABLED(sbi) (unlikely((sbi)->s_mount_flags & \
 						EXT4_MF_TEST_DUMMY_ENCRYPTION))
 #else
@@ -2058,7 +2057,7 @@ struct ext4_filename {
 	const struct qstr *usr_fname;
 	struct fscrypt_str disk_name;
 	struct dx_hash_info hinfo;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	struct fscrypt_str crypto_buf;
 #endif
 };
@@ -2286,7 +2285,7 @@ extern unsigned ext4_free_clusters_after_init(struct super_block *sb,
 					      struct ext4_group_desc *gdp);
 ext4_fsblk_t ext4_inode_to_goal_block(struct inode *);
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
 			int lookup, struct ext4_filename *fname)
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 1dcf44a865cb..b1d7ddd70eee 100644
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
@@ -1302,7 +1302,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
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
index 4cc87f831f9a..ede07d233f21 100644
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
index be6cb69beb12..980166a8122a 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -612,7 +612,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 		{
 			if (show_names)
 			{
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 				int len;
 				char *name;
 				struct fscrypt_str fname_crypto_str =
@@ -984,7 +984,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	top = (struct ext4_dir_entry_2 *) ((char *) de +
 					   dir->i_sb->s_blocksize -
 					   EXT4_DIR_REC_LEN(0));
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	/* Check if the directory is encrypted */
 	if (IS_ENCRYPTED(dir)) {
 		err = fscrypt_get_encryption_info(dir);
@@ -1047,7 +1047,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	}
 errout:
 	brelse(bh);
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	fscrypt_fname_free_buffer(&fname_crypto_str);
 #endif
 	return count;
@@ -1267,7 +1267,7 @@ static inline bool ext4_match(const struct ext4_filename *fname,
 
 	f.usr_fname = fname->usr_fname;
 	f.disk_name = fname->disk_name;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	f.crypto_buf = fname->crypto_buf;
 #endif
 	return fscrypt_match_name(&f, de->name, de->name_len);
@@ -1498,7 +1498,7 @@ static struct buffer_head * ext4_dx_find_entry(struct inode *dir,
 	ext4_lblk_t block;
 	int retval;
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	*res_dir = NULL;
 #endif
 	frame = dx_probe(fname, dir, NULL, frames);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index c398b55da854..b9d6cabe2ea8 100644
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
index 92488df87135..93fbc15177a3 100644
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
index 0f69445f1da4..95a5d9fbbb9f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1233,7 +1233,7 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
 	return try_to_free_buffers(page);
 }
 
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 static int ext4_get_context(struct inode *inode, void *ctx, size_t len)
 {
 	return ext4_xattr_get(inode, EXT4_XATTR_INDEX_ENCRYPTION,
@@ -2019,7 +2019,7 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		*journal_ioprio =
 			IOPRIO_PRIO_VALUE(IOPRIO_CLASS_BE, arg);
 	} else if (token == Opt_test_dummy_encryption) {
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		sbi->s_mount_flags |= EXT4_MF_TEST_DUMMY_ENCRYPTION;
 		ext4_msg(sb, KERN_WARNING,
 			 "Test dummy encryption mode enabled");
@@ -4264,7 +4264,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &ext4_sops;
 	sb->s_export_op = &ext4_export_ops;
 	sb->s_xattr = ext4_xattr_handlers;
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
 #endif
 #ifdef CONFIG_FS_VERITY
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 07b986881d22..6fa0f47c3180 100644
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
 #ifdef CONFIG_FS_VERITY
@@ -236,7 +236,7 @@ static struct attribute *ext4_feat_attrs[] = {
 	ATTR_LIST(lazy_itable_init),
 	ATTR_LIST(batched_discard),
 	ATTR_LIST(meta_bg_resize),
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
 #ifdef CONFIG_FS_VERITY
diff --git a/fs/f2fs/Kconfig b/fs/f2fs/Kconfig
index 9a20ef42fadd..e57cc754d543 100644
--- a/fs/f2fs/Kconfig
+++ b/fs/f2fs/Kconfig
@@ -3,6 +3,7 @@ config F2FS_FS
 	depends on BLOCK
 	select CRYPTO
 	select CRYPTO_CRC32
+	select F2FS_FS_XATTR if FS_ENCRYPTION
 	help
 	  F2FS is based on Log-structured File System (LFS), which supports
 	  versatile "flash-friendly" features. The design has been focused on
@@ -70,17 +71,6 @@ config F2FS_CHECK_FS
 
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
 config F2FS_IO_TRACE
 	bool "F2FS IO tracer"
 	depends on F2FS_FS
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 520558a3fb63..78d2c7c9f517 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -24,7 +24,6 @@
 #include <linux/quotaops.h>
 #include <crypto/hash.h>
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_F2FS_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 #include <linux/fsverity.h>
 
@@ -1140,7 +1139,7 @@ enum fsync_mode {
 	FSYNC_MODE_NOBARRIER,	/* fsync behaves nobarrier based on posix */
 };
 
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define DUMMY_ENCRYPTION_ENABLED(sbi) \
 			(unlikely(F2FS_OPTION(sbi).test_dummy_encryption))
 #else
@@ -3473,7 +3472,7 @@ static inline bool f2fs_encrypted_file(struct inode *inode)
 
 static inline void f2fs_set_encrypted_inode(struct inode *inode)
 {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	file_set_encrypt(inode);
 	f2fs_set_inode_flags(inode);
 #endif
@@ -3553,7 +3552,7 @@ static inline void set_opt_mode(struct f2fs_sb_info *sbi, unsigned int mt)
 
 static inline bool f2fs_may_encrypt(struct inode *inode)
 {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	umode_t mode = inode->i_mode;
 
 	return (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode));
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 137d356b878b..6b04662a90d0 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -757,7 +757,7 @@ static int parse_options(struct super_block *sb, char *options)
 			kvfree(name);
 			break;
 		case Opt_test_dummy_encryption:
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 			if (!f2fs_sb_has_encrypt(sbi)) {
 				f2fs_msg(sb, KERN_ERR, "Encrypt feature is off");
 				return -EINVAL;
@@ -1390,7 +1390,7 @@ static int f2fs_show_options(struct seq_file *seq, struct dentry *root)
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
@@ -3152,7 +3152,7 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 #endif
 
 	sb->s_op = &f2fs_sops;
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &f2fs_cryptops;
 #endif
 #ifdef CONFIG_FS_VERITY
diff --git a/fs/f2fs/sysfs.c b/fs/f2fs/sysfs.c
index a6056f23d56d..7ce160973cdd 100644
--- a/fs/f2fs/sysfs.c
+++ b/fs/f2fs/sysfs.c
@@ -436,7 +436,7 @@ F2FS_GENERAL_RO_ATTR(lifetime_write_kbytes);
 F2FS_GENERAL_RO_ATTR(features);
 F2FS_GENERAL_RO_ATTR(current_reserved_blocks);
 
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 F2FS_FEATURE_RO_ATTR(encryption, FEAT_CRYPTO);
 #endif
 #ifdef CONFIG_BLK_DEV_ZONED
@@ -500,7 +500,7 @@ static struct attribute *f2fs_attrs[] = {
 };
 
 static struct attribute *f2fs_feat_attrs[] = {
-#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
 #ifdef CONFIG_BLK_DEV_ZONED
diff --git a/fs/ubifs/Kconfig b/fs/ubifs/Kconfig
index bc1e082d921d..9da2f135121b 100644
--- a/fs/ubifs/Kconfig
+++ b/fs/ubifs/Kconfig
@@ -8,6 +8,7 @@ config UBIFS_FS
 	select CRYPTO_LZO if UBIFS_FS_LZO
 	select CRYPTO_DEFLATE if UBIFS_FS_ZLIB
 	select CRYPTO_HASH_INFO
+	select UBIFS_FS_XATTR if FS_ENCRYPTION
 	depends on MTD_UBI
 	help
 	  UBIFS is a file system for flash devices which works on top of UBI.
@@ -60,17 +61,6 @@ config UBIFS_FS_XATTR
 
 	  If unsure, say Y.
 
-config UBIFS_FS_ENCRYPTION
-	bool "UBIFS Encryption"
-	depends on UBIFS_FS_XATTR && BLOCK
-	select FS_ENCRYPTION
-	default n
-	help
-	  Enable encryption of UBIFS files and directories. This
-	  feature is similar to ecryptfs, but it is more memory
-	  efficient since it avoids caching the encrypted and
-	  decrypted pages in the page cache.
-
 config UBIFS_FS_SECURITY
 	bool "UBIFS Security Labels"
 	depends on UBIFS_FS_XATTR
diff --git a/fs/ubifs/Makefile b/fs/ubifs/Makefile
index 5f838319c8d5..5c4b845754a7 100644
--- a/fs/ubifs/Makefile
+++ b/fs/ubifs/Makefile
@@ -6,6 +6,6 @@ ubifs-y += tnc.o master.o scan.o replay.o log.o commit.o gc.o orphan.o
 ubifs-y += budget.o find.o tnc_commit.o compress.o lpt.o lprops.o
 ubifs-y += recovery.o ioctl.o lpt_commit.o tnc_misc.o debug.o
 ubifs-y += misc.o
-ubifs-$(CONFIG_UBIFS_FS_ENCRYPTION) += crypto.o
+ubifs-$(CONFIG_FS_ENCRYPTION) += crypto.o
 ubifs-$(CONFIG_UBIFS_FS_XATTR) += xattr.o
 ubifs-$(CONFIG_UBIFS_FS_AUTHENTICATION) += auth.o
diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index 0164bcc827f8..0f9c362a3402 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -185,7 +185,7 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return err;
 	}
 	case FS_IOC_SET_ENCRYPTION_POLICY: {
-#ifdef CONFIG_UBIFS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		struct ubifs_info *c = inode->i_sb->s_fs_info;
 
 		err = ubifs_enable_encryption(c);
@@ -198,7 +198,7 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 #endif
 	}
 	case FS_IOC_GET_ENCRYPTION_POLICY: {
-#ifdef CONFIG_UBIFS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 		return fscrypt_ioctl_get_policy(file, (void __user *)arg);
 #else
 		return -EOPNOTSUPP;
diff --git a/fs/ubifs/sb.c b/fs/ubifs/sb.c
index 3da90c951c23..67fac1e8adfb 100644
--- a/fs/ubifs/sb.c
+++ b/fs/ubifs/sb.c
@@ -748,7 +748,7 @@ int ubifs_read_superblock(struct ubifs_info *c)
 		goto out;
 	}
 
-#ifndef CONFIG_UBIFS_FS_ENCRYPTION
+#ifndef CONFIG_FS_ENCRYPTION
 	if (c->encrypted) {
 		ubifs_err(c, "file system contains encrypted files but UBIFS"
 			     " was built without crypto support.");
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 1fac1133dadd..8dc2818fdd84 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2146,7 +2146,7 @@ static int ubifs_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_UBIFS_FS_XATTR
 	sb->s_xattr = ubifs_xattr_handlers;
 #endif
-#ifdef CONFIG_UBIFS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &ubifs_crypt_operations;
 #endif
 
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 38401adaa00d..1ae12900e01d 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -43,7 +43,6 @@
 #include <crypto/hash.h>
 #include <crypto/algapi.h>
 
-#define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_UBIFS_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
 #include "ubifs-media.h"
@@ -142,7 +141,7 @@
  */
 #define WORST_COMPR_FACTOR 2
 
-#ifdef CONFIG_UBIFS_FS_ENCRYPTION
+#ifdef CONFIG_FS_ENCRYPTION
 #define UBIFS_CIPHER_BLOCK_SIZE FS_CRYPTO_BLOCK_SIZE
 #else
 #define UBIFS_CIPHER_BLOCK_SIZE 0
@@ -2072,7 +2071,7 @@ int ubifs_decompress(const struct ubifs_info *c, const void *buf, int len,
 #include "misc.h"
 #include "key.h"
 
-#ifndef CONFIG_UBIFS_FS_ENCRYPTION
+#ifndef CONFIG_FS_ENCRYPTION
 static inline int ubifs_encrypt(const struct inode *inode,
 				struct ubifs_data_node *dn,
 				unsigned int in_len, unsigned int *out_len,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8bf61c851a79..e64da9c16e0d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -700,7 +700,7 @@ struct inode {
 	struct fsnotify_mark_connector __rcu	*i_fsnotify_marks;
 #endif
 
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+#ifdef CONFIG_FS_ENCRYPTION
 	struct fscrypt_info	*i_crypt_info;
 #endif
 
@@ -1409,7 +1409,7 @@ struct super_block {
 	void                    *s_security;
 #endif
 	const struct xattr_handler **s_xattr;
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+#ifdef CONFIG_FS_ENCRYPTION
 	const struct fscrypt_operations	*s_cop;
 #endif
 #ifdef CONFIG_FS_VERITY
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
