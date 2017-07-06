Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH 1/2] ext4: skip ext4_init_security() and encryption on ea_inodes
Date: Wed,  5 Jul 2017 19:38:18 -0700
Message-Id: <20170706023819.32272-1-tahsin@google.com>
Sender: linux-ext4-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Andreas Dilger <adilger@dilger.ca>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Tahsin Erdogan <tahsin@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Extended attribute inodes are internal to ext4. Adding encryption/security
related attributes on them would mean dealing with nested calls into ea code.
Since they have no direct exposure to user mode, just avoid creating ea
entries for them.

Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
 fs/ext4/ialloc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index fb1b3df17f6e..0c79e3efcaf7 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -771,7 +771,8 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
 
 	if ((ext4_encrypted_inode(dir) ||
 	     DUMMY_ENCRYPTION_ENABLED(EXT4_SB(dir->i_sb))) &&
-	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))) {
+	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) &&
+	    !(i_flags & EXT4_EA_INODE_FL)) {
 		err = fscrypt_get_encryption_info(dir);
 		if (err)
 			return ERR_PTR(err);
@@ -1114,11 +1115,11 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
 		err = ext4_init_acl(handle, inode, dir);
 		if (err)
 			goto fail_free_drop;
-	}
 
-	err = ext4_init_security(handle, inode, dir, qstr);
-	if (err)
-		goto fail_free_drop;
+		err = ext4_init_security(handle, inode, dir, qstr);
+		if (err)
+			goto fail_free_drop;
+	}
 
 	if (ext4_has_feature_extents(sb)) {
 		/* set extent flag only for directory, file and normal symlink*/
-- 
2.13.2.725.g09c95d1e9-goog
