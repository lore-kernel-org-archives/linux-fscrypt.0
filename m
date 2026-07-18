Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F4FF377A95;
	Sat, 18 Jul 2026 21:49:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411350; cv=none; b=KObP770UTThKPyFdNkLMSh7WxCJEC4qA/wI33gXrIojHN7Q7IIkyuPCON1UQjaonV/6mArKyNokpQqZFFR4BlNYDCysAikIt29xHe1vT/Ruwlq5DGp3T01S0n1aRcD82bCNM3y1tp41WzVp3p0wsGOGG2Pox5qh8casmdASZ7ew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411350; c=relaxed/simple;
	bh=UzN3AUg3yPouyeJusVqRGKrfZ7Pf/B3sUo/npKtT4aA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fGrABM8rMqr3PvuYZauSnFj0SEoExx2bmhqs4TcRVtmVpLs6+Ssm7ZRHptIRBDmGqAT18gQGm6wYD51Q2YegQSPltRiROlJdQA/P4gu2WGpoOGLLQuGDVQMc1+9Od8r8cRs0g3P9p7Xu8Pssxp1+BOQTw75nRdzr0qYN6x1Mo9s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BVtd71J2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BVtd71J2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6A2561F00A3E;
	Sat, 18 Jul 2026 21:49:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411349;
	bh=0gESiSJCAMF2nF6DvOYmrqypPXEEEvUEZD60a26iDS0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BVtd71J2kLUxAd0N5bHGPILTOS3c1+n6T1M5mOBwIW6SdWiPcRncWpFHIx0b436s+
	 pSQNwCQrgd9ZG0ciFXM4utybbl07BJ4GLQjeOOSS1eBd74D45gp0axnzoAfb3wAKPc
	 zDNIc79Tlk7IyLdWa5bWxx7zuMVYpJxA3Rk3D1z/hlULVJo9zAMqhnk8uZyw0yy4/X
	 uXp134DHz9C/K4J0nOX8y0K9ibwBK6ZhKtJmpe4b3IXpwumfKo/+hWj8E67c0Ocx4l
	 xGbFXbJC4y9rV6M5r3EBnOsa/nzikQqdQFT2258BX5ZX4KwTLnk1fps4lV/Chj9wB3
	 QH86kpdwUOFMQ==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6/6] blk-crypto: Update docs for blk-crypto-fallback motivation
Date: Sat, 18 Jul 2026 14:46:55 -0700
Message-ID: <20260718214655.63186-7-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260718214655.63186-1-ebiggers@kernel.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The "Objective" section of inline-encryption.rst suggests that
blk-crypto-fallback is just for testing.  That's no longer accurate, so
update it accordingly.  Also fix a typo later in the document.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/block/inline-encryption.rst | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/Documentation/block/inline-encryption.rst b/Documentation/block/inline-encryption.rst
index 0052c7011b48..0df964507f76 100644
--- a/Documentation/block/inline-encryption.rst
+++ b/Documentation/block/inline-encryption.rst
@@ -37,12 +37,12 @@ initialization vector for each sector, and can be tested for correctness.
 Objective
 =========
 
-We want to support inline encryption in the kernel.  To make testing easier, we
-also want support for falling back to the kernel crypto API when actual inline
-encryption hardware is absent.  We also want inline encryption to work with
-layered devices like device-mapper and loopback (i.e. we want to be able to use
-the inline encryption hardware of the underlying devices if present, or else
-fall back to crypto API en/decryption).
+We want to support inline encryption hardware in the kernel.  The API for using
+such hardware should also support a fallback to the CPU, so that users only need
+to use a single API and more of the code can be tested without actual hardware.
+We also want inline encryption to work with layered devices like device-mapper
+and loopback (i.e. we want to be able to use the inline encryption hardware of
+the underlying devices if present, or else fall back to the CPU).
 
 Constraints and notes
 =====================
@@ -295,7 +295,7 @@ hardware implementations might not implement both features together correctly,
 and disallow the combination for now. Whenever a device supports integrity, the
 kernel will pretend that the device does not support hardware inline encryption
 (by setting the blk_crypto_profile in the request_queue of the device to NULL).
-When the crypto API fallback is enabled, this means that all bios with and
+When the crypto API fallback is enabled, this means that all bios with an
 encryption context will use the fallback, and IO will complete as usual.  When
 the fallback is disabled, a bio with an encryption context will be failed.
 
-- 
2.55.0

