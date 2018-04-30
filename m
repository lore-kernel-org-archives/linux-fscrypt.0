Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 14/15] fscrypt: separate key lookup from key derivation
Date: Mon, 30 Apr 2018 15:51:48 -0700
Message-Id: <20180430225149.183514-15-ebiggers3@gmail.com>
In-Reply-To: <20180430225149.183514-1-ebiggers3@gmail.com>
References: <20180430225149.183514-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Refactor the confusingly-named function 'validate_user_key()' into a new
function 'find_and_derive_key()' which first finds the keyring key, then
does the key derivation.  Among other benefits this avoids the strange
behavior we had previously where if key derivation failed for some
reason, then we would fall back to the alternate key prefix.  Now, we'll
only fall back to the alternate key prefix if a valid key isn't found.

This patch also improves the warning messages that are logged when the
keyring key's payload is invalid.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 122 +++++++++++++++++++++++++++-----------------
 1 file changed, 74 insertions(+), 48 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index f63bfd6dffd6..f248ee9974fa 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -27,7 +27,7 @@ static struct crypto_shash *essiv_hash_tfm;
  *
  * Return: Zero on success; non-zero otherwise.
  */
-static int derive_key_aes(u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
+static int derive_key_aes(const u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
 				const struct fscrypt_key *source_key,
 				u8 derived_raw_key[FS_MAX_KEY_SIZE])
 {
@@ -67,52 +67,88 @@ static int derive_key_aes(u8 deriving_key[FS_KEY_DERIVATION_NONCE_SIZE],
 	return res;
 }
 
-static int validate_user_key(struct fscrypt_info *crypt_info,
-			struct fscrypt_context *ctx, u8 *raw_key,
-			const char *prefix, int min_keysize)
+/*
+ * Search the current task's subscribed keyrings for a "logon" key with
+ * description prefix:descriptor, and if found acquire a read lock on it and
+ * return a pointer to its validated payload in *payload_ret.
+ */
+static struct key *
+find_and_lock_process_key(const char *prefix,
+			  const u8 descriptor[FS_KEY_DESCRIPTOR_SIZE],
+			  unsigned int min_keysize,
+			  const struct fscrypt_key **payload_ret)
 {
 	char *description;
-	struct key *keyring_key;
-	struct fscrypt_key *master_key;
+	struct key *key;
 	const struct user_key_payload *ukp;
-	int res;
+	const struct fscrypt_key *payload;
 
 	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
-				FS_KEY_DESCRIPTOR_SIZE,
-				ctx->master_key_descriptor);
+				FS_KEY_DESCRIPTOR_SIZE, descriptor);
 	if (!description)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
-	keyring_key = request_key(&key_type_logon, description, NULL);
+	key = request_key(&key_type_logon, description, NULL);
 	kfree(description);
-	if (IS_ERR(keyring_key))
-		return PTR_ERR(keyring_key);
-	down_read(&keyring_key->sem);
-
-	ukp = user_key_payload_locked(keyring_key);
-	if (!ukp) {
-		/* key was revoked before we acquired its semaphore */
-		res = -EKEYREVOKED;
-		goto out;
+	if (IS_ERR(key))
+		return key;
+
+	down_read(&key->sem);
+	ukp = user_key_payload_locked(key);
+
+	if (!ukp) /* was the key revoked before we acquired its semaphore? */
+		goto invalid;
+
+	payload = (const struct fscrypt_key *)ukp->data;
+
+	if (ukp->datalen != sizeof(struct fscrypt_key) ||
+	    payload->size < 1 || payload->size > FS_MAX_KEY_SIZE) {
+		fscrypt_warn(NULL,
+			     "key with description '%s' has invalid payload",
+			     key->description);
+		goto invalid;
 	}
-	if (ukp->datalen != sizeof(struct fscrypt_key)) {
-		res = -EINVAL;
-		goto out;
+
+	if (payload->size < min_keysize ||
+	    payload->size % AES_BLOCK_SIZE != 0) {
+		fscrypt_warn(NULL,
+			     "key with description '%s' is too short or is misaligned (got %u bytes, need %u+ bytes)",
+			     key->description, payload->size, min_keysize);
+		goto invalid;
 	}
-	master_key = (struct fscrypt_key *)ukp->data;
 
-	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
-	    || master_key->size % AES_BLOCK_SIZE != 0) {
-		fscrypt_warn(NULL, "key size incorrect: %u",
-			     master_key->size);
-		res = -ENOKEY;
-		goto out;
+	*payload_ret = payload;
+	return key;
+
+invalid:
+	up_read(&key->sem);
+	key_put(key);
+	return ERR_PTR(-ENOKEY);
+}
+
+/* Find the master key, then derive the inode's actual encryption key */
+static int find_and_derive_key(const struct inode *inode,
+			       const struct fscrypt_context *ctx,
+			       u8 *derived_key, unsigned int derived_keysize)
+{
+	struct key *key;
+	const struct fscrypt_key *payload;
+	int err;
+
+	key = find_and_lock_process_key(FS_KEY_DESC_PREFIX,
+					ctx->master_key_descriptor,
+					derived_keysize, &payload);
+	if (key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
+		key = find_and_lock_process_key(inode->i_sb->s_cop->key_prefix,
+						ctx->master_key_descriptor,
+						derived_keysize, &payload);
 	}
-	res = derive_key_aes(ctx->nonce, master_key, raw_key);
-out:
-	up_read(&keyring_key->sem);
-	key_put(keyring_key);
-	return res;
+	if (IS_ERR(key))
+		return PTR_ERR(key);
+	err = derive_key_aes(ctx->nonce, payload, derived_key);
+	up_read(&key->sem);
+	key_put(key);
+	return err;
 }
 
 static const struct {
@@ -293,20 +329,10 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (!raw_key)
 		goto out;
 
-	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
-				keysize);
-	if (res && inode->i_sb->s_cop->key_prefix) {
-		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
-					     inode->i_sb->s_cop->key_prefix,
-					     keysize);
-		if (res2) {
-			if (res2 == -ENOKEY)
-				res = -ENOKEY;
-			goto out;
-		}
-	} else if (res) {
+	res = find_and_derive_key(inode, &ctx, raw_key, keysize);
+	if (res)
 		goto out;
-	}
+
 	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (IS_ERR(ctfm)) {
 		res = PTR_ERR(ctfm);
-- 
2.17.0.441.gb46fe60e1d-goog
