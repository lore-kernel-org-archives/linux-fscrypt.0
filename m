Return-Path: <SRS0=14es=LH=vger.kernel.org=linux-integrity-owner@kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 10/10] f2fs: fs-verity support
Date: Fri, 24 Aug 2018 09:16:42 -0700
Message-Id: <20180824161642.1144-11-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Sender: linux-integrity-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add fs-verity support to f2fs.  fs-verity is a filesystem feature that
provides efficient, transparent integrity verification and
authentication of read-only files.  It uses a dm-verity like mechanism
at the file level: a Merkle tree hidden past the end of the file is used
to verify any block in the file in log(filesize) time.  It is
implemented mainly by helper functions in fs/verity/.

In f2fs, the main change is to the I/O path: ->readpage() and
->readpages() now verify data as it is read from verity files.  Pages
that fail verification are set to PG_error && !PG_uptodate, causing
applications to see an I/O error.

Hooks are also added to several other f2fs filesystem operations:

* ->open(), to deny opening verity files for writing and to set up
  the fsverity_info to prepare for I/O

* ->getattr() to set up the fsverity_info to make stat() show the
  original data size of verity files

* ->setattr() to deny truncating verity files

* update_inode() to write out the full file size rather than the
  original data size, since for verity files the in-memory ->i_size is
  overridden with the original data size.

Finally, the FS_IOC_ENABLE_VERITY and FS_IOC_MEASURE_VERITY ioctls are
wired up.  On f2fs, these ioctls require that the filesystem has the
'verity' feature, i.e. it was created with 'mkfs.f2fs -O verity'.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/Kconfig | 20 +++++++++++++++++
 fs/f2fs/data.c  | 43 +++++++++++++++++++++++++++++++-----
 fs/f2fs/f2fs.h  | 17 ++++++++++++---
 fs/f2fs/file.c  | 58 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/f2fs/inode.c |  3 ++-
 fs/f2fs/super.c | 22 +++++++++++++++++++
 fs/f2fs/sysfs.c | 11 ++++++++++
 7 files changed, 165 insertions(+), 9 deletions(-)

diff --git a/fs/f2fs/Kconfig b/fs/f2fs/Kconfig
index 9a20ef42fadde..c8396c7220f2a 100644
--- a/fs/f2fs/Kconfig
+++ b/fs/f2fs/Kconfig
@@ -81,6 +81,26 @@ config F2FS_FS_ENCRYPTION
 	  efficient since it avoids caching the encrypted and
 	  decrypted pages in the page cache.
 
+config F2FS_FS_VERITY
+	bool "F2FS Verity"
+	depends on F2FS_FS
+	select FS_VERITY
+	help
+	  This option enables fs-verity for f2fs.  fs-verity is the
+	  dm-verity mechanism implemented at the file level.  Userspace
+	  can append a Merkle tree (hash tree) to a file, then enable
+	  fs-verity on the file.  f2fs will then transparently verify
+	  any data read from the file against the Merkle tree.  The file
+	  is also made read-only.
+
+	  This serves as an integrity check, but the availability of the
+	  Merkle tree root hash also allows efficiently supporting
+	  various use cases where normally the whole file would need to
+	  be hashed at once, such as auditing and authenticity
+	  verification (appraisal).
+
+	  If unsure, say N.
+
 config F2FS_IO_TRACE
 	bool "F2FS IO tracer"
 	depends on F2FS_FS
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 8f931d699287a..fc9ea831f7235 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -59,6 +59,7 @@ static bool __is_cp_guaranteed(struct page *page)
 enum bio_post_read_step {
 	STEP_INITIAL = 0,
 	STEP_DECRYPT,
+	STEP_VERITY,
 };
 
 struct bio_post_read_ctx {
@@ -103,8 +104,23 @@ static void decrypt_work(struct work_struct *work)
 	bio_post_read_processing(ctx);
 }
 
+static void verity_work(struct work_struct *work)
+{
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
+
+	fsverity_verify_bio(ctx->bio);
+
+	bio_post_read_processing(ctx);
+}
+
 static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
 {
+	/*
+	 * We use different work queues for decryption and for verity because
+	 * verity may require reading metadata pages that need decryption, and
+	 * we shouldn't recurse to the same workqueue.
+	 */
 	switch (++ctx->cur_step) {
 	case STEP_DECRYPT:
 		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
@@ -114,6 +130,14 @@ static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
 		}
 		ctx->cur_step++;
 		/* fall-through */
+	case STEP_VERITY:
+		if (ctx->enabled_steps & (1 << STEP_VERITY)) {
+			INIT_WORK(&ctx->work, verity_work);
+			fsverity_enqueue_verify_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
 	default:
 		__read_end_io(ctx->bio);
 	}
@@ -534,7 +558,7 @@ void f2fs_submit_page_write(struct f2fs_io_info *fio)
 }
 
 static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
