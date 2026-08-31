Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5372136EA8B;
	Mon, 31 Aug 2026 19:25:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788204354; cv=none; b=ToWm0Se7OsBowE2pAwbqh82gcaqVRh8Ul1uGjKlq8otPn/1Mqz2DQoOib2IVNZWMvb4QwW9rwafwKdRW60So4WjS4bAQFZCkuJsHTyHWbrFTvJ4Xao0hwt3XSTsV/ADtOe6gEafVw2jMQ0sbhhuK6s6YiP1bZfY77B9IteTYsXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788204354; c=relaxed/simple;
	bh=G9QhhCagjvtn18l4/2aarjQSUwTP9Jfbcki9KCBqaWE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BTkjd/YsrXYpfuR0JDFKjNuSNo79MvKGxd+j5GrbgPYaTeF7QEOy8/WXTfnbQ3+cuXJ7W2ur9slaZLJXq/F+r9hJxSE2/a99QC9RObH62NrAGJDYoZXX2iwasTIwN+H1GyxAPBM4ypQX2nN/k6sCB+CJOiBfSoi6ccCxy5D8NAU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Cx2KOD5z; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Cx2KOD5z"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 11BEB1F000E9;
	Mon, 31 Aug 2026 19:25:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788204353;
	bh=6aqHLMLZT+gg18mKlo64TRGvpIb3cAJCp5jHu17KQ0U=;
	h=From:To:Cc:Subject:Date;
	b=Cx2KOD5zR/CcvwWIkd8i1/3iqkcdFCKzP/wLqQMxEfK29nx10OGUdnLKg7Ic/PeET
	 jhvbhyV3KNBne4R8ZmSBriQDVPOohdxSPZX8naxd4hdnFXmtIM5vKzmSFAzz4zsGc0
	 vae1BaUQToTN2n+e40pJoinr+C67ulc7Kd5u9XylFeN48MpRhD3M2lrci+W1CjF0cZ
	 YhvkQ1krOAlEIcKdCjowmmDu7EvBEeVywdt9UJxB1aagDUL9loKZBSsucKB+Bt+ZBF
	 xuAKD2wTugVjrtxrkFywhszR79w0eFhOXq4xemXEcWCTL6oRDwOWC48aCmF0ujFlnd
	 cBN1QrtUhBkrg==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Use aes_ecb_encrypt() for v1 key derivation
Date: Mon, 31 Aug 2026 12:24:11 -0700
Message-ID: <20260831192411.99035-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Now that there's a library function aes_ecb_encrypt(), use it instead of
a loop of aes_encrypt() calls.

Note that the use of AES-ECB here is purely for the key derivation
function used by the deprecated v1 encryption policies.  v2 encryption
policies use HKDF-SHA512 instead.  Nevertheless, the original version
has to continue to be supported for backwards compatibility.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/Kconfig       | 2 +-
 fs/crypto/keysetup_v1.c | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index cd934e31dec4..4cfbf4b51be7 100644
--- a/fs/crypto/Kconfig
+++ b/fs/crypto/Kconfig
@@ -5,7 +5,7 @@ config FS_ENCRYPTION
 	select BLK_INLINE_ENCRYPTION_FALLBACK if BLOCK
 	select CRYPTO
 	select CRYPTO_SKCIPHER
-	select CRYPTO_LIB_AES
+	select CRYPTO_LIB_AES_ECB # for deprecated v1 key derivation function
 	select CRYPTO_LIB_SHA256
 	select CRYPTO_LIB_SHA512
 	select KEYS
diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index 87fe13ccb253..d9ac7c4328f8 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -20,7 +20,7 @@
  *    managed alongside the master keys in the filesystem-level keyring)
  */
 
-#include <crypto/aes.h>
+#include <crypto/aes-ecb.h>
 #include <crypto/utils.h>
 #include <keys/user-type.h>
 #include <linux/hashtable.h>
@@ -246,8 +246,7 @@ static int setup_v1_file_key_derived(struct fscrypt_inode_info *ci,
 
 	static_assert(FSCRYPT_FILE_NONCE_SIZE == AES_KEYSIZE_128);
 	aes_prepareenckey(&aes, ci->ci_nonce, FSCRYPT_FILE_NONCE_SIZE);
-	for (unsigned int i = 0; i < derived_keysize; i += AES_BLOCK_SIZE)
-		aes_encrypt(&aes, &derived_key[i], &raw_master_key[i]);
+	aes_ecb_encrypt(derived_key, raw_master_key, derived_keysize, &aes);
 
 	err = fscrypt_set_per_file_enc_key(ci, derived_key);
 

base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
-- 
2.55.0

