Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 5/5] ubifs: switch to fscrypt_prepare_setattr()
Date: Wed, 29 Nov 2017 12:43:17 -0800
Message-Id: <20171129204317.91205-6-ebiggers3@gmail.com>
In-Reply-To: <20171129204317.91205-1-ebiggers3@gmail.com>
References: <20171129204317.91205-1-ebiggers3@gmail.com>
To: linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>
Cc: linux-fscrypt@vger.kernel.org, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/file.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 31dc632a52fc..f5578f1bd170 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1284,13 +1284,9 @@ int ubifs_setattr(struct dentry *dentry, struct iattr *attr)
 	if (err)
 		return err;
 
-	if (ubifs_crypt_is_encrypted(inode) && (attr->ia_valid & ATTR_SIZE)) {
-		err = fscrypt_get_encryption_info(inode);
-		if (err)
-			return err;
-		if (!fscrypt_has_encryption_key(inode))
-			return -ENOKEY;
-	}
+	err = fscrypt_prepare_setattr(dentry, attr);
+	if (err)
+		return err;
 
 	if ((attr->ia_valid & ATTR_SIZE) && attr->ia_size < inode->i_size)
 		/* Truncation to a smaller size */
-- 
2.15.0.531.g2ccb3012c9-goog
