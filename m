Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:37580 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750933AbeCFMfL (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Mar 2018 07:35:11 -0500
Date: Tue, 6 Mar 2018 12:35:06 +0000
From: Dave Martin <Dave.Martin@arm.com>
Subject: Re: [RFC PATCH] crypto: arm64/speck - add NEON-accelerated
 implementation of Speck-XTS
Message-ID: <20180306123505.GK32331@e103592.cambridge.arm.com>
References: <20180305191707.143961-1-ebiggers@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305191707.143961-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Michael Halcrow <mhalcrow@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 05, 2018 at 11:17:07AM -0800, Eric Biggers wrote:
> Add a NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
> for ARM64.  This is ported from the 32-bit version.  It may be useful on
> devices with 64-bit ARM CPUs that don't have the Cryptography
> Extensions, so cannot do AES efficiently -- e.g. the Cortex-A53
> processor on the Raspberry Pi 3.
> 
> It generally works the same way as the 32-bit version, but there are
> some slight differences due to the different instructions, registers,
> and syntax available in ARM64 vs. in ARM32.  For example, in the 64-bit
> version there are enough registers to hold the XTS tweaks for each
> 128-byte chunk, so they don't need to be saved on the stack.
> 
> Benchmarks on a Raspberry Pi 3 running a 64-bit kernel:
> 
>    Algorithm                              Encryption     Decryption
>    ---------                              ----------     ----------
>    Speck64/128-XTS (NEON)                 92.2 MB/s      92.2 MB/s
>    Speck128/256-XTS (NEON)                75.0 MB/s      75.0 MB/s
>    Speck128/256-XTS (generic)             47.4 MB/s      35.6 MB/s
>    AES-128-XTS (NEON bit-sliced)          33.4 MB/s      29.6 MB/s
>    AES-256-XTS (NEON bit-sliced)          24.6 MB/s      21.7 MB/s
> 
> The code performs well on higher-end ARM64 processors as well, though
> such processors tend to have the Crypto Extensions which make AES
> preferred.  For example, here are the same benchmarks run on a HiKey960
> (with CPU affinity set for the A73 cores), with the Crypto Extensions
> implementation of AES-256-XTS added:
> 
>    Algorithm                              Encryption     Decryption
>    ---------                              -----------    -----------
>    AES-256-XTS (Crypto Extensions)        1273.3 MB/s    1274.7 MB/s
>    Speck64/128-XTS (NEON)                  359.8 MB/s     348.0 MB/s
>    Speck128/256-XTS (NEON)                 292.5 MB/s     286.1 MB/s
>    Speck128/256-XTS (generic)              186.3 MB/s     181.8 MB/s
>    AES-128-XTS (NEON bit-sliced)           142.0 MB/s     124.3 MB/s
>    AES-256-XTS (NEON bit-sliced)           104.7 MB/s      91.1 MB/s
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  arch/arm64/crypto/Kconfig           |   6 +
>  arch/arm64/crypto/Makefile          |   3 +
>  arch/arm64/crypto/speck-neon-core.S | 352 ++++++++++++++++++++++++++++
>  arch/arm64/crypto/speck-neon-glue.c | 282 ++++++++++++++++++++++
>  4 files changed, 643 insertions(+)
>  create mode 100644 arch/arm64/crypto/speck-neon-core.S
>  create mode 100644 arch/arm64/crypto/speck-neon-glue.c
> 
> diff --git a/arch/arm64/crypto/Kconfig b/arch/arm64/crypto/Kconfig
> index 285c36c7b408..cb5a243110c4 100644
> --- a/arch/arm64/crypto/Kconfig
> +++ b/arch/arm64/crypto/Kconfig
> @@ -113,4 +113,10 @@ config CRYPTO_AES_ARM64_BS
>  	select CRYPTO_AES_ARM64
>  	select CRYPTO_SIMD
>  
> +config CRYPTO_SPECK_NEON
> +	tristate "NEON accelerated Speck cipher algorithms"
> +	depends on KERNEL_MODE_NEON
> +	select CRYPTO_BLKCIPHER
> +	select CRYPTO_SPECK
> +
>  endif
> diff --git a/arch/arm64/crypto/Makefile b/arch/arm64/crypto/Makefile
> index cee9b8d9830b..d94ebd15a859 100644
> --- a/arch/arm64/crypto/Makefile
> +++ b/arch/arm64/crypto/Makefile
> @@ -53,6 +53,9 @@ sha512-arm64-y := sha512-glue.o sha512-core.o
>  obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha20-neon.o
>  chacha20-neon-y := chacha20-neon-core.o chacha20-neon-glue.o
>  
> +obj-$(CONFIG_CRYPTO_SPECK_NEON) += speck-neon.o
> +speck-neon-y := speck-neon-core.o speck-neon-glue.o
> +
>  obj-$(CONFIG_CRYPTO_AES_ARM64) += aes-arm64.o
>  aes-arm64-y := aes-cipher-core.o aes-cipher-glue.o
>  
> diff --git a/arch/arm64/crypto/speck-neon-core.S b/arch/arm64/crypto/speck-neon-core.S
> new file mode 100644
> index 000000000000..b14463438b09
> --- /dev/null
> +++ b/arch/arm64/crypto/speck-neon-core.S
> @@ -0,0 +1,352 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * ARM64 NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
> + *
> + * Copyright (c) 2018 Google, Inc
> + *
> + * Author: Eric Biggers <ebiggers@google.com>
> + */
> +
> +#include <linux/linkage.h>
> +
> +	.text
> +
> +	// arguments
> +	ROUND_KEYS	.req	x0	// const {u64,u32} *round_keys
> +	NROUNDS		.req	w1	// int nrounds
> +	NROUNDS_X	.req	x1
> +	DST		.req	x2	// void *dst
> +	SRC		.req	x3	// const void *src
> +	NBYTES		.req	w4	// unsigned int nbytes
> +	TWEAK		.req	x5	// void *tweak
> +
> +	// registers which hold the data being encrypted/decrypted
> +	// (underscores avoid a naming collision with ARM64 registers x0-x3)
> +	X_0		.req	v0
> +	Y_0		.req	v1
> +	X_1		.req	v2
> +	Y_1		.req	v3
> +	X_2		.req	v4
> +	Y_2		.req	v5
> +	X_3		.req	v6
> +	Y_3		.req	v7
> +
> +	// the round key, duplicated in all lanes
> +	ROUND_KEY	.req	v8
> +
> +	// index vector for tbl-based 8-bit rotates
> +	ROTATE_TABLE	.req	v9
> +	ROTATE_TABLE_Q	.req	q9
> +
> +	// temporary registers
> +	TMP0		.req	v10
> +	TMP1		.req	v11
> +	TMP2		.req	v12
> +	TMP3		.req	v13
> +
> +	// multiplication table for updating XTS tweaks
> +	GFMUL_TABLE	.req	v14
> +	GFMUL_TABLE_Q	.req	q14
> +
> +	// next XTS tweak value(s)
> +	TWEAKV_NEXT	.req	v15
> +
> +	// XTS tweaks for the blocks currently being encrypted/decrypted
> +	TWEAKV0		.req	v16
> +	TWEAKV1		.req	v17
> +	TWEAKV2		.req	v18
> +	TWEAKV3		.req	v19
> +	TWEAKV4		.req	v20
> +	TWEAKV5		.req	v21
> +	TWEAKV6		.req	v22
> +	TWEAKV7		.req	v23
> +
> +	.align		4
> +.Lror64_8_table:
> +	.octa		0x080f0e0d0c0b0a090007060504030201
> +.Lror32_8_table:
> +	.octa		0x0c0f0e0d080b0a090407060500030201
> +.Lrol64_8_table:
> +	.octa		0x0e0d0c0b0a09080f0605040302010007
> +.Lrol32_8_table:
> +	.octa		0x0e0d0c0f0a09080b0605040702010003
> +.Lgf128mul_table:
> +	.octa		0x00000000000000870000000000000001
> +.Lgf64mul_table:
> +	.octa		0x0000000000000000000000002d361b00

Won't this put the data in the image in an endianness-dependent layout?
Alternatively, if this doesn't matter, then why doesn't it matter?

(I don't claim to understand the code fully here...)

> +
> +/*
> + * _speck_round_128bytes() - Speck encryption round on 128 bytes at a time
> + *
> + * Do one Speck encryption round on the 128 bytes (8 blocks for Speck128, 16 for
> + * Speck64) stored in X0-X3 and Y0-Y3, using the round key stored in all lanes
> + * of ROUND_KEY.  'n' is the lane size: 64 for Speck128, or 32 for Speck64.
> + * 'lanes' is the lane specifier: "2d" for Speck128 or "4s" for Speck64.
> + */
> +.macro _speck_round_128bytes	n, lanes
> +
> +	// x = ror(x, 8)
> +	tbl		X_0.16b, {X_0.16b}, ROTATE_TABLE.16b
> +	tbl		X_1.16b, {X_1.16b}, ROTATE_TABLE.16b
> +	tbl		X_2.16b, {X_2.16b}, ROTATE_TABLE.16b
> +	tbl		X_3.16b, {X_3.16b}, ROTATE_TABLE.16b
> +
> +	// x += y
> +	add		X_0.\lanes, X_0.\lanes, Y_0.\lanes
> +	add		X_1.\lanes, X_1.\lanes, Y_1.\lanes
> +	add		X_2.\lanes, X_2.\lanes, Y_2.\lanes
> +	add		X_3.\lanes, X_3.\lanes, Y_3.\lanes
> +
> +	// x ^= k
> +	eor		X_0.16b, X_0.16b, ROUND_KEY.16b
> +	eor		X_1.16b, X_1.16b, ROUND_KEY.16b
> +	eor		X_2.16b, X_2.16b, ROUND_KEY.16b
> +	eor		X_3.16b, X_3.16b, ROUND_KEY.16b
> +
> +	// y = rol(y, 3)
> +	shl		TMP0.\lanes, Y_0.\lanes, #3
> +	shl		TMP1.\lanes, Y_1.\lanes, #3
> +	shl		TMP2.\lanes, Y_2.\lanes, #3
> +	shl		TMP3.\lanes, Y_3.\lanes, #3
> +	sri		TMP0.\lanes, Y_0.\lanes, #(\n - 3)
> +	sri		TMP1.\lanes, Y_1.\lanes, #(\n - 3)
> +	sri		TMP2.\lanes, Y_2.\lanes, #(\n - 3)
> +	sri		TMP3.\lanes, Y_3.\lanes, #(\n - 3)
> +
> +	// y ^= x
> +	eor		Y_0.16b, TMP0.16b, X_0.16b
> +	eor		Y_1.16b, TMP1.16b, X_1.16b
> +	eor		Y_2.16b, TMP2.16b, X_2.16b
> +	eor		Y_3.16b, TMP3.16b, X_3.16b
> +.endm
> +
> +/*
> + * _speck_unround_128bytes() - Speck decryption round on 128 bytes at a time
> + *
> + * This is the inverse of _speck_round_128bytes().
> + */
> +.macro _speck_unround_128bytes	n, lanes
> +
> +	// y ^= x
> +	eor		TMP0.16b, Y_0.16b, X_0.16b
> +	eor		TMP1.16b, Y_1.16b, X_1.16b
> +	eor		TMP2.16b, Y_2.16b, X_2.16b
> +	eor		TMP3.16b, Y_3.16b, X_3.16b
> +
> +	// y = ror(y, 3)
> +	ushr		Y_0.\lanes, TMP0.\lanes, #3
> +	ushr		Y_1.\lanes, TMP1.\lanes, #3
> +	ushr		Y_2.\lanes, TMP2.\lanes, #3
> +	ushr		Y_3.\lanes, TMP3.\lanes, #3
> +	sli		Y_0.\lanes, TMP0.\lanes, #(\n - 3)
> +	sli		Y_1.\lanes, TMP1.\lanes, #(\n - 3)
> +	sli		Y_2.\lanes, TMP2.\lanes, #(\n - 3)
> +	sli		Y_3.\lanes, TMP3.\lanes, #(\n - 3)
> +
> +	// x ^= k
> +	eor		X_0.16b, X_0.16b, ROUND_KEY.16b
> +	eor		X_1.16b, X_1.16b, ROUND_KEY.16b
> +	eor		X_2.16b, X_2.16b, ROUND_KEY.16b
> +	eor		X_3.16b, X_3.16b, ROUND_KEY.16b
> +
> +	// x -= y
> +	sub		X_0.\lanes, X_0.\lanes, Y_0.\lanes
> +	sub		X_1.\lanes, X_1.\lanes, Y_1.\lanes
> +	sub		X_2.\lanes, X_2.\lanes, Y_2.\lanes
> +	sub		X_3.\lanes, X_3.\lanes, Y_3.\lanes
> +
> +	// x = rol(x, 8)
> +	tbl		X_0.16b, {X_0.16b}, ROTATE_TABLE.16b
> +	tbl		X_1.16b, {X_1.16b}, ROTATE_TABLE.16b
> +	tbl		X_2.16b, {X_2.16b}, ROTATE_TABLE.16b
> +	tbl		X_3.16b, {X_3.16b}, ROTATE_TABLE.16b
> +.endm
> +
> +.macro _next_xts_tweak	next, cur, tmp, n
> +.if \n == 64
> +	/*
> +	 * Calculate the next tweak by multiplying the current one by x,
> +	 * modulo p(x) = x^128 + x^7 + x^2 + x + 1.
> +	 */
> +	sshr		\tmp\().2d, \cur\().2d, #63
> +	and		\tmp\().16b, \tmp\().16b, GFMUL_TABLE.16b
> +	shl		\next\().2d, \cur\().2d, #1
> +	ext		\tmp\().16b, \tmp\().16b, \tmp\().16b, #8
> +	eor		\next\().16b, \next\().16b, \tmp\().16b
> +.else
> +	/*
> +	 * Calculate the next two tweaks by multiplying the current ones by x^2,
> +	 * modulo p(x) = x^64 + x^4 + x^3 + x + 1.
> +	 */
> +	ushr		\tmp\().2d, \cur\().2d, #62
> +	shl		\next\().2d, \cur\().2d, #2
> +	tbl		\tmp\().16b, {GFMUL_TABLE.16b}, \tmp\().16b
> +	eor		\next\().16b, \next\().16b, \tmp\().16b
> +.endif
> +.endm
> +
> +/*
> + * _speck_xts_crypt() - Speck-XTS encryption/decryption
> + *
> + * Encrypt or decrypt NBYTES bytes of data from the SRC buffer to the DST buffer
> + * using Speck-XTS, specifically the variant with a block size of '2n' and round
> + * count given by NROUNDS.  The expanded round keys are given in ROUND_KEYS, and
> + * the current XTS tweak value is given in TWEAK.  It's assumed that NBYTES is a
> + * nonzero multiple of 128.
> + */
> +.macro _speck_xts_crypt	n, lanes, decrypting
> +
> +	/*
> +	 * If decrypting, modify the ROUND_KEYS parameter to point to the last
> +	 * round key rather than the first, since for decryption the round keys
> +	 * are used in reverse order.
> +	 */
> +.if \decrypting
> +	mov		NROUNDS, NROUNDS	/* zero the high 32 bits */
> +.if \n == 64
> +	add		ROUND_KEYS, ROUND_KEYS, NROUNDS_X, lsl #3
> +	sub		ROUND_KEYS, ROUND_KEYS, #8
> +.else
> +	add		ROUND_KEYS, ROUND_KEYS, NROUNDS_X, lsl #2
> +	sub		ROUND_KEYS, ROUND_KEYS, #4
> +.endif
> +.endif
> +
> +	// Load the index vector for tbl-based 8-bit rotates
> +.if \decrypting
> +	ldr		ROTATE_TABLE_Q, .Lrol\n\()_8_table
> +.else
> +	ldr		ROTATE_TABLE_Q, .Lror\n\()_8_table
> +.endif
> +
> +	// One-time XTS preparation
> +.if \n == 64
> +	// Load first tweak
> +	ld1		{TWEAKV0.16b}, [TWEAK]
> +
> +	// Load GF(2^128) multiplication table
> +	ldr		GFMUL_TABLE_Q, .Lgf128mul_table
> +.else
> +	// Load first tweak
> +	ld1		{TWEAKV0.8b}, [TWEAK]
> +
> +	// Load GF(2^64) multiplication table
> +	ldr		GFMUL_TABLE_Q, .Lgf64mul_table
> +
> +	// Calculate second tweak, packing it together with the first
> +	ushr		TMP0.2d, TWEAKV0.2d, #63
> +	shl		TMP1.2d, TWEAKV0.2d, #1
> +	tbl		TMP0.8b, {GFMUL_TABLE.16b}, TMP0.8b
> +	eor		TMP0.8b, TMP0.8b, TMP1.8b
> +	mov		TWEAKV0.d[1], TMP0.d[0]
> +.endif
> +
> +.Lnext_128bytes_\@:
> +
> +	// Calculate XTS tweaks for next 128 bytes
> +	_next_xts_tweak	TWEAKV1, TWEAKV0, TMP0, \n
> +	_next_xts_tweak	TWEAKV2, TWEAKV1, TMP0, \n
> +	_next_xts_tweak	TWEAKV3, TWEAKV2, TMP0, \n
> +	_next_xts_tweak	TWEAKV4, TWEAKV3, TMP0, \n
> +	_next_xts_tweak	TWEAKV5, TWEAKV4, TMP0, \n
> +	_next_xts_tweak	TWEAKV6, TWEAKV5, TMP0, \n
> +	_next_xts_tweak	TWEAKV7, TWEAKV6, TMP0, \n
> +	_next_xts_tweak	TWEAKV_NEXT, TWEAKV7, TMP0, \n
> +
> +	// Load the next source blocks into {X,Y}[0-3]
> +	ld1		{X_0.16b-Y_1.16b}, [SRC], #64
> +	ld1		{X_2.16b-Y_3.16b}, [SRC], #64
> +
> +	// XOR the source blocks with their XTS tweaks
> +	eor		TMP0.16b, X_0.16b, TWEAKV0.16b
> +	eor		Y_0.16b,  Y_0.16b, TWEAKV1.16b
> +	eor		TMP1.16b, X_1.16b, TWEAKV2.16b
> +	eor		Y_1.16b,  Y_1.16b, TWEAKV3.16b
> +	eor		TMP2.16b, X_2.16b, TWEAKV4.16b
> +	eor		Y_2.16b,  Y_2.16b, TWEAKV5.16b
> +	eor		TMP3.16b, X_3.16b, TWEAKV6.16b
> +	eor		Y_3.16b,  Y_3.16b, TWEAKV7.16b
> +
> +	/*
> +	 * De-interleave the 'x' and 'y' elements of each block, i.e. make it so
> +	 * that the X[0-3] registers contain only the second halves of blocks,
> +	 * and the Y[0-3] registers contain only the first halves of blocks.
> +	 * (Speck uses the order (y, x) rather than the more intuitive (x, y).)
> +	 */
> +	uzp2		X_0.\lanes, TMP0.\lanes, Y_0.\lanes
> +	uzp1		Y_0.\lanes, TMP0.\lanes, Y_0.\lanes
> +	uzp2		X_1.\lanes, TMP1.\lanes, Y_1.\lanes
> +	uzp1		Y_1.\lanes, TMP1.\lanes, Y_1.\lanes
> +	uzp2		X_2.\lanes, TMP2.\lanes, Y_2.\lanes
> +	uzp1		Y_2.\lanes, TMP2.\lanes, Y_2.\lanes
> +	uzp2		X_3.\lanes, TMP3.\lanes, Y_3.\lanes
> +	uzp1		Y_3.\lanes, TMP3.\lanes, Y_3.\lanes
> +
> +	// Do the cipher rounds
> +	mov		x6, ROUND_KEYS
> +	mov		w7, NROUNDS
> +.Lnext_round_\@:
> +.if \decrypting
> +	ld1r		{ROUND_KEY.\lanes}, [x6]
> +	sub		x6, x6, #( \n / 8 )
> +	_speck_unround_128bytes	\n, \lanes
> +.else
> +	ld1r		{ROUND_KEY.\lanes}, [x6], #( \n / 8 )
> +	_speck_round_128bytes	\n, \lanes
> +.endif
> +	subs		w7, w7, #1
> +	bne		.Lnext_round_\@
> +
> +	// Re-interleave the 'x' and 'y' elements of each block
> +	zip1		TMP0.\lanes, Y_0.\lanes, X_0.\lanes
> +	zip2		Y_0.\lanes,  Y_0.\lanes, X_0.\lanes
> +	zip1		TMP1.\lanes, Y_1.\lanes, X_1.\lanes
> +	zip2		Y_1.\lanes,  Y_1.\lanes, X_1.\lanes
> +	zip1		TMP2.\lanes, Y_2.\lanes, X_2.\lanes
> +	zip2		Y_2.\lanes,  Y_2.\lanes, X_2.\lanes
> +	zip1		TMP3.\lanes, Y_3.\lanes, X_3.\lanes
> +	zip2		Y_3.\lanes,  Y_3.\lanes, X_3.\lanes
> +
> +	// XOR the encrypted/decrypted blocks with the tweaks calculated earlier
> +	eor		X_0.16b, TMP0.16b, TWEAKV0.16b
> +	eor		Y_0.16b, Y_0.16b,  TWEAKV1.16b
> +	eor		X_1.16b, TMP1.16b, TWEAKV2.16b
> +	eor		Y_1.16b, Y_1.16b,  TWEAKV3.16b
> +	eor		X_2.16b, TMP2.16b, TWEAKV4.16b
> +	eor		Y_2.16b, Y_2.16b,  TWEAKV5.16b
> +	eor		X_3.16b, TMP3.16b, TWEAKV6.16b
> +	eor		Y_3.16b, Y_3.16b,  TWEAKV7.16b
> +	mov		TWEAKV0.16b, TWEAKV_NEXT.16b
> +
> +	// Store the ciphertext in the destination buffer
> +	st1		{X_0.16b-Y_1.16b}, [DST], #64
> +	st1		{X_2.16b-Y_3.16b}, [DST], #64
> +
> +	// Continue if there are more 128-byte chunks remaining
> +	subs		NBYTES, NBYTES, #128
> +	bne		.Lnext_128bytes_\@
> +
> +	// Store the next tweak and return
> +.if \n == 64
> +	st1		{TWEAKV_NEXT.16b}, [TWEAK]
> +.else
> +	st1		{TWEAKV_NEXT.8b}, [TWEAK]
> +.endif
> +	ret
> +.endm
> +
> +ENTRY(speck128_xts_encrypt_neon)
> +	_speck_xts_crypt	n=64, lanes=2d, decrypting=0
> +ENDPROC(speck128_xts_encrypt_neon)
> +
> +ENTRY(speck128_xts_decrypt_neon)
> +	_speck_xts_crypt	n=64, lanes=2d, decrypting=1
> +ENDPROC(speck128_xts_decrypt_neon)
> +
> +ENTRY(speck64_xts_encrypt_neon)
> +	_speck_xts_crypt	n=32, lanes=4s, decrypting=0
> +ENDPROC(speck64_xts_encrypt_neon)
> +
> +ENTRY(speck64_xts_decrypt_neon)
> +	_speck_xts_crypt	n=32, lanes=4s, decrypting=1
> +ENDPROC(speck64_xts_decrypt_neon)
> diff --git a/arch/arm64/crypto/speck-neon-glue.c b/arch/arm64/crypto/speck-neon-glue.c
> new file mode 100644
> index 000000000000..6e233aeb4ff4
> --- /dev/null
> +++ b/arch/arm64/crypto/speck-neon-glue.c
> @@ -0,0 +1,282 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
> + * (64-bit version; based on the 32-bit version)
> + *
> + * Copyright (c) 2018 Google, Inc
> + */
> +
> +#include <asm/hwcap.h>
> +#include <asm/neon.h>
> +#include <asm/simd.h>
> +#include <crypto/algapi.h>
> +#include <crypto/gf128mul.h>
> +#include <crypto/internal/skcipher.h>
> +#include <crypto/speck.h>
> +#include <crypto/xts.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +
> +/* The assembly functions only handle multiples of 128 bytes */
> +#define SPECK_NEON_CHUNK_SIZE	128
> +
> +/* Speck128 */
> +
> +struct speck128_xts_tfm_ctx {
> +	struct speck128_tfm_ctx main_key;
> +	struct speck128_tfm_ctx tweak_key;
> +};
> +
> +asmlinkage void speck128_xts_encrypt_neon(const u64 *round_keys, int nrounds,
> +					  void *dst, const void *src,
> +					  unsigned int nbytes, void *tweak);
> +
> +asmlinkage void speck128_xts_decrypt_neon(const u64 *round_keys, int nrounds,
> +					  void *dst, const void *src,
> +					  unsigned int nbytes, void *tweak);
> +
> +typedef void (*speck128_crypt_one_t)(const struct speck128_tfm_ctx *,
> +				     u8 *, const u8 *);
> +typedef void (*speck128_xts_crypt_many_t)(const u64 *, int, void *,
> +					  const void *, unsigned int, void *);
> +
> +static __always_inline int
> +__speck128_xts_crypt(struct skcipher_request *req,
> +		     speck128_crypt_one_t crypt_one,
> +		     speck128_xts_crypt_many_t crypt_many)
> +{
> +	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
> +	const struct speck128_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
> +	struct skcipher_walk walk;
> +	le128 tweak;
> +	int err;
> +
> +	err = skcipher_walk_virt(&walk, req, true);
> +
> +	crypto_speck128_encrypt(&ctx->tweak_key, (u8 *)&tweak, walk.iv);
> +
> +	while (walk.nbytes > 0) {
> +		unsigned int nbytes = walk.nbytes;
> +		u8 *dst = walk.dst.virt.addr;
> +		const u8 *src = walk.src.virt.addr;
> +
> +		if (nbytes >= SPECK_NEON_CHUNK_SIZE && may_use_simd()) {
> +			unsigned int count;
> +
> +			count = round_down(nbytes, SPECK_NEON_CHUNK_SIZE);
> +			kernel_neon_begin();
> +			(*crypt_many)(ctx->main_key.round_keys,
> +				      ctx->main_key.nrounds,
> +				      dst, src, count, &tweak);

Nitlet: you don't really need the (* ... ) around crypt_many here.
(If you want confirmation that it doesn't do anything, try
(****crypt_many).)

> +			kernel_neon_end();
> +			dst += count;
> +			src += count;
> +			nbytes -= count;
> +		}
> +
> +		/* Handle any remainder with generic code */
> +		while (nbytes >= sizeof(tweak)) {
> +			le128_xor((le128 *)dst, (const le128 *)src, &tweak);
> +			(*crypt_one)(&ctx->main_key, dst, dst);

(Also here, and in a couple of other places for speck64.  This is just a
stylistic thing though.)

> +			le128_xor((le128 *)dst, (const le128 *)dst, &tweak);
> +			gf128mul_x_ble(&tweak, &tweak);
> +
> +			dst += sizeof(tweak);
> +			src += sizeof(tweak);
> +			nbytes -= sizeof(tweak);
> +		}
> +		err = skcipher_walk_done(&walk, nbytes);
> +	}
> +
> +	return err;
> +}
> +
> +static int speck128_xts_encrypt(struct skcipher_request *req)
> +{
> +	return __speck128_xts_crypt(req, crypto_speck128_encrypt,
> +				    speck128_xts_encrypt_neon);
> +}
> +
> +static int speck128_xts_decrypt(struct skcipher_request *req)
> +{
> +	return __speck128_xts_crypt(req, crypto_speck128_decrypt,
> +				    speck128_xts_decrypt_neon);
> +}
> +
> +static int speck128_xts_setkey(struct crypto_skcipher *tfm, const u8 *key,
> +			       unsigned int keylen)
> +{
> +	struct speck128_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
> +	int err;
> +
> +	err = xts_verify_key(tfm, key, keylen);
> +	if (err)
> +		return err;
> +
> +	keylen /= 2;
> +
> +	err = crypto_speck128_setkey(&ctx->main_key, key, keylen);
> +	if (err)
> +		return err;
> +
> +	return crypto_speck128_setkey(&ctx->tweak_key, key + keylen, keylen);
> +}
> +
> +/* Speck64 */
> +
> +struct speck64_xts_tfm_ctx {
> +	struct speck64_tfm_ctx main_key;
> +	struct speck64_tfm_ctx tweak_key;
> +};
> +
> +asmlinkage void speck64_xts_encrypt_neon(const u32 *round_keys, int nrounds,
> +					 void *dst, const void *src,
> +					 unsigned int nbytes, void *tweak);
> +
> +asmlinkage void speck64_xts_decrypt_neon(const u32 *round_keys, int nrounds,
> +					 void *dst, const void *src,
> +					 unsigned int nbytes, void *tweak);
> +
> +typedef void (*speck64_crypt_one_t)(const struct speck64_tfm_ctx *,
> +				    u8 *, const u8 *);
> +typedef void (*speck64_xts_crypt_many_t)(const u32 *, int, void *,
> +					 const void *, unsigned int, void *);
> +
> +static __always_inline int
> +__speck64_xts_crypt(struct skcipher_request *req, speck64_crypt_one_t crypt_one,
> +		    speck64_xts_crypt_many_t crypt_many)
> +{
> +	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
> +	const struct speck64_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
> +	struct skcipher_walk walk;
> +	__le64 tweak;
> +	int err;
> +
> +	err = skcipher_walk_virt(&walk, req, true);
> +
> +	crypto_speck64_encrypt(&ctx->tweak_key, (u8 *)&tweak, walk.iv);
> +
> +	while (walk.nbytes > 0) {
> +		unsigned int nbytes = walk.nbytes;
> +		u8 *dst = walk.dst.virt.addr;
> +		const u8 *src = walk.src.virt.addr;
> +
> +		if (nbytes >= SPECK_NEON_CHUNK_SIZE && may_use_simd()) {
> +			unsigned int count;
> +
> +			count = round_down(nbytes, SPECK_NEON_CHUNK_SIZE);
> +			kernel_neon_begin();
> +			(*crypt_many)(ctx->main_key.round_keys,
> +				      ctx->main_key.nrounds,
> +				      dst, src, count, &tweak);
> +			kernel_neon_end();
> +			dst += count;
> +			src += count;
> +			nbytes -= count;
> +		}
> +
> +		/* Handle any remainder with generic code */
> +		while (nbytes >= sizeof(tweak)) {
> +			*(__le64 *)dst = *(__le64 *)src ^ tweak;
> +			(*crypt_one)(&ctx->main_key, dst, dst);
> +			*(__le64 *)dst ^= tweak;
> +			tweak = cpu_to_le64((le64_to_cpu(tweak) << 1) ^
> +					    ((tweak & cpu_to_le64(1ULL << 63)) ?
> +					     0x1B : 0));
> +			dst += sizeof(tweak);
> +			src += sizeof(tweak);
> +			nbytes -= sizeof(tweak);
> +		}
> +		err = skcipher_walk_done(&walk, nbytes);
> +	}
> +
> +	return err;
> +}
> +
> +static int speck64_xts_encrypt(struct skcipher_request *req)
> +{
> +	return __speck64_xts_crypt(req, crypto_speck64_encrypt,
> +				   speck64_xts_encrypt_neon);
> +}
> +
> +static int speck64_xts_decrypt(struct skcipher_request *req)
> +{
> +	return __speck64_xts_crypt(req, crypto_speck64_decrypt,
> +				   speck64_xts_decrypt_neon);
> +}
> +
> +static int speck64_xts_setkey(struct crypto_skcipher *tfm, const u8 *key,
> +			      unsigned int keylen)
> +{
> +	struct speck64_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
> +	int err;
> +
> +	err = xts_verify_key(tfm, key, keylen);
> +	if (err)
> +		return err;
> +
> +	keylen /= 2;
> +
> +	err = crypto_speck64_setkey(&ctx->main_key, key, keylen);
> +	if (err)
> +		return err;
> +
> +	return crypto_speck64_setkey(&ctx->tweak_key, key + keylen, keylen);
> +}
> +
> +static struct skcipher_alg speck_algs[] = {
> +	{
> +		.base.cra_name		= "xts(speck128)",
> +		.base.cra_driver_name	= "xts-speck128-neon",
> +		.base.cra_priority	= 300,
> +		.base.cra_blocksize	= SPECK128_BLOCK_SIZE,
> +		.base.cra_ctxsize	= sizeof(struct speck128_xts_tfm_ctx),
> +		.base.cra_alignmask	= 7,
> +		.base.cra_module	= THIS_MODULE,
> +		.min_keysize		= 2 * SPECK128_128_KEY_SIZE,
> +		.max_keysize		= 2 * SPECK128_256_KEY_SIZE,
> +		.ivsize			= SPECK128_BLOCK_SIZE,
> +		.walksize		= SPECK_NEON_CHUNK_SIZE,
> +		.setkey			= speck128_xts_setkey,
> +		.encrypt		= speck128_xts_encrypt,
> +		.decrypt		= speck128_xts_decrypt,
> +	}, {
> +		.base.cra_name		= "xts(speck64)",
> +		.base.cra_driver_name	= "xts-speck64-neon",
> +		.base.cra_priority	= 300,
> +		.base.cra_blocksize	= SPECK64_BLOCK_SIZE,
> +		.base.cra_ctxsize	= sizeof(struct speck64_xts_tfm_ctx),
> +		.base.cra_alignmask	= 7,
> +		.base.cra_module	= THIS_MODULE,
> +		.min_keysize		= 2 * SPECK64_96_KEY_SIZE,
> +		.max_keysize		= 2 * SPECK64_128_KEY_SIZE,
> +		.ivsize			= SPECK64_BLOCK_SIZE,
> +		.walksize		= SPECK_NEON_CHUNK_SIZE,
> +		.setkey			= speck64_xts_setkey,
> +		.encrypt		= speck64_xts_encrypt,
> +		.decrypt		= speck64_xts_decrypt,
> +	}
> +};
> +
> +static int __init speck_neon_module_init(void)
> +{
> +	if (!(elf_hwcap & HWCAP_ASIMD))
> +		return -ENODEV;
> +	return crypto_register_skciphers(speck_algs, ARRAY_SIZE(speck_algs));

I haven't tried to understand everything here, but the kernel-mode NEON
integration looks OK to me.

> +}
> +
> +static void __exit speck_neon_module_exit(void)
> +{
> +	crypto_unregister_skciphers(speck_algs, ARRAY_SIZE(speck_algs));
> +}

Cheers
---Dave

> +
> +module_init(speck_neon_module_init);
> +module_exit(speck_neon_module_exit);
> +
> +MODULE_DESCRIPTION("Speck block cipher (NEON-accelerated)");
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
> +MODULE_ALIAS_CRYPTO("xts(speck128)");
> +MODULE_ALIAS_CRYPTO("xts-speck128-neon");
> +MODULE_ALIAS_CRYPTO("xts(speck64)");
> +MODULE_ALIAS_CRYPTO("xts-speck64-neon");
> -- 
> 2.16.2.395.g2e18187dfd-goog
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
