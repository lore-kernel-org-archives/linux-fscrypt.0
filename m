Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Fri, 19 Oct 2018 22:51:37 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 10/12] crypto: arm/nhpoly1305 - add
 NEON-accelerated NHPoly1305
Message-ID: <20181020055136.GD876@sol.localdomain>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <20181015175424.97147-11-ebiggers@kernel.org>
 <CAKv+Gu_HCecGeqFTf-Ys+GiWr98JO_ydZ1cAsMbKM88ZKG=Sog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKv+Gu_HCecGeqFTf-Ys+GiWr98JO_ydZ1cAsMbKM88ZKG=Sog@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Oct 20, 2018 at 12:12:56PM +0800, Ard Biesheuvel wrote:
> On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
> > From: Eric Biggers <ebiggers@google.com>
> >
> > Add an ARM NEON implementation of NHPoly1305, an ε-almost-∆-universal
> > hash function used in the Adiantum encryption mode.  For now, only the
> > NH portion is actually NEON-accelerated; the Poly1305 part is less
> > performance-critical so is just implemented in C.
> >
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  arch/arm/crypto/Kconfig                |   5 ++
> >  arch/arm/crypto/Makefile               |   2 +
> >  arch/arm/crypto/nh-neon-core.S         | 116 +++++++++++++++++++++++++
> >  arch/arm/crypto/nhpoly1305-neon-glue.c |  78 +++++++++++++++++
> >  4 files changed, 201 insertions(+)
> >  create mode 100644 arch/arm/crypto/nh-neon-core.S
> >  create mode 100644 arch/arm/crypto/nhpoly1305-neon-glue.c
> >
> > diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
> > index cc932d9bba561..458562a34aabe 100644
> > --- a/arch/arm/crypto/Kconfig
> > +++ b/arch/arm/crypto/Kconfig
> > @@ -122,4 +122,9 @@ config CRYPTO_CHACHA20_NEON
> >         select CRYPTO_BLKCIPHER
> >         select CRYPTO_CHACHA20
> >
> > +config CRYPTO_NHPOLY1305_NEON
> > +       tristate "NEON accelerated NHPoly1305 hash function (for Adiantum)"
> > +       depends on KERNEL_MODE_NEON
> > +       select CRYPTO_NHPOLY1305
> > +
> >  endif
> > diff --git a/arch/arm/crypto/Makefile b/arch/arm/crypto/Makefile
> > index 005482ff95047..b65d6bfab8e6b 100644
> > --- a/arch/arm/crypto/Makefile
> > +++ b/arch/arm/crypto/Makefile
> > @@ -10,6 +10,7 @@ obj-$(CONFIG_CRYPTO_SHA1_ARM_NEON) += sha1-arm-neon.o
> >  obj-$(CONFIG_CRYPTO_SHA256_ARM) += sha256-arm.o
> >  obj-$(CONFIG_CRYPTO_SHA512_ARM) += sha512-arm.o
> >  obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha-neon.o
> > +obj-$(CONFIG_CRYPTO_NHPOLY1305_NEON) += nhpoly1305-neon.o
> >
> >  ce-obj-$(CONFIG_CRYPTO_AES_ARM_CE) += aes-arm-ce.o
> >  ce-obj-$(CONFIG_CRYPTO_SHA1_ARM_CE) += sha1-arm-ce.o
> > @@ -53,6 +54,7 @@ ghash-arm-ce-y        := ghash-ce-core.o ghash-ce-glue.o
> >  crct10dif-arm-ce-y     := crct10dif-ce-core.o crct10dif-ce-glue.o
> >  crc32-arm-ce-y:= crc32-ce-core.o crc32-ce-glue.o
> >  chacha-neon-y := chacha-neon-core.o chacha-neon-glue.o
> > +nhpoly1305-neon-y := nh-neon-core.o nhpoly1305-neon-glue.o
> >
> >  ifdef REGENERATE_ARM_CRYPTO
> >  quiet_cmd_perl = PERL    $@
> > diff --git a/arch/arm/crypto/nh-neon-core.S b/arch/arm/crypto/nh-neon-core.S
> > new file mode 100644
> > index 0000000000000..434d80ab531c2
> > --- /dev/null
> > +++ b/arch/arm/crypto/nh-neon-core.S
> > @@ -0,0 +1,116 @@
> > +/* SPDX-License-Identifier: GPL-2.0 */
> > +/*
> > + * NH - ε-almost-universal hash function, NEON accelerated version
> > + *
> > + * Copyright 2018 Google LLC
> > + *
> > + * Author: Eric Biggers <ebiggers@google.com>
> > + */
> > +
> > +#include <linux/linkage.h>
> > +
> > +       .text
> > +       .fpu            neon
> > +
> > +       KEY             .req    r0
> > +       MESSAGE         .req    r1
> > +       MESSAGE_LEN     .req    r2
> > +       HASH            .req    r3
> > +
> > +       PASS0_SUMS      .req    q0
> > +       PASS0_SUM_A     .req    d0
> > +       PASS0_SUM_B     .req    d1
> > +       PASS1_SUMS      .req    q1
> > +       PASS1_SUM_A     .req    d2
> > +       PASS1_SUM_B     .req    d3
> > +       PASS2_SUMS      .req    q2
> > +       PASS2_SUM_A     .req    d4
> > +       PASS2_SUM_B     .req    d5
> > +       PASS3_SUMS      .req    q3
> > +       PASS3_SUM_A     .req    d6
> > +       PASS3_SUM_B     .req    d7
> > +       K0              .req    q4
> > +       K1              .req    q5
> > +       K2              .req    q6
> > +       K3              .req    q7
> > +       T0              .req    q8
> > +       T0_L            .req    d16
> > +       T0_H            .req    d17
> > +       T1              .req    q9
> > +       T1_L            .req    d18
> > +       T1_H            .req    d19
> > +       T2              .req    q10
> > +       T2_L            .req    d20
> > +       T2_H            .req    d21
> > +       T3              .req    q11
> > +       T3_L            .req    d22
> > +       T3_H            .req    d23
> > +
> > +.macro _nh_stride      k0, k1, k2, k3
> > +
> > +       // Load next message stride
> > +       vld1.8          {T3}, [MESSAGE]!
> > +
> > +       // Load next key stride
> > +       vld1.32         {\k3}, [KEY]!
> > +
> > +       // Add message words to key words
> > +       vadd.u32        T0, T3, \k0
> > +       vadd.u32        T1, T3, \k1
> > +       vadd.u32        T2, T3, \k2
> > +       vadd.u32        T3, T3, \k3
> > +
> > +       // Multiply 32x32 => 64 and accumulate
> > +       vmlal.u32       PASS0_SUMS, T0_L, T0_H
> > +       vmlal.u32       PASS1_SUMS, T1_L, T1_H
> > +       vmlal.u32       PASS2_SUMS, T2_L, T2_H
> > +       vmlal.u32       PASS3_SUMS, T3_L, T3_H
> > +.endm
> > +
> 
> Since we seem to have some spare NEON registers: would it help to have
> a double round version of this macro?
> 

