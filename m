Return-Path: <SRS0=3xn4=N4=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20181117012631.23528-1-ebiggers@kernel.org> <20181117012631.23528-15-ebiggers@kernel.org>
In-Reply-To: <20181117012631.23528-15-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Nov 2018 18:03:15 -0800
Message-ID: <CAKv+Gu8CQDChr8V4uSzwHMLGV==r-B+zDvaRpd67+s6qtumC=Q@mail.gmail.com>
Subject: Re: [PATCH v4 14/14] crypto: adiantum - add Adiantum support
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 16 Nov 2018 at 17:29, Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> Add support for the Adiantum encryption mode.  Adiantum was designed by
> Paul Crowley and is specified by our paper:
>
>     Adiantum: length-preserving encryption for entry-level processors
>     (https://eprint.iacr.org/2018/720.pdf)
>
> See our paper for full details; this patch only provides an overview.
>
> Adiantum is a tweakable, length-preserving encryption mode designed for
> fast and secure disk encryption, especially on CPUs without dedicated
> crypto instructions.  Adiantum encrypts each sector using the XChaCha12
> stream cipher, two passes of an =CE=B5-almost-=E2=88=86-universal (=CE=B5=
A=E2=88=86U) hash
> function, and an invocation of the AES-256 block cipher on a single
> 16-byte block.  On CPUs without AES instructions, Adiantum is much
> faster than AES-XTS; for example, on ARM Cortex-A7, on 4096-byte sectors
> Adiantum encryption is about 4 times faster than AES-256-XTS encryption,
> and decryption about 5 times faster.
>
> Adiantum is a specialization of the more general HBSH construction.  Our
> earlier proposal, HPolyC, was also a HBSH specialization, but it used a
> different =CE=B5A=E2=88=86U hash function, one based on Poly1305 only.  A=
diantum's
> =CE=B5A=E2=88=86U hash function, which is based primarily on the "NH" has=
h function
> like that used in UMAC (RFC4418), is about twice as fast as HPolyC's;
> consequently, Adiantum is about 20% faster than HPolyC.
>
> This speed comes with no loss of security: Adiantum is provably just as
> secure as HPolyC, in fact slightly *more* secure.  Like HPolyC,
> Adiantum's security is reducible to that of XChaCha12 and AES-256,
> subject to a security bound.  XChaCha12 itself has a security reduction
> to ChaCha12.  Therefore, one need not "trust" Adiantum; one need only
> trust ChaCha12 and AES-256.  Note that the =CE=B5A=E2=88=86U hash functio=
n is only
> used for its proven combinatorical properties so cannot be "broken".
>
> Adiantum is also a true wide-block encryption mode, so flipping any
> plaintext bit in the sector scrambles the entire ciphertext, and vice
> versa.  No other such mode is available in the kernel currently; doing
> the same with XTS scrambles only 16 bytes.  Adiantum also supports
> arbitrary-length tweaks and naturally supports any length input >=3D 16
> bytes without needing "ciphertext stealing".
>
> For the stream cipher, Adiantum uses XChaCha12 rather than XChaCha20 in
> order to make encryption feasible on the widest range of devices.
> Although the 20-round variant is quite popular, the best known attacks
> on ChaCha are on only 7 rounds, so ChaCha12 still has a substantial
> security margin; in fact, larger than AES-256's.  12-round Salsa20 is
> also the eSTREAM recommendation.  For the block cipher, Adiantum uses
> AES-256, despite it having a lower security margin than XChaCha12 and
> needing table lookups, due to AES's extensive adoption and analysis
> making it the obvious first choice.  Nevertheless, for flexibility this
> patch also permits the "adiantum" template to be instantiated with
> XChaCha20 and/or with an alternate block cipher.
>
> We need Adiantum support in the kernel for use in dm-crypt and fscrypt,
> where currently the only other suitable options are block cipher modes
> such as AES-XTS.  A big problem with this is that many low-end mobile
> devices (e.g. Android Go phones sold primarily in developing countries,
> as well as some smartwatches) still have CPUs that lack AES
> instructions, e.g. ARM Cortex-A7.  Sadly, AES-XTS encryption is much too
> slow to be viable on these devices.  We did find that some "lightweight"
> block ciphers are fast enough, but these suffer from problems such as
> not having much cryptanalysis or being too controversial.
>
> The ChaCha stream cipher has excellent performance but is insecure to
> use directly for disk encryption, since each sector's IV is reused each
> time it is overwritten.  Even restricting the threat model to offline
> attacks only isn't enough, since modern flash storage devices don't
> guarantee that "overwrites" are really overwrites, due to wear-leveling.
> Adiantum avoids this problem by constructing a
> "tweakable super-pseudorandom permutation"; this is the strongest
> possible security model for length-preserving encryption.
>
> Of course, storing random nonces along with the ciphertext would be the
> ideal solution.  But doing that with existing hardware and filesystems
> runs into major practical problems; in most cases it would require data
> journaling (like dm-integrity) which severely degrades performance.
> Thus, for now length-preserving encryption is still needed.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  crypto/Kconfig    |  23 ++
>  crypto/Makefile   |   1 +
>  crypto/adiantum.c | 658 ++++++++++++++++++++++++++++++++++++++++++++++
>  crypto/tcrypt.c   |  12 +
>  crypto/testmgr.c  |  12 +
>  crypto/testmgr.h  | 461 ++++++++++++++++++++++++++++++++
>  6 files changed, 1167 insertions(+)
>  create mode 100644 crypto/adiantum.c
>
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index eaeb8a986b7d..b6376d5d973e 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -501,6 +501,29 @@ config CRYPTO_NHPOLY1305
>         select CRYPTO_HASH
>         select CRYPTO_POLY1305
>
> +config CRYPTO_ADIANTUM
> +       tristate "Adiantum support"
> +       select CRYPTO_CHACHA20
> +       select CRYPTO_POLY1305
> +       select CRYPTO_NHPOLY1305
> +       help
> +         Adiantum is a tweakable, length-preserving encryption mode
> +         designed for fast and secure disk encryption, especially on
> +         CPUs without dedicated crypto instructions.  It encrypts
> +         each sector using the XChaCha12 stream cipher, two passes of
> +         an =CE=B5-almost-=E2=88=86-universal hash function, and an invo=
cation of
> +         the AES-256 block cipher on a single 16-byte block.  On CPUs
> +         without AES instructions, Adiantum is much faster than
> +         AES-XTS.
> +
> +         Adiantum's security is provably reducible to that of its
> +         underlying stream and block ciphers, subject to a security
> +         bound.  Unlike XTS, Adiantum is a true wide-block encryption
> +         mode, so it actually provides an even stronger notion of
> +         security than XTS, subject to the security bound.
> +
> +         If unsure, say N.
> +
>  comment "Hash modes"
>
>  config CRYPTO_CMAC
> diff --git a/crypto/Makefile b/crypto/Makefile
> index c3310c85f09f..5e789dc2d4fd 100644
> --- a/crypto/Makefile
> +++ b/crypto/Makefile
> @@ -85,6 +85,7 @@ obj-$(CONFIG_CRYPTO_LRW) +=3D lrw.o
>  obj-$(CONFIG_CRYPTO_XTS) +=3D xts.o
>  obj-$(CONFIG_CRYPTO_CTR) +=3D ctr.o
>  obj-$(CONFIG_CRYPTO_KEYWRAP) +=3D keywrap.o
> +obj-$(CONFIG_CRYPTO_ADIANTUM) +=3D adiantum.o
>  obj-$(CONFIG_CRYPTO_NHPOLY1305) +=3D nhpoly1305.o
>  obj-$(CONFIG_CRYPTO_GCM) +=3D gcm.o
>  obj-$(CONFIG_CRYPTO_CCM) +=3D ccm.o
> diff --git a/crypto/adiantum.c b/crypto/adiantum.c
> new file mode 100644
> index 000000000000..2dfcf12fd452
> --- /dev/null
> +++ b/crypto/adiantum.c
> @@ -0,0 +1,658 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * Adiantum length-preserving encryption mode
> + *
> + * Copyright 2018 Google LLC
> + */
> +
> +/*
> + * Adiantum is a tweakable, length-preserving encryption mode designed f=
or fast
> + * and secure disk encryption, especially on CPUs without dedicated cryp=
to
> + * instructions.  Adiantum encrypts each sector using the XChaCha12 stre=
am
> + * cipher, two passes of an =CE=B5-almost-=E2=88=86-universal (=CE=B5A=
=E2=88=86U) hash function based on
> + * NH and Poly1305, and an invocation of the AES-256 block cipher on a s=
ingle
> + * 16-byte block.  See the paper for details:
> + *
> + *     Adiantum: length-preserving encryption for entry-level processors
> + *      (https://eprint.iacr.org/2018/720.pdf)
> + *
> + * For flexibility, this implementation also allows other ciphers:
> + *
> + *     - Stream cipher: XChaCha12 or XChaCha20
> + *     - Block cipher: any with a 128-bit block size and 256-bit key
> + *
> + * This implementation doesn't currently allow other =CE=B5A=E2=88=86U h=
ash functions, i.e.
> + * HPolyC is not supported.  This is because Adiantum is ~20% faster tha=
n HPolyC
> + * but still provably as secure, and also the =CE=B5A=E2=88=86U hash fun=
ction of HBSH is
> + * formally defined to take two inputs (tweak, message) which makes it d=
ifficult
> + * to wrap with the crypto_shash API.  Rather, some details need to be h=
andled
> + * here.  Nevertheless, if needed in the future, support for other =CE=
=B5A=E2=88=86U hash
> + * functions could be added here.
> + */
> +
> +#include <crypto/b128ops.h>
> +#include <crypto/chacha.h>
> +#include <crypto/internal/hash.h>
> +#include <crypto/internal/skcipher.h>
> +#include <crypto/nhpoly1305.h>
> +#include <crypto/scatterwalk.h>
> +#include <linux/module.h>
> +
> +#include "internal.h"
> +
> +/*
> + * Size of right-hand block of input data, in bytes; also the size of th=
e block
> + * cipher's block size and the hash function's output.
> + */
> +#define BLOCKCIPHER_BLOCK_SIZE         16
> +
> +/* Size of the block cipher key (K_E) in bytes */
> +#define BLOCKCIPHER_KEY_SIZE           32
> +
> +/* Size of the hash key (K_H) in bytes */
> +#define HASH_KEY_SIZE          (POLY1305_BLOCK_SIZE + NHPOLY1305_KEY_SIZ=
E)
> +
> +/*
> + * The specification allows variable-length tweaks, but Linux's crypto A=
PI
> + * currently only allows algorithms to support a single length.  The "na=
tural"
> + * tweak length for Adiantum is 16, since that fits into one Poly1305 bl=
ock for
> + * the best performance.  But longer tweaks are useful for fscrypt, to a=
void
> + * needing to derive per-file keys.  So instead we use two blocks, or 32=
 bytes.
> + */
> +#define TWEAK_SIZE             32
> +
> +struct adiantum_instance_ctx {
> +       struct crypto_skcipher_spawn streamcipher_spawn;
> +       struct crypto_spawn blockcipher_spawn;
> +       struct crypto_shash_spawn hash_spawn;
> +};
> +
> +struct adiantum_tfm_ctx {
> +       struct crypto_skcipher *streamcipher;
> +       struct crypto_cipher *blockcipher;
> +       struct crypto_shash *hash;
> +       struct poly1305_key header_hash_key;
> +};
> +
> +struct adiantum_request_ctx {
> +
> +       /*
> +        * Buffer for right-hand block of data, i.e.
> +        *
> +        *    P_L =3D> P_M =3D> C_M =3D> C_R when encrypting, or
> +        *    C_R =3D> C_M =3D> P_M =3D> P_L when decrypting.
> +        *
> +        * Also used to build the IV for the stream cipher.
> +        */
> +       union {
> +               u8 bytes[XCHACHA_IV_SIZE];
> +               __le32 words[XCHACHA_IV_SIZE / sizeof(__le32)];
> +               le128 bignum;   /* interpret as element of Z/(2^{128}Z) *=
/
> +       } rbuf;
> +
> +       bool enc; /* true if encrypting, false if decrypting */
> +
> +       /*
> +        * The result of the Poly1305 =CE=B5A=E2=88=86U hash function app=
lied to
> +        * (message length, tweak).
> +        */
> +       le128 header_hash;
> +
> +       /* Sub-requests, must be last */
> +       union {
> +               struct shash_desc hash_desc;
> +               struct skcipher_request streamcipher_req;
> +       } u;
> +};
> +
> +/*
> + * Given the XChaCha stream key K_S, derive the block cipher key K_E and=
 the
> + * hash key K_H as follows:
> + *
> + *     K_E || K_H || ... =3D XChaCha(key=3DK_S, nonce=3D1||0^191)
> + *
> + * Note that this denotes using bits from the XChaCha keystream, which h=
ere we
> + * get indirectly by encrypting a buffer containing all 0's.
> + */
> +static int adiantum_setkey(struct crypto_skcipher *tfm, const u8 *key,
> +                          unsigned int keylen)
> +{
> +       struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct {
> +               u8 iv[XCHACHA_IV_SIZE];
> +               u8 derived_keys[BLOCKCIPHER_KEY_SIZE + HASH_KEY_SIZE];
> +               struct scatterlist sg;
> +               struct crypto_wait wait;
> +               struct skcipher_request req; /* must be last */
> +       } *data;
> +       u8 *keyp;
> +       int err;
> +
> +       /* Set the stream cipher key (K_S) */
> +       crypto_skcipher_clear_flags(tctx->streamcipher, CRYPTO_TFM_REQ_MA=
SK);
> +       crypto_skcipher_set_flags(tctx->streamcipher,
> +                                 crypto_skcipher_get_flags(tfm) &
> +                                 CRYPTO_TFM_REQ_MASK);
> +       err =3D crypto_skcipher_setkey(tctx->streamcipher, key, keylen);
> +       crypto_skcipher_set_flags(tfm,
> +                               crypto_skcipher_get_flags(tctx->streamcip=
her) &
> +                               CRYPTO_TFM_RES_MASK);
> +       if (err)
> +               return err;
> +
> +       /* Derive the subkeys */
> +       data =3D kzalloc(sizeof(*data) +
> +                      crypto_skcipher_reqsize(tctx->streamcipher), GFP_K=
ERNEL);
> +       if (!data)
> +               return -ENOMEM;
> +       data->iv[0] =3D 1;
> +       sg_init_one(&data->sg, data->derived_keys, sizeof(data->derived_k=
eys));
> +       crypto_init_wait(&data->wait);
> +       skcipher_request_set_tfm(&data->req, tctx->streamcipher);
> +       skcipher_request_set_callback(&data->req, CRYPTO_TFM_REQ_MAY_SLEE=
P |
> +                                                 CRYPTO_TFM_REQ_MAY_BACK=
LOG,
> +                                     crypto_req_done, &data->wait);
> +       skcipher_request_set_crypt(&data->req, &data->sg, &data->sg,
> +                                  sizeof(data->derived_keys), data->iv);
> +       err =3D crypto_wait_req(crypto_skcipher_encrypt(&data->req), &dat=
a->wait);
> +       if (err)
> +               goto out;
> +       keyp =3D data->derived_keys;
> +
> +       /* Set the block cipher key (K_E) */
> +       crypto_cipher_clear_flags(tctx->blockcipher, CRYPTO_TFM_REQ_MASK)=
;
> +       crypto_cipher_set_flags(tctx->blockcipher,
> +                               crypto_skcipher_get_flags(tfm) &
> +                               CRYPTO_TFM_REQ_MASK);
> +       err =3D crypto_cipher_setkey(tctx->blockcipher, keyp,
> +                                  BLOCKCIPHER_KEY_SIZE);
> +       crypto_skcipher_set_flags(tfm,
> +                                 crypto_cipher_get_flags(tctx->blockciph=
er) &
> +                                 CRYPTO_TFM_RES_MASK);
> +       if (err)
> +               goto out;
> +       keyp +=3D BLOCKCIPHER_KEY_SIZE;
> +
> +       /* Set the hash key (K_H) */
> +       poly1305_core_setkey(&tctx->header_hash_key, keyp);
> +       keyp +=3D POLY1305_BLOCK_SIZE;
> +
> +       crypto_shash_clear_flags(tctx->hash, CRYPTO_TFM_REQ_MASK);
> +       crypto_shash_set_flags(tctx->hash, crypto_skcipher_get_flags(tfm)=
 &
> +                                          CRYPTO_TFM_REQ_MASK);
> +       err =3D crypto_shash_setkey(tctx->hash, keyp, NHPOLY1305_KEY_SIZE=
);
> +       crypto_skcipher_set_flags(tfm, crypto_shash_get_flags(tctx->hash)=
 &
> +                                      CRYPTO_TFM_RES_MASK);
> +       keyp +=3D NHPOLY1305_KEY_SIZE;
> +       WARN_ON(keyp !=3D &data->derived_keys[ARRAY_SIZE(data->derived_ke=
ys)]);
> +out:
> +       kzfree(data);
> +       return err;
> +}
> +
> +/* Addition in Z/(2^{128}Z) */
> +static inline void le128_add(le128 *r, const le128 *v1, const le128 *v2)
> +{
> +       u64 x =3D le64_to_cpu(v1->b);
> +       u64 y =3D le64_to_cpu(v2->b);
> +
> +       r->b =3D cpu_to_le64(x + y);
> +       r->a =3D cpu_to_le64(le64_to_cpu(v1->a) + le64_to_cpu(v2->a) +
> +                          (x + y < x));
> +}
> +
> +/* Subtraction in Z/(2^{128}Z) */
> +static inline void le128_sub(le128 *r, const le128 *v1, const le128 *v2)
> +{
> +       u64 x =3D le64_to_cpu(v1->b);
> +       u64 y =3D le64_to_cpu(v2->b);
> +
> +       r->b =3D cpu_to_le64(x - y);
> +       r->a =3D cpu_to_le64(le64_to_cpu(v1->a) - le64_to_cpu(v2->a) -
> +                          (x - y > x));
> +}
> +
> +/*
> + * Apply the Poly1305 =CE=B5A=E2=88=86U hash function to (message length=
, tweak) and save the
> + * result to rctx->header_hash.
> + *
> + * This value is reused in both the first and second hash steps.  Specif=
ically,
> + * it's added to the result of an independently keyed =CE=B5A=E2=88=86U =
hash function (for
> + * equal length inputs only) taken over the message.  This gives the ove=
rall
> + * Adiantum hash of the (tweak, message) pair.
> + */
> +static void adiantum_hash_header(struct skcipher_request *req)
> +{
> +       struct crypto_skcipher *tfm =3D crypto_skcipher_reqtfm(req);
> +       const struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct adiantum_request_ctx *rctx =3D skcipher_request_ctx(req);
> +       const unsigned int bulk_len =3D req->cryptlen - BLOCKCIPHER_BLOCK=
_SIZE;
> +       struct {
> +               __le64 message_bits;
> +               __le64 padding;
> +       } header =3D {
> +               .message_bits =3D cpu_to_le64((u64)bulk_len * 8)
> +       };
> +       struct poly1305_state state;
> +
> +       poly1305_core_init(&state);
> +
> +       BUILD_BUG_ON(sizeof(header) % POLY1305_BLOCK_SIZE !=3D 0);
> +       poly1305_core_blocks(&state, &tctx->header_hash_key,
> +                            &header, sizeof(header) / POLY1305_BLOCK_SIZ=
E);
> +
> +       BUILD_BUG_ON(TWEAK_SIZE % POLY1305_BLOCK_SIZE !=3D 0);
> +       poly1305_core_blocks(&state, &tctx->header_hash_key, req->iv,
> +                            TWEAK_SIZE / POLY1305_BLOCK_SIZE);
> +
> +       poly1305_core_emit(&state, &rctx->header_hash);
> +}
> +
> +/* Hash the left-hand block (the "bulk") of the message using NHPoly1305=
 */
> +static int adiantum_hash_message(struct skcipher_request *req,
> +                                struct scatterlist *sgl, le128 *digest)
> +{
> +       struct crypto_skcipher *tfm =3D crypto_skcipher_reqtfm(req);
> +       const struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct adiantum_request_ctx *rctx =3D skcipher_request_ctx(req);
> +       const unsigned int bulk_len =3D req->cryptlen - BLOCKCIPHER_BLOCK=
_SIZE;
> +       struct shash_desc *hash_desc =3D &rctx->u.hash_desc;
> +       struct sg_mapping_iter miter;
> +       unsigned int i, n;
> +       int err;
> +
> +       hash_desc->tfm =3D tctx->hash;
> +       hash_desc->flags =3D 0;
> +
> +       err =3D crypto_shash_init(hash_desc);
> +       if (err)
> +               return err;
> +
> +       sg_miter_start(&miter, sgl, sg_nents(sgl),
> +                      SG_MITER_FROM_SG | SG_MITER_ATOMIC);
> +       for (i =3D 0; i < bulk_len; i +=3D n) {
> +               sg_miter_next(&miter);
> +               n =3D min_t(unsigned int, miter.length, bulk_len - i);
> +               err =3D crypto_shash_update(hash_desc, miter.addr, n);
> +               if (err)
> +                       break;
> +       }
> +       sg_miter_stop(&miter);
> +       if (err)
> +               return err;
> +
> +       return crypto_shash_final(hash_desc, (u8 *)digest);
> +}
> +
> +/* Continue Adiantum encryption/decryption after the stream cipher step =
*/
> +static int adiantum_finish(struct skcipher_request *req)
> +{
> +       struct crypto_skcipher *tfm =3D crypto_skcipher_reqtfm(req);
> +       const struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct adiantum_request_ctx *rctx =3D skcipher_request_ctx(req);
> +       const unsigned int bulk_len =3D req->cryptlen - BLOCKCIPHER_BLOCK=
_SIZE;
> +       le128 digest;
> +       int err;
> +
> +       /* If decrypting, decrypt C_M with the block cipher to get P_M */
> +       if (!rctx->enc)
> +               crypto_cipher_decrypt_one(tctx->blockcipher, rctx->rbuf.b=
ytes,
> +                                         rctx->rbuf.bytes);
> +
> +       /*
> +        * Second hash step
> +        *      enc: C_R =3D C_M - H_{K_H}(T, C_L)
> +        *      dec: P_R =3D P_M - H_{K_H}(T, P_L)
> +        */
> +       err =3D adiantum_hash_message(req, req->dst, &digest);
> +       if (err)
> +               return err;
> +       le128_add(&digest, &digest, &rctx->header_hash);
> +       le128_sub(&rctx->rbuf.bignum, &rctx->rbuf.bignum, &digest);
> +       scatterwalk_map_and_copy(&rctx->rbuf.bignum, req->dst,
> +                                bulk_len, BLOCKCIPHER_BLOCK_SIZE, 1);
> +       return 0;
> +}
> +
> +static void adiantum_streamcipher_done(struct crypto_async_request *areq=
,
> +                                      int err)
> +{
> +       struct skcipher_request *req =3D areq->data;
> +
> +       if (!err)
> +               err =3D adiantum_finish(req);
> +
> +       skcipher_request_complete(req, err);
> +}
> +
> +static int adiantum_crypt(struct skcipher_request *req, bool enc)
> +{
> +       struct crypto_skcipher *tfm =3D crypto_skcipher_reqtfm(req);
> +       const struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct adiantum_request_ctx *rctx =3D skcipher_request_ctx(req);
> +       const unsigned int bulk_len =3D req->cryptlen - BLOCKCIPHER_BLOCK=
_SIZE;
> +       unsigned int stream_len;
> +       le128 digest;
> +       int err;
> +
> +       if (req->cryptlen < BLOCKCIPHER_BLOCK_SIZE)
> +               return -EINVAL;
> +
> +       rctx->enc =3D enc;
> +
> +       /*
> +        * First hash step
> +        *      enc: P_M =3D P_R + H_{K_H}(T, P_L)
> +        *      dec: C_M =3D C_R + H_{K_H}(T, C_L)
> +        */
> +       adiantum_hash_header(req);
> +       err =3D adiantum_hash_message(req, req->src, &digest);
> +       if (err)
> +               return err;
> +       le128_add(&digest, &digest, &rctx->header_hash);
> +       scatterwalk_map_and_copy(&rctx->rbuf.bignum, req->src,
> +                                bulk_len, BLOCKCIPHER_BLOCK_SIZE, 0);
> +       le128_add(&rctx->rbuf.bignum, &rctx->rbuf.bignum, &digest);
> +
> +       /* If encrypting, encrypt P_M with the block cipher to get C_M */
> +       if (enc)
> +               crypto_cipher_encrypt_one(tctx->blockcipher, rctx->rbuf.b=
ytes,
> +                                         rctx->rbuf.bytes);
> +
> +       /* Initialize the rest of the XChaCha IV (first part is C_M) */
> +       BUILD_BUG_ON(BLOCKCIPHER_BLOCK_SIZE !=3D 16);
> +       BUILD_BUG_ON(XCHACHA_IV_SIZE !=3D 32);    /* nonce || stream posi=
tion */
> +       rctx->rbuf.words[4] =3D cpu_to_le32(1);
> +       rctx->rbuf.words[5] =3D 0;
> +       rctx->rbuf.words[6] =3D 0;
> +       rctx->rbuf.words[7] =3D 0;
> +
> +       /*
> +        * XChaCha needs to be done on all the data except the last 16 by=
tes;
> +        * for disk encryption that usually means 4080 or 496 bytes.  But=
 ChaCha
> +        * implementations tend to be most efficient when passed a whole =
number
> +        * of 64-byte ChaCha blocks, or sometimes even a multiple of 256 =
bytes.
> +        * And here it doesn't matter whether the last 16 bytes are writt=
en to,
> +        * as the second hash step will overwrite them.  Thus, round the =
XChaCha
> +        * length up to the next 64-byte boundary if possible.
> +        */
> +       stream_len =3D bulk_len;
> +       if (round_up(stream_len, CHACHA_BLOCK_SIZE) <=3D req->cryptlen)
> +               stream_len =3D round_up(stream_len, CHACHA_BLOCK_SIZE);
> +
> +       skcipher_request_set_tfm(&rctx->u.streamcipher_req, tctx->streamc=
ipher);
> +       skcipher_request_set_crypt(&rctx->u.streamcipher_req, req->src,
> +                                  req->dst, stream_len, &rctx->rbuf);
> +       skcipher_request_set_callback(&rctx->u.streamcipher_req,
> +                                     req->base.flags,
> +                                     adiantum_streamcipher_done, req);
> +       return crypto_skcipher_encrypt(&rctx->u.streamcipher_req) ?:
> +               adiantum_finish(req);
> +}
> +
> +static int adiantum_encrypt(struct skcipher_request *req)
> +{
> +       return adiantum_crypt(req, true);
> +}
> +
> +static int adiantum_decrypt(struct skcipher_request *req)
> +{
> +       return adiantum_crypt(req, false);
> +}
> +
> +static int adiantum_init_tfm(struct crypto_skcipher *tfm)
> +{
> +       struct skcipher_instance *inst =3D skcipher_alg_instance(tfm);
> +       struct adiantum_instance_ctx *ictx =3D skcipher_instance_ctx(inst=
);
> +       struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +       struct crypto_skcipher *streamcipher;
> +       struct crypto_cipher *blockcipher;
> +       struct crypto_shash *hash;
> +       unsigned int subreq_size;
> +       int err;
> +
> +       streamcipher =3D crypto_spawn_skcipher(&ictx->streamcipher_spawn)=
;
> +       if (IS_ERR(streamcipher))
> +               return PTR_ERR(streamcipher);
> +
> +       blockcipher =3D crypto_spawn_cipher(&ictx->blockcipher_spawn);
> +       if (IS_ERR(blockcipher)) {
> +               err =3D PTR_ERR(blockcipher);
> +               goto err_free_streamcipher;
> +       }
> +
> +       hash =3D crypto_spawn_shash(&ictx->hash_spawn);
> +       if (IS_ERR(hash)) {
> +               err =3D PTR_ERR(hash);
> +               goto err_free_blockcipher;
> +       }
> +
> +       tctx->streamcipher =3D streamcipher;
> +       tctx->blockcipher =3D blockcipher;
> +       tctx->hash =3D hash;
> +
> +       BUILD_BUG_ON(offsetofend(struct adiantum_request_ctx, u) !=3D
> +                    sizeof(struct adiantum_request_ctx));
> +       subreq_size =3D max(FIELD_SIZEOF(struct adiantum_request_ctx,
> +                                      u.hash_desc) +
> +                         crypto_shash_descsize(hash),
> +                         FIELD_SIZEOF(struct adiantum_request_ctx,
> +                                      u.streamcipher_req) +
> +                         crypto_skcipher_reqsize(streamcipher));
> +
> +       crypto_skcipher_set_reqsize(tfm,
> +                                   offsetof(struct adiantum_request_ctx,=
 u) +
> +                                   subreq_size);
> +       return 0;
> +
> +err_free_blockcipher:
> +       crypto_free_cipher(blockcipher);
> +err_free_streamcipher:
> +       crypto_free_skcipher(streamcipher);
> +       return err;
> +}
> +
> +static void adiantum_exit_tfm(struct crypto_skcipher *tfm)
> +{
> +       struct adiantum_tfm_ctx *tctx =3D crypto_skcipher_ctx(tfm);
> +
> +       crypto_free_skcipher(tctx->streamcipher);
> +       crypto_free_cipher(tctx->blockcipher);
> +       crypto_free_shash(tctx->hash);
> +}
> +
> +static void adiantum_free_instance(struct skcipher_instance *inst)
> +{
> +       struct adiantum_instance_ctx *ictx =3D skcipher_instance_ctx(inst=
);
> +
> +       crypto_drop_skcipher(&ictx->streamcipher_spawn);
> +       crypto_drop_spawn(&ictx->blockcipher_spawn);
> +       crypto_drop_shash(&ictx->hash_spawn);
> +       kfree(inst);
> +}
> +
> +/*
> + * Check for a supported set of inner algorithms.
> + * See the comment at the beginning of this file.
> + */
> +static bool adiantum_supported_algorithms(struct skcipher_alg *streamcip=
her_alg,
> +                                         struct crypto_alg *blockcipher_=
alg,
> +                                         struct shash_alg *hash_alg)
> +{
> +       if (strcmp(streamcipher_alg->base.cra_name, "xchacha12") !=3D 0 &=
&
> +           strcmp(streamcipher_alg->base.cra_name, "xchacha20") !=3D 0)
> +               return false;
> +
> +       if (blockcipher_alg->cra_cipher.cia_min_keysize > BLOCKCIPHER_KEY=
_SIZE ||
> +           blockcipher_alg->cra_cipher.cia_max_keysize < BLOCKCIPHER_KEY=
_SIZE)
> +               return false;
> +       if (blockcipher_alg->cra_blocksize !=3D BLOCKCIPHER_BLOCK_SIZE)
> +               return false;
> +
> +       if (strcmp(hash_alg->base.cra_name, "nhpoly1305") !=3D 0)
> +               return false;
> +
> +       return true;
> +}
> +
> +static int adiantum_create(struct crypto_template *tmpl, struct rtattr *=
*tb)
> +{
> +       struct crypto_attr_type *algt;
> +       const char *streamcipher_name;
> +       const char *blockcipher_name;
> +       const char *nhpoly1305_name;
> +       struct skcipher_instance *inst;
> +       struct adiantum_instance_ctx *ictx;
> +       struct skcipher_alg *streamcipher_alg;
> +       struct crypto_alg *blockcipher_alg;
> +       struct crypto_alg *_hash_alg;
> +       struct shash_alg *hash_alg;
> +       int err;
> +
> +       algt =3D crypto_get_attr_type(tb);
> +       if (IS_ERR(algt))
> +               return PTR_ERR(algt);
> +
> +       if ((algt->type ^ CRYPTO_ALG_TYPE_SKCIPHER) & algt->mask)
> +               return -EINVAL;
> +
> +       streamcipher_name =3D crypto_attr_alg_name(tb[1]);
> +       if (IS_ERR(streamcipher_name))
> +               return PTR_ERR(streamcipher_name);
> +
> +       blockcipher_name =3D crypto_attr_alg_name(tb[2]);
> +       if (IS_ERR(blockcipher_name))
> +               return PTR_ERR(blockcipher_name);
> +
> +       nhpoly1305_name =3D crypto_attr_alg_name(tb[3]);
> +       if (nhpoly1305_name =3D=3D ERR_PTR(-ENOENT))
> +               nhpoly1305_name =3D "nhpoly1305";
> +       if (IS_ERR(nhpoly1305_name))
> +               return PTR_ERR(nhpoly1305_name);
> +
> +       inst =3D kzalloc(sizeof(*inst) + sizeof(*ictx), GFP_KERNEL);
> +       if (!inst)
> +               return -ENOMEM;
> +       ictx =3D skcipher_instance_ctx(inst);
> +
> +       /* Stream cipher, e.g. "xchacha12" */
> +       err =3D crypto_grab_skcipher(&ictx->streamcipher_spawn, streamcip=
her_name,
> +                                  0, crypto_requires_sync(algt->type,
> +                                                          algt->mask));
> +       if (err)
> +               goto out_free_inst;
> +       streamcipher_alg =3D crypto_spawn_skcipher_alg(&ictx->streamciphe=
r_spawn);
> +
> +       /* Block cipher, e.g. "aes" */
> +       err =3D crypto_grab_spawn(&ictx->blockcipher_spawn, blockcipher_n=
ame,
> +                               CRYPTO_ALG_TYPE_CIPHER, CRYPTO_ALG_TYPE_M=
ASK);
> +       if (err)
> +               goto out_drop_streamcipher;
> +       blockcipher_alg =3D ictx->blockcipher_spawn.alg;
> +
> +       /* NHPoly1305 =CE=B5A=E2=88=86U hash function */
> +       _hash_alg =3D crypto_alg_mod_lookup(nhpoly1305_name,
> +                                         CRYPTO_ALG_TYPE_SHASH,
> +                                         CRYPTO_ALG_TYPE_MASK);
> +       if (IS_ERR(_hash_alg)) {
> +               err =3D PTR_ERR(_hash_alg);
> +               goto out_drop_blockcipher;
> +       }
> +       hash_alg =3D __crypto_shash_alg(_hash_alg);
> +       err =3D crypto_init_shash_spawn(&ictx->hash_spawn, hash_alg,
> +                                     skcipher_crypto_instance(inst));
> +       if (err) {
> +               crypto_mod_put(_hash_alg);
> +               goto out_drop_blockcipher;
> +       }
> +
> +       /* Check the set of algorithms */
> +       if (!adiantum_supported_algorithms(streamcipher_alg, blockcipher_=
alg,
> +                                          hash_alg)) {
> +               pr_warn("Unsupported Adiantum instantiation: (%s,%s,%s)\n=
",
> +                       streamcipher_alg->base.cra_name,
> +                       blockcipher_alg->cra_name, hash_alg->base.cra_nam=
e);
> +               err =3D -EINVAL;
> +               goto out_drop_hash;
> +       }
> +
> +       /* Instance fields */
> +
> +       err =3D -ENAMETOOLONG;
> +       if (snprintf(inst->alg.base.cra_name, CRYPTO_MAX_ALG_NAME,
> +                    "adiantum(%s,%s)", streamcipher_alg->base.cra_name,
> +                    blockcipher_alg->cra_name) >=3D CRYPTO_MAX_ALG_NAME)
> +               goto out_drop_hash;
> +       if (snprintf(inst->alg.base.cra_driver_name, CRYPTO_MAX_ALG_NAME,
> +                    "adiantum(%s,%s,%s)",
> +                    streamcipher_alg->base.cra_driver_name,
> +                    blockcipher_alg->cra_driver_name,
> +                    hash_alg->base.cra_driver_name) >=3D CRYPTO_MAX_ALG_=
NAME)
> +               goto out_drop_hash;
> +
> +       inst->alg.base.cra_blocksize =3D BLOCKCIPHER_BLOCK_SIZE;
> +       inst->alg.base.cra_ctxsize =3D sizeof(struct adiantum_tfm_ctx);
> +       inst->alg.base.cra_alignmask =3D streamcipher_alg->base.cra_align=
mask |
> +                                      hash_alg->base.cra_alignmask;
> +       /*
> +        * The block cipher is only invoked once per message, so for long
> +        * messages (e.g. sectors for disk encryption) its performance do=
esn't
> +        * matter as much as that of the stream cipher and hash function.=
  Thus,
> +        * weigh the block cipher's ->cra_priority less.
> +        */
> +       inst->alg.base.cra_priority =3D (4 * streamcipher_alg->base.cra_p=
riority +
> +                                      2 * hash_alg->base.cra_priority +
> +                                      blockcipher_alg->cra_priority) / 7=
;
> +
> +       inst->alg.setkey =3D adiantum_setkey;
> +       inst->alg.encrypt =3D adiantum_encrypt;
> +       inst->alg.decrypt =3D adiantum_decrypt;
> +       inst->alg.init =3D adiantum_init_tfm;
> +       inst->alg.exit =3D adiantum_exit_tfm;
> +       inst->alg.min_keysize =3D crypto_skcipher_alg_min_keysize(streamc=
ipher_alg);
> +       inst->alg.max_keysize =3D crypto_skcipher_alg_max_keysize(streamc=
ipher_alg);
> +       inst->alg.ivsize =3D TWEAK_SIZE;
> +
> +       inst->free =3D adiantum_free_instance;
> +
> +       err =3D skcipher_register_instance(tmpl, inst);
> +       if (err)
> +               goto out_drop_hash;
> +
> +       return 0;
> +
> +out_drop_hash:
> +       crypto_drop_shash(&ictx->hash_spawn);
> +out_drop_blockcipher:
> +       crypto_drop_spawn(&ictx->blockcipher_spawn);
> +out_drop_streamcipher:
> +       crypto_drop_skcipher(&ictx->streamcipher_spawn);
> +out_free_inst:
> +       kfree(inst);
> +       return err;
> +}
> +
> +/* adiantum(streamcipher_name, blockcipher_name [, nhpoly1305_name]) */
> +static struct crypto_template adiantum_tmpl =3D {
> +       .name =3D "adiantum",
> +       .create =3D adiantum_create,
> +       .module =3D THIS_MODULE,
> +};
> +
> +static int __init adiantum_module_init(void)
> +{
> +       return crypto_register_template(&adiantum_tmpl);
> +}
> +
> +static void __exit adiantum_module_exit(void)
> +{
> +       crypto_unregister_template(&adiantum_tmpl);
> +}
> +
> +module_init(adiantum_module_init);
> +module_exit(adiantum_module_exit);
> +
> +MODULE_DESCRIPTION("Adiantum length-preserving encryption mode");
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
> +MODULE_ALIAS_CRYPTO("adiantum");
> diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
> index 5fb120474902..0590a9204562 100644
> --- a/crypto/tcrypt.c
> +++ b/crypto/tcrypt.c
> @@ -2320,6 +2320,18 @@ static int do_test(const char *alg, u32 type, u32 =
mask, int m, u32 num_mb)
>                 test_cipher_speed("ctr(sm4)", DECRYPT, sec, NULL, 0,
>                                 speed_template_16);
>                 break;
> +
> +       case 219:
> +               test_cipher_speed("adiantum(xchacha12,aes)", ENCRYPT, sec=
, NULL,
> +                                 0, speed_template_32);
> +               test_cipher_speed("adiantum(xchacha12,aes)", DECRYPT, sec=
, NULL,
> +                                 0, speed_template_32);
> +               test_cipher_speed("adiantum(xchacha20,aes)", ENCRYPT, sec=
, NULL,
> +                                 0, speed_template_32);
> +               test_cipher_speed("adiantum(xchacha20,aes)", DECRYPT, sec=
, NULL,
> +                                 0, speed_template_32);
> +               break;
> +
>         case 300:
>                 if (alg) {
>                         test_hash_speed(alg, sec, generic_hash_speed_temp=
late);
> diff --git a/crypto/testmgr.c b/crypto/testmgr.c
> index 665911c24786..0f684a414acb 100644
> --- a/crypto/testmgr.c
> +++ b/crypto/testmgr.c
> @@ -2404,6 +2404,18 @@ static int alg_test_null(const struct alg_test_des=
c *desc,
>  /* Please keep this list sorted by algorithm name. */
>  static const struct alg_test_desc alg_test_descs[] =3D {
>         {
> +               .alg =3D "adiantum(xchacha12,aes)",
> +               .test =3D alg_test_skcipher,
> +               .suite =3D {
> +                       .cipher =3D __VECS(adiantum_xchacha12_aes_tv_temp=
late)
> +               },
> +       }, {
> +               .alg =3D "adiantum(xchacha20,aes)",
> +               .test =3D alg_test_skcipher,
> +               .suite =3D {
> +                       .cipher =3D __VECS(adiantum_xchacha20_aes_tv_temp=
late)
> +               },
> +       }, {
>                 .alg =3D "aegis128",
>                 .test =3D alg_test_aead,
>                 .suite =3D {
> diff --git a/crypto/testmgr.h b/crypto/testmgr.h
> index 50ea1f2705c7..e7e56a8febbc 100644
> --- a/crypto/testmgr.h
> +++ b/crypto/testmgr.h
> @@ -33381,6 +33381,467 @@ static const struct cipher_testvec xchacha12_tv=
_template[] =3D {
>         },
>  };
>
> +/* Adiantum test vectors from https://github.com/google/adiantum */
> +static const struct cipher_testvec adiantum_xchacha12_aes_tv_template[] =
=3D {
> +       {
> +               .key    =3D "\x9e\xeb\xb2\x49\x3c\x1c\xf5\xf4"
> +                         "\x6a\x99\xc2\xc4\xdf\xb1\xf4\xdd"
> +                         "\x75\x20\x57\xea\x2c\x4f\xcd\xb2"
> +                         "\xa5\x3d\x7b\x49\x1e\xab\xfd\x0f",
> +               .klen   =3D 32,
> +               .iv     =3D "\xdf\x63\xd4\xab\xd2\x49\xf3\xd8"
> +                         "\x33\x81\x37\x60\x7d\xfa\x73\x08"
> +                         "\xd8\x49\x6d\x80\xe8\x2f\x62\x54"
> +                         "\xeb\x0e\xa9\x39\x5b\x45\x7f\x8a",
> +               .ptext  =3D "\x67\xc9\xf2\x30\x84\x41\x8e\x43"
> +                         "\xfb\xf3\xb3\x3e\x79\x36\x7f\xe8",
> +               .ctext  =3D "\x6d\x32\x86\x18\x67\x86\x0f\x3f"
> +                         "\x96\x7c\x9d\x28\x0d\x53\xec\x9f",
> +               .len    =3D 16,
> +               .also_non_np =3D 1,
> +               .np     =3D 2,
> +               .tap    =3D { 14, 2 },
> +       }, {
> +               .key    =3D "\x36\x2b\x57\x97\xf8\x5d\xcd\x99"
> +                         "\x5f\x1a\x5a\x44\x1d\x92\x0f\x27"
> +                         "\xcc\x16\xd7\x2b\x85\x63\x99\xd3"
> +                         "\xba\x96\xa1\xdb\xd2\x60\x68\xda",
> +               .klen   =3D 32,
> +               .iv     =3D "\xef\x58\x69\xb1\x2c\x5e\x9a\x47"
> +                         "\x24\xc1\xb1\x69\xe1\x12\x93\x8f"
> +                         "\x43\x3d\x6d\x00\xdb\x5e\xd8\xd9"
> +                         "\x12\x9a\xfe\xd9\xff\x2d\xaa\xc4",
> +               .ptext  =3D "\x5e\xa8\x68\x19\x85\x98\x12\x23"
> +                         "\x26\x0a\xcc\xdb\x0a\x04\xb9\xdf"
> +                         "\x4d\xb3\x48\x7b\xb0\xe3\xc8\x19"
> +                         "\x43\x5a\x46\x06\x94\x2d\xf2",
> +               .ctext  =3D "\xc7\xc6\xf1\x73\x8f\xc4\xff\x4a"
> +                         "\x39\xbe\x78\xbe\x8d\x28\xc8\x89"
> +                         "\x46\x63\xe7\x0c\x7d\x87\xe8\x4e"
> +                         "\xc9\x18\x7b\xbe\x18\x60\x50",
> +               .len    =3D 31,
> +       }, {
> +               .key    =3D "\xa5\x28\x24\x34\x1a\x3c\xd8\xf7"
> +                         "\x05\x91\x8f\xee\x85\x1f\x35\x7f"
> +                         "\x80\x3d\xfc\x9b\x94\xf6\xfc\x9e"
> +                         "\x19\x09\x00\xa9\x04\x31\x4f\x11",
> +               .klen   =3D 32,
> +               .iv     =3D "\xa1\xba\x49\x95\xff\x34\x6d\xb8"
> +                         "\xcd\x87\x5d\x5e\xfd\xea\x85\xdb"
> +                         "\x8a\x7b\x5e\xb2\x5d\x57\xdd\x62"
> +                         "\xac\xa9\x8c\x41\x42\x94\x75\xb7",
> +               .ptext  =3D "\x69\xb4\xe8\x8c\x37\xe8\x67\x82"
> +                         "\xf1\xec\x5d\x04\xe5\x14\x91\x13"
> +                         "\xdf\xf2\x87\x1b\x69\x81\x1d\x71"
> +                         "\x70\x9e\x9c\x3b\xde\x49\x70\x11"
> +                         "\xa0\xa3\xdb\x0d\x54\x4f\x66\x69"
> +                         "\xd7\xdb\x80\xa7\x70\x92\x68\xce"
> +                         "\x81\x04\x2c\xc6\xab\xae\xe5\x60"
> +                         "\x15\xe9\x6f\xef\xaa\x8f\xa7\xa7"
> +                         "\x63\x8f\xf2\xf0\x77\xf1\xa8\xea"
> +                         "\xe1\xb7\x1f\x9e\xab\x9e\x4b\x3f"
> +                         "\x07\x87\x5b\x6f\xcd\xa8\xaf\xb9"
> +                         "\xfa\x70\x0b\x52\xb8\xa8\xa7\x9e"
> +                         "\x07\x5f\xa6\x0e\xb3\x9b\x79\x13"
> +                         "\x79\xc3\x3e\x8d\x1c\x2c\x68\xc8"
> +                         "\x51\x1d\x3c\x7b\x7d\x79\x77\x2a"
> +                         "\x56\x65\xc5\x54\x23\x28\xb0\x03",
> +               .ctext  =3D "\x9e\x16\xab\xed\x4b\xa7\x42\x5a"
> +                         "\xc6\xfb\x4e\x76\xff\xbe\x03\xa0"
> +                         "\x0f\xe3\xad\xba\xe4\x98\x2b\x0e"
> +                         "\x21\x48\xa0\xb8\x65\x48\x27\x48"
> +                         "\x84\x54\x54\xb2\x9a\x94\x7b\xe6"
> +                         "\x4b\x29\xe9\xcf\x05\x91\x80\x1a"
> +                         "\x3a\xf3\x41\x96\x85\x1d\x9f\x74"
> +                         "\x51\x56\x63\xfa\x7c\x28\x85\x49"
> +                         "\xf7\x2f\xf9\xf2\x18\x46\xf5\x33"
> +                         "\x80\xa3\x3c\xce\xb2\x57\x93\xf5"
> +                         "\xae\xbd\xa9\xf5\x7b\x30\xc4\x93"
> +                         "\x66\xe0\x30\x77\x16\xe4\xa0\x31"
> +                         "\xba\x70\xbc\x68\x13\xf5\xb0\x9a"
> +                         "\xc1\xfc\x7e\xfe\x55\x80\x5c\x48"
> +                         "\x74\xa6\xaa\xa3\xac\xdc\xc2\xf5"
> +                         "\x8d\xde\x34\x86\x78\x60\x75\x8d",
> +               .len    =3D 128,
> +               .also_non_np =3D 1,
> +               .np     =3D 4,
> +               .tap    =3D { 104, 16, 4, 4 },
> +       }, {
> +               .key    =3D "\xd3\x81\x72\x18\x23\xff\x6f\x4a"
> +                         "\x25\x74\x29\x0d\x51\x8a\x0e\x13"
> +                         "\xc1\x53\x5d\x30\x8d\xee\x75\x0d"
> +                         "\x14\xd6\x69\xc9\x15\xa9\x0c\x60",
> +               .klen   =3D 32,
> +               .iv     =3D "\x65\x9b\xd4\xa8\x7d\x29\x1d\xf4"
> +                         "\xc4\xd6\x9b\x6a\x28\xab\x64\xe2"
> +                         "\x62\x81\x97\xc5\x81\xaa\xf9\x44"
> +                         "\xc1\x72\x59\x82\xaf\x16\xc8\x2c",
> +               .ptext  =3D "\xc7\x6b\x52\x6a\x10\xf0\xcc\x09"
> +                         "\xc1\x12\x1d\x6d\x21\xa6\x78\xf5"
> +                         "\x05\xa3\x69\x60\x91\x36\x98\x57"
> +                         "\xba\x0c\x14\xcc\xf3\x2d\x73\x03"
> +                         "\xc6\xb2\x5f\xc8\x16\x27\x37\x5d"
> +                         "\xd0\x0b\x87\xb2\x50\x94\x7b\x58"
> +                         "\x04\xf4\xe0\x7f\x6e\x57\x8e\xc9"
> +                         "\x41\x84\xc1\xb1\x7e\x4b\x91\x12"
> +                         "\x3a\x8b\x5d\x50\x82\x7b\xcb\xd9"
> +                         "\x9a\xd9\x4e\x18\x06\x23\x9e\xd4"
> +                         "\xa5\x20\x98\xef\xb5\xda\xe5\xc0"
> +                         "\x8a\x6a\x83\x77\x15\x84\x1e\xae"
> +                         "\x78\x94\x9d\xdf\xb7\xd1\xea\x67"
> +                         "\xaa\xb0\x14\x15\xfa\x67\x21\x84"
> +                         "\xd3\x41\x2a\xce\xba\x4b\x4a\xe8"
> +                         "\x95\x62\xa9\x55\xf0\x80\xad\xbd"
> +                         "\xab\xaf\xdd\x4f\xa5\x7c\x13\x36"
> +                         "\xed\x5e\x4f\x72\xad\x4b\xf1\xd0"
> +                         "\x88\x4e\xec\x2c\x88\x10\x5e\xea"
> +                         "\x12\xc0\x16\x01\x29\xa3\xa0\x55"
> +                         "\xaa\x68\xf3\xe9\x9d\x3b\x0d\x3b"
> +                         "\x6d\xec\xf8\xa0\x2d\xf0\x90\x8d"
> +                         "\x1c\xe2\x88\xd4\x24\x71\xf9\xb3"
> +                         "\xc1\x9f\xc5\xd6\x76\x70\xc5\x2e"
> +                         "\x9c\xac\xdb\x90\xbd\x83\x72\xba"
> +                         "\x6e\xb5\xa5\x53\x83\xa9\xa5\xbf"
> +                         "\x7d\x06\x0e\x3c\x2a\xd2\x04\xb5"
> +                         "\x1e\x19\x38\x09\x16\xd2\x82\x1f"
> +                         "\x75\x18\x56\xb8\x96\x0b\xa6\xf9"
> +                         "\xcf\x62\xd9\x32\x5d\xa9\xd7\x1d"
> +                         "\xec\xe4\xdf\x1b\xbe\xf1\x36\xee"
> +                         "\xe3\x7b\xb5\x2f\xee\xf8\x53\x3d"
> +                         "\x6a\xb7\x70\xa9\xfc\x9c\x57\x25"
> +                         "\xf2\x89\x10\xd3\xb8\xa8\x8c\x30"
> +                         "\xae\x23\x4f\x0e\x13\x66\x4f\xe1"
> +                         "\xb6\xc0\xe4\xf8\xef\x93\xbd\x6e"
> +                         "\x15\x85\x6b\xe3\x60\x81\x1d\x68"
> +                         "\xd7\x31\x87\x89\x09\xab\xd5\x96"
> +                         "\x1d\xf3\x6d\x67\x80\xca\x07\x31"
> +                         "\x5d\xa7\xe4\xfb\x3e\xf2\x9b\x33"
> +                         "\x52\x18\xc8\x30\xfe\x2d\xca\x1e"
> +                         "\x79\x92\x7a\x60\x5c\xb6\x58\x87"
> +                         "\xa4\x36\xa2\x67\x92\x8b\xa4\xb7"
> +                         "\xf1\x86\xdf\xdc\xc0\x7e\x8f\x63"
> +                         "\xd2\xa2\xdc\x78\xeb\x4f\xd8\x96"
> +                         "\x47\xca\xb8\x91\xf9\xf7\x94\x21"
> +                         "\x5f\x9a\x9f\x5b\xb8\x40\x41\x4b"
> +                         "\x66\x69\x6a\x72\xd0\xcb\x70\xb7"
> +                         "\x93\xb5\x37\x96\x05\x37\x4f\xe5"
> +                         "\x8c\xa7\x5a\x4e\x8b\xb7\x84\xea"
> +                         "\xc7\xfc\x19\x6e\x1f\x5a\xa1\xac"
> +                         "\x18\x7d\x52\x3b\xb3\x34\x62\x99"
> +                         "\xe4\x9e\x31\x04\x3f\xc0\x8d\x84"
> +                         "\x17\x7c\x25\x48\x52\x67\x11\x27"
> +                         "\x67\xbb\x5a\x85\xca\x56\xb2\x5c"
> +                         "\xe6\xec\xd5\x96\x3d\x15\xfc\xfb"
> +                         "\x22\x25\xf4\x13\xe5\x93\x4b\x9a"
> +                         "\x77\xf1\x52\x18\xfa\x16\x5e\x49"
> +                         "\x03\x45\xa8\x08\xfa\xb3\x41\x92"
> +                         "\x79\x50\x33\xca\xd0\xd7\x42\x55"
> +                         "\xc3\x9a\x0c\x4e\xd9\xa4\x3c\x86"
> +                         "\x80\x9f\x53\xd1\xa4\x2e\xd1\xbc"
> +                         "\xf1\x54\x6e\x93\xa4\x65\x99\x8e"
> +                         "\xdf\x29\xc0\x64\x63\x07\xbb\xea",
> +               .ctext  =3D "\x15\x97\xd0\x86\x18\x03\x9c\x51"
> +                         "\xc5\x11\x36\x62\x13\x92\xe6\x73"
> +                         "\x29\x79\xde\xa1\x00\x3e\x08\x64"
> +                         "\x17\x1a\xbc\xd5\xfe\x33\x0e\x0c"
> +                         "\x7c\x94\xa7\xc6\x3c\xbe\xac\xa2"
> +                         "\x89\xe6\xbc\xdf\x0c\x33\x27\x42"
> +                         "\x46\x73\x2f\xba\x4e\xa6\x46\x8f"
> +                         "\xe4\xee\x39\x63\x42\x65\xa3\x88"
> +                         "\x7a\xad\x33\x23\xa9\xa7\x20\x7f"
> +                         "\x0b\xe6\x6a\xc3\x60\xda\x9e\xb4"
> +                         "\xd6\x07\x8a\x77\x26\xd1\xab\x44"
> +                         "\x99\x55\x03\x5e\xed\x8d\x7b\xbd"
> +                         "\xc8\x21\xb7\x21\x30\x3f\xc0\xb5"
> +                         "\xc8\xec\x6c\x23\xa6\xa3\x6d\xf1"
> +                         "\x30\x0a\xd0\xa6\xa9\x28\x69\xae"
> +                         "\x2a\xe6\x54\xac\x82\x9d\x6a\x95"
> +                         "\x6f\x06\x44\xc5\x5a\x77\x6e\xec"
> +                         "\xf8\xf8\x63\xb2\xe6\xaa\xbd\x8e"
> +                         "\x0e\x8a\x62\x00\x03\xc8\x84\xdd"
> +                         "\x47\x4a\xc3\x55\xba\xb7\xe7\xdf"
> +                         "\x08\xbf\x62\xf5\xe8\xbc\xb6\x11"
> +                         "\xe4\xcb\xd0\x66\x74\x32\xcf\xd4"
> +                         "\xf8\x51\x80\x39\x14\x05\x12\xdb"
> +                         "\x87\x93\xe2\x26\x30\x9c\x3a\x21"
> +                         "\xe5\xd0\x38\x57\x80\x15\xe4\x08"
> +                         "\x58\x05\x49\x7d\xe6\x92\x77\x70"
> +                         "\xfb\x1e\x2d\x6a\x84\x00\xc8\x68"
> +                         "\xf7\x1a\xdd\xf0\x7b\x38\x1e\xd8"
> +                         "\x2c\x78\x78\x61\xcf\xe3\xde\x69"
> +                         "\x1f\xd5\x03\xd5\x1a\xb4\xcf\x03"
> +                         "\xc8\x7a\x70\x68\x35\xb4\xf6\xbe"
> +                         "\x90\x62\xb2\x28\x99\x86\xf5\x44"
> +                         "\x99\xeb\x31\xcf\xca\xdf\xd0\x21"
> +                         "\xd6\x60\xf7\x0f\x40\xb4\x80\xb7"
> +                         "\xab\xe1\x9b\x45\xba\x66\xda\xee"
> +                         "\xdd\x04\x12\x40\x98\xe1\x69\xe5"
> +                         "\x2b\x9c\x59\x80\xe7\x7b\xcc\x63"
> +                         "\xa6\xc0\x3a\xa9\xfe\x8a\xf9\x62"
> +                         "\x11\x34\x61\x94\x35\xfe\xf2\x99"
> +                         "\xfd\xee\x19\xea\x95\xb6\x12\xbf"
> +                         "\x1b\xdf\x02\x1a\xcc\x3e\x7e\x65"
> +                         "\x78\x74\x10\x50\x29\x63\x28\xea"
> +                         "\x6b\xab\xd4\x06\x4d\x15\x24\x31"
> +                         "\xc7\x0a\xc9\x16\xb6\x48\xf0\xbf"
> +                         "\x49\xdb\x68\x71\x31\x8f\x87\xe2"
> +                         "\x13\x05\x64\xd6\x22\x0c\xf8\x36"
> +                         "\x84\x24\x3e\x69\x5e\xb8\x9e\x16"
> +                         "\x73\x6c\x83\x1e\xe0\x9f\x9e\xba"
> +                         "\xe5\x59\x21\x33\x1b\xa9\x26\xc2"
> +                         "\xc7\xd9\x30\x73\xb6\xa6\x73\x82"
> +                         "\x19\xfa\x44\x4d\x40\x8b\x69\x04"
> +                         "\x94\x74\xea\x6e\xb3\x09\x47\x01"
> +                         "\x2a\xb9\x78\x34\x43\x11\xed\xd6"
> +                         "\x8c\x95\x65\x1b\x85\x67\xa5\x40"
> +                         "\xac\x9c\x05\x4b\x57\x4a\xa9\x96"
> +                         "\x0f\xdd\x4f\xa1\xe0\xcf\x6e\xc7"
> +                         "\x1b\xed\xa2\xb4\x56\x8c\x09\x6e"
> +                         "\xa6\x65\xd7\x55\x81\xb7\xed\x11"
> +                         "\x9b\x40\x75\xa8\x6b\x56\xaf\x16"
> +                         "\x8b\x3d\xf4\xcb\xfe\xd5\x1d\x3d"
> +                         "\x85\xc2\xc0\xde\x43\x39\x4a\x96"
> +                         "\xba\x88\x97\xc0\xd6\x00\x0e\x27"
> +                         "\x21\xb0\x21\x52\xba\xa7\x37\xaa"
> +                         "\xcc\xbf\x95\xa8\xf4\xd0\x91\xf6",
> +               .len    =3D 512,
> +               .also_non_np =3D 1,
> +               .np     =3D 2,
> +               .tap    =3D { 144, 368 },
> +       }
> +};
> +
> +/* Adiantum with XChaCha20 instead of XChaCha12 */
> +/* Test vectors from https://github.com/google/adiantum */
> +static const struct cipher_testvec adiantum_xchacha20_aes_tv_template[] =
=3D {
> +       {
> +               .key    =3D "\x9e\xeb\xb2\x49\x3c\x1c\xf5\xf4"
> +                         "\x6a\x99\xc2\xc4\xdf\xb1\xf4\xdd"
> +                         "\x75\x20\x57\xea\x2c\x4f\xcd\xb2"
> +                         "\xa5\x3d\x7b\x49\x1e\xab\xfd\x0f",
> +               .klen   =3D 32,
> +               .iv     =3D "\xdf\x63\xd4\xab\xd2\x49\xf3\xd8"
> +                         "\x33\x81\x37\x60\x7d\xfa\x73\x08"
> +                         "\xd8\x49\x6d\x80\xe8\x2f\x62\x54"
> +                         "\xeb\x0e\xa9\x39\x5b\x45\x7f\x8a",
> +               .ptext  =3D "\x67\xc9\xf2\x30\x84\x41\x8e\x43"
> +                         "\xfb\xf3\xb3\x3e\x79\x36\x7f\xe8",
> +               .ctext  =3D "\xf6\x78\x97\xd6\xaa\x94\x01\x27"
> +                         "\x2e\x4d\x83\xe0\x6e\x64\x9a\xdf",
> +               .len    =3D 16,
> +               .also_non_np =3D 1,
> +               .np     =3D 3,
> +               .tap    =3D { 5, 2, 9 },
> +       }, {
> +               .key    =3D "\x36\x2b\x57\x97\xf8\x5d\xcd\x99"
> +                         "\x5f\x1a\x5a\x44\x1d\x92\x0f\x27"
> +                         "\xcc\x16\xd7\x2b\x85\x63\x99\xd3"
> +                         "\xba\x96\xa1\xdb\xd2\x60\x68\xda",
> +               .klen   =3D 32,
> +               .iv     =3D "\xef\x58\x69\xb1\x2c\x5e\x9a\x47"
> +                         "\x24\xc1\xb1\x69\xe1\x12\x93\x8f"
> +                         "\x43\x3d\x6d\x00\xdb\x5e\xd8\xd9"
> +                         "\x12\x9a\xfe\xd9\xff\x2d\xaa\xc4",
> +               .ptext  =3D "\x5e\xa8\x68\x19\x85\x98\x12\x23"
> +                         "\x26\x0a\xcc\xdb\x0a\x04\xb9\xdf"
> +                         "\x4d\xb3\x48\x7b\xb0\xe3\xc8\x19"
> +                         "\x43\x5a\x46\x06\x94\x2d\xf2",
> +               .ctext  =3D "\x4b\xb8\x90\x10\xdf\x7f\x64\x08"
> +                         "\x0e\x14\x42\x5f\x00\x74\x09\x36"
> +                         "\x57\x72\xb5\xfd\xb5\x5d\xb8\x28"
> +                         "\x0c\x04\x91\x14\x91\xe9\x37",
> +               .len    =3D 31,
> +               .also_non_np =3D 1,
> +               .np     =3D 2,
> +               .tap    =3D { 16, 15 },
> +       }, {
> +               .key    =3D "\xa5\x28\x24\x34\x1a\x3c\xd8\xf7"
> +                         "\x05\x91\x8f\xee\x85\x1f\x35\x7f"
> +                         "\x80\x3d\xfc\x9b\x94\xf6\xfc\x9e"
> +                         "\x19\x09\x00\xa9\x04\x31\x4f\x11",
> +               .klen   =3D 32,
> +               .iv     =3D "\xa1\xba\x49\x95\xff\x34\x6d\xb8"
> +                         "\xcd\x87\x5d\x5e\xfd\xea\x85\xdb"
> +                         "\x8a\x7b\x5e\xb2\x5d\x57\xdd\x62"
> +                         "\xac\xa9\x8c\x41\x42\x94\x75\xb7",
> +               .ptext  =3D "\x69\xb4\xe8\x8c\x37\xe8\x67\x82"
> +                         "\xf1\xec\x5d\x04\xe5\x14\x91\x13"
> +                         "\xdf\xf2\x87\x1b\x69\x81\x1d\x71"
> +                         "\x70\x9e\x9c\x3b\xde\x49\x70\x11"
> +                         "\xa0\xa3\xdb\x0d\x54\x4f\x66\x69"
> +                         "\xd7\xdb\x80\xa7\x70\x92\x68\xce"
> +                         "\x81\x04\x2c\xc6\xab\xae\xe5\x60"
> +                         "\x15\xe9\x6f\xef\xaa\x8f\xa7\xa7"
> +                         "\x63\x8f\xf2\xf0\x77\xf1\xa8\xea"
> +                         "\xe1\xb7\x1f\x9e\xab\x9e\x4b\x3f"
> +                         "\x07\x87\x5b\x6f\xcd\xa8\xaf\xb9"
> +                         "\xfa\x70\x0b\x52\xb8\xa8\xa7\x9e"
> +                         "\x07\x5f\xa6\x0e\xb3\x9b\x79\x13"
> +                         "\x79\xc3\x3e\x8d\x1c\x2c\x68\xc8"
> +                         "\x51\x1d\x3c\x7b\x7d\x79\x77\x2a"
> +                         "\x56\x65\xc5\x54\x23\x28\xb0\x03",
> +               .ctext  =3D "\xb1\x8b\xa0\x05\x77\xa8\x4d\x59"
> +                         "\x1b\x8e\x21\xfc\x3a\x49\xfa\xd4"
> +                         "\xeb\x36\xf3\xc4\xdf\xdc\xae\x67"
> +                         "\x07\x3f\x70\x0e\xe9\x66\xf5\x0c"
> +                         "\x30\x4d\x66\xc9\xa4\x2f\x73\x9c"
> +                         "\x13\xc8\x49\x44\xcc\x0a\x90\x9d"
> +                         "\x7c\xdd\x19\x3f\xea\x72\x8d\x58"
> +                         "\xab\xe7\x09\x2c\xec\xb5\x44\xd2"
> +                         "\xca\xa6\x2d\x7a\x5c\x9c\x2b\x15"
> +                         "\xec\x2a\xa6\x69\x91\xf9\xf3\x13"
> +                         "\xf7\x72\xc1\xc1\x40\xd5\xe1\x94"
> +                         "\xf4\x29\xa1\x3e\x25\x02\xa8\x3e"
> +                         "\x94\xc1\x91\x14\xa1\x14\xcb\xbe"
> +                         "\x67\x4c\xb9\x38\xfe\xa7\xaa\x32"
> +                         "\x29\x62\x0d\xb2\xf6\x3c\x58\x57"
> +                         "\xc1\xd5\x5a\xbb\xd6\xa6\x2a\xe5",
> +               .len    =3D 128,
> +               .also_non_np =3D 1,
> +               .np     =3D 4,
> +               .tap    =3D { 112, 7, 8, 1 },
> +       }, {
> +               .key    =3D "\xd3\x81\x72\x18\x23\xff\x6f\x4a"
> +                         "\x25\x74\x29\x0d\x51\x8a\x0e\x13"
> +                         "\xc1\x53\x5d\x30\x8d\xee\x75\x0d"
> +                         "\x14\xd6\x69\xc9\x15\xa9\x0c\x60",
> +               .klen   =3D 32,
> +               .iv     =3D "\x65\x9b\xd4\xa8\x7d\x29\x1d\xf4"
> +                         "\xc4\xd6\x9b\x6a\x28\xab\x64\xe2"
> +                         "\x62\x81\x97\xc5\x81\xaa\xf9\x44"
> +                         "\xc1\x72\x59\x82\xaf\x16\xc8\x2c",
> +               .ptext  =3D "\xc7\x6b\x52\x6a\x10\xf0\xcc\x09"
> +                         "\xc1\x12\x1d\x6d\x21\xa6\x78\xf5"
> +                         "\x05\xa3\x69\x60\x91\x36\x98\x57"
> +                         "\xba\x0c\x14\xcc\xf3\x2d\x73\x03"
> +                         "\xc6\xb2\x5f\xc8\x16\x27\x37\x5d"
> +                         "\xd0\x0b\x87\xb2\x50\x94\x7b\x58"
> +                         "\x04\xf4\xe0\x7f\x6e\x57\x8e\xc9"
> +                         "\x41\x84\xc1\xb1\x7e\x4b\x91\x12"
> +                         "\x3a\x8b\x5d\x50\x82\x7b\xcb\xd9"
> +                         "\x9a\xd9\x4e\x18\x06\x23\x9e\xd4"
> +                         "\xa5\x20\x98\xef\xb5\xda\xe5\xc0"
> +                         "\x8a\x6a\x83\x77\x15\x84\x1e\xae"
> +                         "\x78\x94\x9d\xdf\xb7\xd1\xea\x67"
> +                         "\xaa\xb0\x14\x15\xfa\x67\x21\x84"
> +                         "\xd3\x41\x2a\xce\xba\x4b\x4a\xe8"
> +                         "\x95\x62\xa9\x55\xf0\x80\xad\xbd"
> +                         "\xab\xaf\xdd\x4f\xa5\x7c\x13\x36"
> +                         "\xed\x5e\x4f\x72\xad\x4b\xf1\xd0"
> +                         "\x88\x4e\xec\x2c\x88\x10\x5e\xea"
> +                         "\x12\xc0\x16\x01\x29\xa3\xa0\x55"
> +                         "\xaa\x68\xf3\xe9\x9d\x3b\x0d\x3b"
> +                         "\x6d\xec\xf8\xa0\x2d\xf0\x90\x8d"
> +                         "\x1c\xe2\x88\xd4\x24\x71\xf9\xb3"
> +                         "\xc1\x9f\xc5\xd6\x76\x70\xc5\x2e"
> +                         "\x9c\xac\xdb\x90\xbd\x83\x72\xba"
> +                         "\x6e\xb5\xa5\x53\x83\xa9\xa5\xbf"
> +                         "\x7d\x06\x0e\x3c\x2a\xd2\x04\xb5"
> +                         "\x1e\x19\x38\x09\x16\xd2\x82\x1f"
> +                         "\x75\x18\x56\xb8\x96\x0b\xa6\xf9"
> +                         "\xcf\x62\xd9\x32\x5d\xa9\xd7\x1d"
> +                         "\xec\xe4\xdf\x1b\xbe\xf1\x36\xee"
> +                         "\xe3\x7b\xb5\x2f\xee\xf8\x53\x3d"
> +                         "\x6a\xb7\x70\xa9\xfc\x9c\x57\x25"
> +                         "\xf2\x89\x10\xd3\xb8\xa8\x8c\x30"
> +                         "\xae\x23\x4f\x0e\x13\x66\x4f\xe1"
> +                         "\xb6\xc0\xe4\xf8\xef\x93\xbd\x6e"
> +                         "\x15\x85\x6b\xe3\x60\x81\x1d\x68"
> +                         "\xd7\x31\x87\x89\x09\xab\xd5\x96"
> +                         "\x1d\xf3\x6d\x67\x80\xca\x07\x31"
> +                         "\x5d\xa7\xe4\xfb\x3e\xf2\x9b\x33"
> +                         "\x52\x18\xc8\x30\xfe\x2d\xca\x1e"
> +                         "\x79\x92\x7a\x60\x5c\xb6\x58\x87"
> +                         "\xa4\x36\xa2\x67\x92\x8b\xa4\xb7"
> +                         "\xf1\x86\xdf\xdc\xc0\x7e\x8f\x63"
> +                         "\xd2\xa2\xdc\x78\xeb\x4f\xd8\x96"
> +                         "\x47\xca\xb8\x91\xf9\xf7\x94\x21"
> +                         "\x5f\x9a\x9f\x5b\xb8\x40\x41\x4b"
> +                         "\x66\x69\x6a\x72\xd0\xcb\x70\xb7"
> +                         "\x93\xb5\x37\x96\x05\x37\x4f\xe5"
> +                         "\x8c\xa7\x5a\x4e\x8b\xb7\x84\xea"
> +                         "\xc7\xfc\x19\x6e\x1f\x5a\xa1\xac"
> +                         "\x18\x7d\x52\x3b\xb3\x34\x62\x99"
> +                         "\xe4\x9e\x31\x04\x3f\xc0\x8d\x84"
> +                         "\x17\x7c\x25\x48\x52\x67\x11\x27"
> +                         "\x67\xbb\x5a\x85\xca\x56\xb2\x5c"
> +                         "\xe6\xec\xd5\x96\x3d\x15\xfc\xfb"
> +                         "\x22\x25\xf4\x13\xe5\x93\x4b\x9a"
> +                         "\x77\xf1\x52\x18\xfa\x16\x5e\x49"
> +                         "\x03\x45\xa8\x08\xfa\xb3\x41\x92"
> +                         "\x79\x50\x33\xca\xd0\xd7\x42\x55"
> +                         "\xc3\x9a\x0c\x4e\xd9\xa4\x3c\x86"
> +                         "\x80\x9f\x53\xd1\xa4\x2e\xd1\xbc"
> +                         "\xf1\x54\x6e\x93\xa4\x65\x99\x8e"
> +                         "\xdf\x29\xc0\x64\x63\x07\xbb\xea",
> +               .ctext  =3D "\xe0\x33\xf6\xe0\xb4\xa5\xdd\x2b"
> +                         "\xdd\xce\xfc\x12\x1e\xfc\x2d\xf2"
> +                         "\x8b\xc7\xeb\xc1\xc4\x2a\xe8\x44"
> +                         "\x0f\x3d\x97\x19\x2e\x6d\xa2\x38"
> +                         "\x9d\xa6\xaa\xe1\x96\xb9\x08\xe8"
> +                         "\x0b\x70\x48\x5c\xed\xb5\x9b\xcb"
> +                         "\x8b\x40\x88\x7e\x69\x73\xf7\x16"
> +                         "\x71\xbb\x5b\xfc\xa3\x47\x5d\xa6"
> +                         "\xae\x3a\x64\xc4\xe7\xb8\xa8\xe7"
> +                         "\xb1\x32\x19\xdb\xe3\x01\xb8\xf0"
> +                         "\xa4\x86\xb4\x4c\xc2\xde\x5c\xd2"
> +                         "\x6c\x77\xd2\xe8\x18\xb7\x0a\xc9"
> +                         "\x3d\x53\xb5\xc4\x5c\xf0\x8c\x06"
> +                         "\xdc\x90\xe0\x74\x47\x1b\x0b\xf6"
> +                         "\xd2\x71\x6b\xc4\xf1\x97\x00\x2d"
> +                         "\x63\x57\x44\x1f\x8c\xf4\xe6\x9b"
> +                         "\xe0\x7a\xdd\xec\x32\x73\x42\x32"
> +                         "\x7f\x35\x67\x60\x0d\xcf\x10\x52"
> +                         "\x61\x22\x53\x8d\x8e\xbb\x33\x76"
> +                         "\x59\xd9\x10\xce\xdf\xef\xc0\x41"
> +                         "\xd5\x33\x29\x6a\xda\x46\xa4\x51"
> +                         "\xf0\x99\x3d\x96\x31\xdd\xb5\xcb"
> +                         "\x3e\x2a\x1f\xc7\x5c\x79\xd3\xc5"
> +                         "\x20\xa1\xb1\x39\x1b\xc6\x0a\x70"
> +                         "\x26\x39\x95\x07\xad\x7a\xc9\x69"
> +                         "\xfe\x81\xc7\x88\x08\x38\xaf\xad"
> +                         "\x9e\x8d\xfb\xe8\x24\x0d\x22\xb8"
> +                         "\x0e\xed\xbe\x37\x53\x7c\xa6\xc6"
> +                         "\x78\x62\xec\xa3\x59\xd9\xc6\x9d"
> +                         "\xb8\x0e\x69\x77\x84\x2d\x6a\x4c"
> +                         "\xc5\xd9\xb2\xa0\x2b\xa8\x80\xcc"
> +                         "\xe9\x1e\x9c\x5a\xc4\xa1\xb2\x37"
> +                         "\x06\x9b\x30\x32\x67\xf7\xe7\xd2"
> +                         "\x42\xc7\xdf\x4e\xd4\xcb\xa0\x12"
> +                         "\x94\xa1\x34\x85\x93\x50\x4b\x0a"
> +                         "\x3c\x7d\x49\x25\x01\x41\x6b\x96"
> +                         "\xa9\x12\xbb\x0b\xc0\xd7\xd0\x93"
> +                         "\x1f\x70\x38\xb8\x21\xee\xf6\xa7"
> +                         "\xee\xeb\xe7\x81\xa4\x13\xb4\x87"
> +                         "\xfa\xc1\xb0\xb5\x37\x8b\x74\xa2"
> +                         "\x4e\xc7\xc2\xad\x3d\x62\x3f\xf8"
> +                         "\x34\x42\xe5\xae\x45\x13\x63\xfe"
> +                         "\xfc\x2a\x17\x46\x61\xa9\xd3\x1c"
> +                         "\x4c\xaf\xf0\x09\x62\x26\x66\x1e"
> +                         "\x74\xcf\xd6\x68\x3d\x7d\xd8\xb7"
> +                         "\xe7\xe6\xf8\xf0\x08\x20\xf7\x47"
> +                         "\x1c\x52\xaa\x0f\x3e\x21\xa3\xf2"
> +                         "\xbf\x2f\x95\x16\xa8\xc8\xc8\x8c"
> +                         "\x99\x0f\x5d\xfb\xfa\x2b\x58\x8a"
> +                         "\x7e\xd6\x74\x02\x60\xf0\xd0\x5b"
> +                         "\x65\xa8\xac\xea\x8d\x68\x46\x34"
> +                         "\x26\x9d\x4f\xb1\x9a\x8e\xc0\x1a"
> +                         "\xf1\xed\xc6\x7a\x83\xfd\x8a\x57"
> +                         "\xf2\xe6\xe4\xba\xfc\xc6\x3c\xad"
> +                         "\x5b\x19\x50\x2f\x3a\xcc\x06\x46"
> +                         "\x04\x51\x3f\x91\x97\xf0\xd2\x07"
> +                         "\xe7\x93\x89\x7e\xb5\x32\x0f\x03"
> +                         "\xe5\x58\x9e\x74\x72\xeb\xc2\x38"
> +                         "\x00\x0c\x91\x72\x69\xed\x7d\x6d"
> +                         "\xc8\x71\xf0\xec\xff\x80\xd9\x1c"
> +                         "\x9e\xd2\xfa\x15\xfc\x6c\x4e\xbc"
> +                         "\xb1\xa6\xbd\xbd\x70\x40\xca\x20"
> +                         "\xb8\x78\xd2\xa3\xc6\xf3\x79\x9c"
> +                         "\xc7\x27\xe1\x6a\x29\xad\xa4\x03",
> +               .len    =3D 512,
> +       }
> +};
> +
>  /*
>   * CTS (Cipher Text Stealing) mode tests
>   */
> --
> 2.19.1.1215.g8438c0b245-goog
>
