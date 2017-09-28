Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 1/7] KEYS: encrypted: fix dereference of NULL user_key_payload
Date: Thu, 28 Sep 2017 14:25:56 -0700
Message-Id: <20170928212602.41744-2-ebiggers3@gmail.com>
In-Reply-To: <20170928212602.41744-1-ebiggers3@gmail.com>
References: <20170928212602.41744-1-ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

A key of type "encrypted" references a "master key" which is used to
encrypt and decrypt the encrypted key's payload.  However, when we
accessed the master key's payload, we failed to handle the case where
the master key has been revoked, which sets the payload pointer to NULL.
Note that request_key() *does* skip revoked keys, but there is still a
window where the key can be revoked before we acquire its semaphore.

Fix it by checking for a NULL payload, treating it like a key which was
already revoked at the time it was requested.

This was an issue for master keys of type "user" only.  Master keys can
also be of type "trusted", but those cannot be revoked.

Fixes: 7e70cb497850 ("keys: add new key-type encrypted")
Cc: <stable@vger.kernel.org>    [v2.6.38+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 security/keys/encrypted-keys/encrypted.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/security/keys/encrypted-keys/encrypted.c b/security/keys/encrypted-keys/encrypted.c
index f54b92868bc3..d92cbf9687c3 100644
--- a/security/keys/encrypted-keys/encrypted.c
+++ b/security/keys/encrypted-keys/encrypted.c
@@ -309,6 +309,13 @@ static struct key *request_user_key(const char *master_desc, const u8 **master_k
 
 	down_read(&ukey->sem);
 	upayload = user_key_payload_locked(ukey);
+	if (!upayload) {
+		/* key was revoked before we acquired its semaphore */
+		up_read(&ukey->sem);
+		key_put(ukey);
+		ukey = ERR_PTR(-EKEYREVOKED);
+		goto error;
+	}
 	*master_key = upayload->data;
 	*master_keylen = upayload->datalen;
 error:
-- 
2.14.2.822.g60be5d43e6-goog
