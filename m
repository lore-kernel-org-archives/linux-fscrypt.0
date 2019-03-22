Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 2/17] crypto: chacha20 - Export chacha20 functions without crypto API
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgQ-0001Gz-Qv@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:38 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch exports the raw chacha20 functions, including the generic
as well as x86/arm accelerated versions.  This allows them to be
used without going through the crypto API.

This patch also renames struct chacha20_ctx to crypto_chacha20_ctx
to avoid naming conflicts with zinc.

In order to ensure that zinc can link to the requisite functions,
this function removes the failure mode from the x86/arm accelerated
glue code so that the modules will always load, even if the hardware
is not available.  In that case, the crypto API functions would not
be registered.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/arm/crypto/chacha-neon-glue.c   |   28 ++++++++++++++++------------
 arch/arm64/crypto/chacha-neon-glue.c |   21 +++++++++++----------
 arch/x86/crypto/chacha_glue.c        |   27 ++++++++++++++++-----------
 crypto/chacha_generic.c              |   26 ++++++++++++++------------
 include/crypto/chacha.h              |   10 ++++++++--
 5 files changed, 65 insertions(+), 47 deletions(-)

diff --git a/arch/arm/crypto/chacha-neon-glue.c b/arch/arm/crypto/chacha-neon-glue.c
index 9d6fda81986d..6d0e880dd471 100644
--- a/arch/arm/crypto/chacha-neon-glue.c
+++ b/arch/arm/crypto/chacha-neon-glue.c
@@ -35,8 +35,8 @@ asmlinkage void chacha_4block_xor_neon(const u32 *state, u8 *dst, const u8 *src,
 				       int nrounds);
 asmlinkage void hchacha_block_neon(const u32 *state, u32 *out, int nrounds);
 
