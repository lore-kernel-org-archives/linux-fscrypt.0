Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 1/5] f2fs: switch to fscrypt_file_open()
Date: Wed, 29 Nov 2017 12:35:28 -0800
Message-Id: <20171129203532.87729-2-ebiggers3@gmail.com>
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 7874bbd7311d..ae2cf96190e4 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -472,22 +472,10 @@ static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
 static int f2fs_file_open(struct inode *inode, struct file *filp)
 {
-	struct dentry *dir;
+	int err = fscrypt_file_open(inode, filp);
 
-	if (f2fs_encrypted_inode(inode)) {
-		int ret = fscrypt_get_encryption_info(inode);
-		if (ret)
-			return -EACCES;
-		if (!fscrypt_has_encryption_key(inode))
-			return -ENOKEY;
-	}
-	dir = dget_parent(file_dentry(filp));
-	if (f2fs_encrypted_inode(d_inode(dir)) &&
-			!fscrypt_has_permitted_context(d_inode(dir), inode)) {
-		dput(dir);
-		return -EPERM;
-	}
-	dput(dir);
+	if (err)
+		return err;
 	return dquot_file_open(inode, filp);
 }
 
-- 
2.15.0.531.g2ccb3012c9-goog
