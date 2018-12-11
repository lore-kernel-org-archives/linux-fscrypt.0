Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 2/2] fsverity: Move verity status check to fsverity_prepare_setattr
Date: Tue, 11 Dec 2018 14:46:51 -0800
Message-Id: <20181211224651.112510-3-ebiggers@kernel.org>
In-Reply-To: <20181211224651.112510-1-ebiggers@kernel.org>
References: <20181211224651.112510-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-ext4-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Instead of conditionally checking for verity status of an inode before
invoking fsverity_prepare_setattr(), this commit moves the check inside the
definition of fsverity_prepare_setattr().

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
(EB: fix the !CONFIG_FS_VERITY case and inline the IS_VERITY() check)
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c          |  8 +++-----
 fs/f2fs/file.c           |  8 +++-----
 fs/verity/setup.c        | 14 ++------------
 include/linux/fsverity.h | 25 ++++++++++++++++++++++---
 4 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b83ab0e812483..817b67c3083be 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5510,11 +5510,9 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (error)
 		return error;
 
-	if (IS_VERITY(inode)) {
-		error = fsverity_prepare_setattr(dentry, attr);
-		if (error)
-			return error;
-	}
+	error = fsverity_prepare_setattr(dentry, attr);
+	if (error)
+		return error;
 
 	if (is_quota_modification(inode, attr)) {
 		error = dquot_initialize(inode);
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 6eea508d8656e..b73609a43baa7 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -798,11 +798,9 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
-	if (IS_VERITY(inode)) {
-		err = fsverity_prepare_setattr(dentry, attr);
-		if (err)
-			return err;
-	}
+	err = fsverity_prepare_setattr(dentry, attr);
+	if (err)
+		return err;
 
 	if (is_quota_modification(inode, attr)) {
 		err = dquot_initialize(inode);
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
index 4ecaeb89166b4..2b707589999c4 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -767,17 +767,7 @@ int __fsverity_file_open(struct inode *inode, struct file *filp)
 }
 EXPORT_SYMBOL_GPL(__fsverity_file_open);
 
-/**
- * fsverity_prepare_setattr - prepare to change a verity inode's attributes
- * @dentry: dentry through which the inode is being changed
- * @attr: attributes to change
- *
- * Verity files are immutable, so deny truncates.  This isn't covered by the
- * open-time check because sys_truncate() takes a path, not a file descriptor.
- *
- * Return: 0 on success, -errno on failure
- */
-int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr)
+int __fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	if (attr->ia_valid & ATTR_SIZE) {
 		pr_debug("Denying truncate of verity file (ino %lu)\n",
@@ -786,7 +776,7 @@ int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr)
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(fsverity_prepare_setattr);
+EXPORT_SYMBOL_GPL(__fsverity_prepare_setattr);
 
 /**
  * fsverity_prepare_getattr - prepare to get a verity inode's attributes
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index 0ce170c2c1676..099fc34936fa6 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -26,7 +26,8 @@ extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
 
 /* setup.c */
 extern int __fsverity_file_open(struct inode *inode, struct file *filp);
-extern int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr);
+extern int __fsverity_prepare_setattr(struct dentry *dentry,
+				      struct iattr *attr);
 extern int fsverity_prepare_getattr(struct inode *inode);
 extern void fsverity_cleanup_inode(struct inode *inode);
 extern loff_t fsverity_full_i_size(const struct inode *inode);
@@ -63,8 +64,8 @@ static inline int __fsverity_file_open(struct inode *inode, struct file *filp)
 	return -EOPNOTSUPP;
 }
 
-static inline int fsverity_prepare_setattr(struct dentry *dentry,
-					   struct iattr *attr)
+static inline int __fsverity_prepare_setattr(struct dentry *dentry,
+					     struct iattr *attr)
 {
 	return -EOPNOTSUPP;
 }
@@ -129,4 +130,22 @@ static inline int fsverity_file_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+/**
+ * fsverity_prepare_setattr - prepare to change a verity inode's attributes
+ * @dentry: dentry through which the inode is being changed
+ * @attr: attributes to change
+ *
+ * Verity files are immutable, so deny truncates.  This isn't covered by the
+ * open-time check because sys_truncate() takes a path, not a file descriptor.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+static inline int fsverity_prepare_setattr(struct dentry *dentry,
+					   struct iattr *attr)
+{
+	if (IS_VERITY(d_inode(dentry)))
+		return __fsverity_prepare_setattr(dentry, attr);
+	return 0;
+}
+
 #endif	/* _LINUX_FSVERITY_H */
-- 
2.20.0.405.gbc1bbc6f85-goog
