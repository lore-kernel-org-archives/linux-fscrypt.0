Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 16/25] f2fs: switch to fscrypt_file_open()
Date: Wed, 20 Sep 2017 15:45:56 -0700
Message-Id: <20170920224605.22030-17-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 517e112c8a9a..8cef3931a00b 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -455,22 +455,10 @@ static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma)
 
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
2.14.1.821.g8fa685d3b7-goog
