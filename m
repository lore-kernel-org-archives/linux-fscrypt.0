Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Thu,  1 Nov 2018 15:52:30 -0700
Message-Id: <20181101225230.88058-13-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 12/12] f2fs: fs-verity support
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
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add fs-verity support to f2fs.  fs-verity is a filesystem feature that
enables transparent integrity protection and authentication of read-only
files.  It uses a dm-verity like mechanism at the file level: a Merkle
tree is used to verify any block in the file in log(filesize) time.  It
is implemented mainly by helper functions in fs/verity/.
See Documentation/filesystems/fsverity.rst for details.

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

Like we did in ext4, in f2fs we choose to retain the fs-verity metadata
past the end of the file rather than move it into an xattr, since in
practice this results in the simplest and most efficient implementation.
For example, it avoids needing to add support for external inode xattrs
and for xattr encryption.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/Kconfig | 20 +++++++++++++++++
 fs/f2fs/data.c  | 43 +++++++++++++++++++++++++++++++-----
 fs/f2fs/f2fs.h  | 17 ++++++++++++---
 fs/f2fs/file.c  | 58 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/f2fs/inode.c |  3 ++-
 fs/f2fs/super.c | 30 +++++++++++++++++++++++++
 fs/f2fs/sysfs.c | 11 ++++++++++
 7 files changed, 173 insertions(+), 9 deletions(-)

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
index b293cb3e27a22..09d9fc1676a7e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -73,6 +73,7 @@ static enum count_type __read_io_type(struct page *page)
 enum bio_post_read_step {
 	STEP_INITIAL = 0,
 	STEP_DECRYPT,
+	STEP_VERITY,
 };
 
 struct bio_post_read_ctx {
@@ -119,8 +120,23 @@ static void decrypt_work(struct work_struct *work)
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
@@ -130,6 +146,14 @@ static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
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
@@ -566,7 +590,8 @@ void f2fs_submit_page_write(struct f2fs_io_info *fio)
 }
 
 static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
