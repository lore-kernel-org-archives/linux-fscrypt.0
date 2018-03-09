Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6209 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751284AbeCIHxb (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 9 Mar 2018 02:53:31 -0500
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v4 1/3] f2fs: introduce F2FS_FEATURE_LOST_FOUND feature
Date: Fri, 9 Mar 2018 15:53:10 +0800
Message-ID: <20180309075312.62357-2-shengyong1@huawei.com>
In-Reply-To: <20180309075312.62357-1-shengyong1@huawei.com>
References: <20180309075312.62357-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patch introduces a new feature, F2FS_FEATURE_LOST_FOUND, which
is set by mkfs. mkfs creates a directory named lost+found, which saves
unreachable files. If fsck finds a file which has no parent, or its
parent is removed by fsck, the file will be placed under lost+found
directory by fsck.

lost+found directory could not be encrypted. As a result, the root
directory cannot be encrypted too. So if LOST_FOUND feature is enabled,
let's avoid to encrypt root directory.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 fs/f2fs/f2fs.h  |  2 ++
 fs/f2fs/super.c | 12 ++++++++++++
 fs/f2fs/sysfs.c |  7 +++++++
 3 files changed, 21 insertions(+)

diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index f6dc70666ebb..31f39ab7fce4 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -125,6 +125,7 @@ struct f2fs_mount_info {
 #define F2FS_FEATURE_FLEXIBLE_INLINE_XATTR	0x0040
 #define F2FS_FEATURE_QUOTA_INO		0x0080
 #define F2FS_FEATURE_INODE_CRTIME	0x0100
+#define F2FS_FEATURE_LOST_FOUND		0x0200
 
 #define F2FS_HAS_FEATURE(sb, mask)					\
 	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
@@ -3211,6 +3212,7 @@ F2FS_FEATURE_FUNCS(inode_chksum, INODE_CHKSUM);
 F2FS_FEATURE_FUNCS(flexible_inline_xattr, FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_FUNCS(quota_ino, QUOTA_INO);
 F2FS_FEATURE_FUNCS(inode_crtime, INODE_CRTIME);
+F2FS_FEATURE_FUNCS(lost_found, LOST_FOUND);
 
 #ifdef CONFIG_BLK_DEV_ZONED
 static inline int get_blkz_type(struct f2fs_sb_info *sbi,
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 30b93ad44b9d..b9a6b97c3bd3 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1865,6 +1865,18 @@ static int f2fs_get_context(struct inode *inode, void *ctx, size_t len)
 static int f2fs_set_context(struct inode *inode, const void *ctx, size_t len,
 							void *fs_data)
 {
+	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
+
+	/*
+	 * Encrypting the root directory is not allowed because fsck
+	 * expects lost+found directory to exist and remain unencrypted
+	 * if LOST_FOUND feature is enabled.
+	 *
+	 */
+	if (f2fs_sb_has_lost_found(sbi->sb) &&
+			inode->i_ino == F2FS_ROOT_INO(sbi))
+		return -EPERM;
+
 	return f2fs_setxattr(inode, F2FS_XATTR_INDEX_ENCRYPTION,
 				F2FS_XATTR_NAME_ENCRYPTION_CONTEXT,
 				ctx, len, fs_data, XATTR_CREATE);
diff --git a/fs/f2fs/sysfs.c b/fs/f2fs/sysfs.c
index 23a2d8d66c43..53c6785c1916 100644
--- a/fs/f2fs/sysfs.c
+++ b/fs/f2fs/sysfs.c
@@ -116,6 +116,9 @@ static ssize_t features_show(struct f2fs_attr *a,
 	if (f2fs_sb_has_inode_crtime(sb))
 		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
 				len ? ", " : "", "inode_crtime");
+	if (f2fs_sb_has_lost_found(sb))
+		len += snprintf(buf + len, PAGE_SIZE - len, "%s%s",
+				len ? ", " : "", "lost_found");
 	len += snprintf(buf + len, PAGE_SIZE - len, "\n");
 	return len;
 }
@@ -292,6 +295,7 @@ enum feat_id {
 	FEAT_FLEXIBLE_INLINE_XATTR,
 	FEAT_QUOTA_INO,
 	FEAT_INODE_CRTIME,
+	FEAT_LOST_FOUND,
 };
 
 static ssize_t f2fs_feature_show(struct f2fs_attr *a,
@@ -307,6 +311,7 @@ static ssize_t f2fs_feature_show(struct f2fs_attr *a,
 	case FEAT_FLEXIBLE_INLINE_XATTR:
 	case FEAT_QUOTA_INO:
 	case FEAT_INODE_CRTIME:
+	case FEAT_LOST_FOUND:
 		return snprintf(buf, PAGE_SIZE, "supported\n");
 	}
 	return 0;
@@ -386,6 +391,7 @@ F2FS_FEATURE_RO_ATTR(inode_checksum, FEAT_INODE_CHECKSUM);
 F2FS_FEATURE_RO_ATTR(flexible_inline_xattr, FEAT_FLEXIBLE_INLINE_XATTR);
 F2FS_FEATURE_RO_ATTR(quota_ino, FEAT_QUOTA_INO);
 F2FS_FEATURE_RO_ATTR(inode_crtime, FEAT_INODE_CRTIME);
+F2FS_FEATURE_RO_ATTR(lost_found, FEAT_LOST_FOUND);
 
 #define ATTR_LIST(name) (&f2fs_attr_##name.attr)
 static struct attribute *f2fs_attrs[] = {
@@ -441,6 +447,7 @@ static struct attribute *f2fs_feat_attrs[] = {
 	ATTR_LIST(flexible_inline_xattr),
 	ATTR_LIST(quota_ino),
 	ATTR_LIST(inode_crtime),
+	ATTR_LIST(lost_found),
 	NULL,
 };
 
-- 
2.14.1

