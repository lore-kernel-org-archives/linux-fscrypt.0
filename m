Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 5/7] ecryptfs: fix dereference of NULL user_key_payload
Date: Thu, 28 Sep 2017 14:26:00 -0700
Message-Id: <20170928212602.41744-6-ebiggers3@gmail.com>
In-Reply-To: <20170928212602.41744-1-ebiggers3@gmail.com>
References: <20170928212602.41744-1-ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In eCryptfs, we failed to verify that the authentication token keys are
not revoked before dereferencing their payloads, which is problematic
because the payload of a revoked key is NULL.  request_key() *does* skip
revoked keys, but there is still a window where the key can be revoked
before we acquire the key semaphore.

Fix it by updating ecryptfs_get_key_payload_data() to return
-EKEYREVOKED if the key payload is NULL.  For completeness we check this
for "encrypted" keys as well as "user" keys, although encrypted keys
cannot be revoked currently.

Alternatively we could use key_validate(), but since we'll also need to
fix ecryptfs_get_key_payload_data() to validate the payload length, it
seems appropriate to just check the payload pointer.

Fixes: 237fead61998 ("[PATCH] ecryptfs: fs/Makefile and fs/Kconfig")
Cc: <stable@vger.kernel.org>    [v2.6.19+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ecryptfs/ecryptfs_kernel.h | 24 +++++++++++++++++-------
 fs/ecryptfs/keystore.c        |  9 ++++++++-
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
index 9c351bf757b2..3fbc0ff79699 100644
--- a/fs/ecryptfs/ecryptfs_kernel.h
+++ b/fs/ecryptfs/ecryptfs_kernel.h
@@ -84,11 +84,16 @@ struct ecryptfs_page_crypt_context {
 static inline struct ecryptfs_auth_tok *
 ecryptfs_get_encrypted_key_payload_data(struct key *key)
 {
-	if (key->type == &key_type_encrypted)
-		return (struct ecryptfs_auth_tok *)
-			(&((struct encrypted_key_payload *)key->payload.data[0])->payload_data);
-	else
+	struct encrypted_key_payload *payload;
+
+	if (key->type != &key_type_encrypted)
 		return NULL;
+
+	payload = key->payload.data[0];
+	if (!payload)
+		return ERR_PTR(-EKEYREVOKED);
+
+	return (struct ecryptfs_auth_tok *)payload->payload_data;
 }
 
 static inline struct key *ecryptfs_get_encrypted_key(char *sig)
@@ -114,12 +119,17 @@ static inline struct ecryptfs_auth_tok *
 ecryptfs_get_key_payload_data(struct key *key)
 {
 	struct ecryptfs_auth_tok *auth_tok;
+	struct user_key_payload *ukp;
 
 	auth_tok = ecryptfs_get_encrypted_key_payload_data(key);
-	if (!auth_tok)
-		return (struct ecryptfs_auth_tok *)user_key_payload_locked(key)->data;
-	else
+	if (auth_tok)
 		return auth_tok;
+
+	ukp = user_key_payload_locked(key);
+	if (!ukp)
+		return ERR_PTR(-EKEYREVOKED);
+
+	return (struct ecryptfs_auth_tok *)ukp->data;
 }
 
 #define ECRYPTFS_MAX_KEYSET_SIZE 1024
diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
index 3cf1546dca82..fa218cd64f74 100644
--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -459,7 +459,8 @@ static int ecryptfs_verify_version(u16 version)
  * @auth_tok_key: key containing the authentication token
  * @auth_tok: authentication token
  *
- * Returns zero on valid auth tok; -EINVAL otherwise
+ * Returns zero on valid auth tok; -EINVAL if the payload is invalid; or
+ * -EKEYREVOKED if the key was revoked before we acquired its semaphore.
  */
 static int
 ecryptfs_verify_auth_tok_from_key(struct key *auth_tok_key,
@@ -468,6 +469,12 @@ ecryptfs_verify_auth_tok_from_key(struct key *auth_tok_key,
 	int rc = 0;
 
 	(*auth_tok) = ecryptfs_get_key_payload_data(auth_tok_key);
+	if (IS_ERR(*auth_tok)) {
+		rc = PTR_ERR(*auth_tok);
+		*auth_tok = NULL;
+		goto out;
+	}
+
 	if (ecryptfs_verify_version((*auth_tok)->version)) {
 		printk(KERN_ERR "Data structure version mismatch. Userspace "
 		       "tools must match eCryptfs kernel module with major "
-- 
2.14.2.822.g60be5d43e6-goog
