Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6AEC2288D0;
	Sat, 18 Jul 2026 20:56:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784408182; cv=none; b=tFDEFu0nSOqkIFIo4G9snPE3zBW7VBfjqsYs0I0W95xXSyZeph5GoPUNjrkAIzNwVrBVBKsWSMk1y9XqV093aGKxKDGclJ5AzO/N1kYOvYbei+KtiS5kjPsWn6f6/gjnui3Qg7spTYgbofPpOAtC4hg7fF4hsN83ym5Ngmnaqr8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784408182; c=relaxed/simple;
	bh=j86XqjC4uNX8trqmIuhMAATgDg++EYAkySrTiEyTG0o=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=h6ZOlA4bS1rCeuTKBcGg5fYvVRkGh78aIqTQi2kGHahhAwNwGNkVHJhJ1GxtcAfg+zRRxqRVkXymgbDObF5DnP2wXNqLskbq43wOPyURqaJLeQdhft0devV9eGaumibBAx6EXBj2fBhIMgoTHGapT7bXvR5L3OpWAwRBxzQDbTI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MeASEBsa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MeASEBsa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69E151F000E9;
	Sat, 18 Jul 2026 20:56:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784408181;
	bh=iOtEdLDyDCXHWeTF+An2Objigmk4V8wMlsD1fAj6n08=;
	h=From:To:Cc:Subject:Date;
	b=MeASEBsa5DQyuECPFFFi0hXvnj/gHCpBfpWQzkC0SZwGArFFtrTyDY9WSV523QfNM
	 SGnhd3pck5OEEwyGpN9abtQ09FvzVIthnYN7zjkF5ZceWuJroAJ9j3JKLGKIpPGlK3
	 Ipe36pZbIFLXX72aviU3AzADpJGGmAwv8G/egDXk0jXNkH3LW0K9Y59C7Glm6KCow9
	 Rt96mcQdBPRQbHvi5fUvdnfoBvdlP9Ib4ILjsAkvcx2nrX2H3c9D71/BPkN0CzlL0O
	 lbr7zvwNLy7iJ8Vi9Dlw9dyzY1K2T9IgLGOCkFh+e+wA8gJdpI8bG304ZsAqfJdl6I
	 2uYUxilnHOTAw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Replace some variable-size memsets with fixed-size
Date: Sat, 18 Jul 2026 13:56:06 -0700
Message-ID: <20260718205606.50713-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

For zeroing IVs and raw keys, remove the misguided optimization of
zeroing the actual size used (typically 16 and 64 bytes respectively)
instead of the max size (32 and 64 bytes respectively).  Using a
compile-time constant size allows the compiler to specialize the memset
for that size (typically by inlining a few 'mov' instructions), which
is more important than zeroing a few extra bytes with these small sizes.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/crypto.c      | 2 +-
 fs/crypto/keysetup.c    | 4 ++--
 fs/crypto/keysetup_v1.c | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 94dd6c89ddcd..3a280dcecc11 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -91,7 +91,7 @@ void fscrypt_generate_iv(union fscrypt_iv *iv, u64 index,
 {
 	u8 flags = fscrypt_policy_flags(&ci->ci_policy);
 
-	memset(iv, 0, ci->ci_mode->ivsize);
+	memset(iv, 0, sizeof(*iv));
 
 	if (flags & FSCRYPT_POLICY_FLAG_IV_INO_LBLK_64) {
 		WARN_ON_ONCE(index > U32_MAX);
diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index cfd348e2252e..348e05283ee4 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -282,7 +282,7 @@ static int setup_per_mode_enc_key(struct fscrypt_inode_info *ci,
 				    hkdf_info, hkdf_infolen, raw_mode_key,
 				    mode->keysize);
 		err = fscrypt_prepare_key(prep_key, raw_mode_key, ci);
-		memzero_explicit(raw_mode_key, mode->keysize);
+		memzero_explicit(raw_mode_key, sizeof(raw_mode_key));
 	}
 	if (err) {
 		kfree(new_node);
@@ -412,7 +412,7 @@ static int fscrypt_setup_v2_file_key(struct fscrypt_inode_info *ci,
 				    ci->ci_nonce, FSCRYPT_FILE_NONCE_SIZE,
 				    derived_key, ci->ci_mode->keysize);
 		err = fscrypt_set_per_file_enc_key(ci, derived_key);
-		memzero_explicit(derived_key, ci->ci_mode->keysize);
+		memzero_explicit(derived_key, sizeof(derived_key));
 	}
 	if (err)
 		return err;
diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index e6e527c73f16..2d95a0048438 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -245,7 +245,7 @@ static int setup_v1_file_key_derived(struct fscrypt_inode_info *ci,
 
 	err = fscrypt_set_per_file_enc_key(ci, derived_key);
 
-	memzero_explicit(derived_key, derived_keysize);
+	memzero_explicit(derived_key, sizeof(derived_key));
 	/* No need to zeroize 'aes', as its key is not secret. */
 	return err;
 }

base-commit: 2d0afaac9137e95e504bd3ad3512a9044745536b
-- 
2.55.0

