Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 4/5] f2fs: switch to fscrypt_prepare_lookup()
Date: Wed, 29 Nov 2017 12:35:31 -0800
Message-Id: <20171129203532.87729-5-ebiggers3@gmail.com>
In-Reply-To: <20171129203532.87729-1-ebiggers3@gmail.com>
References: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index e910d2ebe0c6..bbb3fc1e2bef 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -357,20 +357,9 @@ static struct dentry *f2fs_lookup(struct inode *dir, struct dentry *dentry,
 
 	trace_f2fs_lookup_start(dir, dentry, flags);
 
-	if (f2fs_encrypted_inode(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-
-		/*
-		 * DCACHE_ENCRYPTED_WITH_KEY is set if the dentry is
-		 * created while the directory was encrypted and we
-		 * don't have access to the key.
-		 */
-		if (fscrypt_has_encryption_key(dir))
-			fscrypt_set_encrypted_dentry(dentry);
-		fscrypt_set_d_op(dentry);
-		if (err && err != -ENOKEY)
-			goto out;
-	}
+	err = fscrypt_prepare_lookup(dir, dentry, flags);
+	if (err)
+		goto out;
 
 	if (dentry->d_name.len > F2FS_NAME_LEN) {
 		err = -ENAMETOOLONG;
-- 
2.15.0.531.g2ccb3012c9-goog
