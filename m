Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 15/15] fscrypt: only derive the needed portion of the key
Date: Mon, 30 Apr 2018 15:51:49 -0700
Message-Id: <20180430225149.183514-16-ebiggers3@gmail.com>
In-Reply-To: <20180430225149.183514-1-ebiggers3@gmail.com>
References: <20180430225149.183514-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently the key derivation function in fscrypt uses the master key
length as the amount of output key material to derive.  This works, but
it means we can waste time deriving more key material than is actually
used, e.g. most commonly, deriving 64 bytes for directories which only
take a 32-byte AES-256-CTS-CBC key.  It also forces us to validate that
the master key length is a multiple of AES_BLOCK_SIZE, which wouldn't
otherwise be necessary.

Fix it to only derive the needed length key.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 39 ++++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index f248ee9974fa..c4d1388fc9b4 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -19,17 +19,16 @@
 
 static struct crypto_shash *essiv_hash_tfm;
 
-/**
- * derive_key_aes() - Derive a key using AES-128-ECB
- * @deriving_key: Encryption key used for derivation.
- * @source_key:   Source key to which to apply derivation.
- * @derived_raw_key:  Derived raw key.
+/*
+ * Key derivation function.  This generates the derived key by encrypting the
+ * master key with AES-128-ECB using the inode's nonce as the AES key.
  *
- * Return: Zero on success; non-zero otherwise.
+ * The master key must be at least as long as the derived key.  If the master
+ * key is longer, then only the first 'derived_keysize' bytes are used.
  */
-static int derive_key_aes(const u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
-				const struct fscrypt_key *source_key,
-				u8 derived_raw_key[FS_MAX_KEY_SIZE])
+static int derive_key_aes(const u8 *master_key,
+			  const struct fscrypt_context *ctx,
+			  u8 *derived_key, unsigned int derived_keysize)
 {
 	int res = 0;
 	struct skcipher_request *req = NULL;
@@ -51,14 +50,13 @@ static int derive_key_aes(const u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
 	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			crypto_req_done, &wait);
-	res = crypto_skcipher_setkey(tfm, deriving_key,
-				     FS_KEY_DERIVATION_NONCE_SIZE);
+	res = crypto_skcipher_setkey(tfm, ctx->nonce, sizeof(ctx->nonce));
 	if (res < 0)
 		goto out;
 
-	sg_init_one(&src_sg, source_key->raw, source_key->size);
-	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
-	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
+	sg_init_one(&src_sg, master_key, derived_keysize);
+	sg_init_one(&dst_sg, derived_key, derived_keysize);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, derived_keysize,
 				   NULL);
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 out:
@@ -109,10 +107,9 @@ find_and_lock_process_key(const char *prefix,
 		goto invalid;
 	}
 
-	if (payload->size < min_keysize ||
-	    payload->size % AES_BLOCK_SIZE != 0) {
+	if (payload->size < min_keysize) {
 		fscrypt_warn(NULL,
-			     "key with description '%s' is too short or is misaligned (got %u bytes, need %u+ bytes)",
+			     "key with description '%s' is too short (got %u bytes, need %u+ bytes)",
 			     key->description, payload->size, min_keysize);
 		goto invalid;
 	}
@@ -145,7 +142,7 @@ static int find_and_derive_key(const struct inode *inode,
 	}
 	if (IS_ERR(key))
 		return PTR_ERR(key);
-	err = derive_key_aes(ctx->nonce, payload, derived_key);
+	err = derive_key_aes(payload->raw, ctx, derived_key, derived_keysize);
 	up_read(&key->sem);
 	key_put(key);
 	return err;
@@ -325,7 +322,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	 * crypto API as part of key derivation.
 	 */
 	res = -ENOMEM;
-	raw_key = kmalloc(FS_MAX_KEY_SIZE, GFP_NOFS);
+	raw_key = kmalloc(keysize, GFP_NOFS);
 	if (!raw_key)
 		goto out;
 
@@ -343,10 +340,6 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	}
 	crypt_info->ci_ctfm = ctfm;
 	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
-	/*
-	 * if the provided key is longer than keysize, we use the first
-	 * keysize bytes of the derived key only
-	 */
 	res = crypto_skcipher_setkey(ctfm, raw_key, keysize);
 	if (res)
 		goto out;
-- 
2.17.0.441.gb46fe60e1d-goog
