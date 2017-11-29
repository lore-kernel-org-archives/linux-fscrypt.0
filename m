Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 5/5] f2fs: switch to fscrypt_prepare_setattr()
Date: Wed, 29 Nov 2017 12:35:32 -0800
Message-Id: <20171129203532.87729-6-ebiggers3@gmail.com>
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index ae2cf96190e4..52b8f95b9bee 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -743,6 +743,10 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
+	err = fscrypt_prepare_setattr(dentry, attr);
+	if (err)
+		return err;
+
 	if (is_quota_modification(inode, attr)) {
 		err = dquot_initialize(inode);
 		if (err)
@@ -758,14 +762,6 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 	}
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		if (f2fs_encrypted_inode(inode)) {
-			err = fscrypt_get_encryption_info(inode);
-			if (err)
-				return err;
-			if (!fscrypt_has_encryption_key(inode))
-				return -ENOKEY;
-		}
-
 		if (attr->ia_size <= i_size_read(inode)) {
 			down_write(&F2FS_I(inode)->i_mmap_sem);
 			truncate_setsize(inode, attr->ia_size);
-- 
2.15.0.531.g2ccb3012c9-goog
