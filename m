Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 21/25] ubifs: switch to fscrypt_file_open()
Date: Wed, 20 Sep 2017 15:46:01 -0700
Message-Id: <20170920224605.22030-22-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/file.c | 31 +------------------------------
 1 file changed, 1 insertion(+), 30 deletions(-)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index a02aa59d1e24..31dc632a52fc 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1629,35 +1629,6 @@ static int ubifs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int ubifs_file_open(struct inode *inode, struct file *filp)
-{
-	int ret;
-	struct dentry *dir;
-	struct ubifs_info *c = inode->i_sb->s_fs_info;
-
-	if (ubifs_crypt_is_encrypted(inode)) {
-		ret = fscrypt_get_encryption_info(inode);
-		if (ret)
-			return -EACCES;
-		if (!fscrypt_has_encryption_key(inode))
-			return -ENOKEY;
-	}
-
-	dir = dget_parent(file_dentry(filp));
-	if (ubifs_crypt_is_encrypted(d_inode(dir)) &&
-			!fscrypt_has_permitted_context(d_inode(dir), inode)) {
-		ubifs_err(c, "Inconsistent encryption contexts: %lu/%lu",
-			  (unsigned long) d_inode(dir)->i_ino,
-			  (unsigned long) inode->i_ino);
-		dput(dir);
-		ubifs_ro_mode(c, -EPERM);
-		return -EPERM;
-	}
-	dput(dir);
-
-	return 0;
-}
-
 static const char *ubifs_get_link(struct dentry *dentry,
 					    struct inode *inode,
 					    struct delayed_call *done)
@@ -1746,7 +1717,7 @@ const struct file_operations ubifs_file_operations = {
 	.unlocked_ioctl = ubifs_ioctl,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= iter_file_splice_write,
-	.open		= ubifs_file_open,
+	.open		= fscrypt_file_open,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = ubifs_compat_ioctl,
 #endif
-- 
2.14.1.821.g8fa685d3b7-goog
