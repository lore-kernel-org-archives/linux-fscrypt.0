Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([85.220.165.71]:47325 "EHLO
        metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730422AbfCZHwm (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 26 Mar 2019 03:52:42 -0400
From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 1/2] ubifs: Remove #ifdef around CONFIG_FS_ENCRYPTION
Date: Tue, 26 Mar 2019 08:52:31 +0100
Message-Id: <20190326075232.11717-2-s.hauer@pengutronix.de>
In-Reply-To: <20190326075232.11717-1-s.hauer@pengutronix.de>
References: <20190326075232.11717-1-s.hauer@pengutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: Richard Weinberger <richard@nod.at>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, kernel@pengutronix.de, Sascha Hauer <s.hauer@pengutronix.de>
List-ID: <linux-fscrypt@vger.kernel.org>

ifdefs reduce readablity and compile coverage. This removes the ifdefs
around CONFIG_FS_ENCRYPTION by using IS_ENABLED and relying on static
inline wrappers. A new static inline wrapper for setting sb->s_cop is
introduced to allow filesystems to unconditionally compile in their
s_cop operations.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 fs/ubifs/ioctl.c        | 11 +----------
 fs/ubifs/sb.c           |  7 ++++---
 fs/ubifs/super.c        |  4 +---
 include/linux/fscrypt.h | 11 +++++++++++
 4 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index 82e4e6a30b04..6b05b3ec500e 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -193,7 +193,6 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return err;
 	}
 	case FS_IOC_SET_ENCRYPTION_POLICY: {
-#ifdef CONFIG_FS_ENCRYPTION
 		struct ubifs_info *c = inode->i_sb->s_fs_info;
 
 		err = ubifs_enable_encryption(c);
@@ -201,17 +200,9 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			return err;
 
 		return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
-#else
-		return -EOPNOTSUPP;
-#endif
 	}
-	case FS_IOC_GET_ENCRYPTION_POLICY: {
-#ifdef CONFIG_FS_ENCRYPTION
+	case FS_IOC_GET_ENCRYPTION_POLICY:
 		return fscrypt_ioctl_get_policy(file, (void __user *)arg);
-#else
-		return -EOPNOTSUPP;
-#endif
-	}
 
 	default:
 		return -ENOTTY;
diff --git a/fs/ubifs/sb.c b/fs/ubifs/sb.c
index 67fac1e8adfb..2afc8b1d4c3b 100644
--- a/fs/ubifs/sb.c
+++ b/fs/ubifs/sb.c
@@ -748,14 +748,12 @@ int ubifs_read_superblock(struct ubifs_info *c)
 		goto out;
 	}
 
-#ifndef CONFIG_FS_ENCRYPTION
-	if (c->encrypted) {
+	if (!IS_ENABLED(CONFIG_UBIFS_FS_ENCRYPTION) && c->encrypted) {
 		ubifs_err(c, "file system contains encrypted files but UBIFS"
 			     " was built without crypto support.");
 		err = -EINVAL;
 		goto out;
 	}
-#endif
 
 	/* Automatically increase file system size to the maximum size */
 	c->old_leb_cnt = c->leb_cnt;
@@ -943,6 +941,9 @@ int ubifs_enable_encryption(struct ubifs_info *c)
 	int err;
 	struct ubifs_sb_node *sup = c->sup_node;
 
+	if (!IS_ENABLED(CONFIG_UBIFS_FS_ENCRYPTION))
+		return -EOPNOTSUPP;
+
 	if (c->encrypted)
 		return 0;
 
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 8dc2818fdd84..e6da7fc0e2a4 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -2146,9 +2146,7 @@ static int ubifs_fill_super(struct super_block *sb, void *data, int silent)
 #ifdef CONFIG_UBIFS_FS_XATTR
 	sb->s_xattr = ubifs_xattr_handlers;
 #endif
-#ifdef CONFIG_FS_ENCRYPTION
-	sb->s_cop = &ubifs_crypt_operations;
-#endif
+	fscrypt_set_ops(sb, &ubifs_crypt_operations);
 
 	mutex_lock(&c->umount_mutex);
 	err = mount_ubifs(c);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index e5194fc3983e..9a5792dac16a 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -230,6 +230,11 @@ extern int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 extern const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 				       unsigned int max_size,
 				       struct delayed_call *done);
+static inline void fscrypt_set_ops(struct super_block *sb,
+				   const struct fscrypt_operations *s_cop)
+{
+	sb->s_cop = s_cop;
+}
 #else  /* !CONFIG_FS_ENCRYPTION */
 
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
@@ -446,6 +451,12 @@ static inline const char *fscrypt_get_symlink(struct inode *inode,
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
+
+static inline void fscrypt_set_ops(struct super_block *sb,
+				   const struct fscrypt_operations *s_cop)
+{
+}
+
 #endif	/* !CONFIG_FS_ENCRYPTION */
 
 /**
-- 
2.20.1
