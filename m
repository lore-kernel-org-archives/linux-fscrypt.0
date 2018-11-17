Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:51748 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729923AbeKQLne (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 17 Nov 2018 06:43:34 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v4 01/14] crypto: chacha20-generic - add HChaCha20 library function
Date: Fri, 16 Nov 2018 17:26:18 -0800
Message-Id: <20181117012631.23528-2-ebiggers@kernel.org>
In-Reply-To: <20181117012631.23528-1-ebiggers@kernel.org>
References: <20181117012631.23528-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Refactor the unkeyed permutation part of chacha20_block() into its own
function, then add hchacha20_block() which is the ChaCha equivalent of
HSalsa20 and is an intermediate step towards XChaCha20 (see
https://cr.yp.to/snuffle/xsalsa-20081128.pdf).  HChaCha20 skips the
final addition of the initial state, and outputs only certain words of
the state.  It should not be used for streaming directly.

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Acked-by: Martin Willi <martin@strongswan.org>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/crypto/chacha20.h |  2 ++
 lib/chacha20.c            | 50 ++++++++++++++++++++++++++++++++++-----
 2 files changed, 46 insertions(+), 6 deletions(-)

diff --git a/include/crypto/chacha20.h b/include/crypto/chacha20.h
index 2d3129442a52..56073814eef0 100644
--- a/include/crypto/chacha20.h
+++ b/include/crypto/chacha20.h
@@ -20,6 +20,8 @@ struct chacha20_ctx {
 };
 
 void chacha20_block(u32 *state, u8 *stream);
+void hchacha20_block(const u32 *in, u32 *out);
+
 void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv);
 int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			   unsigned int keysize);
diff --git a/lib/chacha20.c b/lib/chacha20.c
index d907fec6a9ed..6a484e16171d 100644
--- a/lib/chacha20.c
+++ b/lib/chacha20.c
@@ -1,5 +1,5 @@
 /*
- * ChaCha20 256-bit cipher algorithm, RFC7539
+ * The "hash function" used as the core of the ChaCha20 stream cipher (RFC7539)
  *
  * Copyright (C) 2015 Martin Willi
  *
@@ -16,14 +16,10 @@
 #include <asm/unaligned.h>
 #include <crypto/chacha20.h>
 
-void chacha20_block(u32 *state, u8 *stream)
+static void chacha20_permute(u32 *x)
 {
-	u32 x[16];
 	int i;
 
-	for (i = 0; i < ARRAY_SIZE(x); i++)
-		x[i] = state[i];
-
 	for (i = 0; i < 20; i += 2) {
 		x[0]  += x[4];    x[12] = rol32(x[12] ^ x[0],  16);
 		x[1]  += x[5];    x[13] = rol32(x[13] ^ x[1],  16);
@@ -65,6 +61,25 @@ void chacha20_block(u32 *state, u8 *stream)
 		x[8]  += x[13];   x[7]  = rol32(x[7]  ^ x[8],   7);
 		x[9]  += x[14];   x[4]  = rol32(x[4]  ^ x[9],   7);
 	}
+}
+
+/**
+ * chacha20_block - generate one keystream block and increment block counter
+ * @state: input state matrix (16 32-bit words)
+ * @stream: output keystream block (64 bytes)
+ *
+ * This is the ChaCha20 core, a function from 64-byte strings to 64-byte
+ * strings.  The caller has already converted the endianness of the input.  This
+ * function also handles incrementing the block counter in the input matrix.
+ */
+void chacha20_block(u32 *state, u8 *stream)
+{
+	u32 x[16];
+	int i;
+
+	memcpy(x, state, 64);
+
+	chacha20_permute(x);
 
 	for (i = 0; i < ARRAY_SIZE(x); i++)
 		put_unaligned_le32(x[i] + state[i], &stream[i * sizeof(u32)]);
@@ -72,3 +87,26 @@ void chacha20_block(u32 *state, u8 *stream)
 	state[12]++;
 }
 EXPORT_SYMBOL(chacha20_block);
+
+/**
+ * hchacha20_block - abbreviated ChaCha20 core, for XChaCha20
+ * @in: input state matrix (16 32-bit words)
+ * @out: output (8 32-bit words)
+ *
+ * HChaCha20 is the ChaCha equivalent of HSalsa20 and is an intermediate step
+ * towards XChaCha20 (see https://cr.yp.to/snuffle/xsalsa-20081128.pdf).
+ * HChaCha20 skips the final addition of the initial state, and outputs only
+ * certain words of the state.  It should not be used for streaming directly.
+ */
+void hchacha20_block(const u32 *in, u32 *out)
+{
+	u32 x[16];
+
+	memcpy(x, in, 64);
+
+	chacha20_permute(x);
+
+	memcpy(&out[0], &x[0], 16);
+	memcpy(&out[4], &x[12], 16);
+}
+EXPORT_SYMBOL(hchacha20_block);
-- 
2.19.1.1215.g8438c0b245-goog
