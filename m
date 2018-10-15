Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54100 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726848AbeJPBmu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 15 Oct 2018 21:42:50 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v2 08/12] crypto: poly1305 - add Poly1305 core API
Date: Mon, 15 Oct 2018 10:54:20 -0700
Message-Id: <20181015175424.97147-9-ebiggers@kernel.org>
In-Reply-To: <20181015175424.97147-1-ebiggers@kernel.org>
References: <20181015175424.97147-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Expose a low-level Poly1305 API which implements the
ε-almost-∆-universal (εA∆U) hash function underlying the Poly1305 MAC
and supports block-aligned inputs only.

This is needed for Adiantum hashing, which builds an εA∆U hash function
from NH and a polynomial evaluation in GF(2^{130}-5); this polynomial
evaluation is identical to the one the Poly1305 MAC does.  However, the
crypto_shash Poly1305 API isn't very appropriate for this because its
calling convention assumes it is used as a MAC, with a 32-byte
"one-time key" provided for every digest.

But by design, in Adiantum hashing the performance of the polynomial
evaluation isn't nearly as critical as NH.  So it suffices to just have
some C helper functions.  Thus, this patch adds such functions.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/x86/crypto/poly1305_glue.c |  20 ++--
 crypto/poly1305_generic.c       | 174 ++++++++++++++++++--------------
 include/crypto/poly1305.h       |  28 ++++-
 3 files changed, 136 insertions(+), 86 deletions(-)

diff --git a/arch/x86/crypto/poly1305_glue.c b/arch/x86/crypto/poly1305_glue.c
index f012b7e28ad1d..88cc01506c84a 100644
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
index 47d3a6b83931e..2a06874204e87 100644
--- a/crypto/poly1305_generic.c
+++ b/crypto/poly1305_generic.c
@@ -38,7 +38,7 @@ int crypto_poly1305_init(struct shash_desc *desc)
 {
 	struct poly1305_desc_ctx *dctx = shash_desc_ctx(desc);
 
-	memset(dctx->h, 0, sizeof(dctx->h));
+	poly1305_core_init(&dctx->h);
 	dctx->buflen = 0;
 	dctx->rset = false;
 	dctx->sset = false;
@@ -47,23 +47,16 @@ int crypto_poly1305_init(struct shash_desc *desc)
 }
 EXPORT_SYMBOL_GPL(crypto_poly1305_init);
 
