Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 20/25] f2fs: switch to fscrypt_prepare_setattr()
Date: Wed, 20 Sep 2017 15:46:00 -0700
Message-Id: <20170920224605.22030-21-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 8cef3931a00b..629bb91fa44e 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -714,6 +714,10 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
+	err = fscrypt_prepare_setattr(dentry, attr);
+	if (err)
+		return err;
+
 	if (is_quota_modification(inode, attr)) {
 		err = dquot_initialize(inode);
 		if (err)
@@ -729,14 +733,6 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
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
2.14.1.821.g8fa685d3b7-goog
