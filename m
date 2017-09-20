Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 23/25] ubifs: switch to fscrypt_prepare_rename()
Date: Wed, 20 Sep 2017 15:46:03 -0700
Message-Id: <20170920224605.22030-24-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 09e6c56b11bc..7bf847d79b4a 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -1353,12 +1353,6 @@ static int do_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (unlink)
 		ubifs_assert(inode_is_locked(new_inode));
 
-	if (old_dir != new_dir) {
-		if (ubifs_crypt_is_encrypted(new_dir) &&
-		    !fscrypt_has_permitted_context(new_dir, old_inode))
-			return -EPERM;
-	}
-
 	if (unlink && is_dir) {
 		err = ubifs_check_dir_empty(new_inode);
 		if (err)
@@ -1573,13 +1567,6 @@ static int ubifs_xrename(struct inode *old_dir, struct dentry *old_dentry,
 
 	ubifs_assert(fst_inode && snd_inode);
 
-	if ((ubifs_crypt_is_encrypted(old_dir) ||
-	    ubifs_crypt_is_encrypted(new_dir)) &&
-	    (old_dir != new_dir) &&
-	    (!fscrypt_has_permitted_context(new_dir, fst_inode) ||
-	     !fscrypt_has_permitted_context(old_dir, snd_inode)))
-		return -EPERM;
-
 	err = fscrypt_setup_filename(old_dir, &old_dentry->d_name, 0, &fst_nm);
 	if (err)
 		return err;
@@ -1624,12 +1611,19 @@ static int ubifs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			struct inode *new_dir, struct dentry *new_dentry,
 			unsigned int flags)
 {
+	int err;
+
 	if (flags & ~(RENAME_NOREPLACE | RENAME_WHITEOUT | RENAME_EXCHANGE))
 		return -EINVAL;
 
 	ubifs_assert(inode_is_locked(old_dir));
 	ubifs_assert(inode_is_locked(new_dir));
 
+	err = fscrypt_prepare_rename(old_dir, old_dentry, new_dir, new_dentry,
+				     flags);
+	if (err)
+		return err;
+
 	if (flags & RENAME_EXCHANGE)
 		return ubifs_xrename(old_dir, old_dentry, new_dir, new_dentry);
 
-- 
2.14.1.821.g8fa685d3b7-goog
