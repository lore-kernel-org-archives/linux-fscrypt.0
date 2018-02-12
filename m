Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:40598 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932735AbeBLX4J (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Feb 2018 18:56:09 -0500
Received: by mail-it0-f50.google.com with SMTP id v186so3501256itc.5
        for <linux-fscrypt@vger.kernel.org>; Mon, 12 Feb 2018 15:56:08 -0800 (PST)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v2 3/5] crypto: arm/speck - add NEON-accelerated implementation of Speck-XTS
Date: Mon, 12 Feb 2018 15:52:07 -0800
Message-Id: <20180212235209.117393-4-ebiggers@google.com>
In-Reply-To: <20180212235209.117393-1-ebiggers@google.com>
References: <20180212235209.117393-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Add an ARM NEON-accelerated implementation of Speck-XTS.  It operates on
128-byte chunks at a time, i.e. 8 blocks for Speck128 or 16 blocks for
Speck64.  Each 128-byte chunk goes through XTS preprocessing, then is
encrypted/decrypted (doing one cipher round for all the blocks, then the
next round, etc.), then goes through XTS postprocessing.

The performance depends on the processor but can be about 3 times faster
than the generic code.  For example, on an ARMv7 processor we observe
the following performance with Speck128/256-XTS:

    xts-speck128-neon:     Encryption 107.9 MB/s, Decryption 108.1 MB/s
    xts(speck128-generic): Encryption  32.1 MB/s, Decryption  36.6 MB/s

In comparison to AES-256-XTS without the Cryptography Extensions:

    xts-aes-neonbs:        Encryption  41.2 MB/s, Decryption  36.7 MB/s
    xts(aes-asm):          Encryption  31.7 MB/s, Decryption  30.8 MB/s
    xts(aes-generic):      Encryption  21.2 MB/s, Decryption  20.9 MB/s

Speck64/128-XTS is even faster:

    xts-speck64-neon:      Encryption 138.6 MB/s, Decryption 139.1 MB/s

Note that as with the generic code, only the Speck128 and Speck64
variants are supported.  Also, for now only the XTS mode of operation is
supported, to target the disk and file encryption use cases.  The NEON
code also only handles the portion of the data that is evenly divisible
into 128-byte chunks, with any remainder handled by a C fallback.  Of
course, other modes of operation could be added later if needed, and/or
the NEON code could be updated to handle other buffer sizes.

The XTS specification is only defined for AES which has a 128-bit block
size, so for the GF(2^64) math needed for Speck64-XTS we use the
reducing polynomial 'x^64 + x^4 + x^3 + x + 1' given by the original XEX
paper.  Of course, when possible users should use Speck128-XTS, but even
that may be too slow on some processors; Speck64-XTS can be faster.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/arm/crypto/Kconfig           |   6 +
 arch/arm/crypto/Makefile          |   2 +
 arch/arm/crypto/speck-neon-core.S | 432 ++++++++++++++++++++++++++++++++++++++
 arch/arm/crypto/speck-neon-glue.c | 290 +++++++++++++++++++++++++
 4 files changed, 730 insertions(+)
 create mode 100644 arch/arm/crypto/speck-neon-core.S
 create mode 100644 arch/arm/crypto/speck-neon-glue.c

diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
index b8e69fe282b8..925d1364727a 100644
--- a/arch/arm/crypto/Kconfig
+++ b/arch/arm/crypto/Kconfig
@@ -121,4 +121,10 @@ config CRYPTO_CHACHA20_NEON
 	select CRYPTO_BLKCIPHER
 	select CRYPTO_CHACHA20
 
+config CRYPTO_SPECK_NEON
+	tristate "NEON accelerated Speck cipher algorithms"
+	depends on KERNEL_MODE_NEON
+	select CRYPTO_BLKCIPHER
+	select CRYPTO_SPECK
+
 endif
diff --git a/arch/arm/crypto/Makefile b/arch/arm/crypto/Makefile
index 30ef8e291271..a758107c5525 100644
--- a/arch/arm/crypto/Makefile
+++ b/arch/arm/crypto/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_CRYPTO_SHA1_ARM_NEON) += sha1-arm-neon.o
 obj-$(CONFIG_CRYPTO_SHA256_ARM) += sha256-arm.o
 obj-$(CONFIG_CRYPTO_SHA512_ARM) += sha512-arm.o
 obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha20-neon.o
