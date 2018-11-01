Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Thu,  1 Nov 2018 15:52:28 -0700
Message-Id: <20181101225230.88058-11-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 10/12] ext4: add basic fs-verity support
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

Add basic fs-verity support to ext4.  fs-verity is a filesystem feature
that enables transparent integrity protection and authentication of
read-only files.  It uses a dm-verity like mechanism at the file level:
a Merkle tree is used to verify any block in the file in log(filesize)
time.  It is implemented mainly by helper functions in fs/verity/.
See Documentation/filesystems/fsverity.rst for details.

This patch adds everything except the data verification hooks that will
needed in ->readpages().

On ext4, enabling fs-verity on a file requires that the filesystem has
the 'verity' feature, e.g. that it was formatted with
'mkfs.ext4 -O verity' or had 'tune2fs -O verity' run on it.
This requires e2fsprogs 1.44.4-2 or later.

In ext4, we choose to retain the fs-verity metadata past the end of the
file rather than trying to move it into an external inode xattr, since
in practice keeping the metadata in-line actually results in the
simplest and most efficient implementation.  One non-obvious advantage
of keeping the verity metadata in-line is that when fs-verity is
combined with fscrypt, the verity metadata naturally gets encrypted too;
this is actually necessary because it contains hashes of the plaintext.

We also choose to keep the on-disk i_size equal to the original file
size, in order to make the 'verity' feature a RO_COMPAT feature.  Thus,
ext4 has to find the fsverity_footer by looking in the last extent.

Co-developed-by: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Theodore Ts'o <tytso@mit.edu>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/Kconfig | 20 +++++++++++
 fs/ext4/ext4.h  | 20 ++++++++++-
 fs/ext4/file.c  |  6 ++++
 fs/ext4/inode.c |  8 +++++
 fs/ext4/ioctl.c | 12 +++++++
 fs/ext4/super.c | 91 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/ext4/sysfs.c |  6 ++++
 7 files changed, 162 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index a453cc87082b5..5a76125ac0f8a 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -111,6 +111,26 @@ config EXT4_FS_ENCRYPTION
 	default y
 	depends on EXT4_ENCRYPTION
 
+config EXT4_FS_VERITY
+	bool "Ext4 Verity"
+	depends on EXT4_FS
+	select FS_VERITY
+	help
+	  This option enables fs-verity for ext4.  fs-verity is the
+	  dm-verity mechanism implemented at the file level.  Userspace
+	  can append a Merkle tree (hash tree) to a file, then enable
+	  fs-verity on the file.  ext4 will then transparently verify
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
 config EXT4_DEBUG
 	bool "EXT4 debugging support"
 	depends on EXT4_FS
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 12f90d48ba613..e5475a629ed80 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -43,6 +43,9 @@
 #define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
 #include <linux/fscrypt.h>
 
+#define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
+#include <linux/fsverity.h>
+
 #include <linux/compiler.h>
 
 /* Until this gets included into linux/compiler-gcc.h */
@@ -405,6 +408,7 @@ struct flex_groups {
 #define EXT4_TOPDIR_FL			0x00020000 /* Top of directory hierarchies*/
 #define EXT4_HUGE_FILE_FL               0x00040000 /* Set to each huge file */
 #define EXT4_EXTENTS_FL			0x00080000 /* Inode uses extents */
+#define EXT4_VERITY_FL			0x00100000 /* Verity protected inode */
 #define EXT4_EA_INODE_FL	        0x00200000 /* Inode used for large EA */
 #define EXT4_EOFBLOCKS_FL		0x00400000 /* Blocks allocated beyond EOF */
 #define EXT4_INLINE_DATA_FL		0x10000000 /* Inode has inline data. */
@@ -472,6 +476,7 @@ enum {
 	EXT4_INODE_TOPDIR	= 17,	/* Top of directory hierarchies*/
 	EXT4_INODE_HUGE_FILE	= 18,	/* Set to each huge file */
 	EXT4_INODE_EXTENTS	= 19,	/* Inode uses extents */
+	EXT4_INODE_VERITY	= 20,	/* Verity protected inode */
 	EXT4_INODE_EA_INODE	= 21,	/* Inode used for large EA */
 	EXT4_INODE_EOFBLOCKS	= 22,	/* Blocks allocated beyond EOF */
 	EXT4_INODE_INLINE_DATA	= 28,	/* Data in inode. */
@@ -517,6 +522,7 @@ static inline void ext4_check_flag_values(void)
 	CHECK_FLAG_VALUE(TOPDIR);
 	CHECK_FLAG_VALUE(HUGE_FILE);
 	CHECK_FLAG_VALUE(EXTENTS);
+	CHECK_FLAG_VALUE(VERITY);
 	CHECK_FLAG_VALUE(EA_INODE);
 	CHECK_FLAG_VALUE(EOFBLOCKS);
 	CHECK_FLAG_VALUE(INLINE_DATA);
@@ -1654,6 +1660,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 #define EXT4_FEATURE_RO_COMPAT_METADATA_CSUM	0x0400
 #define EXT4_FEATURE_RO_COMPAT_READONLY		0x1000
 #define EXT4_FEATURE_RO_COMPAT_PROJECT		0x2000
+#define EXT4_FEATURE_RO_COMPAT_VERITY		0x8000
 
 #define EXT4_FEATURE_INCOMPAT_COMPRESSION	0x0001
 #define EXT4_FEATURE_INCOMPAT_FILETYPE		0x0002
@@ -1742,6 +1749,7 @@ EXT4_FEATURE_RO_COMPAT_FUNCS(bigalloc,		BIGALLOC)
 EXT4_FEATURE_RO_COMPAT_FUNCS(metadata_csum,	METADATA_CSUM)
 EXT4_FEATURE_RO_COMPAT_FUNCS(readonly,		READONLY)
 EXT4_FEATURE_RO_COMPAT_FUNCS(project,		PROJECT)
+EXT4_FEATURE_RO_COMPAT_FUNCS(verity,		VERITY)
 
 EXT4_FEATURE_INCOMPAT_FUNCS(compression,	COMPRESSION)
 EXT4_FEATURE_INCOMPAT_FUNCS(filetype,		FILETYPE)
@@ -1797,7 +1805,8 @@ EXT4_FEATURE_INCOMPAT_FUNCS(encrypt,		ENCRYPT)
 					 EXT4_FEATURE_RO_COMPAT_BIGALLOC |\
 					 EXT4_FEATURE_RO_COMPAT_METADATA_CSUM|\
 					 EXT4_FEATURE_RO_COMPAT_QUOTA |\
-					 EXT4_FEATURE_RO_COMPAT_PROJECT)
+					 EXT4_FEATURE_RO_COMPAT_PROJECT |\
+					 EXT4_FEATURE_RO_COMPAT_VERITY)
 
 #define EXTN_FEATURE_FUNCS(ver) \
 static inline bool ext4_has_unknown_ext##ver##_compat_features(struct super_block *sb) \
