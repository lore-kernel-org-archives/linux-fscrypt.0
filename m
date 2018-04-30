Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 03/15] fscrypt: remove unnecessary NULL check when allocating skcipher
Date: Mon, 30 Apr 2018 15:51:37 -0700
Message-Id: <20180430225149.183514-4-ebiggers3@gmail.com>
In-Reply-To: <20180430225149.183514-1-ebiggers3@gmail.com>
References: <20180430225149.183514-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

crypto_alloc_skcipher() returns an ERR_PTR() on failure, not NULL.
Remove the unnecessary check for NULL.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 05f5ee1f0705..d09df8f751df 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -318,8 +318,8 @@ int fscrypt_get_encryption_info(struct inode *inode)
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
2.17.0.441.gb46fe60e1d-goog
