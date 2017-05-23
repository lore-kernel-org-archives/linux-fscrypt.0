Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 2/4] f2fs: don't bother checking for encryption key in ->mmap()
Date: Mon, 22 May 2017 17:39:43 -0700
Message-Id: <20170523003945.14279-3-ebiggers3@gmail.com>
In-Reply-To: <20170523003945.14279-1-ebiggers3@gmail.com>
References: <20170523003945.14279-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Since only an open file can be mmap'ed, and we only allow open()ing an
encrypted file when its key is available, there is no need to check for
the key again before permitting each mmap().

This f2fs copy of this code was also broken in that it wouldn't actually
have failed if the key was in fact unavailable.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 61af721329fa..ff4db3efc0ac 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -415,14 +415,6 @@ static int f2fs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	struct inode *inode = file_inode(file);
 	int err;
 
-	if (f2fs_encrypted_inode(inode)) {
-		err = fscrypt_get_encryption_info(inode);
-		if (err)
-			return 0;
-		if (!f2fs_encrypted_inode(inode))
-			return -ENOKEY;
-	}
-
 	/* we don't need to use inline_data strictly */
 	err = f2fs_convert_inline_inode(inode);
 	if (err)
-- 
2.13.0.303.g4ebf302169-goog
