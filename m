Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54070 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726820AbeJPBmu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 15 Oct 2018 21:42:50 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v2 06/12] crypto: arm/chacha20 - refactor to allow varying number of rounds
Date: Mon, 15 Oct 2018 10:54:18 -0700
Message-Id: <20181015175424.97147-7-ebiggers@kernel.org>
In-Reply-To: <20181015175424.97147-1-ebiggers@kernel.org>
References: <20181015175424.97147-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In preparation for adding XChaCha12 support, rename/refactor the NEON
implementation of ChaCha20 to support different numbers of rounds.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/arm/crypto/Makefile                      |  4 +-
 ...hacha20-neon-core.S => chacha-neon-core.S} | 36 ++++++------
 ...hacha20-neon-glue.c => chacha-neon-glue.c} | 56 ++++++++++---------
 3 files changed, 52 insertions(+), 44 deletions(-)
 rename arch/arm/crypto/{chacha20-neon-core.S => chacha-neon-core.S} (96%)
 rename arch/arm/crypto/{chacha20-neon-glue.c => chacha-neon-glue.c} (73%)

diff --git a/arch/arm/crypto/Makefile b/arch/arm/crypto/Makefile
index bd5bceef0605f..005482ff95047 100644
--- a/arch/arm/crypto/Makefile
+++ b/arch/arm/crypto/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_CRYPTO_SHA1_ARM) += sha1-arm.o
 obj-$(CONFIG_CRYPTO_SHA1_ARM_NEON) += sha1-arm-neon.o
 obj-$(CONFIG_CRYPTO_SHA256_ARM) += sha256-arm.o
 obj-$(CONFIG_CRYPTO_SHA512_ARM) += sha512-arm.o
-obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha20-neon.o
+obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha-neon.o
 
 ce-obj-$(CONFIG_CRYPTO_AES_ARM_CE) += aes-arm-ce.o
 ce-obj-$(CONFIG_CRYPTO_SHA1_ARM_CE) += sha1-arm-ce.o
@@ -52,7 +52,7 @@ aes-arm-ce-y	:= aes-ce-core.o aes-ce-glue.o
 ghash-arm-ce-y	:= ghash-ce-core.o ghash-ce-glue.o
 crct10dif-arm-ce-y	:= crct10dif-ce-core.o crct10dif-ce-glue.o
 crc32-arm-ce-y:= crc32-ce-core.o crc32-ce-glue.o
-chacha20-neon-y := chacha20-neon-core.o chacha20-neon-glue.o
+chacha-neon-y := chacha-neon-core.o chacha-neon-glue.o
 
 ifdef REGENERATE_ARM_CRYPTO
 quiet_cmd_perl = PERL    $@
diff --git a/arch/arm/crypto/chacha20-neon-core.S b/arch/arm/crypto/chacha-neon-core.S
similarity index 96%
rename from arch/arm/crypto/chacha20-neon-core.S
rename to arch/arm/crypto/chacha-neon-core.S
index db59f1fbc728b..4b12064449f78 100644
--- a/arch/arm/crypto/chacha20-neon-core.S
+++ b/arch/arm/crypto/chacha-neon-core.S
@@ -1,5 +1,5 @@
 /*
- * ChaCha20 256-bit cipher algorithm, RFC7539, ARM NEON functions
+ * ChaCha/XChaCha NEON helper functions
  *
  * Copyright (C) 2016 Linaro, Ltd. <ard.biesheuvel@linaro.org>
  *
@@ -53,18 +53,19 @@
 	.align		5
 
 /*
- * _chacha20_permute - permute one block
+ * _chacha_permute - permute one block
  *
  * Permute one 64-byte block where the state matrix is stored in the four NEON
  * registers q0-q3.  It performs matrix operation on four words in parallel, but
  * requires shuffling to rearrange the words after each round.
  *
+ * The round count is given in r3.
+ *
  * Clobbers: r3, q4-q5
  */
-.macro	_chacha20_permute
+.macro	_chacha_permute
 
 	adr		ip, .Lrol8_table
-	mov		r3, #10
 	vld1.8		{d10}, [ip, :64]
 
 .Ldoubleround_\@:
@@ -128,14 +129,15 @@
 	// x3 = shuffle32(x3, MASK(0, 3, 2, 1))
 	vext.8		q3, q3, q3, #4
 
-	subs		r3, r3, #1
+	subs		r3, r3, #2
 	bne		.Ldoubleround_\@
 .endm
 
-ENTRY(chacha20_block_xor_neon)
+ENTRY(chacha_block_xor_neon)
 	// r0: Input state matrix, s
 	// r1: 1 data block output, o
 	// r2: 1 data block input, i
+	// r3: nrounds
 
 	// x0..3 = s0..3
 	add		ip, r0, #0x20
@@ -147,7 +149,7 @@ ENTRY(chacha20_block_xor_neon)
 	vmov		q10, q2
 	vmov		q11, q3
 
-	_chacha20_permute
+	_chacha_permute
 
 	add		ip, r2, #0x20
 	vld1.8		{q4-q5}, [r2]
