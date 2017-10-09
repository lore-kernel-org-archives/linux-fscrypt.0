Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 03/11] fscrypt: switch from ->is_encrypted() to IS_ENCRYPTED()
Date: Mon,  9 Oct 2017 12:15:36 -0700
Message-Id: <20171009191544.43656-4-ebiggers3@gmail.com>
In-Reply-To: <20171009191544.43656-1-ebiggers3@gmail.com>
References: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

IS_ENCRYPTED() now gives the same information as
i_sb->s_cop->is_encrypted() but is more efficient, since IS_ENCRYPTED()
is just a simple flag check.  Prepare to remove ->is_encrypted() by
switching all callers to IS_ENCRYPTED().

Acked-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c              | 2 +-
 fs/crypto/fname.c               | 3 +--
 fs/crypto/keyinfo.c             | 2 +-
 fs/crypto/policy.c              | 6 +++---
 include/linux/fscrypt_notsupp.h | 2 +-
 5 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df7e7b8..608f6bbe0f31 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -340,7 +340,7 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 		return -ECHILD;
 
 	dir = dget_parent(dentry);
-	if (!d_inode(dir)->i_sb->s_cop->is_encrypted(d_inode(dir))) {
+	if (!IS_ENCRYPTED(d_inode(dir))) {
 		dput(dir);
 		return 0;
 	}
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index ad9f814fdead..2878289b3ed2 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -382,8 +382,7 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 	memset(fname, 0, sizeof(struct fscrypt_name));
 	fname->usr_fname = iname;
 
-	if (!dir->i_sb->s_cop->is_encrypted(dir) ||
-				fscrypt_is_dot_dotdot(iname)) {
+	if (!IS_ENCRYPTED(dir) || fscrypt_is_dot_dotdot(iname)) {
 		fname->disk_name.name = (unsigned char *)iname->name;
 		fname->disk_name.len = iname->len;
 		return 0;
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 018c588c7ac3..236a68d4ea72 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -268,7 +268,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	res = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
 	if (res < 0) {
 		if (!fscrypt_dummy_context_enabled(inode) ||
-		    inode->i_sb->s_cop->is_encrypted(inode))
+		    IS_ENCRYPTED(inode))
 			return res;
 		/* Fake up a context for an unencrypted directory */
 		memset(&ctx, 0, sizeof(ctx));
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index ce07a86200f3..6a63b8a0d46c 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -109,7 +109,7 @@ int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
 	struct fscrypt_policy policy;
 	int res;
 
-	if (!inode->i_sb->s_cop->is_encrypted(inode))
+	if (!IS_ENCRYPTED(inode))
 		return -ENODATA;
 
 	res = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
@@ -166,11 +166,11 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 		return 1;
 
 	/* No restrictions if the parent directory is unencrypted */
-	if (!cops->is_encrypted(parent))
+	if (!IS_ENCRYPTED(parent))
 		return 1;
 
 	/* Encrypted directories must not contain unencrypted files */
-	if (!cops->is_encrypted(child))
+	if (!IS_ENCRYPTED(child))
 		return 0;
 
 	/*
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 2d0b6960831e..7b390e356f7f 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -100,7 +100,7 @@ static inline int fscrypt_setup_filename(struct inode *dir,
 					 const struct qstr *iname,
 					 int lookup, struct fscrypt_name *fname)
 {
-	if (dir->i_sb->s_cop->is_encrypted(dir))
+	if (IS_ENCRYPTED(dir))
 		return -EOPNOTSUPP;
 
 	memset(fname, 0, sizeof(struct fscrypt_name));
-- 
2.14.2.920.gcf0c67979c-goog
