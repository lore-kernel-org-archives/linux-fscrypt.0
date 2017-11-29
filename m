Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 4/5] ubifs: switch to fscrypt_prepare_lookup()
Date: Wed, 29 Nov 2017 12:43:16 -0800
Message-Id: <20171129204317.91205-5-ebiggers3@gmail.com>
In-Reply-To: <20171129204317.91205-1-ebiggers3@gmail.com>
References: <20171129204317.91205-1-ebiggers3@gmail.com>
To: linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>
Cc: linux-fscrypt@vger.kernel.org, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 7bf847d79b4a..a2ea4856e67b 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -220,20 +220,9 @@ static struct dentry *ubifs_lookup(struct inode *dir, struct dentry *dentry,
 
 	dbg_gen("'%pd' in dir ino %lu", dentry, dir->i_ino);
 
-	if (ubifs_crypt_is_encrypted(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-
-		/*
-		 * DCACHE_ENCRYPTED_WITH_KEY is set if the dentry is
-		 * created while the directory was encrypted and we
-		 * have access to the key.
-		 */
-		if (fscrypt_has_encryption_key(dir))
-			fscrypt_set_encrypted_dentry(dentry);
-		fscrypt_set_d_op(dentry);
-		if (err && err != -ENOKEY)
-			return ERR_PTR(err);
-	}
+	err = fscrypt_prepare_lookup(dir, dentry, flags);
+	if (err)
+		return ERR_PTR(err);
 
 	err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
 	if (err)
-- 
2.15.0.531.g2ccb3012c9-goog
