Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:51770 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729948AbeKQLne (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 17 Nov 2018 06:43:34 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v4 02/14] crypto: chacha20-generic - don't unnecessarily use atomic walk
Date: Fri, 16 Nov 2018 17:26:19 -0800
Message-Id: <20181117012631.23528-3-ebiggers@kernel.org>
In-Reply-To: <20181117012631.23528-1-ebiggers@kernel.org>
References: <20181117012631.23528-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

chacha20-generic doesn't use SIMD instructions or otherwise disable
preemption, so passing atomic=true to skcipher_walk_virt() is
unnecessary.

Suggested-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Acked-by: Martin Willi <martin@strongswan.org>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 crypto/chacha20_generic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/chacha20_generic.c b/crypto/chacha20_generic.c
index 3ae96587caf9..3529521d72a4 100644
--- a/crypto/chacha20_generic.c
+++ b/crypto/chacha20_generic.c
@@ -81,7 +81,7 @@ int crypto_chacha20_crypt(struct skcipher_request *req)
 	u32 state[16];
 	int err;
 
-	err = skcipher_walk_virt(&walk, req, true);
+	err = skcipher_walk_virt(&walk, req, false);
 
 	crypto_chacha20_init(state, ctx, walk.iv);
 
-- 
2.19.1.1215.g8438c0b245-goog
