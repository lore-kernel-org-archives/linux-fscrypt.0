Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [RFC PATCH] crypto: chacha20 - add implementation using 96-bit nonce
Date: Fri,  8 Dec 2017 11:55:02 +0000
Message-Id: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: herbert@gondor.apana.org.au, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Stephan Mueller <smueller@chronox.de>
List-ID: <linux-fscrypt@vger.kernel.org>

As pointed out by Eric [0], the way RFC7539 was interpreted when creating
our implementation of ChaCha20 creates a risk of IV reuse when using a
little endian counter as the IV generator. The reason is that the low end
bits of the counter get mapped onto the ChaCha20 block counter, which
advances every 64 bytes. This means that the counter value that gets
selected as IV for the next input block will collide with the ChaCha20
block counter of the previous block, basically recreating the same
keystream but shifted by 64 bytes.

RFC7539 describes the inputs of the algorithm as follows:

  The inputs to ChaCha20 are:

     o  A 256-bit key

     o  A 32-bit initial counter.  This can be set to any number, but will
        usually be zero or one.  It makes sense to use one if we use the
        zero block for something else, such as generating a one-time
        authenticator key as part of an AEAD algorithm.

     o  A 96-bit nonce.  In some protocols, this is known as the
        Initialization Vector.

     o  An arbitrary-length plaintext

The solution is to use a fixed value of 0 for the initial counter, and
only expose a 96-bit IV to the upper layers of the crypto API.

So introduce a new ChaCha20 flavor called chacha20-iv96, which takes the
above into account, and should become the preferred ChaCha20
implementation going forward for general use.

[0] https://marc.info/?l=linux-crypto-vger&m=151269722430848&w=2

Cc: Eric Biggers <ebiggers@google.com>
Cc: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-mtd@lists.infradead.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-crypto@vger.kernel.org
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Michael Halcrow <mhalcrow@google.com>
Cc: Paul Crowley <paulcrowley@google.com>
Cc: Martin Willi <martin@strongswan.org>
Cc: David Gstir <david@sigma-star.at>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: Stephan Mueller <smueller@chronox.de>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/crypto/chacha20-neon-glue.c | 27 +++++++++++---
 arch/x86/crypto/chacha20_glue.c        | 19 +++++++++-
 crypto/chacha20_generic.c              | 38 ++++++++++++++------
 crypto/testmgr.c                       |  9 +++++
 crypto/testmgr.h                       |  2 +-
 include/crypto/chacha20.h              |  4 ++-
 6 files changed, 81 insertions(+), 18 deletions(-)

diff --git a/arch/arm64/crypto/chacha20-neon-glue.c b/arch/arm64/crypto/chacha20-neon-glue.c
index cbdb75d15cd0..76a570058cc8 100644
--- a/arch/arm64/crypto/chacha20-neon-glue.c
+++ b/arch/arm64/crypto/chacha20-neon-glue.c
@@ -70,7 +70,7 @@ static int chacha20_neon(struct skcipher_request *req)
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha20_init(state, ctx, walk.iv, crypto_skcipher_ivsize(tfm));
 
 	kernel_neon_begin();
 	while (walk.nbytes > 0) {
@@ -88,7 +88,7 @@ static int chacha20_neon(struct skcipher_request *req)
 	return err;
 }
 