+obj-$(CONFIG_CRYPTO_SPECK_NEON) += speck-neon.o
 
 ce-obj-$(CONFIG_CRYPTO_AES_ARM_CE) += aes-arm-ce.o
 ce-obj-$(CONFIG_CRYPTO_SHA1_ARM_CE) += sha1-arm-ce.o
@@ -53,6 +54,7 @@ ghash-arm-ce-y	:= ghash-ce-core.o ghash-ce-glue.o
 crct10dif-arm-ce-y	:= crct10dif-ce-core.o crct10dif-ce-glue.o
 crc32-arm-ce-y:= crc32-ce-core.o crc32-ce-glue.o
 chacha20-neon-y := chacha20-neon-core.o chacha20-neon-glue.o
+speck-neon-y := speck-neon-core.o speck-neon-glue.o
 
 quiet_cmd_perl = PERL    $@
       cmd_perl = $(PERL) $(<) > $(@)
diff --git a/arch/arm/crypto/speck-neon-core.S b/arch/arm/crypto/speck-neon-core.S
new file mode 100644
index 000000000000..3c1e203e53b9
--- /dev/null
+++ b/arch/arm/crypto/speck-neon-core.S
@@ -0,0 +1,432 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
+ *
+ * Copyright (c) 2018 Google, Inc
+ *
+ * Author: Eric Biggers <ebiggers@google.com>
+ */
+
+#include <linux/linkage.h>
+
+	.text
+	.fpu		neon
+
+	// arguments
+	ROUND_KEYS	.req	r0	// const {u64,u32} *round_keys
+	NROUNDS		.req	r1	// int nrounds
+	DST		.req	r2	// void *dst
+	SRC		.req	r3	// const void *src
+	NBYTES		.req	r4	// unsigned int nbytes
+	TWEAK		.req	r5	// void *tweak
+
+	// registers which hold the data being encrypted/decrypted
+	X0		.req	q0
+	X0_L		.req	d0
+	X0_H		.req	d1
+	Y0		.req	q1
+	Y0_H		.req	d3
+	X1		.req	q2
+	X1_L		.req	d4
+	X1_H		.req	d5
+	Y1		.req	q3
+	Y1_H		.req	d7
+	X2		.req	q4
+	X2_L		.req	d8
+	X2_H		.req	d9
+	Y2		.req	q5
+	Y2_H		.req	d11
+	X3		.req	q6
+	X3_L		.req	d12
+	X3_H		.req	d13
+	Y3		.req	q7
+	Y3_H		.req	d15
+
+	// the round key, duplicated in all lanes
+	ROUND_KEY	.req	q8
+	ROUND_KEY_L	.req	d16
+	ROUND_KEY_H	.req	d17
+
+	// index vector for vtbl-based 8-bit rotates
+	ROTATE_TABLE	.req	d18
+
+	// multiplication table for updating XTS tweaks
+	GF128MUL_TABLE	.req	d19
+	GF64MUL_TABLE	.req	d19
+
+	// current XTS tweak value(s)
+	TWEAKV		.req	q10
+	TWEAKV_L	.req	d20
+	TWEAKV_H	.req	d21
+
+	TMP0		.req	q12
+	TMP0_L		.req	d24
+	TMP0_H		.req	d25
+	TMP1		.req	q13
+	TMP2		.req	q14
+	TMP3		.req	q15
+
+	.align		4
+.Lror64_8_table:
+	.byte		1, 2, 3, 4, 5, 6, 7, 0
+.Lror32_8_table:
+	.byte		1, 2, 3, 0, 5, 6, 7, 4
+.Lrol64_8_table:
+	.byte		7, 0, 1, 2, 3, 4, 5, 6
+.Lrol32_8_table:
+	.byte		3, 0, 1, 2, 7, 4, 5, 6
+.Lgf128mul_table:
+	.byte		0, 0x87
+	.fill		14
+.Lgf64mul_table:
+	.byte		0, 0x1b, (0x1b << 1), (0x1b << 1) ^ 0x1b
+	.fill		12
+
+/*
+ * _speck_round_128bytes() - Speck encryption round on 128 bytes at a time
+ *
+ * Do one Speck encryption round on the 128 bytes (8 blocks for Speck128, 16 for
+ * Speck64) stored in X0-X3 and Y0-Y3, using the round key stored in all lanes
+ * of ROUND_KEY.  'n' is the lane size: 64 for Speck128, or 32 for Speck64.
+ *
+ * The 8-bit rotates are implemented using vtbl instead of vshr + vsli because
+ * the vtbl approach is faster on some processors and the same speed on others.
+ */
+.macro _speck_round_128bytes	n
+
+	// x = ror(x, 8)
+	vtbl.8		X0_L, {X0_L}, ROTATE_TABLE
+	vtbl.8		X0_H, {X0_H}, ROTATE_TABLE
+	vtbl.8		X1_L, {X1_L}, ROTATE_TABLE
+	vtbl.8		X1_H, {X1_H}, ROTATE_TABLE
+	vtbl.8		X2_L, {X2_L}, ROTATE_TABLE
+	vtbl.8		X2_H, {X2_H}, ROTATE_TABLE
+	vtbl.8		X3_L, {X3_L}, ROTATE_TABLE
+	vtbl.8		X3_H, {X3_H}, ROTATE_TABLE
+
+	// x += y
+	vadd.u\n	X0, Y0
+	vadd.u\n	X1, Y1
+	vadd.u\n	X2, Y2
+	vadd.u\n	X3, Y3
+
+	// x ^= k
+	veor		X0, ROUND_KEY
+	veor		X1, ROUND_KEY
+	veor		X2, ROUND_KEY
+	veor		X3, ROUND_KEY
+
+	// y = rol(y, 3)
+	vshl.u\n	TMP0, Y0, #3
+	vshl.u\n	TMP1, Y1, #3
+	vshl.u\n	TMP2, Y2, #3
+	vshl.u\n	TMP3, Y3, #3
+	vsri.u\n	TMP0, Y0, #(\n - 3)
+	vsri.u\n	TMP1, Y1, #(\n - 3)
+	vsri.u\n	TMP2, Y2, #(\n - 3)
+	vsri.u\n	TMP3, Y3, #(\n - 3)
+
+	// y ^= x
+	veor		Y0, TMP0, X0
+	veor		Y1, TMP1, X1
+	veor		Y2, TMP2, X2
+	veor		Y3, TMP3, X3
+.endm
+
+/*
+ * _speck_unround_128bytes() - Speck decryption round on 128 bytes at a time
+ *
+ * This is the inverse of _speck_round_128bytes().
+ */
+.macro _speck_unround_128bytes	n
+
+	// y ^= x
+	veor		TMP0, Y0, X0
+	veor		TMP1, Y1, X1
+	veor		TMP2, Y2, X2
+	veor		TMP3, Y3, X3
+
+	// y = ror(y, 3)
+	vshr.u\n	Y0, TMP0, #3
+	vshr.u\n	Y1, TMP1, #3
+	vshr.u\n	Y2, TMP2, #3
+	vshr.u\n	Y3, TMP3, #3
+	vsli.u\n	Y0, TMP0, #(\n - 3)
+	vsli.u\n	Y1, TMP1, #(\n - 3)
+	vsli.u\n	Y2, TMP2, #(\n - 3)
+	vsli.u\n	Y3, TMP3, #(\n - 3)
+
+	// x ^= k
+	veor		X0, ROUND_KEY
+	veor		X1, ROUND_KEY
+	veor		X2, ROUND_KEY
+	veor		X3, ROUND_KEY
+
+	// x -= y
+	vsub.u\n	X0, Y0
+	vsub.u\n	X1, Y1
+	vsub.u\n	X2, Y2
+	vsub.u\n	X3, Y3
+
+	// x = rol(x, 8);
+	vtbl.8		X0_L, {X0_L}, ROTATE_TABLE
+	vtbl.8		X0_H, {X0_H}, ROTATE_TABLE
+	vtbl.8		X1_L, {X1_L}, ROTATE_TABLE
+	vtbl.8		X1_H, {X1_H}, ROTATE_TABLE
+	vtbl.8		X2_L, {X2_L}, ROTATE_TABLE
+	vtbl.8		X2_H, {X2_H}, ROTATE_TABLE
+	vtbl.8		X3_L, {X3_L}, ROTATE_TABLE
+	vtbl.8		X3_H, {X3_H}, ROTATE_TABLE
+.endm
+
+.macro _xts128_precrypt_one	dst_reg, tweak_buf, tmp
+
+	// Load the next source block
+	vld1.8		{\dst_reg}, [SRC]!
+
+	// Save the current tweak in the tweak buffer
+	vst1.8		{TWEAKV}, [\tweak_buf:128]!
+
+	// XOR the next source block with the current tweak
+	veor		\dst_reg, TWEAKV
+
+	/*
+	 * Calculate the next tweak by multiplying the current one by x,
+	 * modulo p(x) = x^128 + x^7 + x^2 + x + 1.
+	 */
+	vshr.u64	\tmp, TWEAKV, #63
+	vshl.u64	TWEAKV, #1
+	veor		TWEAKV_H, \tmp\()_L
+	vtbl.8		\tmp\()_H, {GF128MUL_TABLE}, \tmp\()_H
+	veor		TWEAKV_L, \tmp\()_H
+.endm
+
+.macro _xts64_precrypt_two	dst_reg, tweak_buf, tmp
+
+	// Load the next two source blocks
+	vld1.8		{\dst_reg}, [SRC]!
+
+	// Save the current two tweaks in the tweak buffer
+	vst1.8		{TWEAKV}, [\tweak_buf:128]!
+
+	// XOR the next two source blocks with the current two tweaks
+	veor		\dst_reg, TWEAKV
+
+	/*
+	 * Calculate the next two tweaks by multiplying the current ones by x^2,
+	 * modulo p(x) = x^64 + x^4 + x^3 + x + 1.
+	 */
+	vshr.u64	\tmp, TWEAKV, #62
+	vshl.u64	TWEAKV, #2
+	vtbl.8		\tmp\()_L, {GF64MUL_TABLE}, \tmp\()_L
+	vtbl.8		\tmp\()_H, {GF64MUL_TABLE}, \tmp\()_H
+	veor		TWEAKV, \tmp
+.endm
+
+/*
+ * _speck_xts_crypt() - Speck-XTS encryption/decryption
+ *
+ * Encrypt or decrypt NBYTES bytes of data from the SRC buffer to the DST buffer
+ * using Speck-XTS, specifically the variant with a block size of '2n' and round
+ * count given by NROUNDS.  The expanded round keys are given in ROUND_KEYS, and
+ * the current XTS tweak value is given in TWEAK.  It's assumed that NBYTES is a
+ * nonzero multiple of 128.
+ */
+.macro _speck_xts_crypt	n, decrypting
+	push		{r4-r7}
+	mov		r7, sp
+
+	/*
+	 * The first four parameters were passed in registers r0-r3.  Load the
+	 * additional parameters, which were passed on the stack.
+	 */
+	ldr		NBYTES, [sp, #16]
+	ldr		TWEAK, [sp, #20]
+
+	/*
+	 * If decrypting, modify the ROUND_KEYS parameter to point to the last
+	 * round key rather than the first, since for decryption the round keys
+	 * are used in reverse order.
+	 */
+.if \decrypting
+.if \n == 64
+	add		ROUND_KEYS, ROUND_KEYS, NROUNDS, lsl #3
+	sub		ROUND_KEYS, #8
+.else
+	add		ROUND_KEYS, ROUND_KEYS, NROUNDS, lsl #2
+	sub		ROUND_KEYS, #4
+.endif
+.endif
+
+	// Load the index vector for vtbl-based 8-bit rotates
+.if \decrypting
+	ldr		r12, =.Lrol\n\()_8_table
+.else
+	ldr		r12, =.Lror\n\()_8_table
+.endif
+	vld1.8		{ROTATE_TABLE}, [r12:64]
+
+	// One-time XTS preparation
+
+	/*
+	 * Allocate stack space to store 128 bytes worth of tweaks.  For
+	 * performance, this space is aligned to a 16-byte boundary so that we
+	 * can use the load/store instructions that declare 16-byte alignment.
+	 */
+	sub		sp, #128
+	bic		sp, #0xf
+
+.if \n == 64
+	// Load first tweak
+	vld1.8		{TWEAKV}, [TWEAK]
+
+	// Load GF(2^128) multiplication table
+	ldr		r12, =.Lgf128mul_table
+	vld1.8		{GF128MUL_TABLE}, [r12:64]
+.else
+	// Load first tweak
+	vld1.8		{TWEAKV_L}, [TWEAK]
+
+	// Load GF(2^64) multiplication table
+	ldr		r12, =.Lgf64mul_table
+	vld1.8		{GF64MUL_TABLE}, [r12:64]
+
+	// Calculate second tweak, packing it together with the first
+	vshr.u64	TMP0_L, TWEAKV_L, #63
+	vtbl.u8		TMP0_L, {GF64MUL_TABLE}, TMP0_L
+	vshl.u64	TWEAKV_H, TWEAKV_L, #1
+	veor		TWEAKV_H, TMP0_L
+.endif
+
+.Lnext_128bytes_\@:
+
+	/*
+	 * Load the source blocks into {X,Y}[0-3], XOR them with their XTS tweak
+	 * values, and save the tweaks on the stack for later.  Then
+	 * de-interleave the 'x' and 'y' elements of each block, i.e. make it so
+	 * that the X[0-3] registers contain only the second halves of blocks,
+	 * and the Y[0-3] registers contain only the first halves of blocks.
+	 * (Speck uses the order (y, x) rather than the more intuitive (x, y).)
+	 */
+	mov		r12, sp
+.if \n == 64
+	_xts128_precrypt_one	X0, r12, TMP0
+	_xts128_precrypt_one	Y0, r12, TMP0
+	_xts128_precrypt_one	X1, r12, TMP0
+	_xts128_precrypt_one	Y1, r12, TMP0
+	_xts128_precrypt_one	X2, r12, TMP0
+	_xts128_precrypt_one	Y2, r12, TMP0
+	_xts128_precrypt_one	X3, r12, TMP0
+	_xts128_precrypt_one	Y3, r12, TMP0
+	vswp		X0_L, Y0_H
+	vswp		X1_L, Y1_H
+	vswp		X2_L, Y2_H
+	vswp		X3_L, Y3_H
+.else
+	_xts64_precrypt_two	X0, r12, TMP0
+	_xts64_precrypt_two	Y0, r12, TMP0
+	_xts64_precrypt_two	X1, r12, TMP0
+	_xts64_precrypt_two	Y1, r12, TMP0
+	_xts64_precrypt_two	X2, r12, TMP0
+	_xts64_precrypt_two	Y2, r12, TMP0
+	_xts64_precrypt_two	X3, r12, TMP0
+	_xts64_precrypt_two	Y3, r12, TMP0
+	vuzp.32		Y0, X0
+	vuzp.32		Y1, X1
+	vuzp.32		Y2, X2
+	vuzp.32		Y3, X3
+.endif
+
+	// Do the cipher rounds
+
+	mov		r12, ROUND_KEYS
+	mov		r6, NROUNDS
+
+.Lnext_round_\@:
+.if \decrypting
+.if \n == 64
+	vld1.64		ROUND_KEY_L, [r12]
+	sub		r12, #8
+	vmov		ROUND_KEY_H, ROUND_KEY_L
+.else
+	vld1.32		{ROUND_KEY_L[],ROUND_KEY_H[]}, [r12]
+	sub		r12, #4
+.endif
+	_speck_unround_128bytes	\n
+.else
+.if \n == 64
+	vld1.64		ROUND_KEY_L, [r12]!
+	vmov		ROUND_KEY_H, ROUND_KEY_L
+.else
+	vld1.32		{ROUND_KEY_L[],ROUND_KEY_H[]}, [r12]!
+.endif
+	_speck_round_128bytes	\n
+.endif
+	subs		r6, r6, #1
+	bne		.Lnext_round_\@
+
+	// Re-interleave the 'x' and 'y' elements of each block
+.if \n == 64
+	vswp		X0_L, Y0_H
+	vswp		X1_L, Y1_H
+	vswp		X2_L, Y2_H
+	vswp		X3_L, Y3_H
+.else
+	vzip.32		Y0, X0
+	vzip.32		Y1, X1
+	vzip.32		Y2, X2
+	vzip.32		Y3, X3
+.endif
+
+	// XOR the encrypted/decrypted blocks with the tweaks we saved earlier
+	mov		r12, sp
+	vld1.8		{TMP0, TMP1}, [r12:128]!
+	vld1.8		{TMP2, TMP3}, [r12:128]!
+	veor		X0, TMP0
+	veor		Y0, TMP1
+	veor		X1, TMP2
+	veor		Y1, TMP3
+	vld1.8		{TMP0, TMP1}, [r12:128]!
+	vld1.8		{TMP2, TMP3}, [r12:128]!
+	veor		X2, TMP0
+	veor		Y2, TMP1
+	veor		X3, TMP2
+	veor		Y3, TMP3
+
+	// Store the ciphertext in the destination buffer
+	vst1.8		{X0, Y0}, [DST]!
+	vst1.8		{X1, Y1}, [DST]!
+	vst1.8		{X2, Y2}, [DST]!
+	vst1.8		{X3, Y3}, [DST]!
+
+	// Continue if there are more 128-byte chunks remaining, else return
+	subs		NBYTES, #128
+	bne		.Lnext_128bytes_\@
+
+	// Store the next tweak
+.if \n == 64
+	vst1.8		{TWEAKV}, [TWEAK]
+.else
+	vst1.8		{TWEAKV_L}, [TWEAK]
+.endif
+
+	mov		sp, r7
+	pop		{r4-r7}
+	bx		lr
+.endm
+
+ENTRY(speck128_xts_encrypt_neon)
+	_speck_xts_crypt	n=64, decrypting=0
+ENDPROC(speck128_xts_encrypt_neon)
+
+ENTRY(speck128_xts_decrypt_neon)
+	_speck_xts_crypt	n=64, decrypting=1
+ENDPROC(speck128_xts_decrypt_neon)
+
+ENTRY(speck64_xts_encrypt_neon)
+	_speck_xts_crypt	n=32, decrypting=0
+ENDPROC(speck64_xts_encrypt_neon)
+
+ENTRY(speck64_xts_decrypt_neon)
+	_speck_xts_crypt	n=32, decrypting=1
+ENDPROC(speck64_xts_decrypt_neon)
diff --git a/arch/arm/crypto/speck-neon-glue.c b/arch/arm/crypto/speck-neon-glue.c
new file mode 100644
index 000000000000..3987dd6e063e
--- /dev/null
+++ b/arch/arm/crypto/speck-neon-glue.c
@@ -0,0 +1,290 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
+ *
+ * Copyright (c) 2018 Google, Inc
+ *
+ * Note: the NIST recommendation for XTS only specifies a 128-bit block size,
+ * but a 64-bit version (needed for Speck64) is fairly straightforward; the math
+ * is just done in GF(2^64) instead of GF(2^128), with the reducing polynomial
+ * x^64 + x^4 + x^3 + x + 1 from the original XEX paper (Rogaway, 2004:
+ * "Efficient Instantiations of Tweakable Blockciphers and Refinements to Modes
+ * OCB and PMAC"), represented as 0x1B.
+ */
+
+#include <asm/hwcap.h>
+#include <asm/neon.h>
+#include <asm/simd.h>
+#include <crypto/algapi.h>
+#include <crypto/gf128mul.h>
+#include <crypto/internal/skcipher.h>
+#include <crypto/speck.h>
+#include <crypto/xts.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+/* The assembly functions only handle multiples of 128 bytes */
+#define SPECK_NEON_CHUNK_SIZE	128
+
+/* Speck128 */
+
+struct speck128_xts_tfm_ctx {
+	struct speck128_tfm_ctx main_key;
+	struct speck128_tfm_ctx tweak_key;
+};
+
+asmlinkage void speck128_xts_encrypt_neon(const u64 *round_keys, int nrounds,
+					  void *dst, const void *src,
+					  unsigned int nbytes, void *tweak);
+
+asmlinkage void speck128_xts_decrypt_neon(const u64 *round_keys, int nrounds,
+					  void *dst, const void *src,
+					  unsigned int nbytes, void *tweak);
+
+typedef void (*speck128_crypt_one_t)(const struct speck128_tfm_ctx *,
+				     u8 *, const u8 *);
+typedef void (*speck128_xts_crypt_many_t)(const u64 *, int, void *,
+					  const void *, unsigned int, void *);
+
+
+static __always_inline int
+__speck128_xts_crypt(struct skcipher_request *req,
+		     speck128_crypt_one_t crypt_one,
+		     speck128_xts_crypt_many_t crypt_many)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	const struct speck128_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct skcipher_walk walk;
+	le128 tweak;
+	int err;
+
+	err = skcipher_walk_virt(&walk, req, true);
+
+	crypto_speck128_encrypt(&ctx->tweak_key, (u8 *)&tweak, walk.iv);
+
+	while (walk.nbytes > 0) {
+		unsigned int nbytes = walk.nbytes;
+		u8 *dst = walk.dst.virt.addr;
+		const u8 *src = walk.src.virt.addr;
+
+		if (nbytes >= SPECK_NEON_CHUNK_SIZE && may_use_simd()) {
+			unsigned int count;
+
+			count = round_down(nbytes, SPECK_NEON_CHUNK_SIZE);
+			kernel_neon_begin();
+			(*crypt_many)(ctx->main_key.round_keys,
+				      ctx->main_key.nrounds,
+				      dst, src, count, &tweak);
+			kernel_neon_end();
+			dst += count;
+			src += count;
+			nbytes -= count;
+		}
+
+		/* Handle any remainder with generic code */
+		while (nbytes >= sizeof(le128)) {
+			le128_xor((le128 *)dst, (const le128 *)src, &tweak);
+			(*crypt_one)(&ctx->main_key, dst, dst);
+			le128_xor((le128 *)dst, (const le128 *)dst, &tweak);
+			gf128mul_x_ble(&tweak, &tweak);
+
+			dst += sizeof(le128);
+			src += sizeof(le128);
+			nbytes -= sizeof(le128);
+		}
+		err = skcipher_walk_done(&walk, nbytes);
+	}
+
+	return err;
+}
+
+static int speck128_xts_encrypt(struct skcipher_request *req)
+{
+	return __speck128_xts_crypt(req, crypto_speck128_encrypt,
+				    speck128_xts_encrypt_neon);
+
+}
+
+static int speck128_xts_decrypt(struct skcipher_request *req)
+{
+	return __speck128_xts_crypt(req, crypto_speck128_decrypt,
+				    speck128_xts_decrypt_neon);
+}
+
+static int speck128_xts_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			       unsigned int keylen)
+{
+	struct speck128_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
+	int err;
+
+	err = xts_verify_key(tfm, key, keylen);
+	if (err)
+		return err;
+
+	keylen /= 2;
+
+	err = crypto_speck128_setkey(&ctx->main_key, key, keylen);
+	if (err)
+		return err;
+
+	return crypto_speck128_setkey(&ctx->tweak_key, key + keylen, keylen);
+}
+
+/* Speck64 */
+
+struct speck64_xts_tfm_ctx {
+	struct speck64_tfm_ctx main_key;
+	struct speck64_tfm_ctx tweak_key;
+};
+
+asmlinkage void speck64_xts_encrypt_neon(const u32 *round_keys, int nrounds,
+					 void *dst, const void *src,
+					 unsigned int nbytes, void *tweak);
+
+asmlinkage void speck64_xts_decrypt_neon(const u32 *round_keys, int nrounds,
+					 void *dst, const void *src,
+					 unsigned int nbytes, void *tweak);
+
+typedef void (*speck64_crypt_one_t)(const struct speck64_tfm_ctx *,
+				    u8 *, const u8 *);
+typedef void (*speck64_xts_crypt_many_t)(const u32 *, int, void *,
+					 const void *, unsigned int, void *);
+
+static __always_inline int
+__speck64_xts_crypt(struct skcipher_request *req, speck64_crypt_one_t crypt_one,
+		    speck64_xts_crypt_many_t crypt_many)
+{
+	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
+	const struct speck64_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
+	struct skcipher_walk walk;
+	u64 tweak;
+	int err;
+
+	err = skcipher_walk_virt(&walk, req, true);
+
+	crypto_speck64_encrypt(&ctx->tweak_key, (u8 *)&tweak, walk.iv);
+
+	while (walk.nbytes > 0) {
+		unsigned int nbytes = walk.nbytes;
+		u8 *dst = walk.dst.virt.addr;
+		const u8 *src = walk.src.virt.addr;
+
+		if (nbytes >= SPECK_NEON_CHUNK_SIZE && may_use_simd()) {
+			unsigned int count;
+
+			count = round_down(nbytes, SPECK_NEON_CHUNK_SIZE);
+			kernel_neon_begin();
+			(*crypt_many)(ctx->main_key.round_keys,
+				      ctx->main_key.nrounds,
+				      dst, src, count, &tweak);
+			kernel_neon_end();
+			dst += count;
+			src += count;
+			nbytes -= count;
+		}
+
+		/* Handle any remainder with generic code */
+		while (nbytes >= sizeof(u64)) {
+			*(u64 *)dst = *(u64 *)src ^ tweak;
+			(*crypt_one)(&ctx->main_key, dst, dst);
+			*(u64 *)dst ^= tweak;
+			tweak = (tweak << 1) ^
+				((tweak & (1ULL << 63)) ? 0x1B : 0);
+
+			dst += sizeof(u64);
+			src += sizeof(u64);
+			nbytes -= sizeof(u64);
+		}
+		err = skcipher_walk_done(&walk, nbytes);
+	}
+
+	return err;
+}
+
+static int speck64_xts_encrypt(struct skcipher_request *req)
+{
+	return __speck64_xts_crypt(req, crypto_speck64_encrypt,
+				   speck64_xts_encrypt_neon);
+}
+
+static int speck64_xts_decrypt(struct skcipher_request *req)
+{
+	return __speck64_xts_crypt(req, crypto_speck64_decrypt,
+				   speck64_xts_decrypt_neon);
+}
+
+static int speck64_xts_setkey(struct crypto_skcipher *tfm, const u8 *key,
+			      unsigned int keylen)
+{
+	struct speck64_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
+	int err;
+
+	err = xts_verify_key(tfm, key, keylen);
+	if (err)
+		return err;
+
+	keylen /= 2;
+
+	err = crypto_speck64_setkey(&ctx->main_key, key, keylen);
+	if (err)
+		return err;
+
+	return crypto_speck64_setkey(&ctx->tweak_key, key + keylen, keylen);
+}
+
+static struct skcipher_alg speck_algs[] = {
+	{
+		.base.cra_name		= "xts(speck128)",
+		.base.cra_driver_name	= "xts-speck128-neon",
+		.base.cra_priority	= 300,
+		.base.cra_blocksize	= SPECK128_BLOCK_SIZE,
+		.base.cra_ctxsize	= sizeof(struct speck128_xts_tfm_ctx),
+		.base.cra_alignmask	= 7,
+		.base.cra_module	= THIS_MODULE,
+		.min_keysize		= 2 * SPECK128_128_KEY_SIZE,
+		.max_keysize		= 2 * SPECK128_256_KEY_SIZE,
+		.ivsize			= SPECK128_BLOCK_SIZE,
+		.walksize		= SPECK_NEON_CHUNK_SIZE,
+		.setkey			= speck128_xts_setkey,
+		.encrypt		= speck128_xts_encrypt,
+		.decrypt		= speck128_xts_decrypt,
+	}, {
+		.base.cra_name		= "xts(speck64)",
+		.base.cra_driver_name	= "xts-speck64-neon",
+		.base.cra_priority	= 300,
+		.base.cra_blocksize	= SPECK64_BLOCK_SIZE,
+		.base.cra_ctxsize	= sizeof(struct speck64_xts_tfm_ctx),
+		.base.cra_alignmask	= 7,
+		.base.cra_module	= THIS_MODULE,
+		.min_keysize		= 2 * SPECK64_96_KEY_SIZE,
+		.max_keysize		= 2 * SPECK64_128_KEY_SIZE,
+		.ivsize			= SPECK64_BLOCK_SIZE,
+		.walksize		= SPECK_NEON_CHUNK_SIZE,
+		.setkey			= speck64_xts_setkey,
+		.encrypt		= speck64_xts_encrypt,
+		.decrypt		= speck64_xts_decrypt,
+	}
+};
+
+static int __init speck_neon_module_init(void)
+{
+	if (!(elf_hwcap & HWCAP_NEON))
+		return -ENODEV;
+	return crypto_register_skciphers(speck_algs, ARRAY_SIZE(speck_algs));
+}
+
+static void __exit speck_neon_module_exit(void)
+{
+	crypto_unregister_skciphers(speck_algs, ARRAY_SIZE(speck_algs));
+}
+
+module_init(speck_neon_module_init);
+module_exit(speck_neon_module_exit);
+
+MODULE_DESCRIPTION("Speck block cipher (NEON-accelerated)");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
+MODULE_ALIAS_CRYPTO("xts(speck128)");
+MODULE_ALIAS_CRYPTO("xts-speck128-neon");
+MODULE_ALIAS_CRYPTO("xts(speck64)");
+MODULE_ALIAS_CRYPTO("xts-speck64-neon");
-- 
2.16.0.rc1.238.g530d649a79-goog

