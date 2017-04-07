Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 4/4] ubifs: check for consistent encryption contexts in ubifs_lookup()
Date: Fri,  7 Apr 2017 10:58:40 -0700
Message-Id: <20170407175840.95740-5-ebiggers3@gmail.com>
In-Reply-To: <20170407175840.95740-1-ebiggers3@gmail.com>
References: <20170407175840.95740-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

As ext4 and f2fs do, ubifs should check for consistent encryption
contexts during ->lookup() in an encrypted directory.  This protects
certain users of filesystem encryption against certain types of offline
attacks.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 30825d882aa9..bbe2b346a94f 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -285,6 +285,15 @@ static struct dentry *ubifs_lookup(struct inode *dir, struct dentry *dentry,
 		goto out_dent;
 	}
 
+	if (ubifs_crypt_is_encrypted(dir) &&
+	    (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) &&
+	    !fscrypt_has_permitted_context(dir, inode)) {
+		ubifs_warn(c, "Inconsistent encryption contexts: %lu/%lu",
+			   dir->i_ino, inode->i_ino);
+		err = -EPERM;
+		goto out_inode;
+	}
+
 done:
 	kfree(dent);
 	fscrypt_free_filename(&nm);
@@ -295,6 +304,8 @@ static struct dentry *ubifs_lookup(struct inode *dir, struct dentry *dentry,
 	d_add(dentry, inode);
 	return NULL;
 
+out_inode:
+	iput(inode);
 out_dent:
 	kfree(dent);
 out_fname:
-- 
2.12.2.715.g7642488e1d-goog