-					unsigned nr_pages, unsigned op_flag)
+				      unsigned nr_pages, unsigned op_flag,
+				      pgoff_t first_idx)
 {
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
 	struct bio *bio;
@@ -585,6 +610,11 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 
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
@@ -603,7 +633,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 static int f2fs_submit_page_read(struct inode *inode, struct page *page,
 							block_t blkaddr)
 {
-	struct bio *bio = f2fs_grab_read_bio(inode, blkaddr, 1, 0);
+	struct bio *bio = f2fs_grab_read_bio(inode, blkaddr, 1, 0, page->index);
 
 	if (IS_ERR(bio))
 		return PTR_ERR(bio);
@@ -1540,8 +1570,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 
 		block_in_file = (sector_t)page->index;
 		last_block = block_in_file + nr_pages;
-		last_block_in_file = (i_size_read(inode) + blocksize - 1) >>
-								blkbits;
+		last_block_in_file = (fsverity_full_i_size(inode) +
+				      blocksize - 1) >> blkbits;
 		if (last_block > last_block_in_file)
 			last_block = last_block_in_file;
 
@@ -1582,6 +1612,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 				goto set_error_page;
 		} else {
 			zero_user_segment(page, 0, PAGE_SIZE);
+			if (!fsverity_check_hole(inode, page))
+				goto set_error_page;
 			if (!PageUptodate(page))
 				SetPageUptodate(page);
 			unlock_page(page);
@@ -1600,7 +1632,8 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 		}
 		if (bio == NULL) {
 			bio = f2fs_grab_read_bio(inode, block_nr, nr_pages,
-					is_readahead ? REQ_RAHEAD : 0);
+					is_readahead ? REQ_RAHEAD : 0,
+					page->index);
 			if (IS_ERR(bio)) {
 				bio = NULL;
 				goto set_error_page;
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 1e031971a466c..dadb5f468f20e 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -27,6 +27,9 @@
 #define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_F2FS_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
+#define __FS_HAS_VERITY IS_ENABLED(CONFIG_F2FS_FS_VERITY)
+#include <linux/fsverity.h>
+
 #ifdef CONFIG_F2FS_CHECK_FS
 #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
 #else
@@ -149,7 +152,7 @@ struct f2fs_mount_info {
 #define F2FS_FEATURE_QUOTA_INO		0x0080
 #define F2FS_FEATURE_INODE_CRTIME	0x0100
 #define F2FS_FEATURE_LOST_FOUND		0x0200
-#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
+#define F2FS_FEATURE_VERITY		0x0400
 #define F2FS_FEATURE_SB_CHKSUM		0x0800
 
 #define F2FS_HAS_FEATURE(sb, mask)					\
@@ -623,7 +626,7 @@ enum {
 #define FADVISE_ENC_NAME_BIT	0x08
 #define FADVISE_KEEP_SIZE_BIT	0x10
 #define FADVISE_HOT_BIT		0x20
-#define FADVISE_VERITY_BIT	0x40	/* reserved */
+#define FADVISE_VERITY_BIT	0x40
 
 #define FADVISE_MODIFIABLE_BITS	(FADVISE_COLD_BIT | FADVISE_HOT_BIT)
 
@@ -643,6 +646,8 @@ enum {
 #define file_is_hot(inode)	is_file(inode, FADVISE_HOT_BIT)
 #define file_set_hot(inode)	set_file(inode, FADVISE_HOT_BIT)
 #define file_clear_hot(inode)	clear_file(inode, FADVISE_HOT_BIT)
+#define file_is_verity(inode)	is_file(inode, FADVISE_VERITY_BIT)
+#define file_set_verity(inode)	set_file(inode, FADVISE_VERITY_BIT)
 
 #define DEF_DIR_LEVEL		0
 
@@ -3449,13 +3454,18 @@ static inline void f2fs_set_encrypted_inode(struct inode *inode)
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
@@ -3473,6 +3483,7 @@ F2FS_FEATURE_FUNCS(flexible_inline_xattr, FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_FUNCS(quota_ino, QUOTA_INO);
 F2FS_FEATURE_FUNCS(inode_crtime, INODE_CRTIME);
 F2FS_FEATURE_FUNCS(lost_found, LOST_FOUND);
+F2FS_FEATURE_FUNCS(verity, VERITY);
 F2FS_FEATURE_FUNCS(sb_chksum, SB_CHKSUM);
 
 #ifdef CONFIG_BLK_DEV_ZONED
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 88b124677189b..87794b2a45ff8 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -491,6 +491,12 @@ static int f2fs_file_open(struct inode *inode, struct file *filp)
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
@@ -695,6 +701,22 @@ int f2fs_getattr(const struct path *path, struct kstat *stat,
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
@@ -778,6 +800,12 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
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
@@ -2954,6 +2982,30 @@ static int f2fs_ioc_precache_extents(struct file *filp, unsigned long arg)
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
@@ -3010,6 +3062,10 @@ long f2fs_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
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
@@ -3117,6 +3173,8 @@ long f2fs_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case F2FS_IOC_GET_PIN_FILE:
 	case F2FS_IOC_SET_PIN_FILE:
 	case F2FS_IOC_PRECACHE_EXTENTS:
+	case FS_IOC_ENABLE_VERITY:
+	case FS_IOC_MEASURE_VERITY:
 		break;
 	default:
 		return -ENOIOCTLCMD;
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index 91ceee0ed4c40..ddef483ad689d 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -509,7 +509,7 @@ void f2fs_update_inode(struct inode *inode, struct page *node_page)
 	ri->i_uid = cpu_to_le32(i_uid_read(inode));
 	ri->i_gid = cpu_to_le32(i_gid_read(inode));
 	ri->i_links = cpu_to_le32(inode->i_nlink);
-	ri->i_size = cpu_to_le64(i_size_read(inode));
+	ri->i_size = cpu_to_le64(fsverity_full_i_size(inode));
 	ri->i_blocks = cpu_to_le64(SECTOR_TO_BLOCK(inode->i_blocks) + 1);
 
 	if (et) {
@@ -732,6 +732,7 @@ void f2fs_evict_inode(struct inode *inode)
 	}
 out_clear:
 	fscrypt_put_encryption_info(inode);
+	fsverity_cleanup_inode(inode);
 	clear_inode(inode);
 }
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index af58b2cc21b81..adf38c1b64141 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -2197,6 +2197,33 @@ static const struct fscrypt_operations f2fs_cryptops = {
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
+static int f2fs_get_metadata_end(struct inode *inode, loff_t *metadata_end_ret)
+{
+	/* f2fs on-disk size is the full file size including verity metadata */
+	*metadata_end_ret = i_size_read(inode);
+	return 0;
+}
+
+static const struct fsverity_operations f2fs_verityops = {
+	.set_verity		= f2fs_set_verity,
+	.get_metadata_end	= f2fs_get_metadata_end,
+};
+#endif /* CONFIG_F2FS_FS_VERITY */
+
 static struct inode *f2fs_nfs_get_inode(struct super_block *sb,
 		u64 ino, u32 generation)
 {
@@ -3118,6 +3145,9 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
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
index b777cbdd796ba..5599c9ac4426d 100644
--- a/fs/f2fs/sysfs.c
+++ b/fs/f2fs/sysfs.c
@@ -117,6 +117,9 @@ static ssize_t features_show(struct f2fs_attr *a,
 	if (f2fs_sb_has_lost_found(sb))
 		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
 				len ? ", " : "", "lost_found");
+	if (f2fs_sb_has_verity(sb))
+		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
+				len ? ", " : "", "verity");
 	if (f2fs_sb_has_sb_chksum(sb))
 		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
 				len ? ", " : "", "sb_checksum");
@@ -337,6 +340,7 @@ enum feat_id {
 	FEAT_QUOTA_INO,
 	FEAT_INODE_CRTIME,
 	FEAT_LOST_FOUND,
+	FEAT_VERITY,
 	FEAT_SB_CHECKSUM,
 };
 
@@ -354,6 +358,7 @@ static ssize_t f2fs_feature_show(struct f2fs_attr *a,
 	case FEAT_QUOTA_INO:
 	case FEAT_INODE_CRTIME:
 	case FEAT_LOST_FOUND:
+	case FEAT_VERITY:
 	case FEAT_SB_CHECKSUM:
 		return snprintf(buf, PAGE_SIZE, "supported\n");
 	}
@@ -439,6 +444,9 @@ F2FS_FEATURE_RO_ATTR(flexible_inline_xattr, FEAT_FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_RO_ATTR(quota_ino, FEAT_QUOTA_INO);
 F2FS_FEATURE_RO_ATTR(inode_crtime, FEAT_INODE_CRTIME);
 F2FS_FEATURE_RO_ATTR(lost_found, FEAT_LOST_FOUND);
+#ifdef CONFIG_F2FS_FS_VERITY
+F2FS_FEATURE_RO_ATTR(verity, FEAT_VERITY);
+#endif
 F2FS_FEATURE_RO_ATTR(sb_checksum, FEAT_SB_CHECKSUM);
 
 #define ATTR_LIST(name) (&f2fs_attr_##name.attr)
@@ -499,6 +507,9 @@ static struct attribute *f2fs_feat_attrs[] = {
 	ATTR_LIST(quota_ino),
 	ATTR_LIST(inode_crtime),
 	ATTR_LIST(lost_found),
+#ifdef CONFIG_F2FS_FS_VERITY
+	ATTR_LIST(verity),
+#endif
 	ATTR_LIST(sb_checksum),
 	NULL,
 };
-- 
2.19.1.568.g152ad8e336-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