It helps a little bit, but not much.  The loads are the only part that can be
optimized further.  I think I'd rather have the shorter + simpler version,
unless the loads can be optimized significantly more on other processors.

Also, originally I had it loading the key and message for the next stride while
doing the current one, but that didn't seem worthwhile either.

> > +/*
> > + * void nh_neon(const u32 *key, const u8 *message, size_t message_len,
> > + *             u8 hash[NH_HASH_BYTES])
> > + *
> > + * It's guaranteed that message_len % 16 == 0.
> > + */
> > +ENTRY(nh_neon)
> > +
> > +       vld1.32         {K0,K1}, [KEY]!
> > +         vmov.u64      PASS0_SUMS, #0
> > +         vmov.u64      PASS1_SUMS, #0
> > +       vld1.32         {K2}, [KEY]!
> > +         vmov.u64      PASS2_SUMS, #0
> > +         vmov.u64      PASS3_SUMS, #0
> > +
> > +       subs            MESSAGE_LEN, MESSAGE_LEN, #64
> > +       blt             .Lloop4_done
> > +.Lloop4:
> > +       _nh_stride      K0, K1, K2, K3
> > +       _nh_stride      K1, K2, K3, K0
> > +       _nh_stride      K2, K3, K0, K1
> > +       _nh_stride      K3, K0, K1, K2
> > +       subs            MESSAGE_LEN, MESSAGE_LEN, #64
> > +       bge             .Lloop4
> > +
> > +.Lloop4_done:
> > +       ands            MESSAGE_LEN, MESSAGE_LEN, #63
> > +       beq             .Ldone
> > +       _nh_stride      K0, K1, K2, K3
> > +
> > +       subs            MESSAGE_LEN, MESSAGE_LEN, #16
> > +       beq             .Ldone
> > +       _nh_stride      K1, K2, K3, K0
> > +
> > +       subs            MESSAGE_LEN, MESSAGE_LEN, #16
> > +       beq             .Ldone
> > +       _nh_stride      K2, K3, K0, K1
> > +
> > +.Ldone:
> > +       // Sum the accumulators for each pass, then store the sums to 'hash'
> > +       vadd.u64        T0_L, PASS0_SUM_A, PASS0_SUM_B
> > +       vadd.u64        T0_H, PASS1_SUM_A, PASS1_SUM_B
> > +       vadd.u64        T1_L, PASS2_SUM_A, PASS2_SUM_B
> > +       vadd.u64        T1_H, PASS3_SUM_A, PASS3_SUM_B
> > +       vst1.8          {T0-T1}, [HASH]
> > +       bx              lr
> > +ENDPROC(nh_neon)
> > diff --git a/arch/arm/crypto/nhpoly1305-neon-glue.c b/arch/arm/crypto/nhpoly1305-neon-glue.c
> > new file mode 100644
> > index 0000000000000..df48a00f4c50f
> > --- /dev/null
> > +++ b/arch/arm/crypto/nhpoly1305-neon-glue.c
> > @@ -0,0 +1,78 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +/*
> > + * NHPoly1305 - ε-almost-∆-universal hash function for Adiantum
> > + * (NEON accelerated version)
> > + *
> > + * Copyright 2018 Google LLC
> > + */
> > +
> > +#include <asm/neon.h>
> > +#include <asm/simd.h>
> > +#include <crypto/internal/hash.h>
> > +#include <crypto/nhpoly1305.h>
> > +#include <linux/module.h>
> > +
> > +asmlinkage void nh_neon(const u32 *key, const u8 *message, size_t message_len,
> > +                       u8 hash[NH_HASH_BYTES]);
> > +
> > +static void _nh_neon(const u32 *key, const u8 *message, size_t message_len,
> > +                    __le64 hash[NH_NUM_PASSES])
> > +{
> > +       nh_neon(key, message, message_len, (u8 *)hash);
> > +}
> > +
> 
> Why do we need this function?
> 

For now it's not needed so I should probably just remove it, but it seems likely
that indirect calls to assembly functions in the kernel will be going away in
order to add support for CFI (control flow integrity).  The android-4.9 and
android-4.14 kernels support CFI on arm64, so you might notice that some of the
arm64 crypto code had to be patched for this reason.

- Eric
