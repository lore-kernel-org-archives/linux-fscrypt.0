Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/2] fsverity: Remove filesystem specific build config option
Date: Wed, 31 Oct 2018 10:30:05 +0530
In-Reply-To: <20181031050005.17770-1-chandan@linux.vnet.ibm.com>
References: <20181031050005.17770-1-chandan@linux.vnet.ibm.com>
Message-Id: <20181031050005.17770-2-chandan@linux.vnet.ibm.com>
To: tytso@mit.edu, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

As a first step to avoid copy-pasting common code across filesystems
which implement fsverity, this commit removes filesystem specific
build config option (e.g. CONFIG_EXT4_FS_VERITY) and replaces it with
a build option (i.e. CONFIG_FS_VERITY) whose value affects all the
filesystems making use of fsverity.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---

 fs/ext4/Kconfig          | 20 --------------------
 fs/ext4/ext4.h           |  4 +---
 fs/ext4/super.c          |  6 +++---
 fs/ext4/sysfs.c          |  4 ++--
 fs/verity/Kconfig        |  2 +-
 include/linux/fsverity.h |  3 +--
 6 files changed, 8 insertions(+), 31 deletions(-)

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index e1002bb..031e5a8 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -96,26 +96,6 @@ config EXT4_FS_SECURITY
 	  If you are not using a security module that requires using
 	  extended attributes for file security labels, say N.
 
-config EXT4_FS_VERITY
-	bool "Ext4 Verity"
-	depends on EXT4_FS
-	select FS_VERITY
-	help
-	  This option enables fs-verity for ext4.  fs-verity is the
-	  dm-verity mechanism implemented at the file level.  Userspace
-	  can append a Merkle tree (hash tree) to a file, then enable
-	  fs-verity on the file.  ext4 will then transparently verify
-	  any data read from the file against the Merkle tree.  The file
-	  is also made read-only.
-
-	  This serves as an integrity check, but the availability of the
-	  Merkle tree root hash also allows efficiently supporting
-	  various use cases where normally the whole file would need to
-	  be hashed at once, such as auditing and authenticity
-	  verification (appraisal).
-
-	  If unsure, say N.
-
 config EXT4_DEBUG
 	bool "EXT4 debugging support"
 	depends on EXT4_FS
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 8858a80..9f9a7df 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -41,8 +41,6 @@
 #endif
 
 #include <linux/fscrypt.h>
-
-#define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
 #include <linux/fsverity.h>
 
 /*
@@ -2276,7 +2274,7 @@ ext4_fsblk_t ext4_inode_to_goal_block(struct inode *);
 
 static inline bool ext4_verity_inode(struct inode *inode)
 {
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 	return ext4_test_inode_flag(inode, EXT4_INODE_VERITY);
 #else
 	return false;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 059fab2..8981ed46 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1284,7 +1284,7 @@ static const struct fscrypt_operations ext4_cryptops = {
 };
 #endif
 
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 static int ext4_set_verity(struct inode *inode, loff_t data_i_size)
 {
 	int err;
@@ -1359,7 +1359,7 @@ static const struct fsverity_operations ext4_verityops = {
 	.set_verity		= ext4_set_verity,
 	.get_full_i_size	= ext4_get_verity_full_size,
 };
-#endif /* CONFIG_EXT4_FS_VERITY */
+#endif /* CONFIG_FS_VERITY */
 
 #ifdef CONFIG_QUOTA
 static const char * const quotatypes[] = INITQFNAMES;
@@ -4182,7 +4182,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
 #endif
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 	sb->s_vop = &ext4_verityops;
 #endif
 #ifdef CONFIG_QUOTA
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index d7f5d18..d8e37e8 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -223,7 +223,7 @@ EXT4_ATTR_FEATURE(meta_bg_resize);
 #ifdef CONFIG_FS_ENCRYPTION
 EXT4_ATTR_FEATURE(encryption);
 #endif
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 EXT4_ATTR_FEATURE(verity);
 #endif
 EXT4_ATTR_FEATURE(metadata_csum_seed);
@@ -235,7 +235,7 @@ static struct attribute *ext4_feat_attrs[] = {
 #ifdef CONFIG_FS_ENCRYPTION
 	ATTR_LIST(encryption),
 #endif
-#ifdef CONFIG_EXT4_FS_VERITY
+#ifdef CONFIG_FS_VERITY
 	ATTR_LIST(verity),
 #endif
 	ATTR_LIST(metadata_csum_seed),
diff --git a/fs/verity/Kconfig b/fs/verity/Kconfig
index 4854880..e7a1961 100644
--- a/fs/verity/Kconfig
+++ b/fs/verity/Kconfig
@@ -1,5 +1,5 @@
 config FS_VERITY
-	tristate "FS Verity (file-based integrity/authentication)"
+	bool "FS Verity (file-based integrity/authentication)"
 	depends on BLOCK
 	select CRYPTO
 	# SHA-256 is selected as it's intended to be the default hash algorithm.
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index 9d3371d..e7c467f 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -19,8 +19,7 @@ struct fsverity_operations {
 	int (*get_full_i_size)(struct inode *inode, loff_t *full_i_size_ret);
 };
 
-#if __FS_HAS_VERITY
-
+#ifdef CONFIG_FS_VERITY
 /* ioctl.c */
 extern int fsverity_ioctl_enable(struct file *filp, const void __user *arg);
 extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
-- 
2.9.5
