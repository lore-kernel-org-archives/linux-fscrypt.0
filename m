Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 2/5] f2fs: switch to fscrypt_prepare_link()
Date: Wed, 29 Nov 2017 12:35:29 -0800
Message-Id: <20171129203532.87729-3-ebiggers3@gmail.com>
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 28bdf8828e73..dcf5c3a97059 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -240,9 +240,9 @@ static int f2fs_link(struct dentry *old_dentry, struct inode *dir,
 	if (unlikely(f2fs_cp_error(sbi)))
 		return -EIO;
 
-	if (f2fs_encrypted_inode(dir) &&
-			!fscrypt_has_permitted_context(dir, inode))
-		return -EPERM;
+	err = fscrypt_prepare_link(old_dentry, dir, dentry);
+	if (err)
+		return err;
 
 	if (is_inode_flag_set(dir, FI_PROJ_INHERIT) &&
 			(!projid_eq(F2FS_I(dir)->i_projid,
-- 
2.15.0.531.g2ccb3012c9-goog
