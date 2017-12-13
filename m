Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: remove 'ci' parameter from fscrypt_put_encryption_info()
Date: Wed, 13 Dec 2017 10:37:05 -0800
Message-Id: <20171213183705.195254-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_put_encryption_info() is only called when evicting an inode, so
the 'struct fscrypt_info *ci' parameter is always NULL, and there cannot
be races with other threads.  This was cruft left over from the broken
key revocation code.  Remove the unused parameter and the cmpxchg().

Also remove the #ifdefs around the fscrypt_put_encryption_info() calls,
since fscrypt_notsupp.h defines a no-op stub for it.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c             | 16 +++-------------
 fs/ext4/super.c                 |  4 +---
 fs/f2fs/inode.c                 |  2 +-
 fs/ubifs/super.c                |  4 +---
 include/linux/fscrypt_notsupp.h |  3 +--
 include/linux/fscrypt_supp.h    |  2 +-
 6 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 5e6e846f5a24..4d75af57aa52 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -354,19 +354,9 @@ int fscrypt_get_encryption_info(struct inode *inode)
 }
 EXPORT_SYMBOL(fscrypt_get_encryption_info);
 
-void fscrypt_put_encryption_info(struct inode *inode, struct fscrypt_info *ci)
+void fscrypt_put_encryption_info(struct inode *inode)
 {
-	struct fscrypt_info *prev;
-
-	if (ci == NULL)
-		ci = READ_ONCE(inode->i_crypt_info);
-	if (ci == NULL)
-		return;
-
-	prev = cmpxchg(&inode->i_crypt_info, ci, NULL);
-	if (prev != ci)
-		return;
-
-	put_crypt_info(ci);
+	put_crypt_info(inode->i_crypt_info);
+	inode->i_crypt_info = NULL;
 }
 EXPORT_SYMBOL(fscrypt_put_encryption_info);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 7c46693a14d7..152d05d983f6 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1069,9 +1069,7 @@ void ext4_clear_inode(struct inode *inode)
 		jbd2_free_inode(EXT4_I(inode)->jinode);
 		EXT4_I(inode)->jinode = NULL;
 	}
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
-	fscrypt_put_encryption_info(inode, NULL);
-#endif
+	fscrypt_put_encryption_info(inode);
 }
 
 static struct inode *ext4_nfs_get_inode(struct super_block *sb,
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index b4c4f2b25304..22a5607a0518 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -569,7 +569,7 @@ void f2fs_evict_inode(struct inode *inode)
 			!exist_written_data(sbi, inode->i_ino, ORPHAN_INO));
 	}
 out_clear:
-	fscrypt_put_encryption_info(inode, NULL);
+	fscrypt_put_encryption_info(inode);
 	clear_inode(inode);
 }
 
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 0beb285b143d..b16ef162344a 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -379,9 +379,7 @@ static void ubifs_evict_inode(struct inode *inode)
 	}
 done:
 	clear_inode(inode);
-#ifdef CONFIG_UBIFS_FS_ENCRYPTION
-	fscrypt_put_encryption_info(inode, NULL);
-#endif
+	fscrypt_put_encryption_info(inode);
 }
 
 static void ubifs_dirty_inode(struct inode *inode, int flags)
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 63e58808519a..71cee8a431fc 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -90,8 +90,7 @@ static inline int fscrypt_get_encryption_info(struct inode *inode)
 	return -EOPNOTSUPP;
 }
 
-static inline void fscrypt_put_encryption_info(struct inode *inode,
-					       struct fscrypt_info *ci)
+static inline void fscrypt_put_encryption_info(struct inode *inode)
 {
 	return;
 }
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index cf9e9fc02f0a..872f7514e63c 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -44,7 +44,7 @@ extern int fscrypt_inherit_context(struct inode *, struct inode *,
 					void *, bool);
 /* keyinfo.c */
 extern int fscrypt_get_encryption_info(struct inode *);
-extern void fscrypt_put_encryption_info(struct inode *, struct fscrypt_info *);
+extern void fscrypt_put_encryption_info(struct inode *);
 
 /* fname.c */
 extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
-- 
2.15.1.504.g5279b80103-goog
