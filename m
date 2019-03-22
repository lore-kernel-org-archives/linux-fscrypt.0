Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 7/17] crypto: poly1305 - Export core functions without crypto API
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgW-0001I5-Il@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:44 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch exports the raw poly1305 functions, including the generic
as well as the x86 accelerated version.  This allows them to be
used without going through the crypto API.
    
In order to ensure that zinc can link to the requisite functions,
this function removes the failure mode from the x86 accelerated
glue code so that the modules will always load, even if the hardware
is not available.  In that case, the crypto API functions would not
be registered.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/x86/crypto/poly1305_glue.c |   86 ++++++++++++++++++++--------------------
 crypto/poly1305_generic.c       |   16 +------
 include/crypto/poly1305.h       |   42 ++++++++++++++++++-
 3 files changed, 87 insertions(+), 57 deletions(-)

diff --git a/arch/x86/crypto/poly1305_glue.c b/arch/x86/crypto/poly1305_glue.c
index 88cc01506c84..7a70b0f42c5c 100644
--- a/arch/x86/crypto/poly1305_glue.c
+++ b/arch/x86/crypto/poly1305_glue.c
@@ -20,15 +20,7 @@
 
 struct poly1305_simd_desc_ctx {
 	struct poly1305_desc_ctx base;
-	/* derived key u set? */
-	bool uset;
-#ifdef CONFIG_AS_AVX2
-	/* derived keys r^3, r^4 set? */
-	bool wset;
-#endif
-	/* derived Poly1305 key r^2 */
-	u32 u[5];
-	/* ... silently appended r^3 and r^4 when using AVX2 */
+	struct poly1305_simd_xtra x;
 };
 
 asmlinkage void poly1305_block_sse2(u32 *h, const u8 *src,
@@ -41,14 +33,11 @@ asmlinkage void poly1305_4block_avx2(u32 *h, const u8 *src, const u32 *r,
 static bool poly1305_use_avx2;
 #endif
 
-static int poly1305_simd_init(struct shash_desc *desc)
+static int poly1305_simd_init2(struct shash_desc *desc)
 {
 	struct poly1305_simd_desc_ctx *sctx = shash_desc_ctx(desc);
 
-	sctx->uset = false;
-#ifdef CONFIG_AS_AVX2
-	sctx->wset = false;
-#endif
+	poly1305_simd_init(&sctx->x);
 
 	return crypto_poly1305_init(desc);
 }
@@ -64,60 +53,70 @@ static void poly1305_simd_mult(u32 *a, const u32 *b)
 	poly1305_block_sse2(a, m, b, 1);
 }
 
-static unsigned int poly1305_simd_blocks(struct poly1305_desc_ctx *dctx,
-					 const u8 *src, unsigned int srclen)
+unsigned int poly1305_simd_blocks(struct poly1305_state *state,
+				  const struct poly1305_key *key,
+				  struct poly1305_simd_xtra *sctx,
+				  const void *src, unsigned int srclen)
 {
-	struct poly1305_simd_desc_ctx *sctx;
-	unsigned int blocks, datalen;
-
-	BUILD_BUG_ON(offsetof(struct poly1305_simd_desc_ctx, base));
-	sctx = container_of(dctx, struct poly1305_simd_desc_ctx, base);
-
-	if (unlikely(!dctx->sset)) {
-		datalen = crypto_poly1305_setdesckey(dctx, src, srclen);
-		src += srclen - datalen;
-		srclen = datalen;
-	}
+	unsigned int blocks;
 
 #ifdef CONFIG_AS_AVX2
 	if (poly1305_use_avx2 && srclen >= POLY1305_BLOCK_SIZE * 4) {
 		if (unlikely(!sctx->wset)) {
 			if (!sctx->uset) {
-				memcpy(sctx->u, dctx->r.r, sizeof(sctx->u));
-				poly1305_simd_mult(sctx->u, dctx->r.r);
+				memcpy(sctx->u, key->r, sizeof(sctx->u));
+				poly1305_simd_mult(sctx->u, key->r);
 				sctx->uset = true;
 			}
 			memcpy(sctx->u + 5, sctx->u, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u + 5, dctx->r.r);
+			poly1305_simd_mult(sctx->u + 5, key->r);
 			memcpy(sctx->u + 10, sctx->u + 5, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u + 10, dctx->r.r);
+			poly1305_simd_mult(sctx->u + 10, key->r);
 			sctx->wset = true;
 		}
 		blocks = srclen / (POLY1305_BLOCK_SIZE * 4);
-		poly1305_4block_avx2(dctx->h.h, src, dctx->r.r, blocks,
-				     sctx->u);
+		poly1305_4block_avx2(state->h, src, key->r, blocks, sctx->u);
 		src += POLY1305_BLOCK_SIZE * 4 * blocks;
 		srclen -= POLY1305_BLOCK_SIZE * 4 * blocks;
 	}
 #endif
 	if (likely(srclen >= POLY1305_BLOCK_SIZE * 2)) {
 		if (unlikely(!sctx->uset)) {
-			memcpy(sctx->u, dctx->r.r, sizeof(sctx->u));
-			poly1305_simd_mult(sctx->u, dctx->r.r);
+			memcpy(sctx->u, key->r, sizeof(sctx->u));
+			poly1305_simd_mult(sctx->u, key->r);
 			sctx->uset = true;
 		}
 		blocks = srclen / (POLY1305_BLOCK_SIZE * 2);
-		poly1305_2block_sse2(dctx->h.h, src, dctx->r.r, blocks,
+		poly1305_2block_sse2(state->h, src, key->r, blocks,
 				     sctx->u);
 		src += POLY1305_BLOCK_SIZE * 2 * blocks;
 		srclen -= POLY1305_BLOCK_SIZE * 2 * blocks;
 	}
 	if (srclen >= POLY1305_BLOCK_SIZE) {
-		poly1305_block_sse2(dctx->h.h, src, dctx->r.r, 1);
+		poly1305_block_sse2(state->h, src, key->r, 1);
 		srclen -= POLY1305_BLOCK_SIZE;
 	}
 	return srclen;
 }
+EXPORT_SYMBOL_GPL(poly1305_simd_blocks);
+
+static unsigned int poly1305_simd_blocks2(struct poly1305_desc_ctx *dctx,
+					  const u8 *src, unsigned int srclen)
+{
+	struct poly1305_simd_desc_ctx *sctx;
+	unsigned int datalen;
+
+	BUILD_BUG_ON(offsetof(struct poly1305_simd_desc_ctx, base));
+	sctx = container_of(dctx, struct poly1305_simd_desc_ctx, base);
+
+	if (unlikely(!dctx->sset)) {
+		datalen = crypto_poly1305_setdesckey(dctx, src, srclen);
+		src += srclen - datalen;
+		srclen = datalen;
+	}
+
+	return poly1305_simd_blocks(&dctx->h, &dctx->r, &sctx->x, src, srclen);
+}
 
 static int poly1305_simd_update(struct shash_desc *desc,
 				const u8 *src, unsigned int srclen)
@@ -139,14 +138,14 @@ static int poly1305_simd_update(struct shash_desc *desc,
 		dctx->buflen += bytes;
 
 		if (dctx->buflen == POLY1305_BLOCK_SIZE) {
-			poly1305_simd_blocks(dctx, dctx->buf,
-					     POLY1305_BLOCK_SIZE);
+			poly1305_simd_blocks2(dctx, dctx->buf,
+					      POLY1305_BLOCK_SIZE);
 			dctx->buflen = 0;
 		}
 	}
 
 	if (likely(srclen >= POLY1305_BLOCK_SIZE)) {
-		bytes = poly1305_simd_blocks(dctx, src, srclen);
+		bytes = poly1305_simd_blocks2(dctx, src, srclen);
 		src += srclen - bytes;
 		srclen = bytes;
 	}
@@ -163,7 +162,7 @@ static int poly1305_simd_update(struct shash_desc *desc,
 
 static struct shash_alg alg = {
 	.digestsize	= POLY1305_DIGEST_SIZE,
-	.init		= poly1305_simd_init,
+	.init		= poly1305_simd_init2,
 	.update		= poly1305_simd_update,
 	.final		= crypto_poly1305_final,
 	.descsize	= sizeof(struct poly1305_simd_desc_ctx),
@@ -179,7 +178,7 @@ static struct shash_alg alg = {
 static int __init poly1305_simd_mod_init(void)
 {
 	if (!boot_cpu_has(X86_FEATURE_XMM2))
-		return -ENODEV;
+		return 0;
 
 #ifdef CONFIG_AS_AVX2
 	poly1305_use_avx2 = boot_cpu_has(X86_FEATURE_AVX) &&
@@ -194,6 +193,9 @@ static int __init poly1305_simd_mod_init(void)
 
 static void __exit poly1305_simd_mod_exit(void)
 {
+	if (!boot_cpu_has(X86_FEATURE_XMM2))
+		return;
+
 	crypto_unregister_shash(&alg);
 }
 
diff --git a/crypto/poly1305_generic.c b/crypto/poly1305_generic.c
index 2a06874204e8..2fc44fce66ca 100644
--- a/crypto/poly1305_generic.c
+++ b/crypto/poly1305_generic.c
@@ -87,10 +87,9 @@ unsigned int crypto_poly1305_setdesckey(struct poly1305_desc_ctx *dctx,
 }
 EXPORT_SYMBOL_GPL(crypto_poly1305_setdesckey);
 
-static void poly1305_blocks_internal(struct poly1305_state *state,
-				     const struct poly1305_key *key,
-				     const void *src, unsigned int nblocks,
-				     u32 hibit)
+void poly1305_blocks_internal(struct poly1305_state *state,
+			      const struct poly1305_key *key, const void *src,
+			      unsigned int nblocks, u32 hibit)
 {
 	u32 r0, r1, r2, r3, r4;
 	u32 s1, s2, s3, s4;
@@ -154,14 +153,7 @@ static void poly1305_blocks_internal(struct poly1305_state *state,
 	state->h[3] = h3;
 	state->h[4] = h4;
 }
-
-void poly1305_core_blocks(struct poly1305_state *state,
-			  const struct poly1305_key *key,
-			  const void *src, unsigned int nblocks)
-{
-	poly1305_blocks_internal(state, key, src, nblocks, 1 << 24);
-}
-EXPORT_SYMBOL_GPL(poly1305_core_blocks);
+EXPORT_SYMBOL_GPL(poly1305_blocks_internal);
 
 static void poly1305_blocks(struct poly1305_desc_ctx *dctx,
 			    const u8 *src, unsigned int srclen, u32 hibit)
diff --git a/include/crypto/poly1305.h b/include/crypto/poly1305.h
index 34317ed2071e..4cfb8a46785b 100644
--- a/include/crypto/poly1305.h
+++ b/include/crypto/poly1305.h
@@ -38,6 +38,20 @@ struct poly1305_desc_ctx {
 	bool sset;
 };
 
+struct poly1305_simd_xtra {
+	/* derived key u set? */
+	bool uset;
+#ifdef CONFIG_AS_AVX2
+	/* derived keys r^3, r^4 set? */
+	bool wset;
+#endif
+	/* derived Poly1305 key r^2 */
+	u32 u[5];
+	/* ... silently appended r^3 and r^4 when using AVX2 */
+};
+
+struct shash_desc;
+
 /*
  * Poly1305 core functions.  These implement the ε-almost-∆-universal hash
  * function underlying the Poly1305 MAC, i.e. they don't add an encrypted nonce
@@ -48,9 +62,18 @@ static inline void poly1305_core_init(struct poly1305_state *state)
 {
 	memset(state->h, 0, sizeof(state->h));
 }
-void poly1305_core_blocks(struct poly1305_state *state,
-			  const struct poly1305_key *key,
-			  const void *src, unsigned int nblocks);
+
+void poly1305_blocks_internal(struct poly1305_state *state,
+			      const struct poly1305_key *key, const void *src,
+			      unsigned int nblocks, u32 hibit);
+
+static inline void poly1305_core_blocks(struct poly1305_state *state,
+					const struct poly1305_key *key,
+					const void *src, unsigned int nblocks)
+{
+	poly1305_blocks_internal(state, key, src, nblocks, 1 << 24);
+}
+
 void poly1305_core_emit(const struct poly1305_state *state, void *dst);
 
 /* Crypto API helper functions for the Poly1305 MAC */
@@ -61,4 +84,17 @@ int crypto_poly1305_update(struct shash_desc *desc,
 			   const u8 *src, unsigned int srclen);
 int crypto_poly1305_final(struct shash_desc *desc, u8 *dst);
 
+static inline void poly1305_simd_init(struct poly1305_simd_xtra *x)
+{
+	x->uset = false;
+#ifdef CONFIG_AS_AVX2
+	x->wset = false;
+#endif
+}
+
+unsigned int poly1305_simd_blocks(struct poly1305_state *state,
+				  const struct poly1305_key *key,
+				  struct poly1305_simd_xtra *sctx,
+				  const void *src, unsigned int srclen);
+
 #endif
