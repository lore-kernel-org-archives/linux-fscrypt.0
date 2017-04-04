Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: remove fscrypt_symlink_data_len()
Date: Tue,  4 Apr 2017 14:43:34 -0700
Message-Id: <20170404214334.113915-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_symlink_data_len() is never called and can be removed.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt_common.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 10c1abfbac6c..0a30c106c1e5 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -46,17 +46,6 @@ struct fscrypt_symlink_data {
 	char encrypted_path[1];
 } __packed;
 
-/**
- * This function is used to calculate the disk space required to
- * store a filename of length l in encrypted symlink format.
- */
-static inline u32 fscrypt_symlink_data_len(u32 l)
-{
-	if (l < FS_CRYPTO_BLOCK_SIZE)
-		l = FS_CRYPTO_BLOCK_SIZE;
-	return (l + sizeof(struct fscrypt_symlink_data) - 1);
-}
-
 struct fscrypt_str {
 	unsigned char *name;
 	u32 len;
-- 
2.12.2.715.g7642488e1d-goog
