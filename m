Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 05/11] fscrypt: remove unneeded empty fscrypt_operations structs
Date: Mon,  9 Oct 2017 12:15:38 -0700
Message-Id: <20171009191544.43656-6-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In the case where a filesystem has been configured without encryption
support, there is no longer any need to initialize ->s_cop at all, since
none of the methods are ever called.

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/super.c  | 5 ++---
 fs/f2fs/super.c  | 5 ++---
 fs/ubifs/super.c | 7 ++-----
 3 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index bc63cdf194e3..04f3670748e7 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1244,9 +1244,6 @@ static const struct fscrypt_operations ext4_cryptops = {
 	.empty_dir		= ext4_empty_dir,
 	.max_namelen		= ext4_max_namelen,
 };
-#else
-static const struct fscrypt_operations ext4_cryptops = {
-};
 #endif
 
 #ifdef CONFIG_QUOTA
@@ -3998,7 +3995,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_op = &ext4_sops;
 	sb->s_export_op = &ext4_export_ops;
 	sb->s_xattr = ext4_xattr_handlers;
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
 	sb->s_cop = &ext4_cryptops;
+#endif
 #ifdef CONFIG_QUOTA
 	sb->dq_op = &ext4_quota_operations;
 	if (ext4_has_feature_quota(sb))
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 1cb41f711ab8..c1c7183b3527 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1597,9 +1597,6 @@ static const struct fscrypt_operations f2fs_cryptops = {
 	.empty_dir	= f2fs_empty_dir,
 	.max_namelen	= f2fs_max_namelen,
 };
-#else
-static const struct fscrypt_operations f2fs_cryptops = {
-};
 #endif
 
 static struct inode *f2fs_nfs_get_inode(struct super_block *sb,
@@ -2318,7 +2315,9 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 #endif
 
 	sb->s_op = &f2fs_sops;
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
 	sb->s_cop = &f2fs_cryptops;
+#endif
 	sb->s_xattr = f2fs_xattr_handlers;
 	sb->s_export_op = &f2fs_export_ops;
 	sb->s_magic = F2FS_SUPER_MAGIC;
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index adaca6088836..7503e7cdf870 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2007,11 +2007,6 @@ static struct ubifs_info *alloc_ubifs_info(struct ubi_volume_desc *ubi)
 	return c;
 }
 
-#ifndef CONFIG_UBIFS_FS_ENCRYPTION
-const struct fscrypt_operations ubifs_crypt_operations = {
-};
-#endif
-
 static int ubifs_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct ubifs_info *c = sb->s_fs_info;
@@ -2054,7 +2049,9 @@ static int ubifs_fill_super(struct super_block *sb, void *data, int silent)
 		sb->s_maxbytes = c->max_inode_sz = MAX_LFS_FILESIZE;
 	sb->s_op = &ubifs_super_operations;
 	sb->s_xattr = ubifs_xattr_handlers;
+#ifdef CONFIG_UBIFS_FS_ENCRYPTION
 	sb->s_cop = &ubifs_crypt_operations;
+#endif
 
 	mutex_lock(&c->umount_mutex);
 	err = mount_ubifs(c);
-- 
2.14.2.920.gcf0c67979c-goog
