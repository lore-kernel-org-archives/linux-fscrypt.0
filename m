Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54580 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728899AbeKFItN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Nov 2018 03:49:13 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v3 10/15] crypto: poly1305 - use structures for key and accumulator
Date: Mon,  5 Nov 2018 15:25:21 -0800
Message-Id: <20181105232526.173947-11-ebiggers@kernel.org>
In-Reply-To: <20181105232526.173947-1-ebiggers@kernel.org>
References: <20181105232526.173947-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In preparation for exposing a low-level Poly1305 API which implements
the ε-almost-∆-universal (εA∆U) hash function underlying the Poly1305
MAC and supports block-aligned inputs only, create structures
poly1305_key and poly1305_state which hold the limbs of the Poly1305
"r" key and accumulator, respectively.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/x86/crypto/poly1305_glue.c | 20 +++++++------
 crypto/poly1305_generic.c       | 52 ++++++++++++++++-----------------
 include/crypto/poly1305.h       | 12 ++++++--
 3 files changed, 47 insertions(+), 37 deletions(-)

diff --git a/arch/x86/crypto/poly1305_glue.c b/arch/x86/crypto/poly1305_glue.c
index f012b7e28ad1..88cc01506c84 100644
--- a/arch/x86/crypto/poly1305_glue.c
+++ b/arch/x86/crypto/poly1305_glue.c
@@ -83,35 +83,37 @@ static unsigned int poly1305_simd_blocks(struct poly1305_desc_ctx *dctx,
 	if (poly1305_use_avx2 && srclen >= POLY1305_BLOCK_SIZE * 4) {
 		if (unlikely(!sctx->wset)) {
 			if (!sctx->uset) {
-				memcpy(sctx->u, dctx->r, sizeof(sctx->u));
-				poly1305_simd_mult(sctx->u, dctx->r);
+				memcpy(sctx->u, dctx->r.r, sizeof(sctx->u));
+				poly1305_simd_mult(sctx->u, dctx->r.r);
 				sctx->uset = true;
 			}
 			memcpy(sctx->u + 5, sctx->u, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u + 5, dctx->r);
+			poly1305_simd_mult(sctx->u + 5, dctx->r.r);
 			memcpy(sctx->u + 10, sctx->u + 5, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u + 10, dctx->r);
+			poly1305_simd_mult(sctx->u + 10, dctx->r.r);
 			sctx->wset = true;
 		}
 		blocks = srclen / (POLY1305_BLOCK_SIZE * 4);
-		poly1305_4block_avx2(dctx->h, src, dctx->r, blocks, sctx->u);
+		poly1305_4block_avx2(dctx->h.h, src, dctx->r.r, blocks,
+				     sctx->u);
 		src += POLY1305_BLOCK_SIZE * 4 * blocks;
 		srclen -= POLY1305_BLOCK_SIZE * 4 * blocks;
 	}
 #endif
 	if (likely(srclen >= POLY1305_BLOCK_SIZE * 2)) {
 		if (unlikely(!sctx->uset)) {
-			memcpy(sctx->u, dctx->r, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u, dctx->r);
+			memcpy(sctx->u, dctx->r.r, sizeof(sctx->u));
+			poly1305_simd_mult(sctx->u, dctx->r.r);
 			sctx->uset = true;
 		}
 		blocks = srclen / (POLY1305_BLOCK_SIZE * 2);
-		poly1305_2block_sse2(dctx->h, src, dctx->r, blocks, sctx->u);
+		poly1305_2block_sse2(dctx->h.h, src, dctx->r.r, blocks,
+				     sctx->u);
 		src += POLY1305_BLOCK_SIZE * 2 * blocks;
 		srclen -= POLY1305_BLOCK_SIZE * 2 * blocks;
 	}
 	if (srclen >= POLY1305_BLOCK_SIZE) {
-		poly1305_block_sse2(dctx->h, src, dctx->r, 1);
+		poly1305_block_sse2(dctx->h.h, src, dctx->r.r, 1);
 		srclen -= POLY1305_BLOCK_SIZE;
 	}
 	return srclen;
diff --git a/crypto/poly1305_generic.c b/crypto/poly1305_generic.c
index 47d3a6b83931..a23173f351b7 100644
--- a/crypto/poly1305_generic.c
+++ b/crypto/poly1305_generic.c
@@ -38,7 +38,7 @@ int crypto_poly1305_init(struct shash_desc *desc)
 {
 	struct poly1305_desc_ctx *dctx = shash_desc_ctx(desc);
 
-	memset(dctx->h, 0, sizeof(dctx->h));
+	memset(dctx->h.h, 0, sizeof(dctx->h.h));
 	dctx->buflen = 0;
 	dctx->rset = false;
 	dctx->sset = false;
@@ -50,11 +50,11 @@ EXPORT_SYMBOL_GPL(crypto_poly1305_init);
 static void poly1305_setrkey(struct poly1305_desc_ctx *dctx, const u8 *key)
 {
 	/* r &= 0xffffffc0ffffffc0ffffffc0fffffff */
-	dctx->r[0] = (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
-	dctx->r[1] = (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
-	dctx->r[2] = (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
-	dctx->r[3] = (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
-	dctx->r[4] = (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
+	dctx->r.r[0] = (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
+	dctx->r.r[1] = (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
+	dctx->r.r[2] = (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
+	dctx->r.r[3] = (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
+	dctx->r.r[4] = (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
 }
 
 static void poly1305_setskey(struct poly1305_desc_ctx *dctx, const u8 *key)
@@ -107,22 +107,22 @@ static unsigned int poly1305_blocks(struct poly1305_desc_ctx *dctx,
 		srclen = datalen;
 	}
 
-	r0 = dctx->r[0];
-	r1 = dctx->r[1];
-	r2 = dctx->r[2];
-	r3 = dctx->r[3];
-	r4 = dctx->r[4];
+	r0 = dctx->r.r[0];
+	r1 = dctx->r.r[1];
+	r2 = dctx->r.r[2];
+	r3 = dctx->r.r[3];
+	r4 = dctx->r.r[4];
 
 	s1 = r1 * 5;
 	s2 = r2 * 5;
 	s3 = r3 * 5;
 	s4 = r4 * 5;
 
-	h0 = dctx->h[0];
-	h1 = dctx->h[1];
-	h2 = dctx->h[2];
-	h3 = dctx->h[3];
-	h4 = dctx->h[4];
+	h0 = dctx->h.h[0];
+	h1 = dctx->h.h[1];
+	h2 = dctx->h.h[2];
+	h3 = dctx->h.h[3];
+	h4 = dctx->h.h[4];
 
 	while (likely(srclen >= POLY1305_BLOCK_SIZE)) {
 
@@ -157,11 +157,11 @@ static unsigned int poly1305_blocks(struct poly1305_desc_ctx *dctx,
 		srclen -= POLY1305_BLOCK_SIZE;
 	}
 
-	dctx->h[0] = h0;
-	dctx->h[1] = h1;
-	dctx->h[2] = h2;
-	dctx->h[3] = h3;
-	dctx->h[4] = h4;
+	dctx->h.h[0] = h0;
+	dctx->h.h[1] = h1;
+	dctx->h.h[2] = h2;
+	dctx->h.h[3] = h3;
+	dctx->h.h[4] = h4;
 
 	return srclen;
 }
@@ -220,11 +220,11 @@ int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
 	}
 
 	/* fully carry h */
-	h0 = dctx->h[0];
-	h1 = dctx->h[1];
-	h2 = dctx->h[2];
-	h3 = dctx->h[3];
-	h4 = dctx->h[4];
+	h0 = dctx->h.h[0];
+	h1 = dctx->h.h[1];
+	h2 = dctx->h.h[2];
+	h3 = dctx->h.h[3];
+	h4 = dctx->h.h[4];
 
 	h2 += (h1 >> 26);     h1 = h1 & 0x3ffffff;
 	h3 += (h2 >> 26);     h2 = h2 & 0x3ffffff;
diff --git a/include/crypto/poly1305.h b/include/crypto/poly1305.h
index f718a19da82f..493244c46664 100644
--- a/include/crypto/poly1305.h
+++ b/include/crypto/poly1305.h
@@ -13,13 +13,21 @@
 #define POLY1305_KEY_SIZE	32
 #define POLY1305_DIGEST_SIZE	16
 
+struct poly1305_key {
+	u32 r[5];	/* key, base 2^26 */
+};
+
+struct poly1305_state {
+	u32 h[5];	/* accumulator, base 2^26 */
+};
+
 struct poly1305_desc_ctx {
 	/* key */
-	u32 r[5];
+	struct poly1305_key r;
 	/* finalize key */
 	u32 s[4];
 	/* accumulator */
-	u32 h[5];
+	struct poly1305_state h;
 	/* partial buffer */
 	u8 buf[POLY1305_BLOCK_SIZE];
 	/* bytes used in partial buffer */
-- 
2.19.1.930.g4563a0d9d0-goog
