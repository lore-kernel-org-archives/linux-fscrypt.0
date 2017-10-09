Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2] fscrypt: fix dereference of NULL user_key_payload
Date: Mon,  9 Oct 2017 12:46:18 -0700
Message-Id: <20171009194618.67494-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: keyrings@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

When an fscrypt-encrypted file is opened, we request the file's master
key from the keyrings service as a logon key, then access its payload.
However, a revoked key has a NULL payload, and we failed to check for
this.  request_key() *does* skip revoked keys, but there is still a
window where the key can be revoked before we acquire its semaphore.

Fix it by checking for a NULL payload, treating it like a key which was
already revoked at the time it was requested.

Fixes: 88bd6ccdcdd6 ("ext4 crypto: add encryption key management facilities")
Reviewed-by: James Morris <james.l.morris@oracle.com>
Cc: <stable@vger.kernel.org>    [v4.1+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---

Changed since v1: added Reviewed-by and resent as standalone patch.
Can this please be taken through the fscrypt tree?

 fs/crypto/keyinfo.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 018c588c7ac3..8e704d12a1cf 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -109,6 +109,11 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 		goto out;
 	}
 	ukp = user_key_payload_locked(keyring_key);
+	if (!ukp) {
+		/* key was revoked before we acquired its semaphore */
+		res = -EKEYREVOKED;
+		goto out;
+	}
 	if (ukp->datalen != sizeof(struct fscrypt_key)) {
 		res = -EINVAL;
 		goto out;
-- 
2.14.2.920.gcf0c67979c-goog
