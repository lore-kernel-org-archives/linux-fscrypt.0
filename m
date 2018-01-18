Return-Path: <keyrings-owner@vger.kernel.org>
From: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>
Subject: [PATCH v3] fscrypt: add support for the encrypted key type
Date: Thu, 18 Jan 2018 13:13:59 +0000
Message-Id: <20180118131359.8365-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: keyrings-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, Eric Biggers <ebiggers@google.com>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

fscrypt uses a master key for each directory policy from
which all further keys for that policy are derived, and
at the moment such a master key has to be inserted into
a kernel keyring as a 'logon' key by user-space.

While 'logon' keys have the nice property of not being
readable by user-space (keyctl dump etc.), the fscrypt
master key still needs to be generated initially, in a
secure way, and it needs to be saved somewhere for
subsequent reboots, and hence also needs securing itself.

Usage of the 'logon' key means that it is up to user-space
to do all that, opening up the possibility of creating
cryptographically non-sound master keys, or not storing
the master key securely across reboots.

One approach for securing the master key would be to do
that using a TPM and while one could manually do so e.g.
using tpm-tools, that still leaves creation and actual
correct usage of tpm-tools up to user-space, though. As an
aside, tpm-tools needs the tcsd daemon running, which makes
it awkward to use from within an initramfs, and while other
libraries for interfacing with a TPM do exist, there
appears to be a better way:

The kernel already has a concept of trusted as well as
encrypted keys. Trusted keys are TPM backed keys, which can
be sealed to PCRs and also easily be re-sealed against new
future PCRs, and encrypted keys are keys that are encrypted
using another key, e.g. a trusted key. All are generated
automatically by the kernel using the RNG and never leave
kernel memory space (bar any kernel or hardware bugs).

So it seems reasonable to allow the fscrypt subsystem to
work with encrypted keys as well. This is what this change
here does.

We can utilise keys that never ever exist in user-space,
not even at initial creation time, as well as simplifying
usage / configuration. Something very very similar exists
for eCrypts already.

With these patches, we can

    kmk_id=$(keyctl add trusted kmk "new 128 [pcrinfo=...]" @u)
    fscrypt_id=$(keyctl add encrypted fscrypt:1234567890123456 "new default trusted:kmk 64" @u)
    fscryptctl set_policy 1234567890123456 /encrypted

then we can save those keys for after reboot (optionally
TPM-sealed as per the pcrinfo= argument above):

    keyctl pipe ${kmk_id} > /keys/kmk.blob
    keyctl pipe ${fscrypt_id} > /keys/fscrypt.blob

and on subsequent boots we can simply insert them again
(optionally benefitting from the TPM's capability to only
unseal kmk.blob when the system is in the expected state,
thereby also protecting fscrypt.blob):

    keyctl add trusted kmk "load $(cat /keys/kmk.blob)" @u
    keyctl add encrypted fscrypt:1234567890123456 "load $(cat /keys/fscrypt.blob)" @u

Signed-off-by: André Draszik <git@andred.net>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: David Howells <dhowells@redhat.com>
Cc: James Morris <james.l.morris@oracle.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Eric Biggers <ebiggers@google.com>
Cc: linux-integrity@vger.kernel.org
Cc: keyrings@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

---
changes in v3:
* merge documentation changes into this commit
* update derive_key_aes() signature to not take
  a struct fscrypt_key and update all callers
* try to use the 'encrypted' key as fallback only
  if the a 'logon' key isn't present (ENOKEY)
* update fscrypt_get_encrypted_key() to take a
  'description', not a 'sig'
* update commit message
* re-add keyrings mailing list and encrypted-keys
  maintainers to Cc

changes in v2:
* dropped the previously added 'fscrypt' encrypted-key,
  and just use the 'default' format
---
 Documentation/filesystems/fscrypt.rst | 56 +++++++++++++++++++--
 fs/crypto/keyinfo.c                   | 92 ++++++++++++++++++++++-------------
 2 files changed, 110 insertions(+), 38 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 776ddc655f79..852ac2900b66 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -368,11 +368,19 @@ Adding keys
 To provide a master key, userspace must add it to an appropriate
 keyring using the add_key() system call (see:
 ``Documentation/security/keys/core.rst``).  The key type must be