-static struct skcipher_alg alg = {
+static struct skcipher_alg alg[] = {{
 	.base.cra_name		= "chacha20",
 	.base.cra_driver_name	= "chacha20-neon",
 	.base.cra_priority	= 300,
@@ -104,19 +104,35 @@ static struct skcipher_alg alg = {
 	.setkey			= crypto_chacha20_setkey,
 	.encrypt		= chacha20_neon,
 	.decrypt		= chacha20_neon,
-};
+}, {
+	.base.cra_name		= "chacha20-iv96",
+	.base.cra_driver_name	= "chacha20-neon",
+	.base.cra_priority	= 300,
+	.base.cra_blocksize	= 1,
+	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_module	= THIS_MODULE,
+
+	.min_keysize		= CHACHA20_KEY_SIZE,
+	.max_keysize		= CHACHA20_KEY_SIZE,
+	.ivsize			= CHACHA20_NONCE_SIZE,
+	.chunksize		= CHACHA20_BLOCK_SIZE,
+	.walksize		= 4 * CHACHA20_BLOCK_SIZE,
+	.setkey			= crypto_chacha20_setkey,
+	.encrypt		= chacha20_neon,
+	.decrypt		= chacha20_neon,
+}};
 
 static int __init chacha20_simd_mod_init(void)
 {
 	if (!(elf_hwcap & HWCAP_ASIMD))
 		return -ENODEV;
 
-	return crypto_register_skcipher(&alg);
+	return crypto_register_skciphers(alg, ARRAY_SIZE(alg));
 }
 
 static void __exit chacha20_simd_mod_fini(void)
 {
-	crypto_unregister_skcipher(&alg);
+	crypto_unregister_skciphers(alg, ARRAY_SIZE(alg));
 }
 
 module_init(chacha20_simd_mod_init);
@@ -125,3 +141,4 @@ module_exit(chacha20_simd_mod_fini);
 MODULE_AUTHOR("Ard Biesheuvel <ard.biesheuvel@linaro.org>");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS_CRYPTO("chacha20");
+MODULE_ALIAS_CRYPTO("chacha20-iv96");
diff --git a/arch/x86/crypto/chacha20_glue.c b/arch/x86/crypto/chacha20_glue.c
index dce7c5d39c2f..44c7fe376a1d 100644
--- a/arch/x86/crypto/chacha20_glue.c
+++ b/arch/x86/crypto/chacha20_glue.c
@@ -79,7 +79,7 @@ static int chacha20_simd(struct skcipher_request *req)
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha20_init(state, ctx, walk.iv, crypto_skcipher_ivsize(tfm));
 
 	kernel_fpu_begin();
 
@@ -116,6 +116,22 @@ static struct skcipher_alg alg = {
 	.setkey			= crypto_chacha20_setkey,
 	.encrypt		= chacha20_simd,
 	.decrypt		= chacha20_simd,
+}, {
+	.base.cra_name		= "chacha20-iv96",
+	.base.cra_driver_name	= "chacha20-simd",
+	.base.cra_priority	= 300,
+	.base.cra_blocksize	= 1,
+	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_alignmask	= sizeof(u32) - 1,
+	.base.cra_module	= THIS_MODULE,
+
+	.min_keysize		= CHACHA20_KEY_SIZE,
+	.max_keysize		= CHACHA20_KEY_SIZE,
+	.ivsize			= CHACHA20_NONCE_SIZE,
+	.chunksize		= CHACHA20_BLOCK_SIZE,
+	.setkey			= crypto_chacha20_setkey,
+	.encrypt		= chacha20_simd,
+	.decrypt		= chacha20_simd,
 };
 
 static int __init chacha20_simd_mod_init(void)
@@ -143,4 +159,5 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Martin Willi <martin@strongswan.org>");
 MODULE_DESCRIPTION("chacha20 cipher algorithm, SIMD accelerated");
 MODULE_ALIAS_CRYPTO("chacha20");
+MODULE_ALIAS_CRYPTO("chacha20-iv96");
 MODULE_ALIAS_CRYPTO("chacha20-simd");
diff --git a/crypto/chacha20_generic.c b/crypto/chacha20_generic.c
index e451c3cb6a56..943acb92857e 100644
--- a/crypto/chacha20_generic.c
+++ b/crypto/chacha20_generic.c
@@ -35,7 +35,8 @@ static void chacha20_docrypt(u32 *state, u8 *dst, const u8 *src,
 	}
 }
 
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv)
+void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv,
+			  int ivsize)
 {
 	state[0]  = 0x61707865; /* "expa" */
 	state[1]  = 0x3320646e; /* "nd 3" */
@@ -49,10 +50,10 @@ void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv)
 	state[9]  = ctx->key[5];
 	state[10] = ctx->key[6];
 	state[11] = ctx->key[7];
-	state[12] = get_unaligned_le32(iv +  0);
-	state[13] = get_unaligned_le32(iv +  4);
-	state[14] = get_unaligned_le32(iv +  8);
-	state[15] = get_unaligned_le32(iv + 12);
+	state[12] = (ivsize > CHACHA20_NONCE_SIZE) ? get_unaligned_le32(iv) : 0;
+	state[13] = get_unaligned_le32(iv + ivsize - 12);
+	state[14] = get_unaligned_le32(iv + ivsize -  8);
+	state[15] = get_unaligned_le32(iv + ivsize -  4);
 }
 EXPORT_SYMBOL_GPL(crypto_chacha20_init);
 
@@ -82,7 +83,7 @@ int crypto_chacha20_crypt(struct skcipher_request *req)
 
 	err = skcipher_walk_virt(&walk, req, true);
 
-	crypto_chacha20_init(state, ctx, walk.iv);
+	crypto_chacha20_init(state, ctx, walk.iv, crypto_skcipher_ivsize(tfm));
 
 	while (walk.nbytes > 0) {
 		unsigned int nbytes = walk.nbytes;
@@ -99,7 +100,7 @@ int crypto_chacha20_crypt(struct skcipher_request *req)
 }
 EXPORT_SYMBOL_GPL(crypto_chacha20_crypt);
 
