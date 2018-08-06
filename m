Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45108 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731143AbeHGAqN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Aug 2018 20:46:13 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow varying number of rounds
Date: Mon,  6 Aug 2018 15:32:54 -0700
Message-Id: <20180806223300.113891-4-ebiggers@kernel.org>
In-Reply-To: <20180806223300.113891-1-ebiggers@kernel.org>
References: <20180806223300.113891-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In preparation for adding XChaCha12 support, rename/refactor
chacha20-generic to support different numbers of rounds.

The only difference between ChaCha{8,12,20} are the number of rounds
itself; all other parts of the algorithm are the same.  Therefore,
remove the "20" from all definitions, structures, functions, files, etc.
that will be shared by all ChaCha versions.

Also make ->setkey() store the round count in the chacha_ctx (previously
chacha20_ctx).  The generic code then passes the round count through to
chacha_block().  There will be a ->setkey() function for each explicitly
allowed round count; the encrypt/decrypt functions will be the same.  I
decided not to do it the opposite way (same ->setkey() function for all
round counts, with different encrypt/decrypt functions) because that
would have required more boilerplate code in architecture-specific
implementations of ChaCha and XChaCha.

To be as careful as possible, we whitelist the allowed round counts in
the low-level generic code.  Currently only 20 is allowed, i.e. no
actual use of reduced-round ChaCha is introduced by this patch.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/arm/crypto/chacha20-neon-glue.c          |  44 +++----
 arch/arm64/crypto/chacha20-neon-glue.c        |  40 +++----
 arch/x86/crypto/chacha20_glue.c               |  52 ++++-----
 crypto/Makefile                               |   2 +-
 crypto/chacha20poly1305.c                     |  10 +-
 .../{chacha20_generic.c => chacha_generic.c}  | 110 ++++++++++--------
 drivers/char/random.c                         |  50 ++++----
 include/crypto/chacha.h                       |  47 ++++++++
 include/crypto/chacha20.h                     |  42 -------
 lib/Makefile                                  |   2 +-
 lib/{chacha20.c => chacha.c}                  |  43 ++++---
 11 files changed, 230 insertions(+), 212 deletions(-)
 rename crypto/{chacha20_generic.c => chacha_generic.c} (56%)
 create mode 100644 include/crypto/chacha.h
 delete mode 100644 include/crypto/chacha20.h
 rename lib/{chacha20.c => chacha.c} (67%)

diff --git a/arch/arm/crypto/chacha20-neon-glue.c b/arch/arm/crypto/chacha20-neon-glue.c
index 59a7be08e80c..ed8dec0f1768 100644
--- a/arch/arm/crypto/chacha20-neon-glue.c
+++ b/arch/arm/crypto/chacha20-neon-glue.c
@@ -19,7 +19,7 @@
  */
 
 #include <crypto/algapi.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 #include <crypto/internal/skcipher.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -34,20 +34,20 @@ asmlinkage void chacha20_4block_xor_neon(u32 *state, u8 *dst, const u8 *src);
 static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
-	u8 buf[CHACHA20_BLOCK_SIZE];
+	u8 buf[CHACHA_BLOCK_SIZE];
 