-"logon"; keys of this type are kept in kernel memory and cannot be
-read back by userspace.  The key description must be "fscrypt:"
-followed by the 16-character lower case hex representation of the
-``master_key_descriptor`` that was set in the encryption policy.  The
-key payload must conform to the following structure::
+either "logon" or "encrypted"; "logon" keys are kept in kernel
+memory and cannot be read back by userspace while "encrypted"
+keys can be rooted in a "trusted" key and thus are protected by
+a TPM and cannot be read by userspace in unencrypted form. Note
+that while an "encrypted" key can also be rooted in a "user" key,
+any "encrypted" key rooted in a "user" key can effectively be
+retrieved in the clear, hence only rooting the key in a "trusted"
+key has any useful security properties!
+
+The key description must be "fscrypt:" followed by the 16-character
+lower case hex representation of the ``master_key_descriptor`` that
+was set in the encryption policy.  For a "logon" key, key payload
+must conform to the following structure::
 
     #define FS_MAX_KEY_SIZE 64
 
@@ -386,6 +394,17 @@ key payload must conform to the following structure::
 ``raw`` with ``size`` indicating its size in bytes.  That is, the
 bytes ``raw[0..size-1]`` (inclusive) are the actual key.
 
+When using an "encrypted" key, only the actual ``raw`` key from above
+fscrypt_key structure is needed::
+
+    keyctl add encrypted "fscrypt:``master_key_descriptor``" "new default trusted:``master-key-name`` ``size``" ``ring``
+    keyctl add encrypted "fscrypt:``master_key_descriptor``" "load ``hex_blob``" ``ring``
+
+Where::
+
+    master-key-name:= name of the trusted key this fscrypt master key
+                      shall be rooted in
+
 The key description prefix "fscrypt:" may alternatively be replaced
 with a filesystem-specific prefix such as "ext4:".  However, the
 filesystem-specific prefixes are deprecated and should not be used in
@@ -412,6 +431,33 @@ evicted.  In the future there probably should be a way to provide keys
 directly to the filesystem instead, which would make the intended
 semantics clearer.
 
+Complete Examples
+------------------
+
+Set fscrypt policy on an (empty) encrypted directory, /encrypted::
+
+    $ fscryptctl set_policy 1234567890123456 /encrypted
+
+Create an encrypted key "1234567890123456" of length 64 bytes with format
+'fscrypt' and root it in a previously loaded trusted "kmk"::
+
+    $ keyctl add encrypted "fscrypt:1234567890123456" "new default trusted:kmk 64" @u
+    839715473
+
+    $ keyctl print 839715473
+    default trusted:kmk 64 e98a49dc11eb9312f46530879aac869300ee734035100f4ee
+    5441279369a4c9d83d6e59b8158d0a3de01790c0bb99af82e9603cb6977c7d1229338cda
+    80375aaf034678405a00c19806d6fb12490e39b1d7ca603c491b58a962345160e344ae51
+    83483e066692d05f5ab3d8b9ea39cab0e
+
+    $ keyctl pipe 839715473 > fscrypt.blob
+
+The directory policy will remain across reboots, so after a reboot the key
+generated earlier will simply have to be loaded into the kernel keyring
+again::
+
+    $ keyctl add encrypted fscrypt:1234567890123456 "load $(cat fscrypt.blob)" @u
+
 Access semantics
 ================
 
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 5e6e846f5a24..3d20addadcd4 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,6 +10,7 @@
  */
 
 #include <keys/user-type.h>
+#include <keys/encrypted-type.h>
 #include <linux/scatterlist.h>
 #include <linux/ratelimit.h>
 #include <crypto/aes.h>
@@ -20,14 +21,16 @@ static struct crypto_shash *essiv_hash_tfm;
 
 /**
  * derive_key_aes() - Derive a key using AES-128-ECB
- * @deriving_key: Encryption key used for derivation.
- * @source_key:   Source key to which to apply derivation.
- * @derived_raw_key:  Derived raw key.
+ * @deriving_key:    Encryption key used for derivation.
+ * @source_key:      Raw source key to which to apply derivation.
+ * @source_key_len:  Length of the source key.
+ * @derived_raw_key: Derived raw key.
  *
  * Return: Zero on success; non-zero otherwise.
  */
 static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
-				const struct fscrypt_key *source_key,
+				const u8 source_key[FS_MAX_KEY_SIZE],
+				u32 source_key_len,
 				u8 derived_raw_key[FS_MAX_KEY_SIZE])
 {
 	int res = 0;
@@ -55,9 +58,9 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	if (res < 0)
 		goto out;
 
-	sg_init_one(&src_sg, source_key->raw, source_key->size);
-	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
-	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
+	sg_init_one(&src_sg, source_key, source_key_len);
+	sg_init_one(&dst_sg, derived_raw_key, source_key_len);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key_len,
 				   NULL);
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 out:
@@ -66,14 +69,21 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	return res;
 }
 
