Return-Path: <SRS0=q1Ic=NA=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20181020053834.GC876@sol.localdomain>
References: <20181015175424.97147-1-ebiggers@kernel.org> <20181015175424.97147-10-ebiggers@kernel.org>
 <CAKv+Gu-5WM19g5HguDheAADbigKNxokDCFMekkt4OYdEEa8Avw@mail.gmail.com> <20181020053834.GC876@sol.localdomain>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 20 Oct 2018 23:06:00 +0800
Message-ID: <CAKv+Gu-A_EhMBXq_nqzBzpgN36foo6hA3Ba3=j+WVM-jph=mrw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 09/12] crypto: nhpoly1305 - add NHPoly1305 support
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On 20 October 2018 at 13:38, Eric Biggers <ebiggers@kernel.org> wrote:
> Hi Ard,
>
> On Sat, Oct 20, 2018 at 12:00:31PM +0800, Ard Biesheuvel wrote:
>> On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
>> > From: Eric Biggers <ebiggers@google.com>
>> >
>> > Add a generic implementation of NHPoly1305, an =CE=B5-almost-=E2=88=86=
-universal hash
>> > function used in the Adiantum encryption mode.
>> >
>> > CONFIG_NHPOLY1305 is not selectable by itself since there won't be any
>> > real reason to enable it without also enabling Adiantum support.
>> >
>> > Signed-off-by: Eric Biggers <ebiggers@google.com>
>> > ---
>> >  crypto/Kconfig              |    5 +
>> >  crypto/Makefile             |    1 +
>> >  crypto/nhpoly1305.c         |  288 ++++++++
>> >  crypto/testmgr.c            |    6 +
>> >  crypto/testmgr.h            | 1240 ++++++++++++++++++++++++++++++++++=
-
>> >  include/crypto/nhpoly1305.h |   74 +++
>> >  6 files changed, 1610 insertions(+), 4 deletions(-)
>> >  create mode 100644 crypto/nhpoly1305.c
>> >  create mode 100644 include/crypto/nhpoly1305.h
>> >
>> > diff --git a/crypto/Kconfig b/crypto/Kconfig
>> > index 4fa0a4a0e8615..431beca903623 100644
>> > --- a/crypto/Kconfig
>> > +++ b/crypto/Kconfig
>> > @@ -493,6 +493,11 @@ config CRYPTO_KEYWRAP
>> >           Support for key wrapping (NIST SP800-38F / RFC3394) without
>> >           padding.
>> >
>> > +config CRYPTO_NHPOLY1305
>> > +       tristate
>> > +       select CRYPTO_HASH
>> > +       select CRYPTO_POLY1305
>> > +
>> >  comment "Hash modes"
>> >
>> >  config CRYPTO_CMAC
>> > diff --git a/crypto/Makefile b/crypto/Makefile
>> > index 7e673f7c71107..87b86f221a2a2 100644
>> > --- a/crypto/Makefile
>> > +++ b/crypto/Makefile
>> > @@ -84,6 +84,7 @@ obj-$(CONFIG_CRYPTO_LRW) +=3D lrw.o
>> >  obj-$(CONFIG_CRYPTO_XTS) +=3D xts.o
>> >  obj-$(CONFIG_CRYPTO_CTR) +=3D ctr.o
>> >  obj-$(CONFIG_CRYPTO_KEYWRAP) +=3D keywrap.o
>> > +obj-$(CONFIG_CRYPTO_NHPOLY1305) +=3D nhpoly1305.o
>> >  obj-$(CONFIG_CRYPTO_GCM) +=3D gcm.o
>> >  obj-$(CONFIG_CRYPTO_CCM) +=3D ccm.o
>> >  obj-$(CONFIG_CRYPTO_CHACHA20POLY1305) +=3D chacha20poly1305.o
>> > diff --git a/crypto/nhpoly1305.c b/crypto/nhpoly1305.c
>> > new file mode 100644
>> > index 0000000000000..087ad7680dd62
>> > --- /dev/null
>> > +++ b/crypto/nhpoly1305.c
>> > @@ -0,0 +1,288 @@
>> > +// SPDX-License-Identifier: GPL-2.0
>> > +/*
>> > + * NHPoly1305 - =CE=B5-almost-=E2=88=86-universal hash function for A=
diantum
>> > + *
>> > + * Copyright 2018 Google LLC
>> > + */
>> > +
>> > +/*
>> > + * "NHPoly1305" is the main component of Adiantum hashing.
>> > + * Specifically, it is the calculation
>> > + *
>> > + *     H_M =E2=86=90 Poly1305_{K_M}(NH_{K_N}(pad_{128}(M)))
>> > + *
>> > + * from the procedure in section A.5 of the Adiantum paper [1].  It i=
s an
>> > + * =CE=B5-almost-=E2=88=86-universal (=CE=B5A=E2=88=86U) hash functio=
n for equal-length inputs over
>> > + * Z/(2^{128}Z), where the "=E2=88=86" operation is addition.  It has=
hes 1024-byte
>> > + * chunks of the input with the NH hash function [2], reducing the in=
put length
>> > + * by 32x.  The resulting NH digests are evaluated as a polynomial in
>> > + * GF(2^{130}-5), like in the Poly1305 MAC [3].  Note that the polyno=
mial
>> > + * evaluation by itself would suffice to achieve the =CE=B5A=E2=88=86=
U property; NH is used
>> > + * for performance since it's over twice as fast as Poly1305.
>> > + *
>> > + * This is *not* a cryptographic hash function; do not use it as such=
!
>> > + *
>> > + * [1] Adiantum: length-preserving encryption for entry-level process=
ors
>> > + *     (https://eprint.iacr.org/2018/720.pdf)
>> > + * [2] UMAC: Fast and Secure Message Authentication
>> > + *     (https://fastcrypto.org/umac/umac_proc.pdf)
>> > + * [3] The Poly1305-AES message-authentication code
>> > + *     (https://cr.yp.to/mac/poly1305-20050329.pdf)
>> > + */
>> > +
>> > +#include <asm/unaligned.h>
>> > +#include <crypto/algapi.h>
>> > +#include <crypto/internal/hash.h>
>> > +#include <crypto/nhpoly1305.h>
>> > +#include <linux/crypto.h>
>> > +#include <linux/kernel.h>
>> > +#include <linux/module.h>
>> > +
>> > +#define NH_STRIDE(K0, K1, K2, K3)                              \
>> > +({                                                             \
>> > +       m_A =3D get_unaligned_le32(src); src +=3D 4;                \
>> > +       m_B =3D get_unaligned_le32(src); src +=3D 4;                \
>> > +       m_C =3D get_unaligned_le32(src); src +=3D 4;                \
>> > +       m_D =3D get_unaligned_le32(src); src +=3D 4;                \
>> > +       K3##_A =3D *key++;                                        \
>> > +       K3##_B =3D *key++;                                        \
>> > +       K3##_C =3D *key++;                                        \
>> > +       K3##_D =3D *key++;                                        \
>> > +       sum0 +=3D (u64)(u32)(m_A + K0##_A) * (u32)(m_C + K0##_C); \
>> > +       sum1 +=3D (u64)(u32)(m_A + K1##_A) * (u32)(m_C + K1##_C); \
>> > +       sum2 +=3D (u64)(u32)(m_A + K2##_A) * (u32)(m_C + K2##_C); \
>> > +       sum3 +=3D (u64)(u32)(m_A + K3##_A) * (u32)(m_C + K3##_C); \
>> > +       sum0 +=3D (u64)(u32)(m_B + K0##_B) * (u32)(m_D + K0##_D); \
>> > +       sum1 +=3D (u64)(u32)(m_B + K1##_B) * (u32)(m_D + K1##_D); \
>> > +       sum2 +=3D (u64)(u32)(m_B + K2##_B) * (u32)(m_D + K2##_D); \
>> > +       sum3 +=3D (u64)(u32)(m_B + K3##_B) * (u32)(m_D + K3##_D); \
>> > +})
>> > +
>> > +static void nh_generic(const u32 *key, const u8 *src, size_t srclen,
>> > +                      __le64 hash[NH_NUM_PASSES])
>> > +{
>> > +       u64 sum0 =3D 0, sum1 =3D 0, sum2 =3D 0, sum3 =3D 0;
>> > +       u32 k0_A =3D *key++;
>> > +       u32 k0_B =3D *key++;
>> > +       u32 k0_C =3D *key++;
>> > +       u32 k0_D =3D *key++;
>> > +       u32 k1_A =3D *key++;
>> > +       u32 k1_B =3D *key++;
>> > +       u32 k1_C =3D *key++;
>> > +       u32 k1_D =3D *key++;
>> > +       u32 k2_A =3D *key++;
>> > +       u32 k2_B =3D *key++;
>> > +       u32 k2_C =3D *key++;
>> > +       u32 k2_D =3D *key++;
>> > +       u32 k3_A, k3_B, k3_C, k3_D;
>> > +       u32 m_A, m_B, m_C, m_D;
>> > +       size_t n =3D srclen / NH_MESSAGE_UNIT;
>> > +
>> > +       BUILD_BUG_ON(NH_PAIR_STRIDE !=3D 2);
>> > +       BUILD_BUG_ON(NH_NUM_PASSES !=3D 4);
>> > +
>> > +       while (n >=3D 4) {
>> > +               NH_STRIDE(k0, k1, k2, k3);
>> > +               NH_STRIDE(k1, k2, k3, k0);
>> > +               NH_STRIDE(k2, k3, k0, k1);
>> > +               NH_STRIDE(k3, k0, k1, k2);
>> > +               n -=3D 4;
>> > +       }
>> > +       if (n) {
>> > +               NH_STRIDE(k0, k1, k2, k3);
>> > +               if (--n) {
>> > +                       NH_STRIDE(k1, k2, k3, k0);
>> > +                       if (--n)
>> > +                               NH_STRIDE(k2, k3, k0, k1);
>> > +               }
>> > +       }
>> > +
>>
>> This all looks a bit clunky to me, with the macro, the *key++s in the
>> initializers and these conditionals.
>>
>> Was it written in this particular way to get GCC to optimize it in the
>> right way?
>
> This does get compiled into something much faster than a naive version, w=
hich
> you can find commented out at
> https://github.com/google/adiantum/blob/master/benchmark/src/nh.c#L14.
>
> Though, I admit that I haven't put a ton of effort into this C implementa=
tion of
> NH yet.  Right now it's actually somewhat of a translation of the NEON ve=
rsion.
> I'll do some experiments and see if it can be made into something less ug=
ly
> without losing performance.
>

No that's fine but please document it.

>>
>> > +       hash[0] =3D cpu_to_le64(sum0);
>> > +       hash[1] =3D cpu_to_le64(sum1);
>> > +       hash[2] =3D cpu_to_le64(sum2);
>> > +       hash[3] =3D cpu_to_le64(sum3);
>> > +}
>> > +
>> > +/* Pass the next NH hash value through Poly1305 */
>> > +static void process_nh_hash_value(struct nhpoly1305_state *state,
>> > +                                 const struct nhpoly1305_key *key)
>> > +{
>> > +       BUILD_BUG_ON(NH_HASH_BYTES % POLY1305_BLOCK_SIZE !=3D 0);
>> > +
>> > +       poly1305_core_blocks(&state->poly_state, &key->poly_key, state=
->nh_hash,
>> > +                            NH_HASH_BYTES / POLY1305_BLOCK_SIZE);
>> > +}
>> > +
>> > +/*
>> > + * Feed the next portion of the source data, as a whole number of 16-=
byte
>> > + * "NH message units", through NH and Poly1305.  Each NH hash is take=
n over
>> > + * 1024 bytes, except possibly the final one which is taken over a mu=
ltiple of
>> > + * 16 bytes up to 1024.  Also, in the case where data is passed in mi=
saligned
>> > + * chunks, we combine partial hashes; the end result is the same eith=
er way.
>> > + */
>> > +static void nhpoly1305_units(struct nhpoly1305_state *state,
>> > +                            const struct nhpoly1305_key *key,
>> > +                            const u8 *src, unsigned int srclen, nh_t =
nh_fn)
>>
>> Since indirect calls are going out of style: can we get rid of the
>> function pointer? Or is the compiler already inferring that it always
>> refers to nh_generic()?
>>
>
> At least for now I want to use the same crypto_nhpoly1305_*_helper() func=
tions
> for all nhpoly1305 implementations, and that requires that 'nh' be a func=
tion
> pointer.  The helpers could be placed in a header and inlined which would=
 turn
> 'nh' into a direct call, but it seemed to be too much code to inline, and
> normally 'nh' is only invoked once per 1024 bytes anyway.
>

OK.
