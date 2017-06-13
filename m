Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 3/3] ubifs: require key for truncate(2) of encrypted file
Date: Tue, 13 Jun 2017 16:47:55 -0700
Message-Id: <20170613234755.111167-4-ebiggers3@gmail.com>
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
 fs/ubifs/file.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 2cda3d67e2d0..ee3ff4c6bf4a 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1284,6 +1284,14 @@ int ubifs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
+	if (ubifs_crypt_is_encrypted(inode) && (attr->ia_valid & ATTR_SIZE)) {
+		err = fscrypt_get_encryption_info(inode);
+		if (err)
+			return err;
+		if (!fscrypt_has_encryption_key(inode))
+			return -ENOKEY;
+	}
+
 	if ((attr->ia_valid & ATTR_SIZE) && attr->ia_size < inode->i_size)
 		/* Truncation to a smaller size */
 		err = do_truncation(c, inode, attr);
-- 
2.13.1.508.gb3defc5cc-goog