@@ -174,29 +176,31 @@ ENTRY(chacha20_block_xor_neon)
 	vst1.8		{q2-q3}, [ip]
 
 	bx		lr
-ENDPROC(chacha20_block_xor_neon)
+ENDPROC(chacha_block_xor_neon)
 
-ENTRY(hchacha20_block_neon)
+ENTRY(hchacha_block_neon)
 	// r0: Input state matrix, s
 	// r1: output (8 32-bit words)
+	// r2: nrounds
 
 	vld1.32		{q0-q1}, [r0]!
 	vld1.32		{q2-q3}, [r0]
 
-	_chacha20_permute
+	mov		r3, r2
+	_chacha_permute
 
 	vst1.32		{q0}, [r1]!
 	vst1.32		{q3}, [r1]
 
 	bx		lr
-ENDPROC(hchacha20_block_neon)
+ENDPROC(hchacha_block_neon)
 
 	.align		4
 .Lctrinc:	.word	0, 1, 2, 3
 .Lrol8_table:	.byte	3, 0, 1, 2, 7, 4, 5, 6
 
 	.align		5
-ENTRY(chacha20_4block_xor_neon)
+ENTRY(chacha_4block_xor_neon)
 	push		{r4-r5}
 	mov		r4, sp			// preserve the stack pointer
 	sub		ip, sp, #0x20		// allocate a 32 byte buffer
@@ -206,9 +210,10 @@ ENTRY(chacha20_4block_xor_neon)
 	// r0: Input state matrix, s
 	// r1: 4 data blocks output, o
 	// r2: 4 data blocks input, i
+	// r3: nrounds
 
 	//
-	// This function encrypts four consecutive ChaCha20 blocks by loading
+	// This function encrypts four consecutive ChaCha blocks by loading
 	// the state matrix in NEON registers four times. The algorithm performs
 	// each operation on the corresponding word of each state matrix, hence
 	// requires no word shuffling. The words are re-interleaved before the
@@ -241,7 +246,6 @@ ENTRY(chacha20_4block_xor_neon)
 	vdup.32		q0, d0[0]
 
 	adr		ip, .Lrol8_table
-	mov		r3, #10
 	b		1f
 
 .Ldoubleround4:
@@ -439,7 +443,7 @@ ENTRY(chacha20_4block_xor_neon)
 	vsri.u32	q5, q8, #25
 	vsri.u32	q6, q9, #25
 
-	subs		r3, r3, #1
+	subs		r3, r3, #2
 	bne		.Ldoubleround4
 
 	// x0..7[0-3] are in q0-q7, x10..15[0-3] are in q10-q15.
@@ -549,4 +553,4 @@ ENTRY(chacha20_4block_xor_neon)
 
 	pop		{r4-r5}
 	bx		lr
-ENDPROC(chacha20_4block_xor_neon)
+ENDPROC(chacha_4block_xor_neon)
diff --git a/arch/arm/crypto/chacha20-neon-glue.c b/arch/arm/crypto/chacha-neon-glue.c
similarity index 73%
rename from arch/arm/crypto/chacha20-neon-glue.c
rename to arch/arm/crypto/chacha-neon-glue.c
index becc7990b1d39..b236af4889c61 100644
--- a/arch/arm/crypto/chacha20-neon-glue.c
+++ b/arch/arm/crypto/chacha-neon-glue.c
@@ -28,24 +28,26 @@
 #include <asm/neon.h>
 #include <asm/simd.h>
 