-static struct skcipher_alg alg = {
+static struct skcipher_alg alg[] = {{
 	.base.cra_name		= "chacha20",
 	.base.cra_driver_name	= "chacha20-generic",
 	.base.cra_priority	= 100,
@@ -114,16 +115,32 @@ static struct skcipher_alg alg = {
 	.setkey			= crypto_chacha20_setkey,
 	.encrypt		= crypto_chacha20_crypt,
 	.decrypt		= crypto_chacha20_crypt,
-};
+}, {
+	.base.cra_name		= "chacha20-iv96",
+	.base.cra_driver_name	= "chacha20-generic",
+	.base.cra_priority	= 100,
+	.base.cra_blocksize	= 1,
+	.base.cra_ctxsize	= sizeof(struct chacha20_ctx),
+	.base.cra_alignmask	= sizeof(u32) - 1,
+	.base.cra_module	= THIS_MODULE,
+
+	.min_keysize		= CHACHA20_KEY_SIZE,
+	.max_keysize		= CHACHA20_KEY_SIZE,
+	.ivsize			= CHACHA20_NONCE_SIZE,
+	.chunksize		= CHACHA20_BLOCK_SIZE,
+	.setkey			= crypto_chacha20_setkey,
+	.encrypt		= crypto_chacha20_crypt,
+	.decrypt		= crypto_chacha20_crypt,
+}};
 
 static int __init chacha20_generic_mod_init(void)
 {
-	return crypto_register_skcipher(&alg);
+	return crypto_register_skciphers(alg, ARRAY_SIZE(alg));
 }
 
 static void __exit chacha20_generic_mod_fini(void)
 {
-	crypto_unregister_skcipher(&alg);
+	crypto_unregister_skciphers(alg, ARRAY_SIZE(alg));
 }
 
 module_init(chacha20_generic_mod_init);
@@ -133,4 +150,5 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Martin Willi <martin@strongswan.org>");
 MODULE_DESCRIPTION("chacha20 cipher algorithm");
 MODULE_ALIAS_CRYPTO("chacha20");
+MODULE_ALIAS_CRYPTO("chacha20-iv96");
 MODULE_ALIAS_CRYPTO("chacha20-generic");
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index 29d7020b8826..ce87cc4f81b1 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -2563,6 +2563,15 @@ static const struct alg_test_desc alg_test_descs[] = {
 			}
 		}
 	}, {
+		.alg = "chacha20-iv96",
+		.test = alg_test_skcipher,
+		.suite = {
+			.cipher = {
+				.enc = { .vecs = chacha20_enc_tv_template, .count = 1 },
+				.dec = { .vecs = chacha20_enc_tv_template, .count = 1 },
+			}
+		}
+	}, {
 		.alg = "cmac(aes)",
 		.fips_allowed = 1,
 		.test = alg_test_hash,
diff --git a/crypto/testmgr.h b/crypto/testmgr.h
index a714b6293959..4a5e5411e12c 100644
--- a/crypto/testmgr.h
+++ b/crypto/testmgr.h
@@ -32612,7 +32612,7 @@ static const struct cipher_testvec salsa20_stream_enc_tv_template[] = {
 };
 
 static const struct cipher_testvec chacha20_enc_tv_template[] = {
-	{ /* RFC7539 A.2. Test Vector #1 */
+	{ /* RFC7539 A.2. Test Vector #1 (shared with chacha20-iv96) */
 		.key	= "\x00\x00\x00\x00\x00\x00\x00\x00"
 			  "\x00\x00\x00\x00\x00\x00\x00\x00"
 			  "\x00\x00\x00\x00\x00\x00\x00\x00"
diff --git a/include/crypto/chacha20.h b/include/crypto/chacha20.h
index b83d66073db0..5db09213fe67 100644
--- a/include/crypto/chacha20.h
+++ b/include/crypto/chacha20.h
@@ -10,6 +10,7 @@
 #include <linux/types.h>
 #include <linux/crypto.h>
 
+#define CHACHA20_NONCE_SIZE	12
 #define CHACHA20_IV_SIZE	16
 #define CHACHA20_KEY_SIZE	32
 #define CHACHA20_BLOCK_SIZE	64
@@ -20,7 +21,8 @@ struct chacha20_ctx {
 };
 
 void chacha20_block(u32 *state, u32 *stream);
-void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv);
+void crypto_chacha20_init(u32 *state, struct chacha20_ctx *ctx, u8 *iv,
+			  int ivsize);
 int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
 			   unsigned int keysize);
 int crypto_chacha20_crypt(struct skcipher_request *req);
-- 
2.11.0
