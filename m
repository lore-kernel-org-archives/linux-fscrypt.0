Return-Path: <SRS0=+oNo=N7=gondor.apana.org.au=herbert@kernel.org>
Subject: [v2 PATCH 1/4] crypto: chacha20 - Export chacha20 functions without crypto API
References: <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
Message-Id: <E1gOz9R-00066e-5S@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Nov 2018 14:04:45 +0800
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
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

 arch/arm/crypto/chacha20-neon-glue.c |   16 ++++++++++------
 arch/x86/crypto/chacha20_glue.c      |   16 ++++++++++------
 crypto/chacha20_generic.c            |   15 ++++++++-------
 include/crypto/chacha20.h            |   10 ++++++++--
 4 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/arch/arm/crypto/chacha20-neon-glue.c b/arch/arm/crypto/chacha20-neon-glue.c
index 59a7be08e80c..fb198e11af08 100644
--- a/arch/arm/crypto/chacha20-neon-glue.c
+++ b/arch/arm/crypto/chacha20-neon-glue.c
@@ -31,7 +31,7 @@
 asmlinkage void chacha20_block_xor_neon(u32 *state, u8 *dst, const u8 *src);
 asmlinkage void chacha20_4block_xor_neon(u32 *state, u8 *dst, const u8 *src);
 
-static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
 	u8 buf[CHACHA20_BLOCK_SIZE];
@@ -56,11 +56,12 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 		memcpy(dst, buf, bytes);
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha20_doneon);
 
 static int chacha20_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	u32 state[16];
 	int err;
@@ -79,8 +80,8 @@ static int chacha20_neon(struct skcipher_request *req)
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha20_doneon(state, walk.dst.virt.addr, walk.src.virt.addr,
-				nbytes);
+		crypto_chacha20_doneon(state, walk.dst.virt.addr,
+				       walk.src.virt.addr, nbytes);
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
 	kernel_neon_end();
@@ -93,7 +94,7 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-neon",
 	.base.cra_priority	= 300,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct crypto_chacha20_ctx),
 	.base.cra_module	= THIS_MODULE,
 
 	.min_keysize		= CHACHA20_KEY_SIZE,
@@ -109,13 +110,16 @@ static struct skcipher_alg alg = {
 static int __init chacha20_simd_mod_init(void)
 {
 	if (!(elf_hwcap & HWCAP_NEON))
-		return -ENODEV;
+		return 0;
 
 	return crypto_register_skcipher(&alg);
 }
 
 static void __exit chacha20_simd_mod_fini(void)
 {
+	if (!(elf_hwcap & HWCAP_NEON))
+		return;
+
 	crypto_unregister_skcipher(&alg);
 }
 
diff --git a/arch/x86/crypto/chacha20_glue.c b/arch/x86/crypto/chacha20_glue.c
index 9fd84fe6ec09..ba66e23cd752 100644
--- a/arch/x86/crypto/chacha20_glue.c
+++ b/arch/x86/crypto/chacha20_glue.c
@@ -39,7 +39,7 @@ static unsigned int chacha20_advance(unsigned int len, unsigned int maxblocks)
 	return round_up(len, CHACHA20_BLOCK_SIZE) / CHACHA20_BLOCK_SIZE;
 }
 
-static void chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
 #ifdef CONFIG_AS_AVX2
@@ -85,11 +85,12 @@ static void chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
 		state[12]++;
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha20_dosimd);
 
 static int chacha20_simd(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
 	u32 *state, state_buf[16 + 2] __aligned(8);
 	struct skcipher_walk walk;
 	int err;
@@ -112,8 +113,8 @@ static int chacha20_simd(struct skcipher_request *req)
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha20_dosimd(state, walk.dst.virt.addr, walk.src.virt.addr,
-				nbytes);
+		crypto_chacha20_dosimd(state, walk.dst.virt.addr,
+				       walk.src.virt.addr, nbytes);
 
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
@@ -128,7 +129,7 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-simd",
 	.base.cra_priority	= 300,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct crypto_chacha20_ctx),
 	.base.cra_module	= THIS_MODULE,
 
 	.min_keysize		= CHACHA20_KEY_SIZE,
