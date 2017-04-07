Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 2/4] ext4: remove "nokey" check from ext4_lookup()
Date: Fri,  7 Apr 2017 10:58:38 -0700
Message-Id: <20170407175840.95740-3-ebiggers3@gmail.com>
In-Reply-To: <20170407175840.95740-1-ebiggers3@gmail.com>
References: <20170407175840.95740-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now that fscrypt_has_permitted_context() correctly handles the case
where we have the key for the parent directory but not the child, we
don't need to try to work around this in ext4_lookup().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 6ad612c576fc..600b37874038 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -1616,16 +1616,9 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
 		if (!IS_ERR(inode) && ext4_encrypted_inode(dir) &&
 		    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
 		    !fscrypt_has_permitted_context(dir, inode)) {
-			int nokey = ext4_encrypted_inode(inode) &&
-				!fscrypt_has_encryption_key(inode);
-			if (nokey) {
-				iput(inode);
-				return ERR_PTR(-ENOKEY);
-			}
 			ext4_warning(inode->i_sb,
 				     "Inconsistent encryption contexts: %lu/%lu",
-				     (unsigned long) dir->i_ino,
-				     (unsigned long) inode->i_ino);
+				     dir->i_ino, inode->i_ino);
 			iput(inode);
 			return ERR_PTR(-EPERM);
 		}
-- 
2.12.2.715.g7642488e1d-goog
