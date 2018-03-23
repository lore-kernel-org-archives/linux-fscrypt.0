Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 11/14] fscrypt: remove internal key size constants
Date: Fri, 23 Mar 2018 12:23:55 -0700
Message-Id: <20180323192358.95691-12-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

With one exception, the internal key size constants such as
FS_AES_256_XTS_KEY_SIZE are only used for the 'available_modes' array,
where they really only serve to obfuscate what the values are.  Also
some of the constants are unused, and the key sizes tend to be in the
names of the algorithms anyway.  In the past these values were also
misused, e.g. we used to have FS_AES_256_XTS_KEY_SIZE in places that
technically should have been FS_MAX_KEY_SIZE.

The exception is that FS_AES_128_ECB_KEY_SIZE is used for key
derivation.  But it's more appropriate to use
FS_KEY_DERIVATION_NONCE_SIZE for that instead.

Thus, just put the sizes directly in the 'available_modes' array.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h | 10 +---------
 fs/crypto/keyinfo.c         | 19 +++++++------------
 2 files changed, 8 insertions(+), 21 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index bf0bbba783f8..a3697397e190 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -18,15 +18,7 @@
 
 /* Encryption parameters */
 #define FS_IV_SIZE			16
-#define FS_AES_128_ECB_KEY_SIZE		16
-#define FS_AES_128_CBC_KEY_SIZE		16
-#define FS_AES_128_CTS_KEY_SIZE		16
-#define FS_AES_256_GCM_KEY_SIZE		32
-#define FS_AES_256_CBC_KEY_SIZE		32
-#define FS_AES_256_CTS_KEY_SIZE		32
-#define FS_AES_256_XTS_KEY_SIZE		64
-
-#define FS_KEY_DERIVATION_NONCE_SIZE		16
+#define FS_KEY_DERIVATION_NONCE_SIZE	16
 
 /**
  * Encryption context for inode
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 4913a4d5204f..0a134f985681 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -27,7 +27,7 @@ static struct crypto_shash *essiv_hash_tfm;
  *
  * Return: Zero on success; non-zero otherwise.
  */
-static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
+static int derive_key_aes(u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
 				const struct fscrypt_key *source_key,
 				u8 derived_raw_key[FS_MAX_KEY_SIZE])
 {
@@ -52,7 +52,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			crypto_req_done, &wait);
 	res = crypto_skcipher_setkey(tfm, deriving_key,
-					FS_AES_128_ECB_KEY_SIZE);
+				     FS_KEY_DERIVATION_NONCE_SIZE);
 	if (res < 0)
 		goto out;
 
@@ -100,7 +100,6 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 		goto out;
 	}
 	master_key = (struct fscrypt_key *)ukp->data;
-	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
 
 	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
 	    || master_key->size % AES_BLOCK_SIZE != 0) {
@@ -121,15 +120,11 @@ static const struct {
 	const char *cipher_str;
 	int keysize;
 } available_modes[] = {
-	[FS_ENCRYPTION_MODE_AES_256_XTS] = { "xts(aes)",
-					     FS_AES_256_XTS_KEY_SIZE },
-	[FS_ENCRYPTION_MODE_AES_256_CTS] = { "cts(cbc(aes))",
-					     FS_AES_256_CTS_KEY_SIZE },
-	[FS_ENCRYPTION_MODE_AES_128_CBC] = { "cbc(aes)",
-					     FS_AES_128_CBC_KEY_SIZE },
-	[FS_ENCRYPTION_MODE_AES_128_CTS] = { "cts(cbc(aes))",
-					     FS_AES_128_CTS_KEY_SIZE },
-	[FS_ENCRYPTION_MODE_SPECK128_256_XTS] = { "xts(speck128)", 64 },
+	[FS_ENCRYPTION_MODE_AES_256_XTS]      = { "xts(aes)",		64 },
+	[FS_ENCRYPTION_MODE_AES_256_CTS]      = { "cts(cbc(aes))",	32 },
+	[FS_ENCRYPTION_MODE_AES_128_CBC]      = { "cbc(aes)",		16 },
+	[FS_ENCRYPTION_MODE_AES_128_CTS]      = { "cts(cbc(aes))",	16 },
+	[FS_ENCRYPTION_MODE_SPECK128_256_XTS] = { "xts(speck128)",	64 },
 	[FS_ENCRYPTION_MODE_SPECK128_256_CTS] = { "cts(cbc(speck128))", 32 },
 };
 
-- 
2.17.0.rc0.231.g781580f067-goog
