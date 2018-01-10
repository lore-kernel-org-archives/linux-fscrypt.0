Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:44019 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933445AbeAJMoX (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 10 Jan 2018 07:44:23 -0500
From: =?UTF-8?q?Andr=C3=A9=20Draszik?= <git@andred.net>
Subject: [PATCH 2/3] fscrypt: add support for the encrypted key type
Date: Wed, 10 Jan 2018 12:44:17 +0000
Message-Id: <20180110124418.24385-2-git@andred.net>
In-Reply-To: <20180110124418.24385-1-git@andred.net>
References: <20180110124418.24385-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

We now try to acquire the key according to the
encryption policy from both key types, 'logon'
as well as 'encrypted'.

Signed-off-by: André Draszik <git@andred.net>
Cc: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: David Howells <dhowells@redhat.com>
Cc: James Morris <james.l.morris@oracle.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: linux-integrity@vger.kernel.org
Cc: keyrings@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
---
 fs/crypto/keyinfo.c | 58 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 38 insertions(+), 20 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 5e6e846f5a24..023fa19fec48 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,6 +10,7 @@
  */
 
 #include <keys/user-type.h>
+#include <keys/encrypted-type.h>
 #include <linux/scatterlist.h>
 #include <linux/ratelimit.h>
 #include <crypto/aes.h>
@@ -66,14 +67,20 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	return res;
 }
 
-static int validate_user_key(struct fscrypt_info *crypt_info,
+static inline struct key *fscrypt_get_encrypted_key(const char *sig)
+{
+	if (IS_ENABLED(CONFIG_ENCRYPTED_KEYS))
+		return request_key(&key_type_encrypted, sig, NULL);
+	return ERR_PTR(-ENOKEY);
+}
+
+static int validate_keyring_key(struct fscrypt_info *crypt_info,
 			struct fscrypt_context *ctx, u8 *raw_key,
 			const char *prefix, int min_keysize)
 {
 	char *description;
 	struct key *keyring_key;
 	struct fscrypt_key *master_key;
-	const struct user_key_payload *ukp;
 	int res;
 
 	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
@@ -83,28 +90,39 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 		return -ENOMEM;
 
 	keyring_key = request_key(&key_type_logon, description, NULL);
+	if (IS_ERR(keyring_key))
+		keyring_key = fscrypt_get_encrypted_key(description);
 	kfree(description);
 	if (IS_ERR(keyring_key))
 		return PTR_ERR(keyring_key);
 	down_read(&keyring_key->sem);
 
-	if (keyring_key->type != &key_type_logon) {
+	if (keyring_key->type == &key_type_logon) {
+		const struct user_key_payload *ukp;
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
+		master_key = (struct fscrypt_key *)ukp->data;
+	} else if (keyring_key->type == &key_type_encrypted) {
+		const struct encrypted_key_payload *ekp;
+
+		ekp = keyring_key->payload.data[0];
+		master_key = (struct fscrypt_key *)ekp->payload_data;
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
 
 	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
@@ -302,12 +320,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
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