-asmlinkage void chacha20_block_xor_neon(u32 *state, u8 *dst, const u8 *src);
-asmlinkage void chacha20_4block_xor_neon(u32 *state, u8 *dst, const u8 *src);
-asmlinkage void hchacha20_block_neon(const u32 *state, u32 *out);
-
-static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
-			    unsigned int bytes)
+asmlinkage void chacha_block_xor_neon(const u32 *state, u8 *dst, const u8 *src,
+				      int nrounds);
+asmlinkage void chacha_4block_xor_neon(const u32 *state, u8 *dst, const u8 *src,
+				       int nrounds);
+asmlinkage void hchacha_block_neon(const u32 *state, u32 *out, int nrounds);
+
+static void chacha_doneon(u32 *state, u8 *dst, const u8 *src,
+			  unsigned int bytes, int nrounds)
 {
 	u8 buf[CHACHA_BLOCK_SIZE];
 
 	while (bytes >= CHACHA_BLOCK_SIZE * 4) {
-		chacha20_4block_xor_neon(state, dst, src);
+		chacha_4block_xor_neon(state, dst, src, nrounds);
 		bytes -= CHACHA_BLOCK_SIZE * 4;
 		src += CHACHA_BLOCK_SIZE * 4;
 		dst += CHACHA_BLOCK_SIZE * 4;
 		state[12] += 4;
 	}
 	while (bytes >= CHACHA_BLOCK_SIZE) {
-		chacha20_block_xor_neon(state, dst, src);
+		chacha_block_xor_neon(state, dst, src, nrounds);
 		bytes -= CHACHA_BLOCK_SIZE;
 		src += CHACHA_BLOCK_SIZE;
 		dst += CHACHA_BLOCK_SIZE;
@@ -53,13 +55,13 @@ static void chacha20_doneon(u32 *state, u8 *dst, const u8 *src,
 	}
 	if (bytes) {
 		memcpy(buf, src, bytes);
-		chacha20_block_xor_neon(state, buf, buf);
+		chacha_block_xor_neon(state, buf, buf, nrounds);
 		memcpy(dst, buf, bytes);
 	}
 }
 
-static int chacha20_neon_stream_xor(struct skcipher_request *req,
-				    struct chacha_ctx *ctx, u8 *iv)
+static int chacha_neon_stream_xor(struct skcipher_request *req,
+				  struct chacha_ctx *ctx, u8 *iv)
 {
 	struct skcipher_walk walk;
 	u32 state[16];
@@ -75,15 +77,15 @@ static int chacha20_neon_stream_xor(struct skcipher_request *req,
 		if (nbytes < walk.total)
 			nbytes = round_down(nbytes, walk.stride);
 
-		chacha20_doneon(state, walk.dst.virt.addr, walk.src.virt.addr,
-				nbytes);
+		chacha_doneon(state, walk.dst.virt.addr, walk.src.virt.addr,
+			      nbytes, ctx->nrounds);
 		err = skcipher_walk_done(&walk, walk.nbytes - nbytes);
 	}
 
 	return err;
 }
 
-static int chacha20_neon(struct skcipher_request *req)
+static int chacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
 	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
@@ -93,12 +95,12 @@ static int chacha20_neon(struct skcipher_request *req)
 		return crypto_chacha_crypt(req);
 
 	kernel_neon_begin();
-	err = chacha20_neon_stream_xor(req, ctx, req->iv);
+	err = chacha_neon_stream_xor(req, ctx, req->iv);
 	kernel_neon_end();
 	return err;
 }
 
-static int xchacha20_neon(struct skcipher_request *req)
+static int xchacha_neon(struct skcipher_request *req)
 {
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
 	struct chacha_ctx *ctx = crypto_skcipher_ctx(tfm);
@@ -114,10 +116,11 @@ static int xchacha20_neon(struct skcipher_request *req)
 
 	kernel_neon_begin();
 
-	hchacha20_block_neon(state, subctx.key);
+	hchacha_block_neon(state, subctx.key, ctx->nrounds);
+	subctx.nrounds = ctx->nrounds;
 	memcpy(&real_iv[0], req->iv + 24, 8);
 	memcpy(&real_iv[8], req->iv + 16, 8);
-	err = chacha20_neon_stream_xor(req, &subctx, real_iv);
+	err = chacha_neon_stream_xor(req, &subctx, real_iv);
 
 	kernel_neon_end();
 
@@ -139,8 +142,8 @@ static struct skcipher_alg algs[] = {
 		.chunksize		= CHACHA_BLOCK_SIZE,
 		.walksize		= 4 * CHACHA_BLOCK_SIZE,
 		.setkey			= crypto_chacha20_setkey,
-		.encrypt		= chacha20_neon,
-		.decrypt		= chacha20_neon,
+		.encrypt		= chacha_neon,
+		.decrypt		= chacha_neon,
 	}, {
 		.base.cra_name		= "xchacha20",
 		.base.cra_driver_name	= "xchacha20-neon",
@@ -155,12 +158,12 @@ static struct skcipher_alg algs[] = {
 		.chunksize		= CHACHA_BLOCK_SIZE,
 		.walksize		= 4 * CHACHA_BLOCK_SIZE,
 		.setkey			= crypto_chacha20_setkey,
-		.encrypt		= xchacha20_neon,
-		.decrypt		= xchacha20_neon,
+		.encrypt		= xchacha_neon,
+		.decrypt		= xchacha_neon,
 	}
 };
 
-static int __init chacha20_simd_mod_init(void)
+static int __init chacha_simd_mod_init(void)
 {
 	if (!(elf_hwcap & HWCAP_NEON))
 		return -ENODEV;
@@ -168,14 +171,15 @@ static int __init chacha20_simd_mod_init(void)
 	return crypto_register_skciphers(algs, ARRAY_SIZE(algs));
 }
 
-static void __exit chacha20_simd_mod_fini(void)
+static void __exit chacha_simd_mod_fini(void)
 {
 	crypto_unregister_skciphers(algs, ARRAY_SIZE(algs));
 }
 
-module_init(chacha20_simd_mod_init);
-module_exit(chacha20_simd_mod_fini);
+module_init(chacha_simd_mod_init);
+module_exit(chacha_simd_mod_fini);
 
+MODULE_DESCRIPTION("ChaCha and XChaCha stream ciphers (NEON accelerated)");
 MODULE_AUTHOR("Ard Biesheuvel <ard.biesheuvel@linaro.org>");
 MODULE_LICENSE("GPL v2");
 MODULE_ALIAS_CRYPTO("chacha20");
-- 
2.19.1.331.ge82ca0e54c-goog
