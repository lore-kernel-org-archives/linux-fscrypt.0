Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v3 07/15] crypto: arm/chacha20 - add XChaCha20 support
Date: Mon,  5 Nov 2018 15:25:18 -0800
Message-Id: <20181105232526.173947-8-ebiggers@kernel.org>
In-Reply-To: <20181105232526.173947-1-ebiggers@kernel.org>
References: <20181105232526.173947-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-crypto-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add an XChaCha20 implementation that is hooked up to the ARM NEON
implementation of ChaCha20.  This is needed for use in the Adiantum
encryption mode; see the generic code patch,
"crypto: chacha20-generic - add XChaCha20 support", for more details.

We also update the NEON code to support HChaCha20 on one block, so we
can use that in XChaCha20 rather than calling the generic HChaCha20.
This required factoring the permutation out into its own macro.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/arm/crypto/Kconfig              |   2 +-
 arch/arm/crypto/chacha20-neon-core.S |  70 ++++++++++++------
 arch/arm/crypto/chacha20-neon-glue.c | 103 ++++++++++++++++++++-------
 3 files changed, 126 insertions(+), 49 deletions(-)

diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
index ef0c7feea6e2..0aa1471f27d2 100644
--- a/arch/arm/crypto/Kconfig
+++ b/arch/arm/crypto/Kconfig
@@ -117,7 +117,7 @@ config CRYPTO_CRC32_ARM_CE
 	select CRYPTO_HASH
 
 config CRYPTO_CHACHA20_NEON
-	tristate "NEON accelerated ChaCha20 symmetric cipher"
+	tristate "NEON accelerated ChaCha20 stream cipher algorithms"
 	depends on KERNEL_MODE_NEON
 	select CRYPTO_BLKCIPHER
 	select CRYPTO_CHACHA20
diff --git a/arch/arm/crypto/chacha20-neon-core.S b/arch/arm/crypto/chacha20-neon-core.S
index 50e7b9896818..2335e5055d2b 100644
--- a/arch/arm/crypto/chacha20-neon-core.S
+++ b/arch/arm/crypto/chacha20-neon-core.S
@@ -52,27 +52,16 @@
 	.fpu		neon
 	.align		5
 
-ENTRY(chacha20_block_xor_neon)
-	// r0: Input state matrix, s
-	// r1: 1 data block output, o
-	// r2: 1 data block input, i
-
-	//
-	// This function encrypts one ChaCha20 block by loading the state matrix
-	// in four NEON registers. It performs matrix operation on four words in
-	// parallel, but requireds shuffling to rearrange the words after each
-	// round.
-	//
-
-	// x0..3 = s0..3
-	add		ip, r0, #0x20
-	vld1.32		{q0-q1}, [r0]
-	vld1.32		{q2-q3}, [ip]
-
-	vmov		q8, q0
-	vmov		q9, q1
-	vmov		q10, q2
-	vmov		q11, q3
+/*
+ * chacha20_permute - permute one block
+ *
+ * Permute one 64-byte block where the state matrix is stored in the four NEON
+ * registers q0-q3.  It performs matrix operations on four words in parallel,
+ * but requires shuffling to rearrange the words after each round.
+ *
+ * Clobbers: r3, ip, q4-q5
+ */
+chacha20_permute:
 
 	adr		ip, .Lrol8_table
 	mov		r3, #10
@@ -142,6 +131,27 @@ ENTRY(chacha20_block_xor_neon)
 	subs		r3, r3, #1
 	bne		.Ldoubleround
 
