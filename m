Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 3/4] f2fs: sync f2fs_lookup() with ext4_lookup()
Date: Fri,  7 Apr 2017 10:58:39 -0700
Message-Id: <20170407175840.95740-4-ebiggers3@gmail.com>
In-Reply-To: <20170407175840.95740-1-ebiggers3@gmail.com>
References: <20170407175840.95740-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

As for ext4, now that fscrypt_has_permitted_context() correctly handles
the case where we have the key for the parent directory but not the
child, f2fs_lookup() no longer has to work around it.  Also add the same
warning message that ext4 uses.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 98f00a3a7f50..9a5b9fa55318 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -324,9 +324,10 @@ static struct dentry *f2fs_lookup(struct inode *dir, struct dentry *dentry,
 	if (f2fs_encrypted_inode(dir) &&
 	    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
 	    !fscrypt_has_permitted_context(dir, inode)) {
-		bool nokey = f2fs_encrypted_inode(inode) &&
-			!fscrypt_has_encryption_key(inode);
-		err = nokey ? -ENOKEY : -EPERM;
+		f2fs_msg(inode->i_sb, KERN_WARNING,
+			 "Inconsistent encryption contexts: %lu/%lu",
+			 dir->i_ino, inode->i_ino);
+		err = -EPERM;
 		goto err_out;
 	}
 	return d_splice_alias(inode, dentry);
-- 
2.12.2.715.g7642488e1d-goog
