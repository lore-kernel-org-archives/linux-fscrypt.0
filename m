Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6210 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751305AbeCIHxd (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 9 Mar 2018 02:53:33 -0500
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v4 2/3] f2fs: introduce a new mount option test_dummy_encryption
Date: Fri, 9 Mar 2018 15:53:11 +0800
Message-ID: <20180309075312.62357-3-shengyong1@huawei.com>
In-Reply-To: <20180309075312.62357-1-shengyong1@huawei.com>
References: <20180309075312.62357-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patch introduces a new mount option `test_dummy_encryption' to
allow fscrypt to create a fake fscrypt context. This is used by xfstests.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 fs/f2fs/dir.c   |  4 +++-
 fs/f2fs/f2fs.h  | 11 +++++++++++
 fs/f2fs/namei.c |  9 ++++++---
 fs/f2fs/super.c | 31 +++++++++++++++++++++++++++++++
 4 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 797eb05cb538..73ddc35fba4f 100644
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
index 31f39ab7fce4..c0dbd8b6050b 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -1053,6 +1053,15 @@ enum {
 	ALLOC_MODE_REUSE,	/* reuse segments as much as possible */
 };
 
+#define F2FS_MF_TEST_DUMMY_ENCRYPTION	0x0001
+
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#define DUMMY_ENCRYPTION_ENABLED(sbi) (unlikely((sbi)->mount_flags & \
+						F2FS_MF_TEST_DUMMY_ENCRYPTION))
+#else
+#define DUMMY_ENCRYPTION_ENABLED(sbi) (0)
+#endif
+
 struct f2fs_sb_info {
 	struct super_block *sb;			/* pointer to VFS super block */
 	struct proc_dir_entry *s_proc;		/* proc entry */
@@ -1242,6 +1251,8 @@ struct f2fs_sb_info {
 
 	/* segment allocation policy */
 	int alloc_mode;
+
+	unsigned int mount_flags;
 };
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 318dfe870cb5..5dd6a112e13d 100644
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
@@ -788,10 +789,12 @@ static int __f2fs_tmpfile(struct inode *dir, struct dentry *dentry,
 
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
index b9a6b97c3bd3..345e4f63f6fc 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -131,6 +131,7 @@ enum {
 	Opt_jqfmt_vfsv1,
 	Opt_whint,
 	Opt_alloc,
+	Opt_test_dummy_encryption,
 	Opt_err,
 };
 
@@ -186,6 +187,7 @@ static match_table_t f2fs_tokens = {
 	{Opt_jqfmt_vfsv1, "jqfmt=vfsv1"},
 	{Opt_whint, "whint_mode=%s"},
 	{Opt_alloc, "alloc_mode=%s"},
+	{Opt_test_dummy_encryption, "test_dummy_encryption"},
 	{Opt_err, NULL},
 };
 
@@ -719,6 +721,16 @@ static int parse_options(struct super_block *sb, char *options)
 			}
 			kfree(name);
 			break;
+		case Opt_test_dummy_encryption:
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+			sbi->mount_flags |= F2FS_MF_TEST_DUMMY_ENCRYPTION;
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
@@ -1282,6 +1294,10 @@ static int f2fs_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",whint_mode=%s", "user-based");
 	else if (sbi->whint_mode == WHINT_MODE_FS)
 		seq_printf(seq, ",whint_mode=%s", "fs-based");
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+	if (sbi->mount_flags & F2FS_MF_TEST_DUMMY_ENCRYPTION)
+		seq_puts(seq, ",test_dummy_encryption");
+#endif
 
 	if (sbi->alloc_mode == ALLOC_MODE_DEFAULT)
 		seq_printf(seq, ",alloc_mode=%s", "default");
@@ -1882,6 +1898,11 @@ static int f2fs_set_context(struct inode *inode, const void *ctx, size_t len,
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
@@ -1892,6 +1913,7 @@ static const struct fscrypt_operations f2fs_cryptops = {
 	.key_prefix	= "f2fs:",
 	.get_context	= f2fs_get_context,
 	.set_context	= f2fs_set_context,
+	.dummy_context	= f2fs_dummy_context,
 	.empty_dir	= f2fs_empty_dir,
 	.max_namelen	= f2fs_max_namelen,
 };
@@ -2620,6 +2642,15 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
 	if (err)
 		goto free_options;
 
+	if (DUMMY_ENCRYPTION_ENABLED(sbi) &&
+			(sb_rdonly(sb) || !f2fs_sb_has_encrypt(sb))) {
+		f2fs_msg(sb, KERN_ERR,
+			"Encrypt feature is off or filesystem is read-only");
+		err = -EINVAL;
+		retry = false;
+		goto free_options;
+	}
+
 	sbi->max_file_blocks = max_file_blocks();
 	sb->s_maxbytes = sbi->max_file_blocks <<
 				le32_to_cpu(raw_super->log_blocksize);
-- 
2.14.1