@@ -2293,6 +2302,15 @@ static inline bool ext4_encrypted_inode(struct inode *inode)
 	return ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT);
 }
 
+static inline bool ext4_verity_inode(struct inode *inode)
+{
+#ifdef CONFIG_EXT4_FS_VERITY
+	return ext4_test_inode_flag(inode, EXT4_INODE_VERITY);
+#else
+	return false;
+#endif
+}
+
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 static inline int ext4_fname_setup_filename(struct inode *dir,
 			const struct qstr *iname,
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 69d65d49837bb..cb4b69ef01a22 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -444,6 +444,12 @@ static int ext4_file_open(struct inode * inode, struct file * filp)
 	if (ret)
 		return ret;
 
+	if (ext4_verity_inode(inode)) {
+		ret = fsverity_file_open(inode, filp);
+		if (ret)
+			return ret;
+	}
+
 	/*
 	 * Set up the jbd2_inode if we are opening the inode for
 	 * writing and the journal is present
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 05f01fbd9c7fb..c624c83bbad26 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4723,6 +4723,8 @@ static bool ext4_should_use_dax(struct inode *inode)
 		return false;
 	if (ext4_encrypted_inode(inode))
 		return false;
+	if (ext4_verity_inode(inode))
+		return false;
 	return true;
 }
 
@@ -5505,6 +5507,12 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (error)
 		return error;
 
+	if (ext4_verity_inode(inode)) {
+		error = fsverity_prepare_setattr(dentry, attr);
+		if (error)
+			return error;
+	}
+
 	if (is_quota_modification(inode, attr)) {
 		error = dquot_initialize(inode);
 		if (error)
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 0edee31913d1f..9bb6cc1ae8ceb 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1020,6 +1020,16 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 	case EXT4_IOC_GET_ENCRYPTION_POLICY:
 		return fscrypt_ioctl_get_policy(filp, (void __user *)arg);
 
+	case FS_IOC_ENABLE_VERITY:
+		if (!ext4_has_feature_verity(sb))
+			return -EOPNOTSUPP;
+		return fsverity_ioctl_enable(filp, (const void __user *)arg);
+
+	case FS_IOC_MEASURE_VERITY:
+		if (!ext4_has_feature_verity(sb))
+			return -EOPNOTSUPP;
+		return fsverity_ioctl_measure(filp, (void __user *)arg);
+
 	case EXT4_IOC_FSGETXATTR:
 	{
 		struct fsxattr fa;
@@ -1138,6 +1148,8 @@ long ext4_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case EXT4_IOC_SET_ENCRYPTION_POLICY:
 	case EXT4_IOC_GET_ENCRYPTION_PWSALT:
 	case EXT4_IOC_GET_ENCRYPTION_POLICY:
+	case FS_IOC_ENABLE_VERITY:
+	case FS_IOC_MEASURE_VERITY:
 	case EXT4_IOC_SHUTDOWN:
 	case FS_IOC_GETFSMAP:
 		break;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index a221f1cdf7046..c4a66b64ea604 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1144,6 +1144,7 @@ void ext4_clear_inode(struct inode *inode)
 		EXT4_I(inode)->jinode = NULL;
 	}
 	fscrypt_put_encryption_info(inode);
+	fsverity_cleanup_inode(inode);
 }
 
 static struct inode *ext4_nfs_get_inode(struct super_block *sb,
@@ -1315,6 +1316,93 @@ static const struct fscrypt_operations ext4_cryptops = {
 };
 #endif
 
+#ifdef CONFIG_EXT4_FS_VERITY
+static int ext4_set_verity(struct inode *inode, loff_t data_i_size)
+{
+	int err;
+	handle_t *handle;
+	struct ext4_iloc iloc;
+
+	err = ext4_convert_inline_data(inode);
+	if (err)
+		return err;
+
+	if (!ext4_test_inode_flag(inode, EXT4_INODE_EXTENTS)) {
+		ext4_warning_inode(inode,
+				   "fs-verity is only allowed on extent-based files");
+		return -EINVAL;
+	}
+
+	/* Remove extents past EOF; see ext4_get_verity_full_size() */
+	err = ext4_truncate(inode);
+	if (err)
+		return err;
+
+	handle = ext4_journal_start(inode, EXT4_HT_INODE, 1);
+	if (IS_ERR(handle))
+		return PTR_ERR(handle);
+	err = ext4_reserve_inode_write(handle, inode, &iloc);
+	if (err == 0) {
+		ext4_set_inode_flag(inode, EXT4_INODE_VERITY);
+		EXT4_I(inode)->i_disksize = data_i_size;
+		err = ext4_mark_iloc_dirty(handle, inode, &iloc);
+	}
+	ext4_journal_stop(handle);
+
+	return err;
+}
+
+/*
+ * Retrieve the offset, in bytes, to the end of the verity metadata.  Ext4
+ * stores the verity metadata beyond EOF, but sets the on-disk i_size to the
+ * original data size in order to make verity an RO_COMPAT filesystem feature.
+ * Therefore, it has to compute the end offset implicitly via the end of the
+ * last extent.  Trailing zeroes after the footer are tolerated.
+ */
+static int ext4_get_metadata_end(struct inode *inode, loff_t *metadata_end_ret)
+{
+	struct ext4_ext_path *path;
+	struct ext4_extent *last_extent;
+	u32 end_lblk;
+	int err;
+
+	if (ext4_has_inline_data(inode)) {
+		EXT4_ERROR_INODE(inode, "verity file has inline data");
+		return -EFSCORRUPTED;
+	}
+
+	if (!ext4_test_inode_flag(inode, EXT4_INODE_EXTENTS)) {
+		EXT4_ERROR_INODE(inode, "verity file doesn't use extents");
+		return -EFSCORRUPTED;
+	}
+
+	path = ext4_find_extent(inode, EXT_MAX_BLOCKS - 1, NULL, 0);
+	if (IS_ERR(path))
+		return PTR_ERR(path);
+
+	last_extent = path[path->p_depth].p_ext;
+	if (!last_extent) {
+		EXT4_ERROR_INODE(inode, "verity file has no extents");
+		err = -EFSCORRUPTED;
+		goto out_drop_path;
+	}
+
+	end_lblk = le32_to_cpu(last_extent->ee_block) +
+		   ext4_ext_get_actual_len(last_extent);
+	*metadata_end_ret = (loff_t)end_lblk << inode->i_blkbits;
+	err = 0;
+out_drop_path:
+	ext4_ext_drop_refs(path);
+	kfree(path);
+	return err;
+}
+
+static const struct fsverity_operations ext4_verityops = {
+	.set_verity		= ext4_set_verity,
+	.get_metadata_end	= ext4_get_metadata_end,
+};
+#endif /* CONFIG_EXT4_FS_VERITY */
+
 #ifdef CONFIG_QUOTA
 static const char * const quotatypes[] = INITQFNAMES;
 #define QTYPE2NAME(t) (quotatypes[t])
