Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 2/3] f2fs: require key for truncate(2) of encrypted file
Date: Tue, 13 Jun 2017 16:47:54 -0700
Message-Id: <20170613234755.111167-3-ebiggers3@gmail.com>
In-Reply-To: <20170613234755.111167-1-ebiggers3@gmail.com>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, filesystems allow truncate(2) on an encrypted file without
the encryption key.  However, it's impossible to correctly handle the
case where the size being truncated to is not a multiple of the
filesystem block size, because that would require decrypting the final
block, zeroing the part beyond i_size, then encrypting the block.

As other modifications to encrypted file contents are prohibited without
the key, just prohibit truncate(2) as well, making it fail with ENOKEY.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 61af721329fa..be0b32bd1297 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -682,9 +682,13 @@ int f2fs_setattr(struct dentry *dentry, struct iattr *attr)
 		return err;
 
 	if (attr->ia_valid & ATTR_SIZE) {
-		if (f2fs_encrypted_inode(inode) &&
-				fscrypt_get_encryption_info(inode))
-			return -EACCES;
+		if (f2fs_encrypted_inode(inode)) {
+			err = fscrypt_get_encryption_info(inode);
+			if (err)
+				return err;
+			if (!fscrypt_has_encryption_key(inode))
+				return -ENOKEY;
+		}
 
 		if (attr->ia_size <= i_size_read(inode)) {
 			truncate_setsize(inode, attr->ia_size);
-- 
2.13.1.508.gb3defc5cc-goog
