Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:44342 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933020AbeFQKlX (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 17 Jun 2018 06:41:23 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Sun, 17 Jun 2018 12:41:19 +0200
From: Stefan Agner <stefan@agner.ch>
Subject: Re: [PATCH v3 3/5] crypto: arm/speck - add NEON-accelerated
 implementation of Speck-XTS
In-Reply-To: <CAKv+Gu-J9Ho8GY4EC7k_K3Wg4W_aC2kPryMD0e0SKY+biJOdDw@mail.gmail.com>
References: <20180214184223.254359-1-ebiggers@google.com>
 <20180214184223.254359-4-ebiggers@google.com>
 <bf0d6851c95b40ca970949229e6e6a00@agner.ch>
 <CAKv+Gu_VLcp7gxH-8OY-XoHyB=SKVRYRG5D3KV_fNQ4zn4hgFQ@mail.gmail.com>
 <CAKv+Gu-J9Ho8GY4EC7k_K3Wg4W_aC2kPryMD0e0SKY+biJOdDw@mail.gmail.com>
Message-ID: <8396d433caf1155f9ca422c6bad3200b@agner.ch>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Eric Biggers <ebiggers@google.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-crypto-owner@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 17.06.2018 11:40, Ard Biesheuvel wrote:
> On 17 June 2018 at 11:30, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>> On 17 June 2018 at 00:40, Stefan Agner <stefan@agner.ch> wrote:
>>> Hi Eric,
>>>
>>> On 14.02.2018 19:42, Eric Biggers wrote:
>>>> Add an ARM NEON-accelerated implementation of Speck-XTS.  It operates on
>>>> 128-byte chunks at a time, i.e. 8 blocks for Speck128 or 16 blocks for
>>>> Speck64.  Each 128-byte chunk goes through XTS preprocessing, then is
>>>> encrypted/decrypted (doing one cipher round for all the blocks, then the
>>>> next round, etc.), then goes through XTS postprocessing.
>>>>
>>>> The performance depends on the processor but can be about 3 times faster
>>>> than the generic code.  For example, on an ARMv7 processor we observe
>>>> the following performance with Speck128/256-XTS:
>>>>
>>>>     xts-speck128-neon:     Encryption 107.9 MB/s, Decryption 108.1 MB/s
>>>>     xts(speck128-generic): Encryption  32.1 MB/s, Decryption  36.6 MB/s
>>>>
>>>> In comparison to AES-256-XTS without the Cryptography Extensions:
>>>>
>>>>     xts-aes-neonbs:        Encryption  41.2 MB/s, Decryption  36.7 MB/s
>>>>     xts(aes-asm):          Encryption  31.7 MB/s, Decryption  30.8 MB/s
>>>>     xts(aes-generic):      Encryption  21.2 MB/s, Decryption  20.9 MB/s
>>>>
>>>> Speck64/128-XTS is even faster:
>>>>
>>>>     xts-speck64-neon:      Encryption 138.6 MB/s, Decryption 139.1 MB/s
>>>>
>>>> Note that as with the generic code, only the Speck128 and Speck64
>>>> variants are supported.  Also, for now only the XTS mode of operation is
>>>> supported, to target the disk and file encryption use cases.  The NEON
>>>> code also only handles the portion of the data that is evenly divisible
>>>> into 128-byte chunks, with any remainder handled by a C fallback.  Of
>>>> course, other modes of operation could be added later if needed, and/or
>>>> the NEON code could be updated to handle other buffer sizes.
>>>>
>>>> The XTS specification is only defined for AES which has a 128-bit block
>>>> size, so for the GF(2^64) math needed for Speck64-XTS we use the
>>>> reducing polynomial 'x^64 + x^4 + x^3 + x + 1' given by the original XEX
>>>> paper.  Of course, when possible users should use Speck128-XTS, but even
>>>> that may be too slow on some processors; Speck64-XTS can be faster.
>>>>
>>>> Signed-off-by: Eric Biggers <ebiggers@google.com>
>>>> ---
>>>>  arch/arm/crypto/Kconfig           |   6 +
>>>>  arch/arm/crypto/Makefile          |   2 +
>>>>  arch/arm/crypto/speck-neon-core.S | 432 ++++++++++++++++++++++++++++++
>>>>  arch/arm/crypto/speck-neon-glue.c | 288 ++++++++++++++++++++
>>>>  4 files changed, 728 insertions(+)
>>>>  create mode 100644 arch/arm/crypto/speck-neon-core.S
>>>>  create mode 100644 arch/arm/crypto/speck-neon-glue.c
>>>>
>>>> diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
>>>> index b8e69fe282b8..925d1364727a 100644
>>>> --- a/arch/arm/crypto/Kconfig
>>>> +++ b/arch/arm/crypto/Kconfig
>>>> @@ -121,4 +121,10 @@ config CRYPTO_CHACHA20_NEON
>>>>       select CRYPTO_BLKCIPHER
>>>>       select CRYPTO_CHACHA20
>>>>
>>>> +config CRYPTO_SPECK_NEON
>>>> +     tristate "NEON accelerated Speck cipher algorithms"
>>>> +     depends on KERNEL_MODE_NEON
>>>> +     select CRYPTO_BLKCIPHER
>>>> +     select CRYPTO_SPECK
>>>> +
>>>>  endif
>>>> diff --git a/arch/arm/crypto/Makefile b/arch/arm/crypto/Makefile
>>>> index 30ef8e291271..a758107c5525 100644
>>>> --- a/arch/arm/crypto/Makefile
>>>> +++ b/arch/arm/crypto/Makefile
>>>> @@ -10,6 +10,7 @@ obj-$(CONFIG_CRYPTO_SHA1_ARM_NEON) += sha1-arm-neon.o
>>>>  obj-$(CONFIG_CRYPTO_SHA256_ARM) += sha256-arm.o
>>>>  obj-$(CONFIG_CRYPTO_SHA512_ARM) += sha512-arm.o
>>>>  obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha20-neon.o
>>>> +obj-$(CONFIG_CRYPTO_SPECK_NEON) += speck-neon.o
>>>>
>>>>  ce-obj-$(CONFIG_CRYPTO_AES_ARM_CE) += aes-arm-ce.o
>>>>  ce-obj-$(CONFIG_CRYPTO_SHA1_ARM_CE) += sha1-arm-ce.o
>>>> @@ -53,6 +54,7 @@ ghash-arm-ce-y      := ghash-ce-core.o ghash-ce-glue.o
>>>>  crct10dif-arm-ce-y   := crct10dif-ce-core.o crct10dif-ce-glue.o
>>>>  crc32-arm-ce-y:= crc32-ce-core.o crc32-ce-glue.o
>>>>  chacha20-neon-y := chacha20-neon-core.o chacha20-neon-glue.o
>>>> +speck-neon-y := speck-neon-core.o speck-neon-glue.o
>>>>
>>>>  quiet_cmd_perl = PERL    $@
>>>>        cmd_perl = $(PERL) $(<) > $(@)
>>>> diff --git a/arch/arm/crypto/speck-neon-core.S
>>>> b/arch/arm/crypto/speck-neon-core.S
>>>> new file mode 100644
>>>> index 000000000000..3c1e203e53b9
>>>> --- /dev/null
>>>> +++ b/arch/arm/crypto/speck-neon-core.S
>>>> @@ -0,0 +1,432 @@
>>>> +// SPDX-License-Identifier: GPL-2.0
>>>> +/*
>>>> + * NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
>>>> + *
>>>> + * Copyright (c) 2018 Google, Inc
>>>> + *
>>>> + * Author: Eric Biggers <ebiggers@google.com>
>>>> + */
>>>> +
>>>> +#include <linux/linkage.h>
>>>> +
>>>> +     .text
>>>> +     .fpu            neon
>>>> +
>>>> +     // arguments
>>>> +     ROUND_KEYS      .req    r0      // const {u64,u32} *round_keys
>>>> +     NROUNDS         .req    r1      // int nrounds
>>>> +     DST             .req    r2      // void *dst
>>>> +     SRC             .req    r3      // const void *src
>>>> +     NBYTES          .req    r4      // unsigned int nbytes
>>>> +     TWEAK           .req    r5      // void *tweak
>>>> +
>>>> +     // registers which hold the data being encrypted/decrypted
>>>> +     X0              .req    q0
>>>> +     X0_L            .req    d0
>>>> +     X0_H            .req    d1
>>>> +     Y0              .req    q1
>>>> +     Y0_H            .req    d3
>>>> +     X1              .req    q2
>>>> +     X1_L            .req    d4
>>>> +     X1_H            .req    d5
>>>> +     Y1              .req    q3
>>>> +     Y1_H            .req    d7
>>>> +     X2              .req    q4
>>>> +     X2_L            .req    d8
>>>> +     X2_H            .req    d9
>>>> +     Y2              .req    q5
>>>> +     Y2_H            .req    d11
>>>> +     X3              .req    q6
>>>> +     X3_L            .req    d12
>>>> +     X3_H            .req    d13
>>>> +     Y3              .req    q7
>>>> +     Y3_H            .req    d15
>>>> +
>>>> +     // the round key, duplicated in all lanes
>>>> +     ROUND_KEY       .req    q8
>>>> +     ROUND_KEY_L     .req    d16
>>>> +     ROUND_KEY_H     .req    d17
>>>> +
>>>> +     // index vector for vtbl-based 8-bit rotates
>>>> +     ROTATE_TABLE    .req    d18
>>>> +
>>>> +     // multiplication table for updating XTS tweaks
>>>> +     GF128MUL_TABLE  .req    d19
>>>> +     GF64MUL_TABLE   .req    d19
>>>> +
>>>> +     // current XTS tweak value(s)
>>>> +     TWEAKV          .req    q10
>>>> +     TWEAKV_L        .req    d20
>>>> +     TWEAKV_H        .req    d21
>>>> +
>>>> +     TMP0            .req    q12
>>>> +     TMP0_L          .req    d24
>>>> +     TMP0_H          .req    d25
>>>> +     TMP1            .req    q13
>>>> +     TMP2            .req    q14
>>>> +     TMP3            .req    q15
>>>> +
>>>> +     .align          4
>>>> +.Lror64_8_table:
>>>> +     .byte           1, 2, 3, 4, 5, 6, 7, 0
>>>> +.Lror32_8_table:
>>>> +     .byte           1, 2, 3, 0, 5, 6, 7, 4
>>>> +.Lrol64_8_table:
>>>> +     .byte           7, 0, 1, 2, 3, 4, 5, 6
>>>> +.Lrol32_8_table:
>>>> +     .byte           3, 0, 1, 2, 7, 4, 5, 6
>>>> +.Lgf128mul_table:
>>>> +     .byte           0, 0x87
>>>> +     .fill           14
>>>> +.Lgf64mul_table:
>>>> +     .byte           0, 0x1b, (0x1b << 1), (0x1b << 1) ^ 0x1b
>>>> +     .fill           12
>>>> +
>>>> +/*
>>>> + * _speck_round_128bytes() - Speck encryption round on 128 bytes at a time
>>>> + *
>>>> + * Do one Speck encryption round on the 128 bytes (8 blocks for
>>>> Speck128, 16 for
>>>> + * Speck64) stored in X0-X3 and Y0-Y3, using the round key stored in all lanes
>>>> + * of ROUND_KEY.  'n' is the lane size: 64 for Speck128, or 32 for Speck64.
>>>> + *
>>>> + * The 8-bit rotates are implemented using vtbl instead of vshr + vsli because
>>>> + * the vtbl approach is faster on some processors and the same speed on others.
>>>> + */
>>>> +.macro _speck_round_128bytes n
>>>> +
>>>> +     // x = ror(x, 8)
>>>> +     vtbl.8          X0_L, {X0_L}, ROTATE_TABLE
>>>> +     vtbl.8          X0_H, {X0_H}, ROTATE_TABLE
>>>> +     vtbl.8          X1_L, {X1_L}, ROTATE_TABLE
>>>> +     vtbl.8          X1_H, {X1_H}, ROTATE_TABLE
>>>> +     vtbl.8          X2_L, {X2_L}, ROTATE_TABLE
>>>> +     vtbl.8          X2_H, {X2_H}, ROTATE_TABLE
>>>> +     vtbl.8          X3_L, {X3_L}, ROTATE_TABLE
>>>> +     vtbl.8          X3_H, {X3_H}, ROTATE_TABLE
>>>> +
>>>> +     // x += y
>>>> +     vadd.u\n        X0, Y0
>>>> +     vadd.u\n        X1, Y1
>>>> +     vadd.u\n        X2, Y2
>>>> +     vadd.u\n        X3, Y3
>>>> +
>>>> +     // x ^= k
>>>> +     veor            X0, ROUND_KEY
>>>> +     veor            X1, ROUND_KEY
>>>> +     veor            X2, ROUND_KEY
>>>> +     veor            X3, ROUND_KEY
>>>> +
>>>> +     // y = rol(y, 3)
>>>> +     vshl.u\n        TMP0, Y0, #3
>>>> +     vshl.u\n        TMP1, Y1, #3
>>>> +     vshl.u\n        TMP2, Y2, #3
>>>> +     vshl.u\n        TMP3, Y3, #3
>>>> +     vsri.u\n        TMP0, Y0, #(\n - 3)
>>>> +     vsri.u\n        TMP1, Y1, #(\n - 3)
>>>> +     vsri.u\n        TMP2, Y2, #(\n - 3)
>>>> +     vsri.u\n        TMP3, Y3, #(\n - 3)
>>>> +
>>>> +     // y ^= x
>>>> +     veor            Y0, TMP0, X0
>>>> +     veor            Y1, TMP1, X1
>>>> +     veor            Y2, TMP2, X2
>>>> +     veor            Y3, TMP3, X3
>>>> +.endm
>>>> +
>>>> +/*
>>>> + * _speck_unround_128bytes() - Speck decryption round on 128 bytes at a time
>>>> + *
>>>> + * This is the inverse of _speck_round_128bytes().
>>>> + */
>>>> +.macro _speck_unround_128bytes       n
>>>> +
>>>> +     // y ^= x
>>>> +     veor            TMP0, Y0, X0
>>>> +     veor            TMP1, Y1, X1
>>>> +     veor            TMP2, Y2, X2
>>>> +     veor            TMP3, Y3, X3
>>>> +
>>>> +     // y = ror(y, 3)
>>>> +     vshr.u\n        Y0, TMP0, #3
>>>> +     vshr.u\n        Y1, TMP1, #3
>>>> +     vshr.u\n        Y2, TMP2, #3
>>>> +     vshr.u\n        Y3, TMP3, #3
>>>> +     vsli.u\n        Y0, TMP0, #(\n - 3)
>>>> +     vsli.u\n        Y1, TMP1, #(\n - 3)
>>>> +     vsli.u\n        Y2, TMP2, #(\n - 3)
>>>> +     vsli.u\n        Y3, TMP3, #(\n - 3)
>>>> +
>>>> +     // x ^= k
>>>> +     veor            X0, ROUND_KEY
>>>> +     veor            X1, ROUND_KEY
>>>> +     veor            X2, ROUND_KEY
>>>> +     veor            X3, ROUND_KEY
>>>> +
>>>> +     // x -= y
>>>> +     vsub.u\n        X0, Y0
>>>> +     vsub.u\n        X1, Y1
>>>> +     vsub.u\n        X2, Y2
>>>> +     vsub.u\n        X3, Y3
>>>> +
>>>> +     // x = rol(x, 8);
>>>> +     vtbl.8          X0_L, {X0_L}, ROTATE_TABLE
>>>> +     vtbl.8          X0_H, {X0_H}, ROTATE_TABLE
>>>> +     vtbl.8          X1_L, {X1_L}, ROTATE_TABLE
>>>> +     vtbl.8          X1_H, {X1_H}, ROTATE_TABLE
>>>> +     vtbl.8          X2_L, {X2_L}, ROTATE_TABLE
>>>> +     vtbl.8          X2_H, {X2_H}, ROTATE_TABLE
>>>> +     vtbl.8          X3_L, {X3_L}, ROTATE_TABLE
>>>> +     vtbl.8          X3_H, {X3_H}, ROTATE_TABLE
>>>> +.endm
>>>> +
>>>> +.macro _xts128_precrypt_one  dst_reg, tweak_buf, tmp
>>>> +
>>>> +     // Load the next source block
>>>> +     vld1.8          {\dst_reg}, [SRC]!
>>>> +
>>>> +     // Save the current tweak in the tweak buffer
>>>> +     vst1.8          {TWEAKV}, [\tweak_buf:128]!
>>>> +
>>>> +     // XOR the next source block with the current tweak
>>>> +     veor            \dst_reg, TWEAKV
>>>> +
>>>> +     /*
>>>> +      * Calculate the next tweak by multiplying the current one by x,
>>>> +      * modulo p(x) = x^128 + x^7 + x^2 + x + 1.
>>>> +      */
>>>> +     vshr.u64        \tmp, TWEAKV, #63
>>>> +     vshl.u64        TWEAKV, #1
>>>> +     veor            TWEAKV_H, \tmp\()_L
>>>> +     vtbl.8          \tmp\()_H, {GF128MUL_TABLE}, \tmp\()_H
>>>> +     veor            TWEAKV_L, \tmp\()_H
>>>> +.endm
>>>> +
>>>> +.macro _xts64_precrypt_two   dst_reg, tweak_buf, tmp
>>>> +
>>>> +     // Load the next two source blocks
>>>> +     vld1.8          {\dst_reg}, [SRC]!
>>>> +
>>>> +     // Save the current two tweaks in the tweak buffer
>>>> +     vst1.8          {TWEAKV}, [\tweak_buf:128]!
>>>> +
>>>> +     // XOR the next two source blocks with the current two tweaks
>>>> +     veor            \dst_reg, TWEAKV
>>>> +
>>>> +     /*
>>>> +      * Calculate the next two tweaks by multiplying the current ones by x^2,
>>>> +      * modulo p(x) = x^64 + x^4 + x^3 + x + 1.
>>>> +      */
>>>> +     vshr.u64        \tmp, TWEAKV, #62
>>>> +     vshl.u64        TWEAKV, #2
>>>> +     vtbl.8          \tmp\()_L, {GF64MUL_TABLE}, \tmp\()_L
>>>> +     vtbl.8          \tmp\()_H, {GF64MUL_TABLE}, \tmp\()_H
>>>> +     veor            TWEAKV, \tmp
>>>> +.endm
>>>> +
>>>> +/*
>>>> + * _speck_xts_crypt() - Speck-XTS encryption/decryption
>>>> + *
>>>> + * Encrypt or decrypt NBYTES bytes of data from the SRC buffer to the
>>>> DST buffer
>>>> + * using Speck-XTS, specifically the variant with a block size of
>>>> '2n' and round
>>>> + * count given by NROUNDS.  The expanded round keys are given in
>>>> ROUND_KEYS, and
>>>> + * the current XTS tweak value is given in TWEAK.  It's assumed that
>>>> NBYTES is a
>>>> + * nonzero multiple of 128.
>>>> + */
>>>> +.macro _speck_xts_crypt      n, decrypting
>>>> +     push            {r4-r7}
>>>> +     mov             r7, sp
>>>> +
>>>> +     /*
>>>> +      * The first four parameters were passed in registers r0-r3.  Load the
>>>> +      * additional parameters, which were passed on the stack.
>>>> +      */
>>>> +     ldr             NBYTES, [sp, #16]
>>>> +     ldr             TWEAK, [sp, #20]
>>>> +
>>>> +     /*
>>>> +      * If decrypting, modify the ROUND_KEYS parameter to point to the last
>>>> +      * round key rather than the first, since for decryption the round keys
>>>> +      * are used in reverse order.
>>>> +      */
>>>> +.if \decrypting
>>>> +.if \n == 64
>>>> +     add             ROUND_KEYS, ROUND_KEYS, NROUNDS, lsl #3
>>>> +     sub             ROUND_KEYS, #8
>>>> +.else
>>>> +     add             ROUND_KEYS, ROUND_KEYS, NROUNDS, lsl #2
>>>> +     sub             ROUND_KEYS, #4
>>>> +.endif
>>>> +.endif
>>>> +
>>>> +     // Load the index vector for vtbl-based 8-bit rotates
>>>> +.if \decrypting
>>>> +     ldr             r12, =.Lrol\n\()_8_table
>>>> +.else
>>>> +     ldr             r12, =.Lror\n\()_8_table
>>>> +.endif
>>>> +     vld1.8          {ROTATE_TABLE}, [r12:64]
>>>> +
>>>> +     // One-time XTS preparation
>>>> +
>>>> +     /*
>>>> +      * Allocate stack space to store 128 bytes worth of tweaks.  For
>>>> +      * performance, this space is aligned to a 16-byte boundary so that we
>>>> +      * can use the load/store instructions that declare 16-byte alignment.
>>>> +      */
>>>> +     sub             sp, #128
>>>> +     bic             sp, #0xf
>>>
>>>
>>> This fails here when building with CONFIG_THUMB2_KERNEL=y
>>>
>>>   AS      arch/arm/crypto/speck-neon-core.o
>>>
>>> arch/arm/crypto/speck-neon-core.S: Assembler messages:
>>>
>>> arch/arm/crypto/speck-neon-core.S:419: Error: r13 not allowed here --
>>> `bic sp,#0xf'
>>> arch/arm/crypto/speck-neon-core.S:423: Error: r13 not allowed here --
>>> `bic sp,#0xf'
>>> arch/arm/crypto/speck-neon-core.S:427: Error: r13 not allowed here --
>>> `bic sp,#0xf'
>>> arch/arm/crypto/speck-neon-core.S:431: Error: r13 not allowed here --
>>> `bic sp,#0xf'
>>>
>>> In a quick hack this change seems to address it:
>>>
>>>
>>> -       sub             sp, #128
>>> -       bic             sp, #0xf
>>> +       mov             r6, sp
>>> +       sub             r6, #128
>>> +       bic             r6, #0xf
>>> +       mov             sp, r6
>>>
>>> But there is probably a better solution to address this.
>>>
>>
>> Given that there is no NEON on M class cores, I recommend we put something like
>>
>> THUMB(bx pc)
>> THUMB(nop.w)
>> THUMB(.arm)
>>
>> at the beginning and be done with it.
> 
> I mean nop.n or just nop, of course, and we may need a '.align 2' at
> the beginning as well.

Wouldn't it be preferable to have it assemble it in Thumb2 too? It seems
that bic sp,#0xf is the only issue...

--
Stefan
