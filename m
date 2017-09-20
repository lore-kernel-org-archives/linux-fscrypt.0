Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 15/25] ext4: switch to fscrypt_prepare_setattr()
Date: Wed, 20 Sep 2017 15:45:55 -0700
Message-Id: <20170920224605.22030-16-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index d5a471939fbc..617c7feced24 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5311,6 +5311,10 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 	if (error)
 		return error;
 
+	error = fscrypt_prepare_setattr(dentry, attr);
+	if (error)
+		return error;
+
 	if (is_quota_modification(inode, attr)) {
 		error = dquot_initialize(inode);
 		if (error)
@@ -5356,14 +5360,6 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 		loff_t oldsize = inode->i_size;
 		int shrink = (attr->ia_size <= inode->i_size);
 
-		if (ext4_encrypted_inode(inode)) {
-			error = fscrypt_get_encryption_info(inode);
-			if (error)
-				return error;
-			if (!fscrypt_has_encryption_key(inode))
-				return -ENOKEY;
-		}
-
 		if (!(ext4_test_inode_flag(inode, EXT4_INODE_EXTENTS))) {
 			struct ext4_sb_info *sbi = EXT4_SB(inode->i_sb);
 
-- 
2.14.1.821.g8fa685d3b7-goog