-							 unsigned nr_pages)
+				      unsigned nr_pages, pgoff_t first_idx)
 {
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct bio *bio;
@@ -550,6 +574,11 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 
 	if (f2fs_encrypted_file(inode))
 		post_read_steps |= 1 << STEP_DECRYPT;
+#ifdef CONFIG_F2FS_FS_VERITY
+	if (inode->i_verity_info != NULL &&
+	    (first_idx < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
+		post_read_steps |= 1 << STEP_VERITY;
+#endif
 	if (post_read_steps) {
 		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
 		if (!ctx) {
@@ -571,7 +600,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 static int f2fs_submit_page_read(struct inode *inode, struct page *page,
 							block_t blkaddr)
 {
-	struct bio *bio = f2fs_grab_read_bio(inode, blkaddr, 1);
+	struct bio *bio = f2fs_grab_read_bio(inode, blkaddr, 1, page->index);
 
 	if (IS_ERR(bio))
 		return PTR_ERR(bio);
@@ -1459,8 +1488,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 
 		block_in_file = (sector_t)page->index;
 		last_block = block_in_file + nr_pages;
-		last_block_in_file = (i_size_read(inode) + blocksize - 1) >>
-								blkbits;
+		last_block_in_file = (fsverity_full_i_size(inode) +
+				      blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
 			last_block = last_block_in_file;
 
@@ -1497,6 +1526,9 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 			}
 		} else {
 			zero_user_segment(page, 0, PAGE_SIZE);
+			if (f2fs_verity_file(inode) &&
+			    !fsverity_verify_page(page))
+				goto set_error_page;
 			if (!PageUptodate(page))
 				SetPageUptodate(page);
 			unlock_page(page);
@@ -1514,7 +1546,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 			bio = NULL;
 		}
 		if (bio == NULL) {
-			bio = f2fs_grab_read_bio(inode, block_nr, nr_pages);
+			bio = f2fs_grab_read_bio(inode, block_nr, nr_pages,
+						 page->index);
 			if (IS_ERR(bio)) {
 				bio = NULL;
 				goto set_error_page;
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 4d8b1de831439..e59781b13c5c8 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -29,6 +29,9 @@
 #define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_F2FS_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
+#define __FS_HAS_VERITY IS_ENABLED(CONFIG_F2FS_FS_VERITY)
+#include <linux/fsverity.h>
+
 #ifdef CONFIG_F2FS_CHECK_FS
 #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
 #else
@@ -146,7 +149,7 @@ struct f2fs_mount_info {
 #define F2FS_FEATURE_QUOTA_INO		0x0080
 #define F2FS_FEATURE_INODE_CRTIME	0x0100
 #define F2FS_FEATURE_LOST_FOUND		0x0200
-#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
+#define F2FS_FEATURE_VERITY		0x0400
 
 #define F2FS_HAS_FEATURE(sb, mask)					\
 	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
@@ -598,7 +601,7 @@ enum {
 #define FADVISE_ENC_NAME_BIT	0x08
 #define FADVISE_KEEP_SIZE_BIT	0x10
 #define FADVISE_HOT_BIT		0x20
-#define FADVISE_VERITY_BIT	0x40	/* reserved */
+#define FADVISE_VERITY_BIT	0x40
 
 #define file_is_cold(inode)	is_file(inode, FADVISE_COLD_BIT)
 #define file_wrong_pino(inode)	is_file(inode, FADVISE_LOST_PINO_BIT)
@@ -616,6 +619,8 @@ enum {
 #define file_is_hot(inode)	is_file(inode, FADVISE_HOT_BIT)
 #define file_set_hot(inode)	set_file(inode, FADVISE_HOT_BIT)
 #define file_clear_hot(inode)	clear_file(inode, FADVISE_HOT_BIT)
+#define file_is_verity(inode)	is_file(inode, FADVISE_VERITY_BIT)
+#define file_set_verity(inode)	set_file(inode, FADVISE_VERITY_BIT)
 
 #define DEF_DIR_LEVEL		0
 
@@ -3294,13 +3299,18 @@ static inline void f2fs_set_encrypted_inode(struct inode *inode)
 #endif
 }
 
+static inline bool f2fs_verity_file(struct inode *inode)
+{
+	return file_is_verity(inode);
+}
+
 /*
  * Returns true if the reads of the inode's data need to undergo some
  * postprocessing step, like decryption or authenticity verification.
  */
 static inline bool f2fs_post_read_required(struct inode *inode)
 {
-	return f2fs_encrypted_file(inode);
+	return f2fs_encrypted_file(inode) || f2fs_verity_file(inode);
 }
 
 #define F2FS_FEATURE_FUNCS(name, flagname) \
@@ -3318,6 +3328,7 @@ F2FS_FEATURE_FUNCS(flexible_inline_xattr, FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_FUNCS(quota_ino, QUOTA_INO);
 F2FS_FEATURE_FUNCS(inode_crtime, INODE_CRTIME);
 F2FS_FEATURE_FUNCS(lost_found, LOST_FOUND);
+F2FS_FEATURE_FUNCS(verity, VERITY);
 
 #ifdef CONFIG_BLK_DEV_ZONED
 static inline int get_blkz_type(struct f2fs_sb_info *sbi,
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 6880c6f78d58d..ea86dd35685ff 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -486,6 +486,12 @@ static int f2fs_file_open(struct inode *inode, struct file *filp)
 	if (err)
 		return err;
 
+	if (f2fs_verity_file(inode)) {
+		err = fsverity_file_open(inode, filp);
+		if (err)
+			return err;
+	}
+
 	filp->f_mode |= FMODE_NOWAIT;
 
 	return dquot_file_open(inode, filp);
@@ -684,6 +690,22 @@ int f2fs_getattr(const struct path *path, struct kstat *stat,
 	struct f2fs_inode *ri;
 	unsigned int flags;
 
+	if (f2fs_verity_file(inode)) {
+		/*
+		 * For fs-verity we need to override i_size with the original
+		 * data i_size.  This requires I/O to the file which with
+		 * fscrypt requires that the key be set up.  But, if the key is
+		 * unavailable just continue on without the i_size override.
+		 */
+		int err = fscrypt_require_key(inode);
+
+		if (!err) {
+			err = fsverity_prepare_getattr(inode);
+			if (err)
+				return err;
+		}
+	}
+
 	if (f2fs_has_extra_attr(inode) &&
 			f2fs_sb_has_inode_crtime(inode->i_sb) &&
 			F2FS_FITS_IN_INODE(ri, fi->i_extra_isize, i_crtime)) {
@@ -767,6 +789,12 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
+	if (f2fs_verity_file(inode)) {
+		err = fsverity_prepare_setattr(dentry, attr);
+		if (err)
+			return err;
+	}
+
 	if (is_quota_modification(inode, attr)) {
 		err = dquot_initialize(inode);
 		if (err)
@@ -2851,6 +2879,30 @@ static int f2fs_ioc_precache_extents(struct file *filp, unsigned long arg)
 	return f2fs_precache_extents(file_inode(filp));
 }
 
+static int f2fs_ioc_enable_verity(struct file *filp, unsigned long arg)
+{
+	struct inode *inode = file_inode(filp);
+
+	f2fs_update_time(F2FS_I_SB(inode), REQ_TIME);
+
+	if (!f2fs_sb_has_verity(inode->i_sb)) {
+		f2fs_msg(inode->i_sb, KERN_WARNING,
+			 "Can't enable fs-verity on inode %lu: the fs-verity feature is disabled on this filesystem.\n",
+			 inode->i_ino);
+		return -EOPNOTSUPP;
+	}
+
+	return fsverity_ioctl_enable(filp, (const void __user *)arg);
+}
+
+static int f2fs_ioc_measure_verity(struct file *filp, unsigned long arg)
+{
+	if (!f2fs_sb_has_verity(file_inode(filp)->i_sb))
+		return -EOPNOTSUPP;
+
+	return fsverity_ioctl_measure(filp, (void __user *)arg);
+}
+
 long f2fs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
 	if (unlikely(f2fs_cp_error(F2FS_I_SB(file_inode(filp)))))
@@ -2907,6 +2959,10 @@ long f2fs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		return f2fs_ioc_set_pin_file(filp, arg);
 	case F2FS_IOC_PRECACHE_EXTENTS:
 		return f2fs_ioc_precache_extents(filp, arg);
+	case FS_IOC_ENABLE_VERITY:
+		return f2fs_ioc_enable_verity(filp, arg);
+	case FS_IOC_MEASURE_VERITY:
+		return f2fs_ioc_measure_verity(filp, arg);
 	default:
 		return -ENOTTY;
 	}
@@ -3013,6 +3069,8 @@ long f2fs_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case F2FS_IOC_GET_PIN_FILE:
 	case F2FS_IOC_SET_PIN_FILE:
 	case F2FS_IOC_PRECACHE_EXTENTS:
+	case FS_IOC_ENABLE_VERITY:
+	case FS_IOC_MEASURE_VERITY:
 		break;
 	default:
 		return -ENOIOCTLCMD;
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index f121c864f4c0d..e363e9f0c699e 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -407,7 +407,7 @@ void f2fs_update_inode(struct inode *inode, struct page *node_page)
 	ri->i_uid = cpu_to_le32(i_uid_read(inode));
 	ri->i_gid = cpu_to_le32(i_gid_read(inode));
 	ri->i_links = cpu_to_le32(inode->i_nlink);
-	ri->i_size = cpu_to_le64(i_size_read(inode));
+	ri->i_size = cpu_to_le64(fsverity_full_i_size(inode));
 	ri->i_blocks = cpu_to_le64(SECTOR_TO_BLOCK(inode->i_blocks) + 1);
 
 	if (et) {
@@ -618,6 +618,7 @@ void f2fs_evict_inode(struct inode *inode)
 	}
 out_clear:
 	fscrypt_put_encryption_info(inode);
+	fsverity_cleanup_inode(inode);
 	clear_inode(inode);
 }
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 3995e926ba3a3..52a0de200fb79 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1943,6 +1943,25 @@ static const struct fscrypt_operations f2fs_cryptops = {
 };
 #endif
 
+#ifdef CONFIG_F2FS_FS_VERITY
+static int f2fs_set_verity(struct inode *inode, loff_t data_i_size)
+{
+	int err;
+
+	err = f2fs_convert_inline_inode(inode);
+	if (err)
+		return err;
+
+	file_set_verity(inode);
+	f2fs_mark_inode_dirty_sync(inode, true);
+	return 0;
+}
+
+static const struct fsverity_operations f2fs_verityops = {
+	.set_verity		= f2fs_set_verity,
+};
+#endif /* CONFIG_F2FS_FS_VERITY */
+
 static struct inode *f2fs_nfs_get_inode(struct super_block *sb,
 		u64 ino, u32 generation)
 {
@@ -2758,6 +2777,9 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &f2fs_sops;
 #ifdef CONFIG_F2FS_FS_ENCRYPTION
 	sb->s_cop = &f2fs_cryptops;
+#endif
+#ifdef CONFIG_F2FS_FS_VERITY
+	sb->s_vop = &f2fs_verityops;
 #endif
 	sb->s_xattr = f2fs_xattr_handlers;
 	sb->s_export_op = &f2fs_export_ops;
diff --git a/fs/f2fs/sysfs.c b/fs/f2fs/sysfs.c
index 2e7e611deaef2..f11aa34a8be18 100644
--- a/fs/f2fs/sysfs.c
+++ b/fs/f2fs/sysfs.c
@@ -119,6 +119,9 @@ static ssize_t features_show(struct f2fs_attr *a,
 	if (f2fs_sb_has_lost_found(sb))
 		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
 				len ? ", " : "", "lost_found");
+	if (f2fs_sb_has_verity(sb))
+		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
+				len ? ", " : "", "verity");
 	len += snprintf(buf + len, PAGE_SIZE - len, "\n");
 	return len;
 }
@@ -333,6 +336,7 @@ enum feat_id {
 	FEAT_QUOTA_INO,
 	FEAT_INODE_CRTIME,
 	FEAT_LOST_FOUND,
+	FEAT_VERITY,
 };
 
 static ssize_t f2fs_feature_show(struct f2fs_attr *a,
@@ -349,6 +353,7 @@ static ssize_t f2fs_feature_show(struct f2fs_attr *a,
 	case FEAT_QUOTA_INO:
 	case FEAT_INODE_CRTIME:
 	case FEAT_LOST_FOUND:
+	case FEAT_VERITY:
 		return snprintf(buf, PAGE_SIZE, "supported\n");
 	}
 	return 0;
@@ -429,6 +434,9 @@ F2FS_FEATURE_RO_ATTR(flexible_inline_xattr, FEAT_FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_RO_ATTR(quota_ino, FEAT_QUOTA_INO);
 F2FS_FEATURE_RO_ATTR(inode_crtime, FEAT_INODE_CRTIME);
 F2FS_FEATURE_RO_ATTR(lost_found, FEAT_LOST_FOUND);
+#ifdef CONFIG_F2FS_FS_VERITY
+F2FS_FEATURE_RO_ATTR(verity, FEAT_VERITY);
+#endif
 
 #define ATTR_LIST(name) (&f2fs_attr_##name.attr)
 static struct attribute *f2fs_attrs[] = {
@@ -485,6 +493,9 @@ static struct attribute *f2fs_feat_attrs[] = {
 	ATTR_LIST(quota_ino),
 	ATTR_LIST(inode_crtime),
 	ATTR_LIST(lost_found),
+#ifdef CONFIG_F2FS_FS_VERITY
+	ATTR_LIST(verity),
+#endif
 	NULL,
 };
 
-- 
2.18.0
