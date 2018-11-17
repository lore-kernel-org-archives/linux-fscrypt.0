Return-Path: <SRS0=3xn4=N4=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20181117012631.23528-1-ebiggers@kernel.org> <20181117012631.23528-12-ebiggers@kernel.org>
In-Reply-To: <20181117012631.23528-12-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Nov 2018 17:50:55 -0800
Message-ID: <CAKv+Gu-VicDdZqa=4nbo4EY5r2qTNngYuGyO-MymyoJ0NQP8tA@mail.gmail.com>
Subject: Re: [PATCH v4 11/14] crypto: poly1305 - add Poly1305 core API
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 16 Nov 2018 at 17:29, Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> Expose a low-level Poly1305 API which implements the
> =CE=B5-almost-=E2=88=86-universal (=CE=B5A=E2=88=86U) hash function under=
lying the Poly1305 MAC
> and supports block-aligned inputs only.
>
> This is needed for Adiantum hashing, which builds an =CE=B5A=E2=88=86U ha=
sh function
> from NH and a polynomial evaluation in GF(2^{130}-5); this polynomial
> evaluation is identical to the one the Poly1305 MAC does.  However, the
> crypto_shash Poly1305 API isn't very appropriate for this because its
> calling convention assumes it is used as a MAC, with a 32-byte "one-time
> key" provided for every digest.
>
> But by design, in Adiantum hashing the performance of the polynomial
> evaluation isn't nearly as critical as NH.  So it suffices to just have
> some C helper functions.  Thus, this patch adds such functions.
>
> Acked-by: Martin Willi <martin@strongswan.org>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  crypto/poly1305_generic.c | 174 ++++++++++++++++++++++----------------
>  include/crypto/poly1305.h |  16 ++++
>  2 files changed, 115 insertions(+), 75 deletions(-)
>
> diff --git a/crypto/poly1305_generic.c b/crypto/poly1305_generic.c
> index a23173f351b7..2a06874204e8 100644
> --- a/crypto/poly1305_generic.c
> +++ b/crypto/poly1305_generic.c
> @@ -38,7 +38,7 @@ int crypto_poly1305_init(struct shash_desc *desc)
>  {
>         struct poly1305_desc_ctx *dctx =3D shash_desc_ctx(desc);
>
> -       memset(dctx->h.h, 0, sizeof(dctx->h.h));
> +       poly1305_core_init(&dctx->h);
>         dctx->buflen =3D 0;
>         dctx->rset =3D false;
>         dctx->sset =3D false;
> @@ -47,23 +47,16 @@ int crypto_poly1305_init(struct shash_desc *desc)
>  }
>  EXPORT_SYMBOL_GPL(crypto_poly1305_init);
>
> -static void poly1305_setrkey(struct poly1305_desc_ctx *dctx, const u8 *k=
ey)
> +void poly1305_core_setkey(struct poly1305_key *key, const u8 *raw_key)
>  {
>         /* r &=3D 0xffffffc0ffffffc0ffffffc0fffffff */
> -       dctx->r.r[0] =3D (get_unaligned_le32(key +  0) >> 0) & 0x3ffffff;
> -       dctx->r.r[1] =3D (get_unaligned_le32(key +  3) >> 2) & 0x3ffff03;
> -       dctx->r.r[2] =3D (get_unaligned_le32(key +  6) >> 4) & 0x3ffc0ff;
> -       dctx->r.r[3] =3D (get_unaligned_le32(key +  9) >> 6) & 0x3f03fff;
> -       dctx->r.r[4] =3D (get_unaligned_le32(key + 12) >> 8) & 0x00fffff;
> -}
> -
> -static void poly1305_setskey(struct poly1305_desc_ctx *dctx, const u8 *k=
ey)
> -{
> -       dctx->s[0] =3D get_unaligned_le32(key +  0);
> -       dctx->s[1] =3D get_unaligned_le32(key +  4);
> -       dctx->s[2] =3D get_unaligned_le32(key +  8);
> -       dctx->s[3] =3D get_unaligned_le32(key + 12);
> +       key->r[0] =3D (get_unaligned_le32(raw_key +  0) >> 0) & 0x3ffffff=
;
> +       key->r[1] =3D (get_unaligned_le32(raw_key +  3) >> 2) & 0x3ffff03=
;
> +       key->r[2] =3D (get_unaligned_le32(raw_key +  6) >> 4) & 0x3ffc0ff=
;
> +       key->r[3] =3D (get_unaligned_le32(raw_key +  9) >> 6) & 0x3f03fff=
;
> +       key->r[4] =3D (get_unaligned_le32(raw_key + 12) >> 8) & 0x00fffff=
;
>  }
> +EXPORT_SYMBOL_GPL(poly1305_core_setkey);
>
>  /*
>   * Poly1305 requires a unique key for each tag, which implies that we ca=
n't set
> @@ -75,13 +68,16 @@ unsigned int crypto_poly1305_setdesckey(struct poly13=
05_desc_ctx *dctx,
>  {
>         if (!dctx->sset) {
>                 if (!dctx->rset && srclen >=3D POLY1305_BLOCK_SIZE) {
> -                       poly1305_setrkey(dctx, src);
> +                       poly1305_core_setkey(&dctx->r, src);
>                         src +=3D POLY1305_BLOCK_SIZE;
>                         srclen -=3D POLY1305_BLOCK_SIZE;
>                         dctx->rset =3D true;
>                 }
>                 if (srclen >=3D POLY1305_BLOCK_SIZE) {
> -                       poly1305_setskey(dctx, src);
> +                       dctx->s[0] =3D get_unaligned_le32(src +  0);
> +                       dctx->s[1] =3D get_unaligned_le32(src +  4);
> +                       dctx->s[2] =3D get_unaligned_le32(src +  8);
> +                       dctx->s[3] =3D get_unaligned_le32(src + 12);
>                         src +=3D POLY1305_BLOCK_SIZE;
>                         srclen -=3D POLY1305_BLOCK_SIZE;
>                         dctx->sset =3D true;
> @@ -91,41 +87,37 @@ unsigned int crypto_poly1305_setdesckey(struct poly13=
05_desc_ctx *dctx,
>  }
>  EXPORT_SYMBOL_GPL(crypto_poly1305_setdesckey);
>
> -static unsigned int poly1305_blocks(struct poly1305_desc_ctx *dctx,
> -                                   const u8 *src, unsigned int srclen,
> -                                   u32 hibit)
> +static void poly1305_blocks_internal(struct poly1305_state *state,
> +                                    const struct poly1305_key *key,
> +                                    const void *src, unsigned int nblock=
s,
> +                                    u32 hibit)
>  {
>         u32 r0, r1, r2, r3, r4;
>         u32 s1, s2, s3, s4;
>         u32 h0, h1, h2, h3, h4;
>         u64 d0, d1, d2, d3, d4;
> -       unsigned int datalen;
>
> -       if (unlikely(!dctx->sset)) {
> -               datalen =3D crypto_poly1305_setdesckey(dctx, src, srclen)=
;
> -               src +=3D srclen - datalen;
> -               srclen =3D datalen;
> -       }
> +       if (!nblocks)
> +               return;
>
> -       r0 =3D dctx->r.r[0];
> -       r1 =3D dctx->r.r[1];
> -       r2 =3D dctx->r.r[2];
> -       r3 =3D dctx->r.r[3];
> -       r4 =3D dctx->r.r[4];
> +       r0 =3D key->r[0];
> +       r1 =3D key->r[1];
> +       r2 =3D key->r[2];
> +       r3 =3D key->r[3];
> +       r4 =3D key->r[4];
>
>         s1 =3D r1 * 5;
>         s2 =3D r2 * 5;
>         s3 =3D r3 * 5;
>         s4 =3D r4 * 5;
>
> -       h0 =3D dctx->h.h[0];
> -       h1 =3D dctx->h.h[1];
> -       h2 =3D dctx->h.h[2];
> -       h3 =3D dctx->h.h[3];
> -       h4 =3D dctx->h.h[4];
> -
> -       while (likely(srclen >=3D POLY1305_BLOCK_SIZE)) {
> +       h0 =3D state->h[0];
> +       h1 =3D state->h[1];
> +       h2 =3D state->h[2];
> +       h3 =3D state->h[3];
> +       h4 =3D state->h[4];
>
> +       do {
>                 /* h +=3D m[i] */
>                 h0 +=3D (get_unaligned_le32(src +  0) >> 0) & 0x3ffffff;
>                 h1 +=3D (get_unaligned_le32(src +  3) >> 2) & 0x3ffffff;
> @@ -154,16 +146,36 @@ static unsigned int poly1305_blocks(struct poly1305=
_desc_ctx *dctx,
>                 h1 +=3D h0 >> 26;       h0 =3D h0 & 0x3ffffff;
>
>                 src +=3D POLY1305_BLOCK_SIZE;
> -               srclen -=3D POLY1305_BLOCK_SIZE;
> -       }
> +       } while (--nblocks);
>
> -       dctx->h.h[0] =3D h0;
> -       dctx->h.h[1] =3D h1;
> -       dctx->h.h[2] =3D h2;
> -       dctx->h.h[3] =3D h3;
> -       dctx->h.h[4] =3D h4;
> +       state->h[0] =3D h0;
> +       state->h[1] =3D h1;
> +       state->h[2] =3D h2;
> +       state->h[3] =3D h3;
> +       state->h[4] =3D h4;
> +}
>
> -       return srclen;
> +void poly1305_core_blocks(struct poly1305_state *state,
> +                         const struct poly1305_key *key,
> +                         const void *src, unsigned int nblocks)
> +{
> +       poly1305_blocks_internal(state, key, src, nblocks, 1 << 24);
> +}
> +EXPORT_SYMBOL_GPL(poly1305_core_blocks);
> +
> +static void poly1305_blocks(struct poly1305_desc_ctx *dctx,
> +                           const u8 *src, unsigned int srclen, u32 hibit=
)
> +{
> +       unsigned int datalen;
> +
> +       if (unlikely(!dctx->sset)) {
> +               datalen =3D crypto_poly1305_setdesckey(dctx, src, srclen)=
;
> +               src +=3D srclen - datalen;
> +               srclen =3D datalen;
> +       }
> +
> +       poly1305_blocks_internal(&dctx->h, &dctx->r,
> +                                src, srclen / POLY1305_BLOCK_SIZE, hibit=
);
>  }
>
>  int crypto_poly1305_update(struct shash_desc *desc,
> @@ -187,9 +199,9 @@ int crypto_poly1305_update(struct shash_desc *desc,
>         }
>
>         if (likely(srclen >=3D POLY1305_BLOCK_SIZE)) {
> -               bytes =3D poly1305_blocks(dctx, src, srclen, 1 << 24);
> -               src +=3D srclen - bytes;
> -               srclen =3D bytes;
> +               poly1305_blocks(dctx, src, srclen, 1 << 24);
> +               src +=3D srclen - (srclen % POLY1305_BLOCK_SIZE);
> +               srclen %=3D POLY1305_BLOCK_SIZE;
>         }
>
>         if (unlikely(srclen)) {
> @@ -201,30 +213,18 @@ int crypto_poly1305_update(struct shash_desc *desc,
>  }
>  EXPORT_SYMBOL_GPL(crypto_poly1305_update);
>
> -int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
> +void poly1305_core_emit(const struct poly1305_state *state, void *dst)
>  {
> -       struct poly1305_desc_ctx *dctx =3D shash_desc_ctx(desc);
>         u32 h0, h1, h2, h3, h4;
>         u32 g0, g1, g2, g3, g4;
>         u32 mask;
> -       u64 f =3D 0;
> -
> -       if (unlikely(!dctx->sset))
> -               return -ENOKEY;
> -
> -       if (unlikely(dctx->buflen)) {
> -               dctx->buf[dctx->buflen++] =3D 1;
> -               memset(dctx->buf + dctx->buflen, 0,
> -                      POLY1305_BLOCK_SIZE - dctx->buflen);
> -               poly1305_blocks(dctx, dctx->buf, POLY1305_BLOCK_SIZE, 0);
> -       }
>
>         /* fully carry h */
> -       h0 =3D dctx->h.h[0];
> -       h1 =3D dctx->h.h[1];
> -       h2 =3D dctx->h.h[2];
> -       h3 =3D dctx->h.h[3];
> -       h4 =3D dctx->h.h[4];
> +       h0 =3D state->h[0];
> +       h1 =3D state->h[1];
> +       h2 =3D state->h[2];
> +       h3 =3D state->h[3];
> +       h4 =3D state->h[4];
>
>         h2 +=3D (h1 >> 26);     h1 =3D h1 & 0x3ffffff;
>         h3 +=3D (h2 >> 26);     h2 =3D h2 & 0x3ffffff;
> @@ -254,16 +254,40 @@ int crypto_poly1305_final(struct shash_desc *desc, =
u8 *dst)
>         h4 =3D (h4 & mask) | g4;
>
>         /* h =3D h % (2^128) */
> -       h0 =3D (h0 >>  0) | (h1 << 26);
> -       h1 =3D (h1 >>  6) | (h2 << 20);
> -       h2 =3D (h2 >> 12) | (h3 << 14);
> -       h3 =3D (h3 >> 18) | (h4 <<  8);
> +       put_unaligned_le32((h0 >>  0) | (h1 << 26), dst +  0);
> +       put_unaligned_le32((h1 >>  6) | (h2 << 20), dst +  4);
> +       put_unaligned_le32((h2 >> 12) | (h3 << 14), dst +  8);
> +       put_unaligned_le32((h3 >> 18) | (h4 <<  8), dst + 12);
> +}
> +EXPORT_SYMBOL_GPL(poly1305_core_emit);
> +
> +int crypto_poly1305_final(struct shash_desc *desc, u8 *dst)
> +{
> +       struct poly1305_desc_ctx *dctx =3D shash_desc_ctx(desc);
> +       __le32 digest[4];
> +       u64 f =3D 0;
> +
> +       if (unlikely(!dctx->sset))
> +               return -ENOKEY;
> +
> +       if (unlikely(dctx->buflen)) {
> +               dctx->buf[dctx->buflen++] =3D 1;
> +               memset(dctx->buf + dctx->buflen, 0,
> +                      POLY1305_BLOCK_SIZE - dctx->buflen);
> +               poly1305_blocks(dctx, dctx->buf, POLY1305_BLOCK_SIZE, 0);
> +       }
> +
> +       poly1305_core_emit(&dctx->h, digest);
>
>         /* mac =3D (h + s) % (2^128) */
> -       f =3D (f >> 32) + h0 + dctx->s[0]; put_unaligned_le32(f, dst +  0=
);
> -       f =3D (f >> 32) + h1 + dctx->s[1]; put_unaligned_le32(f, dst +  4=
);
> -       f =3D (f >> 32) + h2 + dctx->s[2]; put_unaligned_le32(f, dst +  8=
);
> -       f =3D (f >> 32) + h3 + dctx->s[3]; put_unaligned_le32(f, dst + 12=
);
> +       f =3D (f >> 32) + le32_to_cpu(digest[0]) + dctx->s[0];
> +       put_unaligned_le32(f, dst + 0);
> +       f =3D (f >> 32) + le32_to_cpu(digest[1]) + dctx->s[1];
> +       put_unaligned_le32(f, dst + 4);
> +       f =3D (f >> 32) + le32_to_cpu(digest[2]) + dctx->s[2];
> +       put_unaligned_le32(f, dst + 8);
> +       f =3D (f >> 32) + le32_to_cpu(digest[3]) + dctx->s[3];
> +       put_unaligned_le32(f, dst + 12);
>
>         return 0;
>  }
> diff --git a/include/crypto/poly1305.h b/include/crypto/poly1305.h
> index 493244c46664..34317ed2071e 100644
> --- a/include/crypto/poly1305.h
> +++ b/include/crypto/poly1305.h
> @@ -38,6 +38,22 @@ struct poly1305_desc_ctx {
>         bool sset;
>  };
>
> +/*
> + * Poly1305 core functions.  These implement the =CE=B5-almost-=E2=88=86=
-universal hash
> + * function underlying the Poly1305 MAC, i.e. they don't add an encrypte=
d nonce
> + * ("s key") at the end.  They also only support block-aligned inputs.
> + */
> +void poly1305_core_setkey(struct poly1305_key *key, const u8 *raw_key);
> +static inline void poly1305_core_init(struct poly1305_state *state)
> +{
> +       memset(state->h, 0, sizeof(state->h));
> +}
> +void poly1305_core_blocks(struct poly1305_state *state,
> +                         const struct poly1305_key *key,
> +                         const void *src, unsigned int nblocks);
> +void poly1305_core_emit(const struct poly1305_state *state, void *dst);
> +
> +/* Crypto API helper functions for the Poly1305 MAC */
>  int crypto_poly1305_init(struct shash_desc *desc);
>  unsigned int crypto_poly1305_setdesckey(struct poly1305_desc_ctx *dctx,
>                                         const u8 *src, unsigned int srcle=
n);
> --
> 2.19.1.1215.g8438c0b245-goog
>
