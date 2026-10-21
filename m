Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792622749;
	b=3KmfQTDVTIbB+syIAhDOVaHP9lHWGiIkTuvHOHQ4c//44OoYaNBStZCVN7qP0bWL1t+j
	 lKw/zLeEiJXHZTXnw9y7jlRbKp0kzjw1QvG9nBFLlVbSPdwEaiBCs7M4hNhYwwsI31S6M
	 BmgRBF9i5aM6aAROJjDG2WeZ8vwwsbh+wpwfFdruikV675xH/JKNQXdW2M3F+N3iBLSjR
	 4IF3V9CggHaEdS9Lsy4TdiPosTGTJ9pb9WHlEbyWJeBgbyntSyQ78WnKcVn5bUrwEljk+
	 WWaBTsKobd4A49JkCjZxrP0C8Q86KqDq82BPZ1AyWbLqG3JIWHkEGl1ZImRfRYuOvMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792622749;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=sOjElZm/fFgJtxW5aomI8p2CM7DqWptk/YkqplyYGGI=;
	b=1tV3FfnkAf3cH0OP+OvZN5S3R/Xxd1Lh/2O0l52Li8I0WZncSvdRTfDUjq5wS7MCsv9d
	 U0/QrGF1JL4jr0in+wff9lYdSZd6YtYBUN8Ife8eVsvr1ewnLhX/pFuDk/RqDiGtsmYBT
	 X53MkGPfOYBvdHINWJXS6gCJXsU4z8mhnkt9PnJbSNQ54LoBSdrTmGr9tcWLs4HEvNek6
	 WEml3OjqKr2gesovCzPU94FpV3mDAhzB21GCixIBjz/sO8OSN5lh9p4E2z4BmRDFXHany
	 kpUxl0VPVbuUbAwSu0tdhUZ1MnjoQHo6ALey9VtnVXZ3DXT4LFwY13Ex5fWzdQQ5Y1A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UdvbE7SJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E52F606A326
	for <linux-fscrypt@vger.kernel.org>; Wed, 21 Oct 2026 22:45:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UdvbE7SJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 021E51F000C1;
	Wed, 21 Oct 2026 22:45:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792622749;
	bh=sOjElZm/fFgJtxW5aomI8p2CM7DqWptk/YkqplyYGGI=;
	h=From:To:Cc:Subject:Date;
	b=UdvbE7SJ62ZwJM6V8qkKjq/m+2a5tII5FCOgwGp5FNR2djikI5Y9nWeb7BSnA1Ti0
	 Cu+0CY1jYN25KiV3HX4JB0m+0sjEGE7Z2zI3j13w/oTvBsRFriXgoj2VDAyF3FvJ38
	 D4sxR25hkIVbHKA+aG8pzN/BKlse7ud7+5aRCSmgpw/Fatr0NDMksarpcP8cphsVPz
	 25sFL/+qx6viCnhTRF5U7JQK67sc+9M0xz07y0g2RTlgEOhKuicRlRy1UO3Y1TNcsP
	 UBnI4rOO05W+7069utHJqu6sa7pYhUDE1ZhIIK7a4kNTk/xIz0LCPD1javR9BkZ+3b
	 1zdYB5NLP9H/g==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Explicitly zeroize sw_secret in error path
Date: Wed, 21 Oct 2026 22:44:31 +0000
Message-ID: <20261021224431.2353673-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.56.0.218.g1ec904b173-goog
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Explicitly zeroize the sw_secret array in the case where
fscrypt_derive_sw_secret() fails, in case anything was written to it.
Doesn't really matter, but this came up in a code review.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/keyring.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 874cc183ee624..09364fddcb7a1 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -561,8 +561,10 @@ static int add_master_key(struct super_block *sb,
 		if (secret->is_hw_wrapped) {
 			err = fscrypt_derive_sw_secret(sb, secret->bytes,
 						       secret->size, sw_secret);
-			if (err)
+			if (err) {
+				memzero_explicit(sw_secret, sizeof(sw_secret));
 				return err;
+			}
 			kdf_key = sw_secret;
 			kdf_key_size = sizeof(sw_secret);
 			/*

base-commit: ccc4d9f8912a5d9f519a34c3633fe53c8f9b429e
-- 
2.56.0.218.g1ec904b173-goog