+	bx		lr
+ENDPROC(chacha20_permute)
+
+ENTRY(chacha20_block_xor_neon)
+	// r0: Input state matrix, s
+	// r1: 1 data block output, o
+	// r2: 1 data block input, i
+	push		{lr}
+
+	// x0..3 = s0..3
+	add		ip, r0, #0x20
+	vld1.32		{q0-q1}, [r0]
+	vld1.32		{q2-q3}, [ip]
+
+	vmov		q8, q0
+	vmov		q9, q1
+	vmov		q10, q2
+	vmov		q11, q3
+
+	bl		chacha20_permute
+
 	add		ip, r2, #0x20
 	vld1.8		{q4-q5}, [r2]
 	vld1.8		{q6-q7}, [ip]
@@ -166,9 +176,25 @@ ENTRY(chacha20_block_xor_neon)
 	vst1.8		{q0-q1}, [r1]
 	vst1.8		{q2-q3}, [ip]
 
-	bx		lr
+	pop		{pc}
 ENDPROC(chacha20_block_xor_neon)
 
+ENTRY(hchacha20_block_neon)
+	// r0: Input state matrix, s
+	// r1: output (8 32-bit words)
+	push		{lr}
+
+	vld1.32		{q0-q1}, [r0]!
+	vld1.32		{q2-q3}, [r0]
+
+	bl		chacha20_permute
+
+	vst1.32		{q0}, [r1]!
+	vst1.32		{q3}, [r1]
+
+	pop		{pc}
+ENDPROC(hchacha20_block_neon)
+
 	.align		4
 .Lctrinc:	.word	0, 1, 2, 3
 .Lrol8_table:	.byte	3, 0, 1, 2, 7, 4, 5, 6