-static void poly1305_setrkey(struct poly1305_desc_ctx *dctx, const u8 *key)
+void poly1305_core_setkey(struct poly1305_key *key, const u8 *raw_key)
 {
 	/* r &= 0xffffffc0ffffffc0ffffffc0fffffff */
-	dctx->r[0] = (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
-	dctx->r[1] = (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
-	dctx->r[2] = (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
-	dctx->r[3] = (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
-	dctx->r[4] = (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
-}
-
-static void poly1305_setskey(struct poly1305_desc_ctx *dctx, const u8 *key)
-{
-	dctx->s[0] = get_unaligned_le32(key +  0);
-	dctx->s[1] = get_unaligned_le32(key +  4);
-	dctx->s[2] = get_unaligned_le32(key +  8);
-	dctx->s[3] = get_unaligned_le32(key + 12);
+	key->r[0] = (get_unaligned_le32(raw_key +  0) >> 0) & 0x3ffffff;
+	key->r[1] = (get_unaligned_le32(raw_key +  3) >> 2) & 0x3ffff03;
+	key->r[2] = (get_unaligned_le32(raw_key +  6) >> 4) & 0x3ffc0ff;
+	key->r[3] = (get_unaligned_le32(raw_key +  9) >> 6) & 0x3f03fff;
+	key->r[4] = (get_unaligned_le32(raw_key + 12) >> 8) & 0x00fffff;
 }
+EXPORT_SYMBOL_GPL(poly1305_core_setkey);
 
 /*
  * Poly1305 requires a unique key for each tag, which implies that we can't set
@@ -75,13 +68,16 @@ unsigned int crypto_poly1305_setdesckey(struct poly1305_desc_ctx *dctx,
 {
 	if (!dctx->sset) {
 		if (!dctx->rset && srclen >= POLY1305_BLOCK_SIZE) {
-			poly1305_setrkey(dctx, src);
+			poly1305_core_setkey(&dctx->r, src);
 			src += POLY1305_BLOCK_SIZE;
 			srclen -= POLY1305_BLOCK_SIZE;
 			dctx->rset = true;
 		}
 		if (srclen >= POLY1305_BLOCK_SIZE) {
-			poly1305_setskey(dctx, src);
+			dctx->s[0] = get_unaligned_le32(src +  0);
+			dctx->s[1] = get_unaligned_le32(src +  4);
+			dctx->s[2] = get_unaligned_le32(src +  8);
+			dctx->s[3] = get_unaligned_le32(src + 12);
 			src += POLY1305_BLOCK_SIZE;
 			srclen -= POLY1305_BLOCK_SIZE;
 			dctx->sset = true;
@@ -91,41 +87,37 @@ unsigned int crypto_poly1305_setdesckey(struct poly1305_desc_ctx *dctx,
 }
 EXPORT_SYMBOL_GPL(crypto_poly1305_setdesckey);
 
-static unsigned int poly1305_blocks(struct poly1305_desc_ctx *dctx,
-				    const u8 *src, unsigned int srclen,
-				    u32 hibit)
+static void poly1305_blocks_internal(struct poly1305_state *state,
+				     const struct poly1305_key *key,
+				     const void *src, unsigned int nblocks,
+				     u32 hibit)
 {
 	u32 r0, r1, r2, r3, r4;
 	u32 s1, s2, s3, s4;
 	u32 h0, h1, h2, h3, h4;
 	u64 d0, d1, d2, d3, d4;
-	unsigned int datalen;
 
-	if (unlikely(!dctx->sset)) {
-		datalen = crypto_poly1305_setdesckey(dctx, src, srclen);
-		src += srclen - datalen;
-		srclen = datalen;
-	}
+	if (!nblocks)
+		return;
 
-	r0 = dctx->r[0];
-	r1 = dctx->r[1];
-	r2 = dctx->r[2];
-	r3 = dctx->r[3];
-	r4 = dctx->r[4];
+	r0 = key->r[0];
+	r1 = key->r[1];
+	r2 = key->r[2];
+	r3 = key->r[3];
+	r4 = key->r[4];
 
 	s1 = r1 * 5;
 	s2 = r2 * 5;
 	s3 = r3 * 5;
 	s4 = r4 * 5;
 
-	h0 = dctx->h[0];
-	h1 = dctx->h[1];
-	h2 = dctx->h[2];
-	h3 = dctx->h[3];
-	h4 = dctx->h[4];
-
-	while (likely(srclen >= POLY1305_BLOCK_SIZE)) {
+	h0 = state->h[0];
+	h1 = state->h[1];
+	h2 = state->h[2];
+	h3 = state->h[3];
+	h4 = state->h[4];
 
+	do {
 		/* h += m[i] */
 		h0 += (get_unaligned_le32(src +  0) >> 0) & 0x3ffffff;
 		h1 += (get_unaligned_le32(src +  3) >> 2) & 0x3ffffff;
@@ -154,16 +146,36 @@ static unsigned int poly1305_blocks(struct poly1305_desc_ctx *dctx,
 		h1 += h0 >> 26;       h0 = h0 & 0x3ffffff;
 
 		src += POLY1305_BLOCK_SIZE;
-		srclen -= POLY1305_BLOCK_SIZE;
-	}
+	} while (--nblocks);
 
-	dctx->h[0] = h0;
-	dctx->h[1] = h1;
-	dctx->h[2] = h2;
-	dctx->h[3] = h3;
-	dctx->h[4] = h4;
+	state->h[0] = h0;
+	state->h[1] = h1;
+	state->h[2] = h2;
+	state->h[3] = h3;
+	state->h[4] = h4;
+}
 
-	return srclen;
+void poly1305_core_blocks(struct poly1305_state *state,
+			  const struct poly1305_key *key,
+			  const void *src, unsigned int nblocks)
+{
+	poly1305_blocks_internal(state, key, src, nblocks, 1 << 24);
+}
+EXPORT_SYMBOL_GPL(poly1305_core_blocks);
+
+static void poly1305_blocks(struct poly1305_desc_ctx *dctx,
+			    const u8 *src, unsigned int srclen, u32 hibit)
+{
+	unsigned int datalen;
+
+	if (unlikely(!dctx->sset)) {
+		datalen = crypto_poly1305_setdesckey(dctx, src, srclen);
+		src += srclen - datalen;
+		srclen = datalen;
+	}
+
+	poly1305_blocks_internal(&dctx->h, &dctx->r,
+				 src, srclen / POLY1305_BLOCK_SIZE, hibit);
 }
 
 int crypto_poly1305_update(struct shash_desc *desc,
@@ -187,9 +199,9 @@ int crypto_poly1305_update(struct shash_desc *desc,
 	}
 
 	if (likely(srclen >= POLY1305_BLOCK_SIZE)) {
-		bytes = poly1305_blocks(dctx, src, srclen, 1 << 24);
-		src += srclen - bytes;
-		srclen = bytes;
+		poly1305_blocks(dctx, src, srclen, 1 << 24);
+		src += srclen - (srclen % POLY1305_BLOCK_SIZE);
+		srclen %= POLY1305_BLOCK_SIZE;
 	}
 
 	if (unlikely(srclen)) {
@@ -201,30 +213,18 @@ int crypto_poly1305_update(struct shash_desc *desc,
 }
 EXPORT_SYMBOL_GPL(crypto_poly1305_update);
 
-int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
+void poly1305_core_emit(const struct poly1305_state *state, void *dst)
 {
-	struct poly1305_desc_ctx *dctx = shash_desc_ctx(desc);
 	u32 h0, h1, h2, h3, h4;
 	u32 g0, g1, g2, g3, g4;
 	u32 mask;
-	u64 f = 0;
-
-	if (unlikely(!dctx->sset))
-		return -ENOKEY;
-
-	if (unlikely(dctx->buflen)) {
-		dctx->buf[dctx->buflen++] = 1;
-		memset(dctx->buf + dctx->buflen, 0,
-		       POLY1305_BLOCK_SIZE - dctx->buflen);
-		poly1305_blocks(dctx, dctx->buf, POLY1305_BLOCK_SIZE, 0);
-	}
 
 	/* fully carry h */
-	h0 = dctx->h[0];
-	h1 = dctx->h[1];
-	h2 = dctx->h[2];
-	h3 = dctx->h[3];
-	h4 = dctx->h[4];
+	h0 = state->h[0];
+	h1 = state->h[1];
+	h2 = state->h[2];
+	h3 = state->h[3];
+	h4 = state->h[4];
 
 	h2 += (h1 >> 26);     h1 = h1 & 0x3ffffff;
 	h3 += (h2 >> 26);     h2 = h2 & 0x3ffffff;
@@ -254,16 +254,40 @@ int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
 	h4 = (h4 & mask) | g4;
 
 	/* h = h % (2^128) */
-	h0 = (h0 >>  0) | (h1 << 26);
-	h1 = (h1 >>  6) | (h2 << 20);
-	h2 = (h2 >> 12) | (h3 << 14);
-	h3 = (h3 >> 18) | (h4 <<  8);
+	put_unaligned_le32((h0 >>  0) | (h1 << 26), dst +  0);
+	put_unaligned_le32((h1 >>  6) | (h2 << 20), dst +  4);
+	put_unaligned_le32((h2 >> 12) | (h3 << 14), dst +  8);
+	put_unaligned_le32((h3 >> 18) | (h4 <<  8), dst + 12);
+}
+EXPORT_SYMBOL_GPL(poly1305_core_emit);
+
+int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
+{
+	struct poly1305_desc_ctx *dctx = shash_desc_ctx(desc);
+	__le32 digest[4];
+	u64 f = 0;
+
+	if (unlikely(!dctx->sset))
+		return -ENOKEY;
+
+	if (unlikely(dctx->buflen)) {
+		dctx->buf[dctx->buflen++] = 1;
+		memset(dctx->buf + dctx->buflen, 0,
+		       POLY1305_BLOCK_SIZE - dctx->buflen);
+		poly1305_blocks(dctx, dctx->buf, POLY1305_BLOCK_SIZE, 0);
+	}
+
+	poly1305_core_emit(&dctx->h, digest);
 
 	/* mac = (h + s) % (2^128) */
-	f = (f >> 32) + h0 + dctx->s[0]; put_unaligned_le32(f, dst +  0);
-	f = (f >> 32) + h1 + dctx->s[1]; put_unaligned_le32(f, dst +  4);
-	f = (f >> 32) + h2 + dctx->s[2]; put_unaligned_le32(f, dst +  8);
-	f = (f >> 32) + h3 + dctx->s[3]; put_unaligned_le32(f, dst + 12);
+	f = (f >> 32) + le32_to_cpu(digest[0]) + dctx->s[0];
+	put_unaligned_le32(f, dst + 0);
+	f = (f >> 32) + le32_to_cpu(digest[1]) + dctx->s[1];
+	put_unaligned_le32(f, dst + 4);
+	f = (f >> 32) + le32_to_cpu(digest[2]) + dctx->s[2];
+	put_unaligned_le32(f, dst + 8);
+	f = (f >> 32) + le32_to_cpu(digest[3]) + dctx->s[3];
+	put_unaligned_le32(f, dst + 12);
 
 	return 0;
 }
diff --git a/include/crypto/poly1305.h b/include/crypto/poly1305.h
index f718a19da82f7..34317ed2071e6 100644
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
@@ -30,6 +38,22 @@ struct poly1305_desc_ctx {
 	bool sset;
 };
 
+/*
+ * Poly1305 core functions.  These implement the ε-almost-∆-universal hash
+ * function underlying the Poly1305 MAC, i.e. they don't add an encrypted nonce
+ * ("s key") at the end.  They also only support block-aligned inputs.
+ */
+void poly1305_core_setkey(struct poly1305_key *key, const u8 *raw_key);
+static inline void poly1305_core_init(struct poly1305_state *state)
+{
+	memset(state->h, 0, sizeof(state->h));
+}
+void poly1305_core_blocks(struct poly1305_state *state,
+			  const struct poly1305_key *key,
+			  const void *src, unsigned int nblocks);
+void poly1305_core_emit(const struct poly1305_state *state, void *dst);
+
+/* Crypto API helper functions for the Poly1305 MAC */
 int crypto_poly1305_init(struct shash_desc *desc);
 unsigned int crypto_poly1305_setdesckey(struct poly1305_desc_ctx *dctx,
 					const u8 *src, unsigned int srclen);
-- 
2.19.1.331.ge82ca0e54c-goog
