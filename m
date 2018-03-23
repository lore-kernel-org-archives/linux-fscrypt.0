Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 05/14] fscrypt: don't clear flags on crypto transform
Date: Fri, 23 Mar 2018 12:23:49 -0700
Message-Id: <20180323192358.95691-6-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt is clearing the flags on the crypto_skcipher it allocates for
each inode.  But, this is unnecessary and may cause problems in the
future because it will even clear flags that are meant to be internal to
the crypto API, e.g. CRYPTO_TFM_NEED_KEY.

Remove the unnecessary flag clearing.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 8099388f5581..1435a1c81010 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -327,7 +327,6 @@ int fscrypt_get_encryption_info(struct inode *inode)
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
-	crypto_skcipher_clear_flags(ctfm, ~0);
 	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
 	/*
 	 * if the provided key is longer than keysize, we use the first
-- 
2.17.0.rc0.231.g781580f067-goog