-	while (bytes >= CHACHA20_BLOCK_SIZE * 4) {
+	while (bytes >= CHACHA_BLOCK_SIZE * 4) {
 		chacha20_4block_xor_neon(state, dst, src);
-		bytes -= CHACHA20_BLOCK_SIZE * 4;
-		src += CHACHA20_BLOCK_SIZE * 4;
-		dst += CHACHA20_BLOCK_SIZE * 4;
+		bytes -= CHACHA_BLOCK_SIZE * 4;
+		src += CHACHA_BLOCK_SIZE * 4;
+		dst += CHACHA_BLOCK_SIZE * 4;
 		state[12] += 4;
 	}
-	while (bytes >= CHACHA20_BLOCK_SIZE) {
+	while (bytes >= CHACHA_BLOCK_SIZE) {
 		chacha20_block_xor_neon(state, dst, src);
-		bytes -= CHACHA20_BLOCK_SIZE;
-		src += CHACHA20_BLOCK_SIZE;
-		dst += CHACHA20_BLOCK_SIZE;
+		bytes -= CHACHA_BLOCK_SIZE;
+		src += CHACHA_BLOCK_SIZE;
+		dst += CHACHA_BLOCK_SIZE;
 		state[12]++;
 	}
 	if (bytes) {
@@ -60,17 +60,17 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 static int chacha20_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	u32 state[16];
 	int err;
 
-	if (req->cryptlen <= CHACHA20_BLOCK_SIZE || !may_use_simd())
-		return crypto_chacha20_crypt(req);
+	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
+		return crypto_chacha_crypt(req);
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha_init(state, ctx, walk.iv);
 
 	kernel_neon_begin();
 	while (walk.nbytes > 0) {
@@ -93,17 +93,17 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-neon",
 	.base.cra_priority	= 300,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct chacha_ctx),
 	.base.cra_module	= THIS_MODULE,
 
-	.min_keysize		= CHACHA20_KEY_SIZE,
-	.max_keysize		= CHACHA20_KEY_SIZE,
-	.ivsize			= CHACHA20_IV_SIZE,
-	.chunksize		= CHACHA20_BLOCK_SIZE,
-	.walksize		= 4 * CHACHA20_BLOCK_SIZE,
+	.min_keysize		= CHACHA_KEY_SIZE,
+	.max_keysize		= CHACHA_KEY_SIZE,
+	.ivsize			= CHACHA_IV_SIZE,
+	.chunksize		= CHACHA_BLOCK_SIZE,
+	.walksize		= 4 * CHACHA_BLOCK_SIZE,
 	.setkey			= crypto_chacha20_setkey,
-	.encrypt		= chacha20_neon,
-	.decrypt		= chacha20_neon,
+	.encrypt		= chacha_neon,
+	.decrypt		= chacha_neon,
 };
 
 static int __init chacha20_simd_mod_init(void)
diff --git a/arch/arm64/crypto/chacha20-neon-glue.c b/arch/arm64/crypto/chacha20-neon-glue.c
index 727579c93ded..96e0cfb8c3f5 100644
--- a/arch/arm64/crypto/chacha20-neon-glue.c
+++ b/arch/arm64/crypto/chacha20-neon-glue.c
@@ -19,7 +19,7 @@
  */
 
 #include <crypto/algapi.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 #include <crypto/internal/skcipher.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -34,15 +34,15 @@ asmlinkage void chacha20_4block_xor_neon(u32 *state, u8 *dst, const u8 *src);
 static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
-	u8 buf[CHACHA20_BLOCK_SIZE];
+	u8 buf[CHACHA_BLOCK_SIZE];
 
-	while (bytes >= CHACHA20_BLOCK_SIZE * 4) {
+	while (bytes >= CHACHA_BLOCK_SIZE * 4) {
 		kernel_neon_begin();
 		chacha20_4block_xor_neon(state, dst, src);
 		kernel_neon_end();
-		bytes -= CHACHA20_BLOCK_SIZE * 4;
-		src += CHACHA20_BLOCK_SIZE * 4;
-		dst += CHACHA20_BLOCK_SIZE * 4;
+		bytes -= CHACHA_BLOCK_SIZE * 4;
+		src += CHACHA_BLOCK_SIZE * 4;
+		dst += CHACHA_BLOCK_SIZE * 4;
 		state[12] += 4;
 	}
 
@@ -50,11 +50,11 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 		return;
 
 	kernel_neon_begin();
-	while (bytes >= CHACHA20_BLOCK_SIZE) {
+	while (bytes >= CHACHA_BLOCK_SIZE) {
 		chacha20_block_xor_neon(state, dst, src);
-		bytes -= CHACHA20_BLOCK_SIZE;
-		src += CHACHA20_BLOCK_SIZE;
-		dst += CHACHA20_BLOCK_SIZE;
+		bytes -= CHACHA_BLOCK_SIZE;
+		src += CHACHA_BLOCK_SIZE;
+		dst += CHACHA_BLOCK_SIZE;
 		state[12]++;
 	}
 	if (bytes) {
@@ -68,17 +68,17 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 static int chacha20_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	u32 state[16];
 	int err;
 
-	if (!may_use_simd() || req->cryptlen <= CHACHA20_BLOCK_SIZE)
-		return crypto_chacha20_crypt(req);
+	if (!may_use_simd() || req->cryptlen <= CHACHA_BLOCK_SIZE)
+		return crypto_chacha_crypt(req);
 
 	err = skcipher_walk_virt(&walk, req, false);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha_init(state, ctx, walk.iv);
 
 	while (walk.nbytes > 0) {
 		unsigned int nbytes = walk.nbytes;
@@ -99,14 +99,14 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-neon",
 	.base.cra_priority	= 300,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct chacha_ctx),
 	.base.cra_module	= THIS_MODULE,
 
-	.min_keysize		= CHACHA20_KEY_SIZE,
-	.max_keysize		= CHACHA20_KEY_SIZE,
-	.ivsize			= CHACHA20_IV_SIZE,
-	.chunksize		= CHACHA20_BLOCK_SIZE,
-	.walksize		= 4 * CHACHA20_BLOCK_SIZE,
+	.min_keysize		= CHACHA_KEY_SIZE,
+	.max_keysize		= CHACHA_KEY_SIZE,
+	.ivsize			= CHACHA_IV_SIZE,
+	.chunksize		= CHACHA_BLOCK_SIZE,
+	.walksize		= 4 * CHACHA_BLOCK_SIZE,
 	.setkey			= crypto_chacha20_setkey,
 	.encrypt		= chacha20_neon,
 	.decrypt		= chacha20_neon,
diff --git a/arch/x86/crypto/chacha20_glue.c b/arch/x86/crypto/chacha20_glue.c
index dce7c5d39c2f..bd249f0b29dc 100644
--- a/arch/x86/crypto/chacha20_glue.c
+++ b/arch/x86/crypto/chacha20_glue.c
@@ -10,7 +10,7 @@
  */
 
 #include <crypto/algapi.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 #include <crypto/internal/skcipher.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -29,31 +29,31 @@ static bool chacha20_use_avx2;
 static void chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
-	u8 buf[CHACHA20_BLOCK_SIZE];
+	u8 buf[CHACHA_BLOCK_SIZE];
 
 #ifdef CONFIG_AS_AVX2
 	if (chacha20_use_avx2) {
-		while (bytes >= CHACHA20_BLOCK_SIZE * 8) {
+		while (bytes >= CHACHA_BLOCK_SIZE * 8) {
 			chacha20_8block_xor_avx2(state, dst, src);
-			bytes -= CHACHA20_BLOCK_SIZE * 8;
-			src += CHACHA20_BLOCK_SIZE * 8;
-			dst += CHACHA20_BLOCK_SIZE * 8;
+			bytes -= CHACHA_BLOCK_SIZE * 8;
+			src += CHACHA_BLOCK_SIZE * 8;
+			dst += CHACHA_BLOCK_SIZE * 8;
 			state[12] += 8;
 		}
 	}
 #endif
-	while (bytes >= CHACHA20_BLOCK_SIZE * 4) {
+	while (bytes >= CHACHA_BLOCK_SIZE * 4) {
 		chacha20_4block_xor_ssse3(state, dst, src);
-		bytes -= CHACHA20_BLOCK_SIZE * 4;
-		src += CHACHA20_BLOCK_SIZE * 4;
-		dst += CHACHA20_BLOCK_SIZE * 4;
+		bytes -= CHACHA_BLOCK_SIZE * 4;
+		src += CHACHA_BLOCK_SIZE * 4;
+		dst += CHACHA_BLOCK_SIZE * 4;
 		state[12] += 4;
 	}
-	while (bytes >= CHACHA20_BLOCK_SIZE) {
+	while (bytes >= CHACHA_BLOCK_SIZE) {
 		chacha20_block_xor_ssse3(state, dst, src);
-		bytes -= CHACHA20_BLOCK_SIZE;
-		src += CHACHA20_BLOCK_SIZE;
-		dst += CHACHA20_BLOCK_SIZE;
+		bytes -= CHACHA_BLOCK_SIZE;
+		src += CHACHA_BLOCK_SIZE;
+		dst += CHACHA_BLOCK_SIZE;
 		state[12]++;
 	}
 	if (bytes) {
@@ -66,7 +66,7 @@ static void chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
 static int chacha20_simd(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	u32 *state, state_buf[16 + 2] __aligned(8);
 	struct skcipher_walk walk;
 	int err;
@@ -74,20 +74,20 @@ static int chacha20_simd(struct skcipher_request *req)
 	BUILD_BUG_ON(CHACHA20_STATE_ALIGN != 16);
 	state = PTR_ALIGN(state_buf + 0, CHACHA20_STATE_ALIGN);
 
-	if (req->cryptlen <= CHACHA20_BLOCK_SIZE || !may_use_simd())
-		return crypto_chacha20_crypt(req);
+	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
+		return crypto_chacha_crypt(req);
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha_init(state, ctx, walk.iv);
 
 	kernel_fpu_begin();
 
-	while (walk.nbytes >= CHACHA20_BLOCK_SIZE) {
+	while (walk.nbytes >= CHACHA_BLOCK_SIZE) {
 		chacha20_dosimd(state, walk.dst.virt.addr, walk.src.virt.addr,
-				rounddown(walk.nbytes, CHACHA20_BLOCK_SIZE));
+				rounddown(walk.nbytes, CHACHA_BLOCK_SIZE));
 		err = skcipher_walk_done(&walk,
-					 walk.nbytes % CHACHA20_BLOCK_SIZE);
+					 walk.nbytes % CHACHA_BLOCK_SIZE);
 	}
 
 	if (walk.nbytes) {
@@ -106,13 +106,13 @@ static struct skcipher_alg alg = {
 	.base.cra_driver_name	= "chacha20-simd",
 	.base.cra_priority	= 300,
 	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_ctxsize	= sizeof(struct chacha_ctx),
 	.base.cra_module	= THIS_MODULE,
 
-	.min_keysize		= CHACHA20_KEY_SIZE,
-	.max_keysize		= CHACHA20_KEY_SIZE,
-	.ivsize			= CHACHA20_IV_SIZE,
-	.chunksize		= CHACHA20_BLOCK_SIZE,
+	.min_keysize		= CHACHA_KEY_SIZE,
+	.max_keysize		= CHACHA_KEY_SIZE,
+	.ivsize			= CHACHA_IV_SIZE,
+	.chunksize		= CHACHA_BLOCK_SIZE,
 	.setkey			= crypto_chacha20_setkey,
 	.encrypt		= chacha20_simd,
 	.decrypt		= chacha20_simd,
diff --git a/crypto/Makefile b/crypto/Makefile
index 6d1d40eeb964..0701c4577dc6 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -117,7 +117,7 @@ obj-$(CONFIG_CRYPTO_ANUBIS) += anubis.o
 obj-$(CONFIG_CRYPTO_SEED) += seed.o
 obj-$(CONFIG_CRYPTO_SPECK) += speck.o
 obj-$(CONFIG_CRYPTO_SALSA20) += salsa20_generic.o
-obj-$(CONFIG_CRYPTO_CHACHA20) += chacha20_generic.o
+obj-$(CONFIG_CRYPTO_CHACHA20) += chacha_generic.o
 obj-$(CONFIG_CRYPTO_POLY1305) += poly1305_generic.o
 obj-$(CONFIG_CRYPTO_DEFLATE) += deflate.o
 obj-$(CONFIG_CRYPTO_MICHAEL_MIC) += michael_mic.o
diff --git a/crypto/chacha20poly1305.c b/crypto/chacha20poly1305.c
index 600afa99941f..573c07e6f189 100644
--- a/crypto/chacha20poly1305.c
+++ b/crypto/chacha20poly1305.c
@@ -13,7 +13,7 @@
 #include <crypto/internal/hash.h>
 #include <crypto/internal/skcipher.h>
 #include <crypto/scatterwalk.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 #include <crypto/poly1305.h>
 #include <linux/err.h>
 #include <linux/init.h>
@@ -51,7 +51,7 @@ struct poly_req {
 };
 
 struct chacha_req {
-	u8 iv[CHACHA20_IV_SIZE];
+	u8 iv[CHACHA_IV_SIZE];
 	struct scatterlist src[1];
 	struct skcipher_request req; /* must be last member */
 };
@@ -91,7 +91,7 @@ static void chacha_iv(u8 *iv, struct aead_request *req, u32 icb)
 	memcpy(iv, &leicb, sizeof(leicb));
 	memcpy(iv + sizeof(leicb), ctx->salt, ctx->saltlen);
 	memcpy(iv + sizeof(leicb) + ctx->saltlen, req->iv,
-	       CHACHA20_IV_SIZE - sizeof(leicb) - ctx->saltlen);
+	       CHACHA_IV_SIZE - sizeof(leicb) - ctx->saltlen);
 }
 
 static int poly_verify_tag(struct aead_request *req)
@@ -494,7 +494,7 @@ static int chachapoly_setkey(struct crypto_aead *aead, const u8 *key,
 	struct chachapoly_ctx *ctx = crypto_aead_ctx(aead);
 	int err;
 
-	if (keylen != ctx->saltlen + CHACHA20_KEY_SIZE)
+	if (keylen != ctx->saltlen + CHACHA_KEY_SIZE)
 		return -EINVAL;
 
 	keylen -= ctx->saltlen;
@@ -639,7 +639,7 @@ static int chachapoly_create(struct crypto_template *tmpl, struct rtattr **tb,
 
 	err = -EINVAL;
 	/* Need 16-byte IV size, including Initial Block Counter value */
-	if (crypto_skcipher_alg_ivsize(chacha) != CHACHA20_IV_SIZE)
+	if (crypto_skcipher_alg_ivsize(chacha) != CHACHA_IV_SIZE)
 		goto out_drop_chacha;
 	/* Not a stream cipher? */
 	if (chacha->base.cra_blocksize != 1)
diff --git a/crypto/chacha20_generic.c b/crypto/chacha_generic.c
similarity index 56%
rename from crypto/chacha20_generic.c
rename to crypto/chacha_generic.c
index ba97aac93912..46496997847a 100644
--- a/crypto/chacha20_generic.c
+++ b/crypto/chacha_generic.c
@@ -12,32 +12,32 @@
 
 #include <asm/unaligned.h>
 #include <crypto/algapi.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 #include <crypto/internal/skcipher.h>
 #include <linux/module.h>
 
-static void chacha20_docrypt(u32 *state, u8 *dst, const u8 *src,
-			     unsigned int bytes)
+static void chacha_docrypt(u32 *state, u8 *dst, const u8 *src,
+			   unsigned int bytes, int nrounds)
 {
-	u32 stream[CHACHA20_BLOCK_WORDS];
+	u32 stream[CHACHA_BLOCK_WORDS];
 
 	if (dst != src)
 		memcpy(dst, src, bytes);
 
-	while (bytes >= CHACHA20_BLOCK_SIZE) {
-		chacha20_block(state, stream);
-		crypto_xor(dst, (const u8 *)stream, CHACHA20_BLOCK_SIZE);
-		bytes -= CHACHA20_BLOCK_SIZE;
-		dst += CHACHA20_BLOCK_SIZE;
+	while (bytes >= CHACHA_BLOCK_SIZE) {
+		chacha_block(state, stream, nrounds);
+		crypto_xor(dst, (const u8 *)stream, CHACHA_BLOCK_SIZE);
+		bytes -= CHACHA_BLOCK_SIZE;
+		dst += CHACHA_BLOCK_SIZE;
 	}
 	if (bytes) {
-		chacha20_block(state, stream);
+		chacha_block(state, stream, nrounds);
 		crypto_xor(dst, (const u8 *)stream, bytes);
 	}
 }
 
-static int chacha20_stream_xor(struct skcipher_request *req,
-			       struct chacha20_ctx *ctx, u8 *iv)
+static int chacha_stream_xor(struct skcipher_request *req,
+			     struct chacha_ctx *ctx, u8 *iv)
 {
 	struct skcipher_walk walk;
 	u32 state[16];
@@ -45,7 +45,7 @@ static int chacha20_stream_xor(struct skcipher_request *req,
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, iv);
+	crypto_chacha_init(state, ctx, iv);
 
 	while (walk.nbytes > 0) {
 		unsigned int nbytes = walk.nbytes;
@@ -53,15 +53,15 @@ static int chacha20_stream_xor(struct skcipher_request *req,
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha20_docrypt(state, walk.dst.virt.addr, walk.src.virt.addr,
-				 nbytes);
+		chacha_docrypt(state, walk.dst.virt.addr, walk.src.virt.addr,
+			       nbytes, ctx->nrounds);
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
 
 	return err;
 }
 
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv)
+void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv)
 {
 	state[0]  = 0x61707865; /* "expa" */
 	state[1]  = 0x3320646e; /* "nd 3" */
@@ -80,53 +80,61 @@ void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv)
 	state[14] = get_unaligned_le32(iv +  8);
 	state[15] = get_unaligned_le32(iv + 12);
 }
-EXPORT_SYMBOL_GPL(crypto_chacha20_init);
+EXPORT_SYMBOL_GPL(crypto_chacha_init);
 
-int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
-			   unsigned int keysize)
+static int chacha_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			 unsigned int keysize, int nrounds)
 {
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	int i;
 
-	if (keysize != CHACHA20_KEY_SIZE)
+	if (keysize != CHACHA_KEY_SIZE)
 		return -EINVAL;
 
 	for (i = 0; i < ARRAY_SIZE(ctx->key); i++)
 		ctx->key[i] = get_unaligned_le32(key + i * sizeof(u32));
 
+	ctx->nrounds = nrounds;
 	return 0;
 }
+
+int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			   unsigned int keysize)
+{
+	return chacha_setkey(tfm, key, keysize, 20);
+}
 EXPORT_SYMBOL_GPL(crypto_chacha20_setkey);
 
-int crypto_chacha20_crypt(struct skcipher_request *req)
+int crypto_chacha_crypt(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 
-	return chacha20_stream_xor(req, ctx, req->iv);
+	return chacha_stream_xor(req, ctx, req->iv);
 }
-EXPORT_SYMBOL_GPL(crypto_chacha20_crypt);
+EXPORT_SYMBOL_GPL(crypto_chacha_crypt);
 
-int crypto_xchacha20_crypt(struct skcipher_request *req)
+int crypto_xchacha_crypt(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha20_ctx *ctx = crypto_skcipher_ctx(tfm);
-	struct chacha20_ctx subctx;
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx subctx;
 	u32 state[16];
 	u8 real_iv[16];
 
 	/* Compute the subkey given the original key and first 128 nonce bits */
-	crypto_chacha20_init(state, ctx, req->iv);
-	hchacha20_block(state, subctx.key);
+	crypto_chacha_init(state, ctx, req->iv);
+	hchacha_block(state, subctx.key, ctx->nrounds);
+	subctx.nrounds = ctx->nrounds;
 
 	/* Build the real IV */
 	memcpy(&real_iv[0], req->iv + 24, 8); /* stream position */
 	memcpy(&real_iv[8], req->iv + 16, 8); /* remaining 64 nonce bits */
 
 	/* Generate the stream and XOR it with the data */
-	return chacha20_stream_xor(req, &subctx, real_iv);
+	return chacha_stream_xor(req, &subctx, real_iv);
 }
-EXPORT_SYMBOL_GPL(crypto_xchacha20_crypt);
+EXPORT_SYMBOL_GPL(crypto_xchacha_crypt);
 
 static struct skcipher_alg algs[] = {
 	{
@@ -134,50 +142,50 @@ static struct skcipher_alg algs[] = {
 		.base.cra_driver_name	= "chacha20-generic",
 		.base.cra_priority	= 100,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
-		.min_keysize		= CHACHA20_KEY_SIZE,
-		.max_keysize		= CHACHA20_KEY_SIZE,
-		.ivsize			= CHACHA20_IV_SIZE,
-		.chunksize		= CHACHA20_BLOCK_SIZE,
+		.min_keysize		= CHACHA_KEY_SIZE,
+		.max_keysize		= CHACHA_KEY_SIZE,
+		.ivsize			= CHACHA_IV_SIZE,
+		.chunksize		= CHACHA_BLOCK_SIZE,
 		.setkey			= crypto_chacha20_setkey,
-		.encrypt		= crypto_chacha20_crypt,
-		.decrypt		= crypto_chacha20_crypt,
+		.encrypt		= crypto_chacha_crypt,
+		.decrypt		= crypto_chacha_crypt,
 	}, {
 		.base.cra_name		= "xchacha20",
 		.base.cra_driver_name	= "xchacha20-generic",
 		.base.cra_priority	= 100,
 		.base.cra_blocksize	= 1,
-		.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
 		.base.cra_module	= THIS_MODULE,
 
-		.min_keysize		= CHACHA20_KEY_SIZE,
-		.max_keysize		= CHACHA20_KEY_SIZE,
-		.ivsize			= XCHACHA20_IV_SIZE,
-		.chunksize		= CHACHA20_BLOCK_SIZE,
+		.min_keysize		= CHACHA_KEY_SIZE,
+		.max_keysize		= CHACHA_KEY_SIZE,
+		.ivsize			= XCHACHA_IV_SIZE,
+		.chunksize		= CHACHA_BLOCK_SIZE,
 		.setkey			= crypto_chacha20_setkey,
-		.encrypt		= crypto_xchacha20_crypt,
-		.decrypt		= crypto_xchacha20_crypt,
+		.encrypt		= crypto_xchacha_crypt,
+		.decrypt		= crypto_xchacha_crypt,
 	}
 };
 
-static int __init chacha20_generic_mod_init(void)
+static int __init chacha_generic_mod_init(void)
 {
 	return crypto_register_skciphers(algs, ARRAY_SIZE(algs));
 }
 
-static void __exit chacha20_generic_mod_fini(void)
+static void __exit chacha_generic_mod_fini(void)
 {
 	crypto_unregister_skciphers(algs, ARRAY_SIZE(algs));
 }
 
-module_init(chacha20_generic_mod_init);
-module_exit(chacha20_generic_mod_fini);
+module_init(chacha_generic_mod_init);
+module_exit(chacha_generic_mod_fini);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Martin Willi <martin@strongswan.org>");
-MODULE_DESCRIPTION("ChaCha20 and XChaCha20 stream ciphers (generic)");
+MODULE_DESCRIPTION("ChaCha and XChaCha stream ciphers (generic)");
 MODULE_ALIAS_CRYPTO("chacha20");
 MODULE_ALIAS_CRYPTO("chacha20-generic");
 MODULE_ALIAS_CRYPTO("xchacha20");
diff --git a/drivers/char/random.c b/drivers/char/random.c
index bd449ad52442..edf956084179 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -265,7 +265,7 @@
 #include <linux/syscalls.h>
 #include <linux/completion.h>
 #include <linux/uuid.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 
 #include <asm/processor.h>
 #include <linux/uaccess.h>
@@ -431,11 +431,11 @@ static int crng_init = 0;
 #define crng_ready() (likely(crng_init > 1))
 static int crng_init_cnt = 0;
 static unsigned long crng_global_init_time = 0;
-#define CRNG_INIT_CNT_THRESH (2*CHACHA20_KEY_SIZE)
+#define CRNG_INIT_CNT_THRESH (2*CHACHA_KEY_SIZE)
 static void _extract_crng(struct crng_state *crng,
-			  __u32 out[CHACHA20_BLOCK_WORDS]);
+			  __u32 out[CHACHA_BLOCK_WORDS]);
 static void _crng_backtrack_protect(struct crng_state *crng,
-				    __u32 tmp[CHACHA20_BLOCK_WORDS], int used);
+				    __u32 tmp[CHACHA_BLOCK_WORDS], int used);
 static void process_random_ready_list(void);
 static void _get_random_bytes(void *buf, int nbytes);
 
@@ -849,7 +849,7 @@ static int crng_fast_load(const char *cp, size_t len)
 	}
 	p = (unsigned char *) &primary_crng.state[4];
 	while (len > 0 && crng_init_cnt < CRNG_INIT_CNT_THRESH) {
-		p[crng_init_cnt % CHACHA20_KEY_SIZE] ^= *cp;
+		p[crng_init_cnt % CHACHA_KEY_SIZE] ^= *cp;
 		cp++; crng_init_cnt++; len--;
 	}
 	spin_unlock_irqrestore(&primary_crng.lock, flags);
@@ -881,7 +881,7 @@ static int crng_slow_load(const char *cp, size_t len)
 	unsigned long		flags;
 	static unsigned char	lfsr = 1;
 	unsigned char		tmp;
-	unsigned		i, max = CHACHA20_KEY_SIZE;
+	unsigned		i, max = CHACHA_KEY_SIZE;
 	const char *		src_buf = cp;
 	char *			dest_buf = (char *) &primary_crng.state[4];
 
@@ -899,8 +899,8 @@ static int crng_slow_load(const char *cp, size_t len)
 		lfsr >>= 1;
 		if (tmp & 1)
 			lfsr ^= 0xE1;
-		tmp = dest_buf[i % CHACHA20_KEY_SIZE];
-		dest_buf[i % CHACHA20_KEY_SIZE] ^= src_buf[i % len] ^ lfsr;
+		tmp = dest_buf[i % CHACHA_KEY_SIZE];
+		dest_buf[i % CHACHA_KEY_SIZE] ^= src_buf[i % len] ^ lfsr;
 		lfsr += (tmp << 3) | (tmp >> 5);
 	}
 	spin_unlock_irqrestore(&primary_crng.lock, flags);
@@ -912,7 +912,7 @@ static void crng_reseed(struct crng_state *crng, struct entropy_store *r)
 	unsigned long	flags;
 	int		i, num;
 	union {
-		__u32	block[CHACHA20_BLOCK_WORDS];
+		__u32	block[CHACHA_BLOCK_WORDS];
 		__u32	key[8];
 	} buf;
 
@@ -923,7 +923,7 @@ static void crng_reseed(struct crng_state *crng, struct entropy_store *r)
 	} else {
 		_extract_crng(&primary_crng, buf.block);
 		_crng_backtrack_protect(&primary_crng, buf.block,
-					CHACHA20_KEY_SIZE);
+					CHACHA_KEY_SIZE);
 	}
 	spin_lock_irqsave(&crng->lock, flags);
 	for (i = 0; i < 8; i++) {
@@ -959,7 +959,7 @@ static void crng_reseed(struct crng_state *crng, struct entropy_store *r)
 }
 
 static void _extract_crng(struct crng_state *crng,
-			  __u32 out[CHACHA20_BLOCK_WORDS])
+			  __u32 out[CHACHA_BLOCK_WORDS])
 {
 	unsigned long v, flags;
 
@@ -976,7 +976,7 @@ static void _extract_crng(struct crng_state *crng,
 	spin_unlock_irqrestore(&crng->lock, flags);
 }
 
-static void extract_crng(__u32 out[CHACHA20_BLOCK_WORDS])
+static void extract_crng(__u32 out[CHACHA_BLOCK_WORDS])
 {
 	struct crng_state *crng = NULL;
 
@@ -994,14 +994,14 @@ static void extract_crng(__u32 out[CHACHA20_BLOCK_WORDS])
  * enough) to mutate the CRNG key to provide backtracking protection.
  */
 static void _crng_backtrack_protect(struct crng_state *crng,
-				    __u32 tmp[CHACHA20_BLOCK_WORDS], int used)
+				    __u32 tmp[CHACHA_BLOCK_WORDS], int used)
 {
 	unsigned long	flags;
 	__u32		*s, *d;
 	int		i;
 
 	used = round_up(used, sizeof(__u32));
-	if (used + CHACHA20_KEY_SIZE > CHACHA20_BLOCK_SIZE) {
+	if (used + CHACHA_KEY_SIZE > CHACHA_BLOCK_SIZE) {
 		extract_crng(tmp);
 		used = 0;
 	}
@@ -1013,7 +1013,7 @@ static void _crng_backtrack_protect(struct crng_state *crng,
 	spin_unlock_irqrestore(&crng->lock, flags);
 }
 
-static void crng_backtrack_protect(__u32 tmp[CHACHA20_BLOCK_WORDS], int used)
+static void crng_backtrack_protect(__u32 tmp[CHACHA_BLOCK_WORDS], int used)
 {
 	struct crng_state *crng = NULL;
 
@@ -1028,8 +1028,8 @@ static void crng_backtrack_protect(__u32 tmp[CHACHA20_BLOCK_WORDS], int used)
 
 static ssize_t extract_crng_user(void __user *buf, size_t nbytes)
 {
-	ssize_t ret = 0, i = CHACHA20_BLOCK_SIZE;
-	__u32 tmp[CHACHA20_BLOCK_WORDS];
+	ssize_t ret = 0, i = CHACHA_BLOCK_SIZE;
+	__u32 tmp[CHACHA_BLOCK_WORDS];
 	int large_request = (nbytes > 256);
 
 	while (nbytes) {
@@ -1043,7 +1043,7 @@ static ssize_t extract_crng_user(void __user *buf, size_t nbytes)
 		}
 
 		extract_crng(tmp);
-		i = min_t(int, nbytes, CHACHA20_BLOCK_SIZE);
+		i = min_t(int, nbytes, CHACHA_BLOCK_SIZE);
 		if (copy_to_user(buf, tmp, i)) {
 			ret = -EFAULT;
 			break;
@@ -1612,14 +1612,14 @@ static void _warn_unseeded_randomness(const char *func_name, void *caller,
  */
 static void _get_random_bytes(void *buf, int nbytes)
 {
-	__u32 tmp[CHACHA20_BLOCK_WORDS];
+	__u32 tmp[CHACHA_BLOCK_WORDS];
 
 	trace_get_random_bytes(nbytes, _RET_IP_);
 
-	while (nbytes >= CHACHA20_BLOCK_SIZE) {
+	while (nbytes >= CHACHA_BLOCK_SIZE) {
 		extract_crng(buf);
-		buf += CHACHA20_BLOCK_SIZE;
-		nbytes -= CHACHA20_BLOCK_SIZE;
+		buf += CHACHA_BLOCK_SIZE;
+		nbytes -= CHACHA_BLOCK_SIZE;
 	}
 
 	if (nbytes > 0) {
@@ -1627,7 +1627,7 @@ static void _get_random_bytes(void *buf, int nbytes)
 		memcpy(buf, tmp, nbytes);
 		crng_backtrack_protect(tmp, nbytes);
 	} else
-		crng_backtrack_protect(tmp, CHACHA20_BLOCK_SIZE);
+		crng_backtrack_protect(tmp, CHACHA_BLOCK_SIZE);
 	memzero_explicit(tmp, sizeof(tmp));
 }
 
@@ -2182,8 +2182,8 @@ struct ctl_table random_table[] = {
 
 struct batched_entropy {
 	union {
-		u64 entropy_u64[CHACHA20_BLOCK_SIZE / sizeof(u64)];
-		u32 entropy_u32[CHACHA20_BLOCK_SIZE / sizeof(u32)];
+		u64 entropy_u64[CHACHA_BLOCK_SIZE / sizeof(u64)];
+		u32 entropy_u32[CHACHA_BLOCK_SIZE / sizeof(u32)];
 	};
 	unsigned int position;
 };
diff --git a/include/crypto/chacha.h b/include/crypto/chacha.h
new file mode 100644
index 000000000000..a504350f54df
--- /dev/null
+++ b/include/crypto/chacha.h
@@ -0,0 +1,47 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * Common values and helper functions for the ChaCha and XChaCha algorithms.
+ *
+ * XChaCha extends ChaCha's nonce to 192 bits, while provably retaining ChaCha's
+ * security.  Here they share the same key size, tfm context, and setkey
+ * function; only their IV size and encrypt/decrypt function differ.
+ */
+
+#ifndef _CRYPTO_CHACHA_H
+#define _CRYPTO_CHACHA_H
+
+#include <crypto/skcipher.h>
+#include <linux/types.h>
+#include <linux/crypto.h>
+
+/* 32-bit stream position, then 96-bit nonce (RFC7539 convention) */
+#define CHACHA_IV_SIZE		16
+
+#define CHACHA_KEY_SIZE		32
+#define CHACHA_BLOCK_SIZE	64
+#define CHACHA_BLOCK_WORDS	(CHACHA_BLOCK_SIZE / sizeof(u32))
+
+/* 192-bit nonce, then 64-bit stream position */
+#define XCHACHA_IV_SIZE		32
+
+struct chacha_ctx {
+	u32 key[8];
+	int nrounds;
+};
+
+void chacha_block(u32 *state, u32 *stream, int nrounds);
+static inline void chacha20_block(u32 *state, u32 *stream)
+{
+	chacha_block(state, stream, 20);
+}
+void hchacha_block(const u32 *in, u32 *out, int nrounds);
+
+void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv);
+
+int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			   unsigned int keysize);
+
+int crypto_chacha_crypt(struct skcipher_request *req);
+int crypto_xchacha_crypt(struct skcipher_request *req);
+
+#endif /* _CRYPTO_CHACHA_H */
diff --git a/include/crypto/chacha20.h b/include/crypto/chacha20.h
deleted file mode 100644
index f977e685925d..000000000000
--- a/include/crypto/chacha20.h
+++ /dev/null
@@ -1,42 +0,0 @@
-/* SPDX-License-Identifier: GPL-2.0 */
-/*
- * Common values and helper functions for the ChaCha20 and XChaCha20 algorithms.
- *
- * XChaCha20 extends ChaCha20's nonce to 192 bits, while provably retaining
- * ChaCha20's security.  Here they share the same key size, tfm context, and
- * setkey function; only their IV size and encrypt/decrypt function differ.
- */
-
-#ifndef _CRYPTO_CHACHA20_H
-#define _CRYPTO_CHACHA20_H
-
-#include <crypto/skcipher.h>
-#include <linux/types.h>
-#include <linux/crypto.h>
-
-/* 32-bit stream position, then 96-bit nonce (RFC7539 convention) */
-#define CHACHA20_IV_SIZE	16
-
-#define CHACHA20_KEY_SIZE	32
-#define CHACHA20_BLOCK_SIZE	64
-#define CHACHA20_BLOCK_WORDS	(CHACHA20_BLOCK_SIZE / sizeof(u32))
-
-/* 192-bit nonce, then 64-bit stream position */
-#define XCHACHA20_IV_SIZE	32
-
-struct chacha20_ctx {
-	u32 key[8];
-};
-
-void chacha20_block(u32 *state, u32 *stream);
-void hchacha20_block(const u32 *in, u32 *out);
-
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv);
-
-int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
-			   unsigned int keysize);
-
-int crypto_chacha20_crypt(struct skcipher_request *req);
-int crypto_xchacha20_crypt(struct skcipher_request *req);
-
-#endif
diff --git a/lib/Makefile b/lib/Makefile
index 90dc5520b784..e37f0f922185 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -20,7 +20,7 @@ KCOV_INSTRUMENT_dynamic_debug.o := n
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o timerqueue.o\
 	 idr.o int_sqrt.o extable.o \
-	 sha1.o chacha20.o irq_regs.o argv_split.o \
+	 sha1.o chacha.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
 	 earlycpio.o seq_buf.o siphash.o dec_and_lock.o \
diff --git a/lib/chacha20.c b/lib/chacha.c
similarity index 67%
rename from lib/chacha20.c
rename to lib/chacha.c
index 13a0bdcb1604..b0fd1e0882e3 100644
--- a/lib/chacha20.c
+++ b/lib/chacha.c
@@ -1,5 +1,5 @@
 /*
- * The "hash function" used as the core of the ChaCha20 stream cipher (RFC7539)
+ * The "hash function" used as the core of the ChaCha stream cipher (RFC7539)
  *
  * Copyright (C) 2015 Martin Willi
  *
@@ -14,13 +14,16 @@
 #include <linux/bitops.h>
 #include <linux/cryptohash.h>
 #include <asm/unaligned.h>
-#include <crypto/chacha20.h>
+#include <crypto/chacha.h>
 
-static void chacha20_permute(u32 *x)
+static void chacha_permute(u32 *x, int nrounds)
 {
 	int i;
 
-	for (i = 0; i < 20; i += 2) {
+	/* whitelist the allowed round counts */
+	BUG_ON(nrounds != 20);
+
+	for (i = 0; i < nrounds; i += 2) {
 		x[0]  += x[4];    x[12] = rol32(x[12] ^ x[0],  16);
 		x[1]  += x[5];    x[13] = rol32(x[13] ^ x[1],  16);
 		x[2]  += x[6];    x[14] = rol32(x[14] ^ x[2],  16);
@@ -64,49 +67,51 @@ static void chacha20_permute(u32 *x)
 }
 
 /**
- * chacha20_block - generate one keystream block and increment block counter
+ * chacha_block - generate one keystream block and increment block counter
  * @state: input state matrix (16 32-bit words)
  * @stream: output keystream block (64 bytes)
+ * @nrounds: number of rounds (currently must be 20)
  *
- * This is the ChaCha20 core, a function from 64-byte strings to 64-byte
- * strings.  The caller has already converted the endianness of the input.  This
- * function also handles incrementing the block counter in the input matrix.
+ * This is the ChaCha core, a function from 64-byte strings to 64-byte strings.
+ * The caller has already converted the endianness of the input.  This function
+ * also handles incrementing the block counter in the input matrix.
  */
-void chacha20_block(u32 *state, u32 *stream)
+void chacha_block(u32 *state, u32 *stream, int nrounds)
 {
 	u32 x[16];
 	int i;
 
 	memcpy(x, state, 64);
 
-	chacha20_permute(x);
+	chacha_permute(x, nrounds);
 
 	for (i = 0; i < ARRAY_SIZE(x); i++)
 		stream[i] = cpu_to_le32(x[i] + state[i]);
 
 	state[12]++;
 }
-EXPORT_SYMBOL(chacha20_block);
+EXPORT_SYMBOL(chacha_block);
 
 /**
- * hchacha20_block - abbreviated ChaCha20 core, for XChaCha20
+ * hchacha_block - abbreviated ChaCha core, for XChaCha
  * @in: input state matrix (16 32-bit words)
  * @out: output (8 32-bit words)
+ * @nrounds: number of rounds (currently must be 20)
  *
- * HChaCha20 is the ChaCha equivalent of HSalsa20 and is an intermediate step
- * towards XChaCha20 (see https://cr.yp.to/snuffle/xsalsa-20081128.pdf).
- * HChaCha20 skips the final addition of the initial state, and outputs only
- * certain words of the state.  It should not be used for streaming directly.
+ * HChaCha is the ChaCha equivalent of HSalsa and is an intermediate step
+ * towards XChaCha (see https://cr.yp.to/snuffle/xsalsa-20081128.pdf).  HChaCha
+ * skips the final addition of the initial state, and outputs only certain words
+ * of the state.  It should not be used for streaming directly.
  */
-void hchacha20_block(const u32 *in, u32 *out)
+void hchacha_block(const u32 *in, u32 *out, int nrounds)
 {
 	u32 x[16];
 
 	memcpy(x, in, 64);
 
-	chacha20_permute(x);
+	chacha_permute(x, nrounds);
 
 	memcpy(&out[0], &x[0], 16);
 	memcpy(&out[4], &x[12], 16);
 }
-EXPORT_SYMBOL(hchacha20_block);
+EXPORT_SYMBOL(hchacha_block);
-- 
2.18.0.597.ga71716f1ad-goog