-static int validate_user_key(struct fscrypt_info *crypt_info,
+static inline struct key *fscrypt_get_encrypted_key(const char *description)
+{
+	if (IS_ENABLED(CONFIG_ENCRYPTED_KEYS))
+		return request_key(&key_type_encrypted, description, NULL);
+	return ERR_PTR(-ENOKEY);
+}
+
+static int validate_keyring_key(struct fscrypt_info *crypt_info,
 			struct fscrypt_context *ctx, u8 *raw_key,
 			const char *prefix, int min_keysize)
 {
 	char *description;
 	struct key *keyring_key;
-	struct fscrypt_key *master_key;
-	const struct user_key_payload *ukp;
+	const u8 *master_key;
+	u32 master_key_len;
 	int res;
 
 	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
@@ -83,39 +93,55 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 		return -ENOMEM;
 
 	keyring_key = request_key(&key_type_logon, description, NULL);
+	if (keyring_key == ERR_PTR(-ENOKEY))
+		keyring_key = fscrypt_get_encrypted_key(description);
 	kfree(description);
 	if (IS_ERR(keyring_key))
 		return PTR_ERR(keyring_key);
 	down_read(&keyring_key->sem);
 
-	if (keyring_key->type != &key_type_logon) {
+	if (keyring_key->type == &key_type_logon) {
+		const struct user_key_payload *ukp;
+		const struct fscrypt_key *fk;
+
+		ukp = user_key_payload_locked(keyring_key);
+		if (!ukp) {
+			/* key was revoked before we acquired its semaphore */
+			res = -EKEYREVOKED;
+			goto out;
+		}
+		if (ukp->datalen != sizeof(struct fscrypt_key)) {
+			res = -EINVAL;
+			goto out;
+		}
+		fk = (struct fscrypt_key *)ukp->data;
+		master_key = fk->raw;
+		master_key_len = fk->size;
+	} else if (keyring_key->type == &key_type_encrypted) {
+		const struct encrypted_key_payload *ekp;
+
+		ekp = keyring_key->payload.data[0];
+		master_key = ekp->decrypted_data;
+		master_key_len = ekp->decrypted_datalen;
+	} else {
 		printk_once(KERN_WARNING
-				"%s: key type must be logon\n", __func__);
+				"%s: key type must be logon or encrypted\n",
+				__func__);
 		res = -ENOKEY;
 		goto out;
 	}
-	ukp = user_key_payload_locked(keyring_key);
-	if (!ukp) {
-		/* key was revoked before we acquired its semaphore */
-		res = -EKEYREVOKED;
-		goto out;
-	}
-	if (ukp->datalen != sizeof(struct fscrypt_key)) {
-		res = -EINVAL;
-		goto out;
-	}
-	master_key = (struct fscrypt_key *)ukp->data;
 	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
 
-	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
-	    || master_key->size % AES_BLOCK_SIZE != 0) {
+	if (master_key_len < min_keysize || master_key_len > FS_MAX_KEY_SIZE
+	    || master_key_len % AES_BLOCK_SIZE != 0) {
 		printk_once(KERN_WARNING
-				"%s: key size incorrect: %d\n",
-				__func__, master_key->size);
+				"%s: key size incorrect: %u\n",
+				__func__, master_key_len);
 		res = -ENOKEY;
 		goto out;
 	}
-	res = derive_key_aes(ctx->nonce, master_key, raw_key);
+	res = derive_key_aes(ctx->nonce, master_key, master_key_len, raw_key);
+
 out:
 	up_read(&keyring_key->sem);
 	key_put(keyring_key);
@@ -302,12 +328,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (!raw_key)
 		goto out;
 
-	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
-				keysize);
+	res = validate_keyring_key(crypt_info, &ctx, raw_key,
+				   FS_KEY_DESC_PREFIX, keysize);
 	if (res && inode->i_sb->s_cop->key_prefix) {
-		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
-					     inode->i_sb->s_cop->key_prefix,
-					     keysize);
+		int res2 = validate_keyring_key(crypt_info, &ctx, raw_key,
+						inode->i_sb->s_cop->key_prefix,
+						keysize);
 		if (res2) {
 			if (res2 == -ENOKEY)
 				res = -ENOKEY;
-- 
2.15.1

