Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:45453 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753223AbeCFMrq (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Mar 2018 07:47:46 -0500
Received: by mail-io0-f196.google.com with SMTP id m22so21887831iob.12
        for <linux-fscrypt@vger.kernel.org>; Tue, 06 Mar 2018 04:47:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180306123505.GK32331@e103592.cambridge.arm.com>
References: <20180305191707.143961-1-ebiggers@google.com> <20180306123505.GK32331@e103592.cambridge.arm.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 6 Mar 2018 12:47:45 +0000
Message-ID: <CAKv+Gu9bgJ_zW30Q=nFcof_xhQzno4WvtNbpweav=22B6ef5GA@mail.gmail.com>
Subject: Re: [RFC PATCH] crypto: arm64/speck - add NEON-accelerated
 implementation of Speck-XTS
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Dave Martin <Dave.Martin@arm.com>
Cc: Eric Biggers <ebiggers@google.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 6 March 2018 at 12:35, Dave Martin <Dave.Martin@arm.com> wrote:
> On Mon, Mar 05, 2018 at 11:17:07AM -0800, Eric Biggers wrote:
>> Add a NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
>> for ARM64.  This is ported from the 32-bit version.  It may be useful on
>> devices with 64-bit ARM CPUs that don't have the Cryptography
>> Extensions, so cannot do AES efficiently -- e.g. the Cortex-A53
>> processor on the Raspberry Pi 3.
>>
>> It generally works the same way as the 32-bit version, but there are
>> some slight differences due to the different instructions, registers,
>> and syntax available in ARM64 vs. in ARM32.  For example, in the 64-bit
>> version there are enough registers to hold the XTS tweaks for each
>> 128-byte chunk, so they don't need to be saved on the stack.
>>
>> Benchmarks on a Raspberry Pi 3 running a 64-bit kernel:
>>
>>    Algorithm                              Encryption     Decryption
>>    ---------                              ----------     ----------
>>    Speck64/128-XTS (NEON)                 92.2 MB/s      92.2 MB/s
>>    Speck128/256-XTS (NEON)                75.0 MB/s      75.0 MB/s
>>    Speck128/256-XTS (generic)             47.4 MB/s      35.6 MB/s
>>    AES-128-XTS (NEON bit-sliced)          33.4 MB/s      29.6 MB/s
>>    AES-256-XTS (NEON bit-sliced)          24.6 MB/s      21.7 MB/s
>>
>> The code performs well on higher-end ARM64 processors as well, though
>> such processors tend to have the Crypto Extensions which make AES
>> preferred.  For example, here are the same benchmarks run on a HiKey960
>> (with CPU affinity set for the A73 cores), with the Crypto Extensions
>> implementation of AES-256-XTS added:
>>
>>    Algorithm                              Encryption     Decryption
>>    ---------                              -----------    -----------
>>    AES-256-XTS (Crypto Extensions)        1273.3 MB/s    1274.7 MB/s
>>    Speck64/128-XTS (NEON)                  359.8 MB/s     348.0 MB/s
>>    Speck128/256-XTS (NEON)                 292.5 MB/s     286.1 MB/s
>>    Speck128/256-XTS (generic)              186.3 MB/s     181.8 MB/s
>>    AES-128-XTS (NEON bit-sliced)           142.0 MB/s     124.3 MB/s
>>    AES-256-XTS (NEON bit-sliced)           104.7 MB/s      91.1 MB/s
>>
>> Signed-off-by: Eric Biggers <ebiggers@google.com>
>> ---
>>  arch/arm64/crypto/Kconfig           |   6 +
>>  arch/arm64/crypto/Makefile          |   3 +
>>  arch/arm64/crypto/speck-neon-core.S | 352 ++++++++++++++++++++++++++++
>>  arch/arm64/crypto/speck-neon-glue.c | 282 ++++++++++++++++++++++
>>  4 files changed, 643 insertions(+)
>>  create mode 100644 arch/arm64/crypto/speck-neon-core.S
>>  create mode 100644 arch/arm64/crypto/speck-neon-glue.c
>>
>> diff --git a/arch/arm64/crypto/Kconfig b/arch/arm64/crypto/Kconfig
>> index 285c36c7b408..cb5a243110c4 100644
>> --- a/arch/arm64/crypto/Kconfig
>> +++ b/arch/arm64/crypto/Kconfig
>> @@ -113,4 +113,10 @@ config CRYPTO_AES_ARM64_BS
>>       select CRYPTO_AES_ARM64
>>       select CRYPTO_SIMD
>>
>> +config CRYPTO_SPECK_NEON
>> +     tristate "NEON accelerated Speck cipher algorithms"
>> +     depends on KERNEL_MODE_NEON
>> +     select CRYPTO_BLKCIPHER
>> +     select CRYPTO_SPECK
>> +
>>  endif
>> diff --git a/arch/arm64/crypto/Makefile b/arch/arm64/crypto/Makefile
>> index cee9b8d9830b..d94ebd15a859 100644
>> --- a/arch/arm64/crypto/Makefile
>> +++ b/arch/arm64/crypto/Makefile
>> @@ -53,6 +53,9 @@ sha512-arm64-y := sha512-glue.o sha512-core.o
>>  obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha20-neon.o
>>  chacha20-neon-y := chacha20-neon-core.o chacha20-neon-glue.o
>>
>> +obj-$(CONFIG_CRYPTO_SPECK_NEON) += speck-neon.o
>> +speck-neon-y := speck-neon-core.o speck-neon-glue.o
>> +
>>  obj-$(CONFIG_CRYPTO_AES_ARM64) += aes-arm64.o
>>  aes-arm64-y := aes-cipher-core.o aes-cipher-glue.o
>>
>> diff --git a/arch/arm64/crypto/speck-neon-core.S b/arch/arm64/crypto/speck-neon-core.S
>> new file mode 100644
>> index 000000000000..b14463438b09
>> --- /dev/null
>> +++ b/arch/arm64/crypto/speck-neon-core.S
>> @@ -0,0 +1,352 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +/*
>> + * ARM64 NEON-accelerated implementation of Speck128-XTS and Speck64-XTS
>> + *
>> + * Copyright (c) 2018 Google, Inc
>> + *
>> + * Author: Eric Biggers <ebiggers@google.com>
>> + */
>> +
>> +#include <linux/linkage.h>
>> +
>> +     .text
>> +
>> +     // arguments
>> +     ROUND_KEYS      .req    x0      // const {u64,u32} *round_keys
>> +     NROUNDS         .req    w1      // int nrounds
>> +     NROUNDS_X       .req    x1
>> +     DST             .req    x2      // void *dst
>> +     SRC             .req    x3      // const void *src
>> +     NBYTES          .req    w4      // unsigned int nbytes
>> +     TWEAK           .req    x5      // void *tweak
>> +
>> +     // registers which hold the data being encrypted/decrypted
>> +     // (underscores avoid a naming collision with ARM64 registers x0-x3)
>> +     X_0             .req    v0
>> +     Y_0             .req    v1
>> +     X_1             .req    v2
>> +     Y_1             .req    v3
>> +     X_2             .req    v4
>> +     Y_2             .req    v5
>> +     X_3             .req    v6
>> +     Y_3             .req    v7
>> +
>> +     // the round key, duplicated in all lanes
>> +     ROUND_KEY       .req    v8
>> +
>> +     // index vector for tbl-based 8-bit rotates
>> +     ROTATE_TABLE    .req    v9
>> +     ROTATE_TABLE_Q  .req    q9
>> +
>> +     // temporary registers
>> +     TMP0            .req    v10
>> +     TMP1            .req    v11
>> +     TMP2            .req    v12
>> +     TMP3            .req    v13
>> +
>> +     // multiplication table for updating XTS tweaks
>> +     GFMUL_TABLE     .req    v14
>> +     GFMUL_TABLE_Q   .req    q14
>> +
>> +     // next XTS tweak value(s)
>> +     TWEAKV_NEXT     .req    v15
>> +
>> +     // XTS tweaks for the blocks currently being encrypted/decrypted
>> +     TWEAKV0         .req    v16
>> +     TWEAKV1         .req    v17
>> +     TWEAKV2         .req    v18
>> +     TWEAKV3         .req    v19
>> +     TWEAKV4         .req    v20
>> +     TWEAKV5         .req    v21
>> +     TWEAKV6         .req    v22
>> +     TWEAKV7         .req    v23
>> +
>> +     .align          4
>> +.Lror64_8_table:
>> +     .octa           0x080f0e0d0c0b0a090007060504030201
>> +.Lror32_8_table:
>> +     .octa           0x0c0f0e0d080b0a090407060500030201
>> +.Lrol64_8_table:
>> +     .octa           0x0e0d0c0b0a09080f0605040302010007
>> +.Lrol32_8_table:
>> +     .octa           0x0e0d0c0f0a09080b0605040702010003
>> +.Lgf128mul_table:
>> +     .octa           0x00000000000000870000000000000001
>> +.Lgf64mul_table:
>> +     .octa           0x0000000000000000000000002d361b00
>
> Won't this put the data in the image in an endianness-dependent layout?
> Alternatively, if this doesn't matter, then why doesn't it matter?
>
> (I don't claim to understand the code fully here...)
>

Since these constants get loaded using 'ldr q#, .Lxxxx' instructions,
this arrangement is actually endian agnostic.

...
>> +static int __init speck_neon_module_init(void)
>> +{
>> +     if (!(elf_hwcap & HWCAP_ASIMD))
>> +             return -ENODEV;
>> +     return crypto_register_skciphers(speck_algs, ARRAY_SIZE(speck_algs));
>
> I haven't tried to understand everything here, but the kernel-mode NEON
> integration looks OK to me.
>

I agree that the conditional use of the NEON looks fine here. The RT
folks will frown at handling all input inside a single
kernel_mode_neon_begin/_end pair, but we can fix that later once my
changes for yielding the NEON get merged (which may take a while)