-static void chacha_doneon(u32 *state, u8 *dst, const u8 *src,
-			  unsigned int bytes, int nrounds)
+static void crypto_chacha_doneon(u32 *state, u8 *dst, const u8 *src,
+				 unsigned int bytes, int nrounds)
 {
 	u8 buf[CHACHA_BLOCK_SIZE];
 
@@ -60,9 +60,10 @@ static void chacha_doneon(u32 *state, u8 *dst, const u8 *src,
 		memcpy(dst, buf, bytes);
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha_doneon);
 
 static int chacha_neon_stream_xor(struct skcipher_request *req,
-				  struct chacha_ctx *ctx, u8 *iv)
+				  struct crypto_chacha_ctx *ctx, u8 *iv)
 {
 	struct skcipher_walk walk;
 	u32 state[16];
@@ -79,8 +80,8 @@ static int chacha_neon_stream_xor(struct skcipher_request *req,
 			nbytes = round_down(nbytes, walk.stride);
 
 		kernel_neon_begin();
-		chacha_doneon(state, walk.dst.virt.addr, walk.src.virt.addr,
-			      nbytes, ctx->nrounds);
+		crypto_chacha_doneon(state, walk.dst.virt.addr,
+				     walk.src.virt.addr, nbytes, ctx->nrounds);
 		kernel_neon_end();
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
@@ -91,7 +92,7 @@ static int chacha_neon_stream_xor(struct skcipher_request *req,
 static int chacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 
 	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
 		return crypto_chacha_crypt(req);
@@ -102,8 +103,8 @@ static int chacha_neon(struct skcipher_request *req)
 static int xchacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
-	struct chacha_ctx subctx;
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx subctx;
 	u32 state[16];
 	u8 real_iv[16];
 
@@ -128,7 +129,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "chacha20-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -144,7 +145,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha20-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -160,7 +161,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha12-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -177,13 +178,16 @@ static struct skcipher_alg algs[] = {
 static int __init chacha_simd_mod_init(void)
 {
 	if (!(elf_hwcap & HWCAP_NEON))
-		return -ENODEV;
+		return 0;
 
 	return crypto_register_skciphers(algs, ARRAY_SIZE(algs));
 }
 
 static void __exit chacha_simd_mod_fini(void)
 {
+	if (!(elf_hwcap & HWCAP_NEON))
+		return;
+
 	crypto_unregister_skciphers(algs, ARRAY_SIZE(algs));
 }
 
diff --git a/arch/arm64/crypto/chacha-neon-glue.c b/arch/arm64/crypto/chacha-neon-glue.c
index bece1d85bd81..405e44c02e57 100644
--- a/arch/arm64/crypto/chacha-neon-glue.c
+++ b/arch/arm64/crypto/chacha-neon-glue.c
@@ -35,7 +35,7 @@ asmlinkage void chacha_4block_xor_neon(u32 *state, u8 *dst, const u8 *src,
 				       int nrounds, int bytes);
 asmlinkage void hchacha_block_neon(const u32 *state, u32 *out, int nrounds);
 
-static void chacha_doneon(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha_doneon(u32 *state, u8 *dst, const u8 *src,
 			  int bytes, int nrounds)
 {
 	while (bytes > 0) {
@@ -57,9 +57,10 @@ static void chacha_doneon(u32 *state, u8 *dst, const u8 *src,
 		state[12] += 5;
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha_doneon);
 
 static int chacha_neon_stream_xor(struct skcipher_request *req,
-				  struct chacha_ctx *ctx, u8 *iv)
+				  struct crypto_chacha_ctx *ctx, u8 *iv)
 {
 	struct skcipher_walk walk;
 	u32 state[16];
@@ -76,8 +77,8 @@ static int chacha_neon_stream_xor(struct skcipher_request *req,
 			nbytes = rounddown(nbytes, walk.stride);
 
 		kernel_neon_begin();
-		chacha_doneon(state, walk.dst.virt.addr, walk.src.virt.addr,
-			      nbytes, ctx->nrounds);
+		crypto_chacha_doneon(state, walk.dst.virt.addr,
+				     walk.src.virt.addr, nbytes, ctx->nrounds);
 		kernel_neon_end();
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
@@ -88,7 +89,7 @@ static int chacha_neon_stream_xor(struct skcipher_request *req,
 static int chacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 
 	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
 		return crypto_chacha_crypt(req);
@@ -99,8 +100,8 @@ static int chacha_neon(struct skcipher_request *req)
 static int xchacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
-	struct chacha_ctx subctx;
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx subctx;
 	u32 state[16];
 	u8 real_iv[16];
 
@@ -125,7 +126,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "chacha20-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -141,7 +142,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha20-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -157,7 +158,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha12-neon",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
diff --git a/arch/x86/crypto/chacha_glue.c b/arch/x86/crypto/chacha_glue.c
index 45c1c4143176..97e278df2bc7 100644
--- a/arch/x86/crypto/chacha_glue.c
+++ b/arch/x86/crypto/chacha_glue.c
@@ -50,7 +50,7 @@ static unsigned int chacha_advance(unsigned int len, unsigned int maxblocks)
 	return round_up(len, CHACHA_BLOCK_SIZE) / CHACHA_BLOCK_SIZE;
 }
 
-static void chacha_dosimd(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha_dosimd(u32 *state, u8 *dst, const u8 *src,
 			  unsigned int bytes, int nrounds)
 {
 #ifdef CONFIG_AS_AVX2
@@ -126,9 +126,10 @@ static void chacha_dosimd(u32 *state, u8 *dst, const u8 *src,
 		state[12]++;
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha_dosimd);
 
 static int chacha_simd_stream_xor(struct skcipher_walk *walk,
-				  struct chacha_ctx *ctx, u8 *iv)
+				  struct crypto_chacha_ctx *ctx, u8 *iv)
 {
 	u32 *state, state_buf[16 + 2] __aligned(8);
 	int next_yield = 4096; /* bytes until next FPU yield */
@@ -147,8 +148,9 @@ static int chacha_simd_stream_xor(struct skcipher_walk *walk,
 			next_yield -= nbytes;
 		}
 
-		chacha_dosimd(state, walk->dst.virt.addr, walk->src.virt.addr,
-			      nbytes, ctx->nrounds);
+		crypto_chacha_dosimd(state, walk->dst.virt.addr,
+				     walk->src.virt.addr, nbytes,
+				     ctx->nrounds);
 
 		if (next_yield <= 0) {
 			/* temporarily allow preemption */
@@ -166,7 +168,7 @@ static int chacha_simd_stream_xor(struct skcipher_walk *walk,
 static int chacha_simd(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	int err;
 
@@ -186,9 +188,9 @@ static int chacha_simd(struct skcipher_request *req)
 static int xchacha_simd(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
-	struct chacha_ctx subctx;
+	struct crypto_chacha_ctx subctx;
 	u32 *state, state_buf[16 + 2] __aligned(8);
 	u8 real_iv[16];
 	int err;
@@ -224,7 +226,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "chacha20-simd",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -239,7 +241,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha20-simd",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -254,7 +256,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha12-simd",
 		.base.cra_priority	= 300,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -270,7 +272,7 @@ static struct skcipher_alg algs[] = {
 static int __init chacha_simd_mod_init(void)
 {
 	if (!boot_cpu_has(X86_FEATURE_SSSE3))
-		return -ENODEV;
+		return 0;
 
 #ifdef CONFIG_AS_AVX2
 	chacha_use_avx2 = boot_cpu_has(X86_FEATURE_AVX) &&
@@ -287,6 +289,9 @@ static int __init chacha_simd_mod_init(void)
 
 static void __exit chacha_simd_mod_fini(void)
 {
+	if (!boot_cpu_has(X86_FEATURE_SSSE3))
+		return;
+
 	crypto_unregister_skciphers(algs, ARRAY_SIZE(algs));
 }
 
diff --git a/crypto/chacha_generic.c b/crypto/chacha_generic.c
index 35b583101f4f..4a337de5c2a0 100644
--- a/crypto/chacha_generic.c
+++ b/crypto/chacha_generic.c
@@ -16,7 +16,7 @@
 #include <crypto/internal/skcipher.h>
 #include <linux/module.h>
 
-static void chacha_docrypt(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha_generic(u32 *state, u8 *dst, const u8 *src,
 			   unsigned int bytes, int nrounds)
 {
 	/* aligned to potentially speed up crypto_xor() */
@@ -36,9 +36,10 @@ static void chacha_docrypt(u32 *state, u8 *dst, const u8 *src,
 		crypto_xor(dst, stream, bytes);
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha_generic);
 
 static int chacha_stream_xor(struct skcipher_request *req,
-			     struct chacha_ctx *ctx, u8 *iv)
+			     struct crypto_chacha_ctx *ctx, u8 *iv)
 {
 	struct skcipher_walk walk;
 	u32 state[16];
@@ -54,15 +55,16 @@ static int chacha_stream_xor(struct skcipher_request *req,
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha_docrypt(state, walk.dst.virt.addr, walk.src.virt.addr,
-			       nbytes, ctx->nrounds);
+		crypto_chacha_generic(state, walk.dst.virt.addr,
+				      walk.src.virt.addr, nbytes,
+				      ctx->nrounds);
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
 
 	return err;
 }
 
-void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv)
+void crypto_chacha_init(u32 *state, struct crypto_chacha_ctx *ctx, u8 *iv)
 {
 	state[0]  = 0x61707865; /* "expa" */
 	state[1]  = 0x3320646e; /* "nd 3" */
@@ -86,7 +88,7 @@ EXPORT_SYMBOL_GPL(crypto_chacha_init);
 static int chacha_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			 unsigned int keysize, int nrounds)
 {
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	int i;
 
 	if (keysize != CHACHA_KEY_SIZE)
@@ -116,7 +118,7 @@ EXPORT_SYMBOL_GPL(crypto_chacha12_setkey);
 int crypto_chacha_crypt(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 
 	return chacha_stream_xor(req, ctx, req->iv);
 }
@@ -125,8 +127,8 @@ EXPORT_SYMBOL_GPL(crypto_chacha_crypt);
 int crypto_xchacha_crypt(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
-	struct chacha_ctx subctx;
+	struct crypto_chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha_ctx subctx;
 	u32 state[16];
 	u8 real_iv[16];
 
@@ -150,7 +152,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "chacha20-generic",
 		.base.cra_priority	= 100,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -165,7 +167,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha20-generic",
 		.base.cra_priority	= 100,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
@@ -180,7 +182,7 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "xchacha12-generic",
 		.base.cra_priority	= 100,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_ctxsize	= sizeof(struct crypto_chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
 		.min_keysize		= CHACHA_KEY_SIZE,
diff --git a/include/crypto/chacha.h b/include/crypto/chacha.h
index 1fc70a69d550..24db07508701 100644
--- a/include/crypto/chacha.h
+++ b/include/crypto/chacha.h
@@ -29,7 +29,7 @@
 /* 192-bit nonce, then 64-bit stream position */
 #define XCHACHA_IV_SIZE		32
 
-struct chacha_ctx {
+struct crypto_chacha_ctx {
 	u32 key[8];
 	int nrounds;
 };
@@ -41,7 +41,9 @@ static inline void chacha20_block(u32 *state, u8 *stream)
 }
 void hchacha_block(const u32 *in, u32 *out, int nrounds);
 
-void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv);
+void crypto_chacha_generic(u32 *state, u8 *dst, const u8 *src,
+			  unsigned int bytes, int nrounds);
+void crypto_chacha_init(u32 *state, struct crypto_chacha_ctx *ctx, u8 *iv);
 
 int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			   unsigned int keysize);
@@ -50,5 +52,9 @@ int crypto_chacha12_setkey(struct crypto_skcipher *tfm, const u8 *key,
 
 int crypto_chacha_crypt(struct skcipher_request *req);
 int crypto_xchacha_crypt(struct skcipher_request *req);
+void crypto_chacha_dosimd(u32 *state, u8 *dst, const u8 *src,
+			  unsigned int bytes, int nrounds);
+void crypto_chacha_doneon(u32 *state, u8 *dst, const u8 *src,
+			  unsigned int bytes, int nrounds);
 
 #endif /* _CRYPTO_CHACHA_H */
