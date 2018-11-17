Return-Path: <SRS0=3xn4=N4=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20181117012631.23528-1-ebiggers@kernel.org> <20181117012631.23528-11-ebiggers@kernel.org>
In-Reply-To: <20181117012631.23528-11-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Nov 2018 17:43:46 -0800
Message-ID: <CAKv+Gu8=VXiK8MJSB=Np1jmj7=K1cfGJdSkfAR-Supkw5aZTvA@mail.gmail.com>
Subject: Re: [PATCH v4 10/14] crypto: poly1305 - use structures for key and accumulator
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 16 Nov 2018 at 17:29, Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> In preparation for exposing a low-level Poly1305 API which implements
> the =CE=B5-almost-=E2=88=86-universal (=CE=B5A=E2=88=86U) hash function u=
nderlying the Poly1305
> MAC and supports block-aligned inputs only, create structures
> poly1305_key and poly1305_state which hold the limbs of the Poly1305
> "r" key and accumulator, respectively.
>
> These structures could actually have the same type (e.g. poly1305_val),
> but different types are preferable, to prevent misuse.
>
> Acked-by: Martin Willi <martin@strongswan.org>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  arch/x86/crypto/poly1305_glue.c | 20 +++++++------
>  crypto/poly1305_generic.c       | 52 ++++++++++++++++-----------------
>  include/crypto/poly1305.h       | 12 ++++++--
>  3 files changed, 47 insertions(+), 37 deletions(-)
>
> diff --git a/arch/x86/crypto/poly1305_glue.c b/arch/x86/crypto/poly1305_g=
lue.c
> index f012b7e28ad1..88cc01506c84 100644
> --- a/arch/x86/crypto/poly1305_glue.c
> +++ b/arch/x86/crypto/poly1305_glue.c
> @@ -83,35 +83,37 @@ static unsigned int poly1305_simd_blocks(struct poly1=
305_desc_ctx *dctx,
>         if (poly1305_use_avx2 && srclen >=3D POLY1305_BLOCK_SIZE * 4) {
>                 if (unlikely(!sctx->wset)) {
>                         if (!sctx->uset) {
> -                               memcpy(sctx->u, dctx->r, sizeof(sctx->u))=
;
> -                               poly1305_simd_mult(sctx->u, dctx->r);
> +                               memcpy(sctx->u, dctx->r.r, sizeof(sctx->u=
));
> +                               poly1305_simd_mult(sctx->u, dctx->r.r);
>                                 sctx->uset =3D true;
>                         }
>                         memcpy(sctx->u + 5, sctx->u, sizeof(sctx->u));
> -                       poly1305_simd_mult(sctx->u + 5, dctx->r);
> +                       poly1305_simd_mult(sctx->u + 5, dctx->r.r);
>                         memcpy(sctx->u + 10, sctx->u + 5, sizeof(sctx->u)=
);
> -                       poly1305_simd_mult(sctx->u + 10, dctx->r);
> +                       poly1305_simd_mult(sctx->u + 10, dctx->r.r);
>                         sctx->wset =3D true;
>                 }
>                 blocks =3D srclen / (POLY1305_BLOCK_SIZE * 4);
> -               poly1305_4block_avx2(dctx->h, src, dctx->r, blocks, sctx-=
>u);
> +               poly1305_4block_avx2(dctx->h.h, src, dctx->r.r, blocks,
> +                                    sctx->u);
>                 src +=3D POLY1305_BLOCK_SIZE * 4 * blocks;
>                 srclen -=3D POLY1305_BLOCK_SIZE * 4 * blocks;
>         }
>  #endif
>         if (likely(srclen >=3D POLY1305_BLOCK_SIZE * 2)) {
>                 if (unlikely(!sctx->uset)) {
> -                       memcpy(sctx->u, dctx->r, sizeof(sctx->u));
> -                       poly1305_simd_mult(sctx->u, dctx->r);
> +                       memcpy(sctx->u, dctx->r.r, sizeof(sctx->u));
> +                       poly1305_simd_mult(sctx->u, dctx->r.r);
>                         sctx->uset =3D true;
>                 }
>                 blocks =3D srclen / (POLY1305_BLOCK_SIZE * 2);
> -               poly1305_2block_sse2(dctx->h, src, dctx->r, blocks, sctx-=
>u);
> +               poly1305_2block_sse2(dctx->h.h, src, dctx->r.r, blocks,
> +                                    sctx->u);
>                 src +=3D POLY1305_BLOCK_SIZE * 2 * blocks;
>                 srclen -=3D POLY1305_BLOCK_SIZE * 2 * blocks;
>         }
>         if (srclen >=3D POLY1305_BLOCK_SIZE) {
> -               poly1305_block_sse2(dctx->h, src, dctx->r, 1);
> +               poly1305_block_sse2(dctx->h.h, src, dctx->r.r, 1);
>                 srclen -=3D POLY1305_BLOCK_SIZE;
>         }
>         return srclen;
> diff --git a/crypto/poly1305_generic.c b/crypto/poly1305_generic.c
> index 47d3a6b83931..a23173f351b7 100644
> --- a/crypto/poly1305_generic.c
> +++ b/crypto/poly1305_generic.c
> @@ -38,7 +38,7 @@ int crypto_poly1305_init(struct shash_desc *desc)
>  {
>         struct poly1305_desc_ctx *dctx =3D shash_desc_ctx(desc);
>
> -       memset(dctx->h, 0, sizeof(dctx->h));
> +       memset(dctx->h.h, 0, sizeof(dctx->h.h));
>         dctx->buflen =3D 0;
>         dctx->rset =3D false;
>         dctx->sset =3D false;
> @@ -50,11 +50,11 @@ EXPORT_SYMBOL_GPL(crypto_poly1305_init);
>  static void poly1305_setrkey(struct poly1305_desc_ctx *dctx, const u8 *k=
ey)
>  {
>         /* r &=3D 0xffffffc0ffffffc0ffffffc0fffffff */
> -       dctx->r[0] =3D (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
> -       dctx->r[1] =3D (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
> -       dctx->r[2] =3D (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
> -       dctx->r[3] =3D (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
> -       dctx->r[4] =3D (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
> +       dctx->r.r[0] =3D (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
> +       dctx->r.r[1] =3D (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
> +       dctx->r.r[2] =3D (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
> +       dctx->r.r[3] =3D (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
> +       dctx->r.r[4] =3D (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
>  }
>
>  static void poly1305_setskey(struct poly1305_desc_ctx *dctx, const u8 *k=
ey)
> @@ -107,22 +107,22 @@ static unsigned int poly1305_blocks(struct poly1305=
_desc_ctx *dctx,
>                 srclen =3D datalen;
>         }
>
> -       r0 =3D dctx->r[0];
> -       r1 =3D dctx->r[1];
> -       r2 =3D dctx->r[2];
> -       r3 =3D dctx->r[3];
> -       r4 =3D dctx->r[4];
> +       r0 =3D dctx->r.r[0];
> +       r1 =3D dctx->r.r[1];
> +       r2 =3D dctx->r.r[2];
> +       r3 =3D dctx->r.r[3];
> +       r4 =3D dctx->r.r[4];
>
>         s1 =3D r1 * 5;
>         s2 =3D r2 * 5;
>         s3 =3D r3 * 5;
>         s4 =3D r4 * 5;
>
> -       h0 =3D dctx->h[0];
> -       h1 =3D dctx->h[1];
> -       h2 =3D dctx->h[2];
> -       h3 =3D dctx->h[3];
> -       h4 =3D dctx->h[4];
> +       h0 =3D dctx->h.h[0];
> +       h1 =3D dctx->h.h[1];
> +       h2 =3D dctx->h.h[2];
> +       h3 =3D dctx->h.h[3];
> +       h4 =3D dctx->h.h[4];
>
>         while (likely(srclen >=3D POLY1305_BLOCK_SIZE)) {
>
> @@ -157,11 +157,11 @@ static unsigned int poly1305_blocks(struct poly1305=
_desc_ctx *dctx,
>                 srclen -=3D POLY1305_BLOCK_SIZE;
>         }
>
> -       dctx->h[0] =3D h0;
> -       dctx->h[1] =3D h1;
> -       dctx->h[2] =3D h2;
> -       dctx->h[3] =3D h3;
> -       dctx->h[4] =3D h4;
> +       dctx->h.h[0] =3D h0;
> +       dctx->h.h[1] =3D h1;
> +       dctx->h.h[2] =3D h2;
> +       dctx->h.h[3] =3D h3;
> +       dctx->h.h[4] =3D h4;
>
>         return srclen;
>  }
> @@ -220,11 +220,11 @@ int crypto_poly1305_final(struct shash_desc *desc, =
u8 *dst)
>         }
>
>         /* fully carry h */
> -       h0 =3D dctx->h[0];
> -       h1 =3D dctx->h[1];
> -       h2 =3D dctx->h[2];
> -       h3 =3D dctx->h[3];
> -       h4 =3D dctx->h[4];
> +       h0 =3D dctx->h.h[0];
> +       h1 =3D dctx->h.h[1];
> +       h2 =3D dctx->h.h[2];
> +       h3 =3D dctx->h.h[3];
> +       h4 =3D dctx->h.h[4];
>
>         h2 +=3D (h1 >> 26);     h1 =3D h1 & 0x3ffffff;
>         h3 +=3D (h2 >> 26);     h2 =3D h2 & 0x3ffffff;
> diff --git a/include/crypto/poly1305.h b/include/crypto/poly1305.h
> index f718a19da82f..493244c46664 100644
> --- a/include/crypto/poly1305.h
> +++ b/include/crypto/poly1305.h
> @@ -13,13 +13,21 @@
>  #define POLY1305_KEY_SIZE      32
>  #define POLY1305_DIGEST_SIZE   16
>
> +struct poly1305_key {
> +       u32 r[5];       /* key, base 2^26 */
> +};
> +
> +struct poly1305_state {
> +       u32 h[5];       /* accumulator, base 2^26 */
> +};
> +
>  struct poly1305_desc_ctx {
>         /* key */
> -       u32 r[5];
> +       struct poly1305_key r;
>         /* finalize key */
>         u32 s[4];
>         /* accumulator */
> -       u32 h[5];
> +       struct poly1305_state h;
>         /* partial buffer */
>         u8 buf[POLY1305_BLOCK_SIZE];
>         /* bytes used in partial buffer */
> --
> 2.19.1.1215.g8438c0b245-goog
>
