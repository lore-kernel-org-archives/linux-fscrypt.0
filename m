Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 01/14] fscrypt: remove unnecessary NULL check when allocating skcipher
Date: Fri, 23 Mar 2018 12:23:45 -0700
Message-Id: <20180323192358.95691-2-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

crypto_alloc_skcipher() returns an ERR_PTR() on failure, not NULL.
Remove the unnecessary check for NULL.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 96a1eae9e51d..8099388f5581 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -320,8 +320,8 @@ int fscrypt_get_encryption_info(struct inode *inode)
 		goto out;
 	}
 	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
-	if (!ctfm || IS_ERR(ctfm)) {
-		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
+	if (IS_ERR(ctfm)) {
+		res = PTR_ERR(ctfm);
 		pr_debug("%s: error %d (inode %lu) allocating crypto tfm\n",
 			 __func__, res, inode->i_ino);
 		goto out;
-- 
2.17.0.rc0.231.g781580f067-goog
