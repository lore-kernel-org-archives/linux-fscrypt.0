Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 22/25] ubifs: switch to fscrypt_prepare_link()
Date: Wed, 20 Sep 2017 15:46:02 -0700
Message-Id: <20170920224605.22030-23-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 417fe0b29f23..09e6c56b11bc 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -743,9 +743,9 @@ static int ubifs_link(struct dentry *old_dentry, struct inode *dir,
 	ubifs_assert(inode_is_locked(dir));
 	ubifs_assert(inode_is_locked(inode));
 
-	if (ubifs_crypt_is_encrypted(dir) &&
-	    !fscrypt_has_permitted_context(dir, inode))
-		return -EPERM;
+	err = fscrypt_prepare_link(old_dentry, dir, dentry);
+	if (err)
+		return err;
 
 	err = fscrypt_setup_filename(dir, &dentry->d_name, 0, &nm);
 	if (err)
-- 
2.14.1.821.g8fa685d3b7-goog