@@ -143,7 +144,7 @@ static struct skcipher_alg alg = {
 static int __init chacha20_simd_mod_init(void)
 {
 	if (!boot_cpu_has(X86_FEATURE_SSSE3))
-		return -ENODEV;
+		return 0;
 
 #ifdef CONFIG_AS_AVX2
 	chacha20_use_avx2 = boot_cpu_has(X86_FEATURE_AVX) &&
@@ -155,6 +156,9 @@ static int __init chacha20_simd_mod_init(void)
 
 static void __exit chacha20_simd_mod_fini(void)
 {
+	if (!boot_cpu_has(X86_FEATURE_SSSE3))
+		return;
+
 	crypto_unregister_skcipher(&alg);
 }
 
diff --git a/crypto/chacha20_generic.c b/crypto/chacha20_generic.c
index 3ae96587caf9..405179c310b9 100644
--- a/crypto/chacha20_generic.c
+++ b/crypto/chacha20_generic.c
@@ -15,7 +15,7 @@
 #include <crypto/internal/skcipher.h>
 #include <linux/module.h>
 
-static void chacha20_docrypt(u32 *state, u8 *dst, const u8 *src,
+void crypto_chacha20_generic(u32 *state, u8 *dst, const u8 *src,
 			     unsigned int bytes)
 {
 	/* aligned to potentially speed up crypto_xor() */
@@ -35,8 +35,9 @@ static void chacha20_docrypt(u32 *state, u8 *dst, const u8 *src,
 		crypto_xor(dst, stream, bytes);
 	}
 }
+EXPORT_SYMBOL_GPL(crypto_chacha20_generic);
 
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv)
+void crypto_chacha20_init(u32 *state, struct crypto_chacha20_ctx *ctx, u8 *iv)
 {
 	state[0]  = 0x61707865; /* "expa" */
 	state[1]  = 0x3320646e; /* "nd 3" */
@@ -60,7 +61,7 @@ EXPORT_SYMBOL_GPL(crypto_chacha20_init);
 int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			   unsigned int keysize)
 {
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
 	int i;
 
 	if (keysize != CHACHA20_KEY_SIZE)
@@ -76,7 +77,7 @@ EXPORT_SYMBOL_GPL(crypto_chacha20_setkey);
 int crypto_chacha20_crypt(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct crypto_chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	u32 state[16];
 	int err;
@@ -91,8 +92,8 @@ int crypto_chacha20_crypt(struct skcipher_request *req)
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha20_docrypt(state, walk.dst.virt.addr, walk.src.virt.addr,
-				 nbytes);
+		crypto_chacha20_generic(state, walk.dst.virt.addr,
+					walk.src.virt.addr, nbytes);
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
 
@@ -105,7 +106,7 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-generic",
 	.base.cra_priority	= 100,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct crypto_chacha20_ctx),
 	.base.cra_module	= THIS_MODULE,
 
 	.min_keysize		= CHACHA20_KEY_SIZE,
diff --git a/include/crypto/chacha20.h b/include/crypto/chacha20.h
index 2d3129442a52..0dd99c928123 100644
--- a/include/crypto/chacha20.h
+++ b/include/crypto/chacha20.h
@@ -15,14 +15,20 @@
 #define CHACHA20_BLOCK_SIZE	64
 #define CHACHAPOLY_IV_SIZE	12
 
-struct chacha20_ctx {
+struct crypto_chacha20_ctx {
 	u32 key[8];
 };
 
 void chacha20_block(u32 *state, u8 *stream);
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv);
+void crypto_chacha20_generic(u32 *state, u8 *dst, const u8 *src,
+			     unsigned int bytes);
+void crypto_chacha20_init(u32 *state, struct crypto_chacha20_ctx *ctx, u8 *iv);
 int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			   unsigned int keysize);
 int crypto_chacha20_crypt(struct skcipher_request *req);
+void crypto_chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
+			    unsigned int bytes);
+void crypto_chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
+			    unsigned int bytes);
 
 #endif
