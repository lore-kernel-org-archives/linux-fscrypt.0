Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 14/25] ext4: switch to fscrypt_prepare_lookup()
Date: Wed, 20 Sep 2017 15:45:54 -0700
Message-Id: <20170920224605.22030-15-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index b2fbc2b87bcf..a6b6f09e0a88 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -1538,24 +1538,14 @@ static struct dentry *ext4_lookup(struct inode *dir, struct dentry *dentry, unsi
 	struct inode *inode;
 	struct ext4_dir_entry_2 *de;
 	struct buffer_head *bh;
+	int err;
 
-	if (ext4_encrypted_inode(dir)) {
-		int res = fscrypt_get_encryption_info(dir);
-
-		/*
-		 * DCACHE_ENCRYPTED_WITH_KEY is set if the dentry is
-		 * created while the directory was encrypted and we
-		 * have access to the key.
-		 */
-		if (fscrypt_has_encryption_key(dir))
-			fscrypt_set_encrypted_dentry(dentry);
-		fscrypt_set_d_op(dentry);
-		if (res && res != -ENOKEY)
-			return ERR_PTR(res);
-	}
+	err = fscrypt_prepare_lookup(dir, dentry, flags);
+	if (err)
+		return ERR_PTR(err);
 
-       if (dentry->d_name.len > EXT4_NAME_LEN)
-	       return ERR_PTR(-ENAMETOOLONG);
+	if (dentry->d_name.len > EXT4_NAME_LEN)
+		return ERR_PTR(-ENAMETOOLONG);
 
 	bh = ext4_find_entry(dir, &dentry->d_name, &de, NULL);
 	if (IS_ERR(bh))
-- 
2.14.1.821.g8fa685d3b7-goog