diff --git a/arch/arm/crypto/chacha20-neon-glue.c b/arch/arm/crypto/chacha20-neon-glue.c
index 2bc035cb8f23..f2d3b0f70a8d 100644
--- a/arch/arm/crypto/chacha20-neon-glue.c
+++ b/arch/arm/crypto/chacha20-neon-glue.c
@@ -1,5 +1,5 @@
 /*
- * ChaCha20 256-bit cipher algorithm, RFC7539, ARM NEON functions
+ * ChaCha20 (RFC7539) and XChaCha20 stream ciphers, NEON accelerated
  *
  * Copyright (C) 2016 Linaro, Ltd. <ard.biesheuvel@linaro.org>
  *
@@ -30,6 +30,7 @@
 
 asmlinkage void chacha20_block_xor_neon(u32 *state, u8 *dst, const u8 *src);
 asmlinkage void chacha20_4block_xor_neon(u32 *state, u8 *dst, const u8 *src);
+asmlinkage void hchacha20_block_neon(const u32 *state, u32 *out);
 
 static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
@@ -57,20 +58,16 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 	}
 }
 
-static int chacha20_neon(struct skcipher_request *req)
+static int chacha20_neon_stream_xor(struct skcipher_request *req,
+				    struct chacha_ctx *ctx, u8 *iv)
 {
-	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
-	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
 	u32 state[16];
 	int err;
 
-	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
-		return crypto_chacha_crypt(req);
-
 	err = skcipher_walk_virt(&walk, req, false);
 
-	crypto_chacha_init(state, ctx, walk.iv);
+	crypto_chacha_init(state, ctx, iv);
 
 	while (walk.nbytes > 0) {
 		unsigned int nbytes = walk.nbytes;
@@ -88,22 +85,73 @@ static int chacha20_neon(struct skcipher_request *req)
 	return err;
 }
 
-static struct skcipher_alg alg = {
-	.base.cra_name		= "chacha20",
-	.base.cra_driver_name	= "chacha20-neon",
-	.base.cra_priority	= 300,
-	.base.cra_blocksize	= 1,
-	.base.cra_ctxsize	= sizeof(struct chacha_ctx),
-	.base.cra_module	= THIS_MODULE,
-
-	.min_keysize		= CHACHA_KEY_SIZE,
-	.max_keysize		= CHACHA_KEY_SIZE,
-	.ivsize			= CHACHA_IV_SIZE,
-	.chunksize		= CHACHA_BLOCK_SIZE,
-	.walksize		= 4 * CHACHA_BLOCK_SIZE,
-	.setkey			= crypto_chacha20_setkey,
-	.encrypt		= chacha20_neon,
-	.decrypt		= chacha20_neon,
+static int chacha20_neon(struct skcipher_request *req)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+
+	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
+		return crypto_chacha_crypt(req);
+
+	return chacha20_neon_stream_xor(req, ctx, req->iv);
+}
+
+static int xchacha20_neon(struct skcipher_request *req)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct chacha_ctx subctx;
+	u32 state[16];
+	u8 real_iv[16];
+
+	if (req->cryptlen <= CHACHA_BLOCK_SIZE || !may_use_simd())
+		return crypto_xchacha_crypt(req);
+
+	crypto_chacha_init(state, ctx, req->iv);
+
+	kernel_neon_begin();
+	hchacha20_block_neon(state, subctx.key);
+	kernel_neon_end();
+
+	memcpy(&real_iv[0], req->iv + 24, 8);
+	memcpy(&real_iv[8], req->iv + 16, 8);
+	return chacha20_neon_stream_xor(req, &subctx, real_iv);
+}
+
+static struct skcipher_alg algs[] = {
+	{
+		.base.cra_name		= "chacha20",
+		.base.cra_driver_name	= "chacha20-neon",
+		.base.cra_priority	= 300,
+		.base.cra_blocksize	= 1,
+		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_module	= THIS_MODULE,
+
+		.min_keysize		= CHACHA_KEY_SIZE,
+		.max_keysize		= CHACHA_KEY_SIZE,
+		.ivsize			= CHACHA_IV_SIZE,
+		.chunksize		= CHACHA_BLOCK_SIZE,
+		.walksize		= 4 * CHACHA_BLOCK_SIZE,
+		.setkey			= crypto_chacha20_setkey,
+		.encrypt		= chacha20_neon,
+		.decrypt		= chacha20_neon,
+	}, {
+		.base.cra_name		= "xchacha20",
+		.base.cra_driver_name	= "xchacha20-neon",
+		.base.cra_priority	= 300,
+		.base.cra_blocksize	= 1,
+		.base.cra_ctxsize	= sizeof(struct chacha_ctx),
+		.base.cra_module	= THIS_MODULE,
+
+		.min_keysize		= CHACHA_KEY_SIZE,
+		.max_keysize		= CHACHA_KEY_SIZE,
+		.ivsize			= XCHACHA_IV_SIZE,
+		.chunksize		= CHACHA_BLOCK_SIZE,
+		.walksize		= 4 * CHACHA_BLOCK_SIZE,
+		.setkey			= crypto_chacha20_setkey,
+		.encrypt		= xchacha20_neon,
+		.decrypt		= xchacha20_neon,
+	}
 };
 
 static int __init chacha20_simd_mod_init(void)
@@ -111,12 +159,12 @@ static int __init chacha20_simd_mod_init(void)
 	if (!(elf_hwcap & HWCAP_NEON))
 		return -ENODEV;
 
-	return crypto_register_skcipher(&alg);
+	return crypto_register_skciphers(algs, ARRAY_SIZE(algs));
 }
 
 static void __exit chacha20_simd_mod_fini(void)
 {
-	crypto_unregister_skcipher(&alg);
+	crypto_unregister_skciphers(algs, ARRAY_SIZE(algs));
 }
 
 module_init(chacha20_simd_mod_init);
@@ -125,3 +173,6 @@ module_exit(chacha20_simd_mod_fini);
 MODULE_AUTHOR("Ard Biesheuvel <ard.biesheuvel@linaro.org>");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS_CRYPTO("chacha20");
+MODULE_ALIAS_CRYPTO("chacha20-neon");
+MODULE_ALIAS_CRYPTO("xchacha20");
+MODULE_ALIAS_CRYPTO("xchacha20-neon");
-- 
2.19.1.930.g4563a0d9d0-goog
