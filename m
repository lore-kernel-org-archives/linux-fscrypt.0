Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40534 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726474AbeLKWsJ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 11 Dec 2018 17:48:09 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 1/2] fsverity: Move verity status check to fsverity_file_open
Date: Tue, 11 Dec 2018 14:46:50 -0800
Message-Id: <20181211224651.112510-2-ebiggers@kernel.org>
In-Reply-To: <20181211224651.112510-1-ebiggers@kernel.org>
References: <20181211224651.112510-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Instead of conditionally checking for verity status of an inode before
invoking fsverity_file_open(), this commit moves the check inside the
definition of fsverity_file_open().

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
(EB: fix the !CONFIG_FS_VERITY case and inline the IS_VERITY() check)
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/file.c           |  8 +++-----
 fs/f2fs/file.c           |  8 +++-----
 fs/verity/setup.c        | 18 ++----------------
 include/linux/fsverity.h | 25 +++++++++++++++++++++++--
 4 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index 30fbd663354f9..b404a857cd487 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -444,11 +444,9 @@ static int ext4_file_open(struct inode * inode, struct file * filp)
 	if (ret)
 		return ret;
 
-	if (IS_VERITY(inode)) {
-		ret = fsverity_file_open(inode, filp);
-		if (ret)
-			return ret;
-	}
+	ret = fsverity_file_open(inode, filp);
+	if (ret)
+		return ret;
 
 	/*
 	 * Set up the jbd2_inode if we are opening the inode for
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index c2746f10e119f..6eea508d8656e 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -491,11 +491,9 @@ static int f2fs_file_open(struct inode *inode, struct file *filp)
 	if (err)
 		return err;
 
-	if (IS_VERITY(inode)) {
-		err = fsverity_file_open(inode, filp);
-		if (err)
-			return err;
-	}
+	err = fsverity_file_open(inode, filp);
+	if (err)
+		return err;
 
 	filp->f_mode |= FMODE_NOWAIT;
 
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
index 08b609127531b..4ecaeb89166b4 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -755,21 +755,7 @@ static int setup_fsverity_info(struct inode *inode)
 	return 0;
 }
 
-/**
- * fsverity_file_open - prepare to open a verity file
- * @inode: the inode being opened
- * @filp: the struct file being set up
- *
- * When opening a verity file, deny the open if it is for writing.  Otherwise,
- * set up the inode's ->i_verity_info (if not already done) by parsing the
- * verity metadata at the end of the file.
- *
- * When combined with fscrypt, this must be called after fscrypt_file_open().
- * Otherwise, we won't have the key set up to decrypt the verity metadata.
- *
- * Return: 0 on success, -errno on failure
- */
-int fsverity_file_open(struct inode *inode, struct file *filp)
+int __fsverity_file_open(struct inode *inode, struct file *filp)
 {
 	if (filp->f_mode & FMODE_WRITE) {
 		pr_debug("Denying opening verity file (ino %lu) for write\n",
@@ -779,7 +765,7 @@ int fsverity_file_open(struct inode *inode, struct file *filp)
 
 	return setup_fsverity_info(inode);
 }
-EXPORT_SYMBOL_GPL(fsverity_file_open);
+EXPORT_SYMBOL_GPL(__fsverity_file_open);
 
 /**
  * fsverity_prepare_setattr - prepare to change a verity inode's attributes
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index ea8c418bd7d53..0ce170c2c1676 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -25,7 +25,7 @@ extern int fsverity_ioctl_enable(struct file *filp, const void __user *arg);
 extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
 
 /* setup.c */
-extern int fsverity_file_open(struct inode *inode, struct file *filp);
+extern int __fsverity_file_open(struct inode *inode, struct file *filp);
 extern int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr);
 extern int fsverity_prepare_getattr(struct inode *inode);
 extern void fsverity_cleanup_inode(struct inode *inode);
@@ -58,7 +58,7 @@ static inline int fsverity_ioctl_measure(struct file *filp, void __user *arg)
 
 /* setup.c */
 
-static inline int fsverity_file_open(struct inode *inode, struct file *filp)
+static inline int __fsverity_file_open(struct inode *inode, struct file *filp)
 {
 	return -EOPNOTSUPP;
 }
@@ -108,4 +108,25 @@ static inline bool fsverity_check_hole(struct inode *inode, struct page *page)
 
 #endif	/* ! CONFIG_FS_VERITY */
 
+/**
+ * fsverity_file_open - prepare to open a verity file
+ * @inode: the inode being opened
+ * @filp: the struct file being set up
+ *
+ * When opening a verity file, deny the open if it is for writing.  Otherwise,
+ * set up the inode's ->i_verity_info (if not already done) by parsing the
+ * verity metadata at the end of the file.
+ *
+ * When combined with fscrypt, this must be called after fscrypt_file_open().
+ * Otherwise, we won't have the key set up to decrypt the verity metadata.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+static inline int fsverity_file_open(struct inode *inode, struct file *filp)
+{
+	if (IS_VERITY(inode))
+		return __fsverity_file_open(inode, filp);
+	return 0;
+}
+
 #endif	/* _LINUX_FSVERITY_H */
-- 
2.20.0.405.gbc1bbc6f85-goog
