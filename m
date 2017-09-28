Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 6/7] ecryptfs: fix out-of-bounds read of key payload
Date: Thu, 28 Sep 2017 14:26:01 -0700
Message-Id: <20170928212602.41744-7-ebiggers3@gmail.com>
In-Reply-To: <20170928212602.41744-1-ebiggers3@gmail.com>
References: <20170928212602.41744-1-ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, Michael Halcrow <mhalcrow@google.com>, linux-cachefs@redhat.com, ecryptfs@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-security-module@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

eCryptfs blindly casts the user-supplied key payload to a
'struct ecryptfs_auth_tok' without validating that the payload does, in
fact, have the size of a 'struct ecryptfs_auth_tok'.  Fix it.

Fixes: 237fead61998 ("[PATCH] ecryptfs: fs/Makefile and fs/Kconfig")
Cc: <stable@vger.kernel.org>    [v2.6.19+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ecryptfs/ecryptfs_kernel.h | 6 ++++++
 fs/ecryptfs/keystore.c        | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
index 3fbc0ff79699..945844d5f0ef 100644
--- a/fs/ecryptfs/ecryptfs_kernel.h
+++ b/fs/ecryptfs/ecryptfs_kernel.h
@@ -93,6 +93,9 @@ ecryptfs_get_encrypted_key_payload_data(struct key *key)
 	if (!payload)
 		return ERR_PTR(-EKEYREVOKED);
 
+	if (payload->payload_datalen != sizeof(struct ecryptfs_auth_tok))
+		return ERR_PTR(-EINVAL);
+
 	return (struct ecryptfs_auth_tok *)payload->payload_data;
 }
 
@@ -129,6 +132,9 @@ ecryptfs_get_key_payload_data(struct key *key)
 	if (!ukp)
 		return ERR_PTR(-EKEYREVOKED);
 
+	if (ukp->datalen != sizeof(struct ecryptfs_auth_tok))
+		return ERR_PTR(-EINVAL);
+
 	return (struct ecryptfs_auth_tok *)ukp->data;
 }
 
diff --git a/fs/ecryptfs/keystore.c b/fs/ecryptfs/keystore.c
index fa218cd64f74..95e20ab67df3 100644
--- a/fs/ecryptfs/keystore.c
+++ b/fs/ecryptfs/keystore.c
@@ -471,6 +471,10 @@ ecryptfs_verify_auth_tok_from_key(struct key *auth_tok_key,
 	(*auth_tok) = ecryptfs_get_key_payload_data(auth_tok_key);
 	if (IS_ERR(*auth_tok)) {
 		rc = PTR_ERR(*auth_tok);
+		if (rc == -EINVAL) {
+			ecryptfs_printk(KERN_ERR,
+					"Authentication token payload has wrong length\n");
+		}
 		*auth_tok = NULL;
 		goto out;
 	}
-- 
2.14.2.822.g60be5d43e6-goog
