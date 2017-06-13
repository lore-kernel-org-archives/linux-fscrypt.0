Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Date: Tue, 13 Jun 2017 16:47:53 -0700
Message-Id: <20170613234755.111167-2-ebiggers3@gmail.com>
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
 fs/ext4/inode.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5cf82d03968c..baf8630de6a5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5307,6 +5307,14 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 		loff_t oldsize = inode->i_size;
 		int shrink = (attr->ia_size <= inode->i_size);
 
+		if (ext4_encrypted_inode(inode)) {
+			error = fscrypt_get_encryption_info(inode);
+			if (error)
+				return error;
+			if (!fscrypt_has_encryption_key(inode))
+				return -ENOKEY;
+		}
+
 		if (!(ext4_test_inode_flag(inode, EXT4_INODE_EXTENTS))) {
 			struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
 
-- 
2.13.1.508.gb3defc5cc-goog