@@ -4146,6 +4234,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
 #endif
+#ifdef CONFIG_EXT4_FS_VERITY
+	sb->s_vop = &ext4_verityops;
+#endif
 #ifdef CONFIG_QUOTA
 	sb->dq_op = &ext4_quota_operations;
 	if (ext4_has_feature_quota(sb))
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 9212a026a1f12..8e86087c2f039 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -227,6 +227,9 @@ EXT4_ATTR_FEATURE(meta_bg_resize);
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 EXT4_ATTR_FEATURE(encryption);
 #endif
+#ifdef CONFIG_EXT4_FS_VERITY
+EXT4_ATTR_FEATURE(verity);
+#endif
 EXT4_ATTR_FEATURE(metadata_csum_seed);
 
 static struct attribute *ext4_feat_attrs[] = {
@@ -235,6 +238,9 @@ static struct attribute *ext4_feat_attrs[] = {
 	ATTR_LIST(meta_bg_resize),
 #ifdef CONFIG_EXT4_FS_ENCRYPTION
 	ATTR_LIST(encryption),
+#endif
+#ifdef CONFIG_EXT4_FS_VERITY
+	ATTR_LIST(verity),
 #endif
 	ATTR_LIST(metadata_csum_seed),
 	NULL,
-- 
2.19.1.568.g152ad8e336-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
