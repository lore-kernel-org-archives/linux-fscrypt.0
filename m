Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga07-in.huawei.com ([45.249.212.35]:60885 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751595AbeCOKv5 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 15 Mar 2018 06:51:57 -0400
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v5 2/3] f2fs: introduce a new mount option test_dummy_encryption
Date: Thu, 15 Mar 2018 18:51:42 +0800
Message-ID: <20180315105143.133050-3-shengyong1@huawei.com>
In-Reply-To: <20180315105143.133050-1-shengyong1@huawei.com>
References: <20180315105143.133050-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patch introduces a new mount option `test_dummy_encryption'
to allow fscrypt to create a fake fscrypt context. This is used
by xfstests.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 Documentation/filesystems/f2fs.txt |  2 ++
 fs/f2fs/dir.c                      |  4 +++-
 fs/f2fs/f2fs.h                     |  8 ++++++++
 fs/f2fs/namei.c                    |  9 ++++++---
 fs/f2fs/super.c                    | 28 ++++++++++++++++++++++++++++
 5 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/f2fs.txt b/Documentation/filesystems/f2fs.txt
index 514e44983a8e..12a147c9f87f 100644
--- a/Documentation/filesystems/f2fs.txt
+++ b/Documentation/filesystems/f2fs.txt
@@ -189,6 +189,8 @@ fsync_mode=%s          Control the policy of fsync. Currently supports "posix"
                        fsync will be heavy and behaves in line with xfs, ext4
                        and btrfs, where xfstest generic/342 will pass, but the
                        performance will regress.
+test_dummy_encryption  Enable dummy encryption, which provides a fake fscrypt
+                       context. The fake fscrypt context is used by xfstests.
 
 ================================================================================
 DEBUGFS ENTRIES
diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 9a0d103b5052..fe661274ff10 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -361,6 +361,7 @@ struct page *init_inode_metadata(struct inode *inode, struct inode *dir,
 			struct page *dpage)
 {
 	struct page *page;
+	int dummy_encrypt = DUMMY_ENCRYPTION_ENABLED(F2FS_I_SB(dir));
 	int err;
 
 	if (is_inode_flag_set(inode, FI_NEW_INODE)) {
@@ -387,7 +388,8 @@ struct page *init_inode_metadata(struct inode *inode, struct inode *dir,
 		if (err)
 			goto put_error;
 
-		if (f2fs_encrypted_inode(dir) && f2fs_may_encrypt(inode)) {
+		if ((f2fs_encrypted_inode(dir) || dummy_encrypt) &&
+					f2fs_may_encrypt(inode)) {
 			err = fscrypt_inherit_context(dir, inode, page, false);
 			if (err)
 				goto put_error;
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index c0d74ff9a6d7..191ee5718369 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -133,6 +133,7 @@ struct f2fs_mount_info {
 	int whint_mode;
 	int alloc_mode;			/* segment allocation policy */
 	int fsync_mode;			/* fsync policy */
+	bool test_dummy_encryption;	/* test dummy encryption */
 };
 
 #define F2FS_FEATURE_ENCRYPT		0x0001
@@ -1077,6 +1078,13 @@ enum fsync_mode {
 	FSYNC_MODE_STRICT,	/* fsync behaves in line with ext4 */
 };
 
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#define DUMMY_ENCRYPTION_ENABLED(sbi) \
+			(unlikely(F2FS_OPTION(sbi).test_dummy_encryption))
+#else
+#define DUMMY_ENCRYPTION_ENABLED(sbi) (0)
+#endif
+
 struct f2fs_sb_info {
 	struct super_block *sb;			/* pointer to VFS super block */
 	struct proc_dir_entry *s_proc;		/* proc entry */
diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index f4ae46282eef..d5098efe577c 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -78,7 +78,8 @@ static struct inode *f2fs_new_inode(struct inode *dir, umode_t mode)
 	set_inode_flag(inode, FI_NEW_INODE);
 
 	/* If the directory encrypted, then we should encrypt the inode. */
-	if (f2fs_encrypted_inode(dir) && f2fs_may_encrypt(inode))
+	if ((f2fs_encrypted_inode(dir) || DUMMY_ENCRYPTION_ENABLED(sbi)) &&
+				f2fs_may_encrypt(inode))
 		f2fs_set_encrypted_inode(inode);
 
 	if (f2fs_sb_has_extra_attr(sbi->sb)) {
@@ -787,10 +788,12 @@ static int __f2fs_tmpfile(struct inode *dir, struct dentry *dentry,
 
 static int f2fs_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
-	if (unlikely(f2fs_cp_error(F2FS_I_SB(dir))))
+	struct f2fs_sb_info *sbi = F2FS_I_SB(dir);
+
+	if (unlikely(f2fs_cp_error(sbi)))
 		return -EIO;
 
-	if (f2fs_encrypted_inode(dir)) {
+	if (f2fs_encrypted_inode(dir) || DUMMY_ENCRYPTION_ENABLED(sbi)) {
 		int err = fscrypt_get_encryption_info(dir);
 		if (err)
 			return err;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index dcdae3f932e2..98b2c7ff1804 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -132,6 +132,7 @@ enum {
 	Opt_whint,
 	Opt_alloc,
 	Opt_fsync,
+	Opt_test_dummy_encryption,
 	Opt_err,
 };
 
@@ -188,6 +189,7 @@ static match_table_t f2fs_tokens = {
 	{Opt_whint, "whint_mode=%s"},
 	{Opt_alloc, "alloc_mode=%s"},
 	{Opt_fsync, "fsync_mode=%s"},
+	{Opt_test_dummy_encryption, "test_dummy_encryption"},
 	{Opt_err, NULL},
 };
 
@@ -744,6 +746,21 @@ static int parse_options(struct super_block *sb, char *options)
 			}
 			kfree(name);
 			break;
+		case Opt_test_dummy_encryption:
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+			if (!f2fs_sb_has_encrypt(sb)) {
+				f2fs_msg(sb, KERN_ERR, "Encrypt feature is off");
+				return -EINVAL;
+			}
+
+			F2FS_OPTION(sbi).test_dummy_encryption = true;
+			f2fs_msg(sb, KERN_INFO,
+					"Test dummy encryption mode enabled");
+#else
+			f2fs_msg(sb, KERN_INFO,
+					"Test dummy encryption mount option ignored");
+#endif
+			break;
 		default:
 			f2fs_msg(sb, KERN_ERR,
 				"Unrecognized mount option \"%s\" or missing value",
@@ -1314,6 +1331,10 @@ static int f2fs_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",whint_mode=%s", "user-based");
 	else if (F2FS_OPTION(sbi).whint_mode == WHINT_MODE_FS)
 		seq_printf(seq, ",whint_mode=%s", "fs-based");
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+	if (F2FS_OPTION(sbi).test_dummy_encryption)
+		seq_puts(seq, ",test_dummy_encryption");
+#endif
 
 	if (F2FS_OPTION(sbi).alloc_mode == ALLOC_MODE_DEFAULT)
 		seq_printf(seq, ",alloc_mode=%s", "default");
@@ -1335,6 +1356,7 @@ static void default_options(struct f2fs_sb_info *sbi)
 	F2FS_OPTION(sbi).whint_mode = WHINT_MODE_OFF;
 	F2FS_OPTION(sbi).alloc_mode = ALLOC_MODE_DEFAULT;
 	F2FS_OPTION(sbi).fsync_mode = FSYNC_MODE_POSIX;
+	F2FS_OPTION(sbi).test_dummy_encryption = false;
 	sbi->readdir_ra = 1;
 
 	set_opt(sbi, BG_GC);
@@ -1908,6 +1930,11 @@ static int f2fs_set_context(struct inode *inode, const void *ctx, size_t len,
 				ctx, len, fs_data, XATTR_CREATE);
 }
 
+static bool f2fs_dummy_context(struct inode *inode)
+{
+	return DUMMY_ENCRYPTION_ENABLED(F2FS_I_SB(inode));
+}
+
 static unsigned f2fs_max_namelen(struct inode *inode)
 {
 	return S_ISLNK(inode->i_mode) ?
@@ -1918,6 +1945,7 @@ static const struct fscrypt_operations f2fs_cryptops = {
 	.key_prefix	= "f2fs:",
 	.get_context	= f2fs_get_context,
 	.set_context	= f2fs_set_context,
+	.dummy_context	= f2fs_dummy_context,
 	.empty_dir	= f2fs_empty_dir,
 	.max_namelen	= f2fs_max_namelen,
 };
-- 
2.16.2

