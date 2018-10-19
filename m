Return-Path: <SRS0=QmQ6=M7=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20181015175424.97147-5-ebiggers@kernel.org>
References: <20181015175424.97147-1-ebiggers@kernel.org> <20181015175424.97147-5-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 19 Oct 2018 22:34:41 +0800
Message-ID: <CAKv+Gu_wVmnEND3MGTG7bqqynbBqyzmE_gTmqZfrT551_n9Hmw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 04/12] crypto: chacha - add XChaCha12 support
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Greg Kaiser <gkaiser@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Samuel Neves <samuel.c.p.neves@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> Now that the generic implementation of ChaCha20 has been refactored to
> allow varying the number of rounds, add support for XChaCha12, which is
> the XSalsa construction applied to ChaCha12.  ChaCha12 is one of the
> three ciphers specified by the original ChaCha paper
> (https://cr.yp.to/chacha/chacha-20080128.pdf: "ChaCha, a variant of
> Salsa20"), alongside ChaCha8 and ChaCha20.  ChaCha12 is faster than
> ChaCha20 but has a lower, but still large, security margin.
>
> We need XChaCha12 support so that it can be used in the Adiantum
> encryption mode, which enables disk/file encryption on low-end mobile
> devices where AES-XTS is too slow as the CPUs lack AES instructions.
>
> We'd prefer XChaCha20 (the more popular variant), but it's too slow on
> some of our target devices, so at least in some cases we do need the
> XChaCha12-based version.  In more detail, the problem is that Adiantum
> is still much slower than we're happy with, and encryption still has a
> quite noticeable effect on the feel of low-end devices.  Users and
> vendors push back hard against encryption that degrades the user
> experience, which always risks encryption being disabled entirely.  So
> we need to choose the fastest option that gives us a solid margin of
> security, and here that's XChaCha12.  The best known attack on ChaCha
> breaks only 7 rounds and has 2^235 time complexity, so ChaCha12's
> security margin is still better than AES-256's.  Much has been learned
> about cryptanalysis of ARX ciphers since Salsa20 was originally designed
> in 2005, and it now seems we can be comfortable with a smaller number of
> rounds.  The eSTREAM project also suggests the 12-round version of
> Salsa20 as providing the best balance among the different variants:
> combining very good performance with a "comfortable margin of security".
>
> Note that it would be trivial to add vanilla ChaCha12 in addition to
> XChaCha12.  However, it's unneeded for now and therefore is omitted.
>
> As discussed in the patch that introduced XChaCha20 support, I
> considered splitting the code into separate chacha-common, chacha20,
> xchacha20, and xchacha12 modules, so that these algorithms could be
> enabled/disabled independently.  However, since nearly all the code is
> shared anyway, I ultimately decided there would have been little benefit
> to the added complexity.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

One nit below but

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  crypto/Kconfig          |   8 +-
>  crypto/chacha_generic.c |  26 +-
>  crypto/testmgr.c        |   6 +
>  crypto/testmgr.h        | 578 ++++++++++++++++++++++++++++++++++++++++
>  include/crypto/chacha.h |   7 +
>  lib/chacha.c            |   6 +-
>  6 files changed, 625 insertions(+), 6 deletions(-)
>
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index d9acbce23d4d5..4fa0a4a0e8615 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -1387,10 +1387,10 @@ config CRYPTO_SALSA20
>           Bernstein <djb@cr.yp.to>. See <http://cr.yp.to/snuffle.html>
>
>  config CRYPTO_CHACHA20
> -       tristate "ChaCha20 stream cipher algorithms"
> +       tristate "ChaCha stream cipher algorithms"
>         select CRYPTO_BLKCIPHER
>         help
> -         The ChaCha20 and XChaCha20 stream cipher algorithms.
> +         The ChaCha20, XChaCha20, and XChaCha12 stream cipher algorithms.
>
>           ChaCha20 is a 256-bit high-speed stream cipher designed by Daniel J.
>           Bernstein and further specified in RFC7539 for use in IETF protocols.
> @@ -1403,6 +1403,10 @@ config CRYPTO_CHACHA20
>           while provably retaining ChaCha20's security.  See also:
>           <https://cr.yp.to/snuffle/xsalsa-20081128.pdf>
>
> +         XChaCha12 is XChaCha20 reduced to 12 rounds, with correspondingly
> +         reduced security margin but increased performance.  It can be needed
> +         in some performance-sensitive scenarios.
> +
>  config CRYPTO_CHACHA20_X86_64
>         tristate "ChaCha20 cipher algorithm (x86_64/SSSE3/AVX2)"
>         depends on X86 && 64BIT
> diff --git a/crypto/chacha_generic.c b/crypto/chacha_generic.c
> index 8e25e9930c549..8f8f84e51f334 100644
> --- a/crypto/chacha_generic.c
> +++ b/crypto/chacha_generic.c
> @@ -1,5 +1,5 @@
>  /*
> - * ChaCha20 (RFC7539) and XChaCha20 stream cipher algorithms
> + * ChaCha and XChaCha stream ciphers, including ChaCha20 (RFC7539)
>   *
>   * Copyright (C) 2015 Martin Willi
>   * Copyright (C) 2018 Google LLC
> @@ -106,6 +106,13 @@ int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
>  }
>  EXPORT_SYMBOL_GPL(crypto_chacha20_setkey);
>
> +int crypto_chacha12_setkey(struct crypto_skcipher *tfm, const u8 *key,
> +                          unsigned int keysize)
> +{
> +       return chacha_setkey(tfm, key, keysize, 12);
> +}
> +EXPORT_SYMBOL_GPL(crypto_chacha12_setkey);
> +
>  int crypto_chacha_crypt(struct skcipher_request *req)
>  {
>         struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
> @@ -168,6 +175,21 @@ static struct skcipher_alg algs[] = {
>                 .setkey                 = crypto_chacha20_setkey,
>                 .encrypt                = crypto_xchacha_crypt,
>                 .decrypt                = crypto_xchacha_crypt,
> +       }, {
> +               .base.cra_name          = "xchacha12",
> +               .base.cra_driver_name   = "xchacha12-generic",
> +               .base.cra_priority      = 100,
> +               .base.cra_blocksize     = 1,
> +               .base.cra_ctxsize       = sizeof(struct chacha_ctx),
> +               .base.cra_module        = THIS_MODULE,
> +
> +               .min_keysize            = CHACHA_KEY_SIZE,
> +               .max_keysize            = CHACHA_KEY_SIZE,
> +               .ivsize                 = XCHACHA_IV_SIZE,
> +               .chunksize              = CHACHA_BLOCK_SIZE,
> +               .setkey                 = crypto_chacha12_setkey,
> +               .encrypt                = crypto_xchacha_crypt,
> +               .decrypt                = crypto_xchacha_crypt,
>         }
>  };
>
> @@ -191,3 +213,5 @@ MODULE_ALIAS_CRYPTO("chacha20");
>  MODULE_ALIAS_CRYPTO("chacha20-generic");
>  MODULE_ALIAS_CRYPTO("xchacha20");
>  MODULE_ALIAS_CRYPTO("xchacha20-generic");
> +MODULE_ALIAS_CRYPTO("xchacha12");
> +MODULE_ALIAS_CRYPTO("xchacha12-generic");
> diff --git a/crypto/testmgr.c b/crypto/testmgr.c
> index a5512e69c8f31..3ff70ebc745cb 100644
> --- a/crypto/testmgr.c
> +++ b/crypto/testmgr.c
> @@ -3544,6 +3544,12 @@ static const struct alg_test_desc alg_test_descs[] = {
>                 .suite = {
>                         .hash = __VECS(aes_xcbc128_tv_template)
>                 }
> +       }, {
> +               .alg = "xchacha12",
> +               .test = alg_test_skcipher,
> +               .suite = {
> +                       .cipher = __VECS(xchacha12_tv_template)
> +               },
>         }, {
>                 .alg = "xchacha20",
>                 .test = alg_test_skcipher,
> diff --git a/crypto/testmgr.h b/crypto/testmgr.h
> index 371641c73cf8c..3b57b2701fcb2 100644
> --- a/crypto/testmgr.h
> +++ b/crypto/testmgr.h
> @@ -31379,6 +31379,584 @@ static const struct cipher_testvec xchacha20_tv_template[] = {
>         },
>  };
>
> +/*
> + * Same as XChaCha20 test vectors above, but recomputed the ciphertext with
> + * XChaCha12, using a modified libsodium.
> + */
> +static const struct cipher_testvec xchacha12_tv_template[] = {
> +       {
> +               .key    = "\x79\xc9\x97\x98\xac\x67\x30\x0b"
> +                         "\xbb\x27\x04\xc9\x5c\x34\x1e\x32"
> +                         "\x45\xf3\xdc\xb2\x17\x61\xb9\x8e"
> +                         "\x52\xff\x45\xb2\x4f\x30\x4f\xc4",
> +               .klen   = 32,
> +               .iv     = "\xb3\x3f\xfd\x30\x96\x47\x9b\xcf"
> +                         "\xbc\x9a\xee\x49\x41\x76\x88\xa0"
> +                         "\xa2\x55\x4f\x8d\x95\x38\x94\x19"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00",
> +               .ctext  = "\x1b\x78\x7f\xd7\xa1\x41\x68\xab"
> +                         "\x3d\x3f\xd1\x7b\x69\x56\xb2\xd5"
> +                         "\x43\xce\xeb\xaf\x36\xf0\x29\x9d"
> +                         "\x3a\xfb\x18\xae\x1b",
> +               .len    = 29,
> +       }, {
> +               .key    = "\x9d\x23\xbd\x41\x49\xcb\x97\x9c"
> +                         "\xcf\x3c\x5c\x94\xdd\x21\x7e\x98"
> +                         "\x08\xcb\x0e\x50\xcd\x0f\x67\x81"
> +                         "\x22\x35\xea\xaf\x60\x1d\x62\x32",
> +               .klen   = 32,
> +               .iv     = "\xc0\x47\x54\x82\x66\xb7\xc3\x70"
> +                         "\xd3\x35\x66\xa2\x42\x5c\xbf\x30"
> +                         "\xd8\x2d\x1e\xaf\x52\x94\x10\x9e"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00",
> +               .ctext  = "\xfb\x32\x09\x1d\x83\x05\xae\x4c"
> +                         "\x13\x1f\x12\x71\xf2\xca\xb2\xeb"
> +                         "\x5b\x83\x14\x7d\x83\xf6\x57\x77"
> +                         "\x2e\x40\x1f\x92\x2c\xf9\xec\x35"
> +                         "\x34\x1f\x93\xdf\xfb\x30\xd7\x35"
> +                         "\x03\x05\x78\xc1\x20\x3b\x7a\xe3"
> +                         "\x62\xa3\x89\xdc\x11\x11\x45\xa8"
> +                         "\x82\x89\xa0\xf1\x4e\xc7\x0f\x11"
> +                         "\x69\xdd\x0c\x84\x2b\x89\x5c\xdc"
> +                         "\xf0\xde\x01\xef\xc5\x65\x79\x23"
> +                         "\x87\x67\xd6\x50\xd9\x8d\xd9\x92"
> +                         "\x54\x5b\x0e",
> +               .len    = 91,
> +       }, {
> +               .key    = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00",
> +               .klen   = 32,
> +               .iv     = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x67\xc6\x69\x73"
> +                         "\x51\xff\x4a\xec\x29\xcd\xba\xab"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00",
> +               .ctext  = "\xdf\x2d\xc6\x21\x2a\x9d\xa1\xbb"
> +                         "\xc2\x77\x66\x0c\x5c\x46\xef\xa7"
> +                         "\x79\x1b\xb9\xdf\x55\xe2\xf9\x61"
> +                         "\x4c\x7b\xa4\x52\x24\xaf\xa2\xda"
> +                         "\xd1\x8f\x8f\xa2\x9e\x53\x4d\xc4"
> +                         "\xb8\x55\x98\x08\x7c\x08\xd4\x18"
> +                         "\x67\x8f\xef\x50\xb1\x5f\xa5\x77"
> +                         "\x4c\x25\xe7\x86\x26\x42\xca\x44",
> +               .len    = 64,
> +       }, {
> +               .key    = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x00\x00\x00\x00\x01",
> +               .klen   = 32,
> +               .iv     = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x02\xf2\xfb\xe3\x46"
> +                         "\x7c\xc2\x54\xf8\x1b\xe8\xe7\x8d"
> +                         "\x01\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x41\x6e\x79\x20\x73\x75\x62\x6d"
> +                         "\x69\x73\x73\x69\x6f\x6e\x20\x74"
> +                         "\x6f\x20\x74\x68\x65\x20\x49\x45"
> +                         "\x54\x46\x20\x69\x6e\x74\x65\x6e"
> +                         "\x64\x65\x64\x20\x62\x79\x20\x74"
> +                         "\x68\x65\x20\x43\x6f\x6e\x74\x72"
> +                         "\x69\x62\x75\x74\x6f\x72\x20\x66"
> +                         "\x6f\x72\x20\x70\x75\x62\x6c\x69"
> +                         "\x63\x61\x74\x69\x6f\x6e\x20\x61"
> +                         "\x73\x20\x61\x6c\x6c\x20\x6f\x72"
> +                         "\x20\x70\x61\x72\x74\x20\x6f\x66"
> +                         "\x20\x61\x6e\x20\x49\x45\x54\x46"
> +                         "\x20\x49\x6e\x74\x65\x72\x6e\x65"
> +                         "\x74\x2d\x44\x72\x61\x66\x74\x20"
> +                         "\x6f\x72\x20\x52\x46\x43\x20\x61"
> +                         "\x6e\x64\x20\x61\x6e\x79\x20\x73"
> +                         "\x74\x61\x74\x65\x6d\x65\x6e\x74"
> +                         "\x20\x6d\x61\x64\x65\x20\x77\x69"
> +                         "\x74\x68\x69\x6e\x20\x74\x68\x65"
> +                         "\x20\x63\x6f\x6e\x74\x65\x78\x74"
> +                         "\x20\x6f\x66\x20\x61\x6e\x20\x49"
> +                         "\x45\x54\x46\x20\x61\x63\x74\x69"
> +                         "\x76\x69\x74\x79\x20\x69\x73\x20"
> +                         "\x63\x6f\x6e\x73\x69\x64\x65\x72"
> +                         "\x65\x64\x20\x61\x6e\x20\x22\x49"
> +                         "\x45\x54\x46\x20\x43\x6f\x6e\x74"
> +                         "\x72\x69\x62\x75\x74\x69\x6f\x6e"
> +                         "\x22\x2e\x20\x53\x75\x63\x68\x20"
> +                         "\x73\x74\x61\x74\x65\x6d\x65\x6e"
> +                         "\x74\x73\x20\x69\x6e\x63\x6c\x75"
> +                         "\x64\x65\x20\x6f\x72\x61\x6c\x20"
> +                         "\x73\x74\x61\x74\x65\x6d\x65\x6e"
> +                         "\x74\x73\x20\x69\x6e\x20\x49\x45"
> +                         "\x54\x46\x20\x73\x65\x73\x73\x69"
> +                         "\x6f\x6e\x73\x2c\x20\x61\x73\x20"
> +                         "\x77\x65\x6c\x6c\x20\x61\x73\x20"
> +                         "\x77\x72\x69\x74\x74\x65\x6e\x20"
> +                         "\x61\x6e\x64\x20\x65\x6c\x65\x63"
> +                         "\x74\x72\x6f\x6e\x69\x63\x20\x63"
> +                         "\x6f\x6d\x6d\x75\x6e\x69\x63\x61"
> +                         "\x74\x69\x6f\x6e\x73\x20\x6d\x61"
> +                         "\x64\x65\x20\x61\x74\x20\x61\x6e"
> +                         "\x79\x20\x74\x69\x6d\x65\x20\x6f"
> +                         "\x72\x20\x70\x6c\x61\x63\x65\x2c"
> +                         "\x20\x77\x68\x69\x63\x68\x20\x61"
> +                         "\x72\x65\x20\x61\x64\x64\x72\x65"
> +                         "\x73\x73\x65\x64\x20\x74\x6f",
> +               .ctext  = "\xe4\xa6\xc8\x30\xc4\x23\x13\xd6"
> +                         "\x08\x4d\xc9\xb7\xa5\x64\x7c\xb9"
> +                         "\x71\xe2\xab\x3e\xa8\x30\x8a\x1c"
> +                         "\x4a\x94\x6d\x9b\xe0\xb3\x6f\xf1"
> +                         "\xdc\xe3\x1b\xb3\xa9\x6d\x0d\xd6"
> +                         "\xd0\xca\x12\xef\xe7\x5f\xd8\x61"
> +                         "\x3c\x82\xd3\x99\x86\x3c\x6f\x66"
> +                         "\x02\x06\xdc\x55\xf9\xed\xdf\x38"
> +                         "\xb4\xa6\x17\x00\x7f\xef\xbf\x4f"
> +                         "\xf8\x36\xf1\x60\x7e\x47\xaf\xdb"
> +                         "\x55\x9b\x12\xcb\x56\x44\xa7\x1f"
> +                         "\xd3\x1a\x07\x3b\x00\xec\xe6\x4c"
> +                         "\xa2\x43\x27\xdf\x86\x19\x4f\x16"
> +                         "\xed\xf9\x4a\xf3\x63\x6f\xfa\x7f"
> +                         "\x78\x11\xf6\x7d\x97\x6f\xec\x6f"
> +                         "\x85\x0f\x5c\x36\x13\x8d\x87\xe0"
> +                         "\x80\xb1\x69\x0b\x98\x89\x9c\x4e"
> +                         "\xf8\xdd\xee\x5c\x0a\x85\xce\xd4"
> +                         "\xea\x1b\x48\xbe\x08\xf8\xe2\xa8"
> +                         "\xa5\xb0\x3c\x79\xb1\x15\xb4\xb9"
> +                         "\x75\x10\x95\x35\x81\x7e\x26\xe6"
> +                         "\x78\xa4\x88\xcf\xdb\x91\x34\x18"
> +                         "\xad\xd7\x8e\x07\x7d\xab\x39\xf9"
> +                         "\xa3\x9e\xa5\x1d\xbb\xed\x61\xfd"
> +                         "\xdc\xb7\x5a\x27\xfc\xb5\xc9\x10"
> +                         "\xa8\xcc\x52\x7f\x14\x76\x90\xe7"
> +                         "\x1b\x29\x60\x74\xc0\x98\x77\xbb"
> +                         "\xe0\x54\xbb\x27\x49\x59\x1e\x62"
> +                         "\x3d\xaf\x74\x06\xa4\x42\x6f\xc6"
> +                         "\x52\x97\xc4\x1d\xc4\x9f\xe2\xe5"
> +                         "\x38\x57\x91\xd1\xa2\x28\xcc\x40"
> +                         "\xcc\x70\x59\x37\xfc\x9f\x4b\xda"
> +                         "\xa0\xeb\x97\x9a\x7d\xed\x14\x5c"
> +                         "\x9c\xb7\x93\x26\x41\xa8\x66\xdd"
> +                         "\x87\x6a\xc0\xd3\xc2\xa9\x3e\xae"
> +                         "\xe9\x72\xfe\xd1\xb3\xac\x38\xea"
> +                         "\x4d\x15\xa9\xd5\x36\x61\xe9\x96"
> +                         "\x6c\x23\xf8\x43\xe4\x92\x29\xd9"
> +                         "\x8b\x78\xf7\x0a\x52\xe0\x19\x5b"
> +                         "\x59\x69\x5b\x5d\xa1\x53\xc4\x68"
> +                         "\xe1\xbb\xac\x89\x14\xe2\xe2\x85"
> +                         "\x41\x18\xf5\xb3\xd1\xfa\x68\x19"
> +                         "\x44\x78\xdc\xcf\xe7\x88\x2d\x52"
> +                         "\x5f\x40\xb5\x7e\xf8\x88\xa2\xae"
> +                         "\x4a\xb2\x07\x35\x9d\x9b\x07\x88"
> +                         "\xb7\x00\xd0\x0c\xb6\xa0\x47\x59"
> +                         "\xda\x4e\xc9\xab\x9b\x8a\x7b",
> +
> +               .len    = 375,
> +               .also_non_np = 1,
> +               .np     = 3,
> +               .tap    = { 375 - 20, 4, 16 },
> +
> +       }, {
> +               .key    = "\x1c\x92\x40\xa5\xeb\x55\xd3\x8a"
> +                         "\xf3\x33\x88\x86\x04\xf6\xb5\xf0"
> +                         "\x47\x39\x17\xc1\x40\x2b\x80\x09"
> +                         "\x9d\xca\x5c\xbc\x20\x70\x75\xc0",
> +               .klen   = 32,
> +               .iv     = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x02\x76\x5a\x2e\x63"
> +                         "\x33\x9f\xc9\x9a\x66\x32\x0d\xb7"
> +                         "\x2a\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x27\x54\x77\x61\x73\x20\x62\x72"
> +                         "\x69\x6c\x6c\x69\x67\x2c\x20\x61"
> +                         "\x6e\x64\x20\x74\x68\x65\x20\x73"
> +                         "\x6c\x69\x74\x68\x79\x20\x74\x6f"
> +                         "\x76\x65\x73\x0a\x44\x69\x64\x20"
> +                         "\x67\x79\x72\x65\x20\x61\x6e\x64"
> +                         "\x20\x67\x69\x6d\x62\x6c\x65\x20"
> +                         "\x69\x6e\x20\x74\x68\x65\x20\x77"
> +                         "\x61\x62\x65\x3a\x0a\x41\x6c\x6c"
> +                         "\x20\x6d\x69\x6d\x73\x79\x20\x77"
> +                         "\x65\x72\x65\x20\x74\x68\x65\x20"
> +                         "\x62\x6f\x72\x6f\x67\x6f\x76\x65"
> +                         "\x73\x2c\x0a\x41\x6e\x64\x20\x74"
> +                         "\x68\x65\x20\x6d\x6f\x6d\x65\x20"
> +                         "\x72\x61\x74\x68\x73\x20\x6f\x75"
> +                         "\x74\x67\x72\x61\x62\x65\x2e",
> +               .ctext  = "\xb9\x68\xbc\x6a\x24\xbc\xcc\xd8"
> +                         "\x9b\x2a\x8d\x5b\x96\xaf\x56\xe3"
> +                         "\x11\x61\xe7\xa7\x9b\xce\x4e\x7d"
> +                         "\x60\x02\x48\xac\xeb\xd5\x3a\x26"
> +                         "\x9d\x77\x3b\xb5\x32\x13\x86\x8e"
> +                         "\x20\x82\x26\x72\xae\x64\x1b\x7e"
> +                         "\x2e\x01\x68\xb4\x87\x45\xa1\x24"
> +                         "\xe4\x48\x40\xf0\xaa\xac\xee\xa9"
> +                         "\xfc\x31\xad\x9d\x89\xa3\xbb\xd2"
> +                         "\xe4\x25\x13\xad\x0f\x5e\xdf\x3c"
> +                         "\x27\xab\xb8\x62\x46\x22\x30\x48"
> +                         "\x55\x2c\x4e\x84\x78\x1d\x0d\x34"
> +                         "\x8d\x3c\x91\x0a\x7f\x5b\x19\x9f"
> +                         "\x97\x05\x4c\xa7\x62\x47\x8b\xc5"
> +                         "\x44\x2e\x20\x33\xdd\xa0\x82\xa9"
> +                         "\x25\x76\x37\xe6\x3c\x67\x5b",
> +               .len    = 127,
> +       }, {
> +               .key    = "\x1c\x92\x40\xa5\xeb\x55\xd3\x8a"
> +                         "\xf3\x33\x88\x86\x04\xf6\xb5\xf0"
> +                         "\x47\x39\x17\xc1\x40\x2b\x80\x09"
> +                         "\x9d\xca\x5c\xbc\x20\x70\x75\xc0",
> +               .klen   = 32,
> +               .iv     = "\x00\x00\x00\x00\x00\x00\x00\x00"
> +                         "\x00\x00\x00\x01\x31\x58\xa3\x5a"
> +                         "\x25\x5d\x05\x17\x58\xe9\x5e\xd4"
> +                         "\x1c\x00\x00\x00\x00\x00\x00\x00",
> +               .ptext  = "\x49\xee\xe0\xdc\x24\x90\x40\xcd"
> +                         "\xc5\x40\x8f\x47\x05\xbc\xdd\x81"
> +                         "\x47\xc6\x8d\xe6\xb1\x8f\xd7\xcb"
> +                         "\x09\x0e\x6e\x22\x48\x1f\xbf\xb8"
> +                         "\x5c\xf7\x1e\x8a\xc1\x23\xf2\xd4"
> +                         "\x19\x4b\x01\x0f\x4e\xa4\x43\xce"
> +                         "\x01\xc6\x67\xda\x03\x91\x18\x90"
> +                         "\xa5\xa4\x8e\x45\x03\xb3\x2d\xac"
> +                         "\x74\x92\xd3\x53\x47\xc8\xdd\x25"
> +                         "\x53\x6c\x02\x03\x87\x0d\x11\x0c"
> +                         "\x58\xe3\x12\x18\xfd\x2a\x5b\x40"
> +                         "\x0c\x30\xf0\xb8\x3f\x43\xce\xae"
> +                         "\x65\x3a\x7d\x7c\xf4\x54\xaa\xcc"
> +                         "\x33\x97\xc3\x77\xba\xc5\x70\xde"
> +                         "\xd7\xd5\x13\xa5\x65\xc4\x5f\x0f"
> +                         "\x46\x1a\x0d\x97\xb5\xf3\xbb\x3c"
> +                         "\x84\x0f\x2b\xc5\xaa\xea\xf2\x6c"
> +                         "\xc9\xb5\x0c\xee\x15\xf3\x7d\xbe"
> +                         "\x9f\x7b\x5a\xa6\xae\x4f\x83\xb6"
> +                         "\x79\x49\x41\xf4\x58\x18\xcb\x86"
> +                         "\x7f\x30\x0e\xf8\x7d\x44\x36\xea"
> +                         "\x75\xeb\x88\x84\x40\x3c\xad\x4f"
> +                         "\x6f\x31\x6b\xaa\x5d\xe5\xa5\xc5"
> +                         "\x21\x66\xe9\xa7\xe3\xb2\x15\x88"
> +                         "\x78\xf6\x79\xa1\x59\x47\x12\x4e"
> +                         "\x9f\x9f\x64\x1a\xa0\x22\x5b\x08"
> +                         "\xbe\x7c\x36\xc2\x2b\x66\x33\x1b"
> +                         "\xdd\x60\x71\xf7\x47\x8c\x61\xc3"
> +                         "\xda\x8a\x78\x1e\x16\xfa\x1e\x86"
> +                         "\x81\xa6\x17\x2a\xa7\xb5\xc2\xe7"
> +                         "\xa4\xc7\x42\xf1\xcf\x6a\xca\xb4"
> +                         "\x45\xcf\xf3\x93\xf0\xe7\xea\xf6"
> +                         "\xf4\xe6\x33\x43\x84\x93\xa5\x67"
> +                         "\x9b\x16\x58\x58\x80\x0f\x2b\x5c"
> +                         "\x24\x74\x75\x7f\x95\x81\xb7\x30"
> +                         "\x7a\x33\xa7\xf7\x94\x87\x32\x27"
> +                         "\x10\x5d\x14\x4c\x43\x29\xdd\x26"
> +                         "\xbd\x3e\x3c\x0e\xfe\x0e\xa5\x10"
> +                         "\xea\x6b\x64\xfd\x73\xc6\xed\xec"
> +                         "\xa8\xc9\xbf\xb3\xba\x0b\x4d\x07"
> +                         "\x70\xfc\x16\xfd\x79\x1e\xd7\xc5"
> +                         "\x49\x4e\x1c\x8b\x8d\x79\x1b\xb1"
> +                         "\xec\xca\x60\x09\x4c\x6a\xd5\x09"
> +                         "\x49\x46\x00\x88\x22\x8d\xce\xea"
> +                         "\xb1\x17\x11\xde\x42\xd2\x23\xc1"
> +                         "\x72\x11\xf5\x50\x73\x04\x40\x47"
> +                         "\xf9\x5d\xe7\xa7\x26\xb1\x7e\xb0"
> +                         "\x3f\x58\xc1\x52\xab\x12\x67\x9d"
> +                         "\x3f\x43\x4b\x68\xd4\x9c\x68\x38"
> +                         "\x07\x8a\x2d\x3e\xf3\xaf\x6a\x4b"
> +                         "\xf9\xe5\x31\x69\x22\xf9\xa6\x69"
> +                         "\xc6\x9c\x96\x9a\x12\x35\x95\x1d"
> +                         "\x95\xd5\xdd\xbe\xbf\x93\x53\x24"
> +                         "\xfd\xeb\xc2\x0a\x64\xb0\x77\x00"
> +                         "\x6f\x88\xc4\x37\x18\x69\x7c\xd7"
> +                         "\x41\x92\x55\x4c\x03\xa1\x9a\x4b"
> +                         "\x15\xe5\xdf\x7f\x37\x33\x72\xc1"
> +                         "\x8b\x10\x67\xa3\x01\x57\x94\x25"
> +                         "\x7b\x38\x71\x7e\xdd\x1e\xcc\x73"
> +                         "\x55\xd2\x8e\xeb\x07\xdd\xf1\xda"
> +                         "\x58\xb1\x47\x90\xfe\x42\x21\x72"
> +                         "\xa3\x54\x7a\xa0\x40\xec\x9f\xdd"
> +                         "\xc6\x84\x6e\xca\xae\xe3\x68\xb4"
> +                         "\x9d\xe4\x78\xff\x57\xf2\xf8\x1b"
> +                         "\x03\xa1\x31\xd9\xde\x8d\xf5\x22"
> +                         "\x9c\xdd\x20\xa4\x1e\x27\xb1\x76"
> +                         "\x4f\x44\x55\xe2\x9b\xa1\x9c\xfe"
> +                         "\x54\xf7\x27\x1b\xf4\xde\x02\xf5"
> +                         "\x1b\x55\x48\x5c\xdc\x21\x4b\x9e"
> +                         "\x4b\x6e\xed\x46\x23\xdc\x65\xb2"
> +                         "\xcf\x79\x5f\x28\xe0\x9e\x8b\xe7"
> +                         "\x4c\x9d\x8a\xff\xc1\xa6\x28\xb8"
> +                         "\x65\x69\x8a\x45\x29\xef\x74\x85"
> +                         "\xde\x79\xc7\x08\xae\x30\xb0\xf4"
> +                         "\xa3\x1d\x51\x41\xab\xce\xcb\xf6"
> +                         "\xb5\xd8\x6d\xe0\x85\xe1\x98\xb3"
> +                         "\x43\xbb\x86\x83\x0a\xa0\xf5\xb7"
> +                         "\x04\x0b\xfa\x71\x1f\xb0\xf6\xd9"
> +                         "\x13\x00\x15\xf0\xc7\xeb\x0d\x5a"
> +                         "\x9f\xd7\xb9\x6c\x65\x14\x22\x45"
> +                         "\x6e\x45\x32\x3e\x7e\x60\x1a\x12"
> +                         "\x97\x82\x14\xfb\xaa\x04\x22\xfa"
> +                         "\xa0\xe5\x7e\x8c\x78\x02\x48\x5d"
> +                         "\x78\x33\x5a\x7c\xad\xdb\x29\xce"
> +                         "\xbb\x8b\x61\xa4\xb7\x42\xe2\xac"
> +                         "\x8b\x1a\xd9\x2f\x0b\x8b\x62\x21"
> +                         "\x83\x35\x7e\xad\x73\xc2\xb5\x6c"
> +                         "\x10\x26\x38\x07\xe5\xc7\x36\x80"
> +                         "\xe2\x23\x12\x61\xf5\x48\x4b\x2b"
> +                         "\xc5\xdf\x15\xd9\x87\x01\xaa\xac"
> +                         "\x1e\x7c\xad\x73\x78\x18\x63\xe0"
> +                         "\x8b\x9f\x81\xd8\x12\x6a\x28\x10"
> +                         "\xbe\x04\x68\x8a\x09\x7c\x1b\x1c"
> +                         "\x83\x66\x80\x47\x80\xe8\xfd\x35"
> +                         "\x1c\x97\x6f\xae\x49\x10\x66\xcc"
> +                         "\xc6\xd8\xcc\x3a\x84\x91\x20\x77"
> +                         "\x72\xe4\x24\xd2\x37\x9f\xc5\xc9"
> +                         "\x25\x94\x10\x5f\x40\x00\x64\x99"
> +                         "\xdc\xae\xd7\x21\x09\x78\x50\x15"
> +                         "\xac\x5f\xc6\x2c\xa2\x0b\xa9\x39"
> +                         "\x87\x6e\x6d\xab\xde\x08\x51\x16"
> +                         "\xc7\x13\xe9\xea\xed\x06\x8e\x2c"
> +                         "\xf8\x37\x8c\xf0\xa6\x96\x8d\x43"
> +                         "\xb6\x98\x37\xb2\x43\xed\xde\xdf"
> +                         "\x89\x1a\xe7\xeb\x9d\xa1\x7b\x0b"
> +                         "\x77\xb0\xe2\x75\xc0\xf1\x98\xd9"
> +                         "\x80\x55\xc9\x34\x91\xd1\x59\xe8"
> +                         "\x4b\x0f\xc1\xa9\x4b\x7a\x84\x06"
> +                         "\x20\xa8\x5d\xfa\xd1\xde\x70\x56"
> +                         "\x2f\x9e\x91\x9c\x20\xb3\x24\xd8"
> +                         "\x84\x3d\xe1\x8c\x7e\x62\x52\xe5"
> +                         "\x44\x4b\x9f\xc2\x93\x03\xea\x2b"
> +                         "\x59\xc5\xfa\x3f\x91\x2b\xbb\x23"
> +                         "\xf5\xb2\x7b\xf5\x38\xaf\xb3\xee"
> +                         "\x63\xdc\x7b\xd1\xff\xaa\x8b\xab"
> +                         "\x82\x6b\x37\x04\xeb\x74\xbe\x79"
> +                         "\xb9\x83\x90\xef\x20\x59\x46\xff"
> +                         "\xe9\x97\x3e\x2f\xee\xb6\x64\x18"
> +                         "\x38\x4c\x7a\x4a\xf9\x61\xe8\x9a"
> +                         "\xa1\xb5\x01\xa6\x47\xd3\x11\xd4"
> +                         "\xce\xd3\x91\x49\x88\xc7\xb8\x4d"
> +                         "\xb1\xb9\x07\x6d\x16\x72\xae\x46"
> +                         "\x5e\x03\xa1\x4b\xb6\x02\x30\xa8"
> +                         "\x3d\xa9\x07\x2a\x7c\x19\xe7\x62"
> +                         "\x87\xe3\x82\x2f\x6f\xe1\x09\xd9"
> +                         "\x94\x97\xea\xdd\x58\x9e\xae\x76"
> +                         "\x7e\x35\xe5\xb4\xda\x7e\xf4\xde"
> +                         "\xf7\x32\x87\xcd\x93\xbf\x11\x56"
> +                         "\x11\xbe\x08\x74\xe1\x69\xad\xe2"
> +                         "\xd7\xf8\x86\x75\x8a\x3c\xa4\xbe"
> +                         "\x70\xa7\x1b\xfc\x0b\x44\x2a\x76"
> +                         "\x35\xea\x5d\x85\x81\xaf\x85\xeb"
> +                         "\xa0\x1c\x61\xc2\xf7\x4f\xa5\xdc"
> +                         "\x02\x7f\xf6\x95\x40\x6e\x8a\x9a"
> +                         "\xf3\x5d\x25\x6e\x14\x3a\x22\xc9"
> +                         "\x37\x1c\xeb\x46\x54\x3f\xa5\x91"
> +                         "\xc2\xb5\x8c\xfe\x53\x08\x97\x32"
> +                         "\x1b\xb2\x30\x27\xfe\x25\x5d\xdc"
> +                         "\x08\x87\xd0\xe5\x94\x1a\xd4\xf1"
> +                         "\xfe\xd6\xb4\xa3\xe6\x74\x81\x3c"
> +                         "\x1b\xb7\x31\xa7\x22\xfd\xd4\xdd"
> +                         "\x20\x4e\x7c\x51\xb0\x60\x73\xb8"
> +                         "\x9c\xac\x91\x90\x7e\x01\xb0\xe1"
> +                         "\x8a\x2f\x75\x1c\x53\x2a\x98\x2a"
> +                         "\x06\x52\x95\x52\xb2\xe9\x25\x2e"
> +                         "\x4c\xe2\x5a\x00\xb2\x13\x81\x03"
> +                         "\x77\x66\x0d\xa5\x99\xda\x4e\x8c"
> +                         "\xac\xf3\x13\x53\x27\x45\xaf\x64"
> +                         "\x46\xdc\xea\x23\xda\x97\xd1\xab"
> +                         "\x7d\x6c\x30\x96\x1f\xbc\x06\x34"
> +                         "\x18\x0b\x5e\x21\x35\x11\x8d\x4c"
> +                         "\xe0\x2d\xe9\x50\x16\x74\x81\xa8"
> +                         "\xb4\x34\xb9\x72\x42\xa6\xcc\xbc"
> +                         "\xca\x34\x83\x27\x10\x5b\x68\x45"
> +                         "\x8f\x52\x22\x0c\x55\x3d\x29\x7c"
> +                         "\xe3\xc0\x66\x05\x42\x91\x5f\x58"
> +                         "\xfe\x4a\x62\xd9\x8c\xa9\x04\x19"
> +                         "\x04\xa9\x08\x4b\x57\xfc\x67\x53"
> +                         "\x08\x7c\xbc\x66\x8a\xb0\xb6\x9f"
> +                         "\x92\xd6\x41\x7c\x5b\x2a\x00\x79"
> +                         "\x72",
> +               .ctext  = "\xe1\xb6\x8b\x5c\x80\xb8\xcc\x08"
> +                         "\x1b\x84\xb2\xd1\xad\xa4\x70\xac"
> +                         "\x67\xa9\x39\x27\xac\xb4\x5b\xb7"
> +                         "\x4c\x26\x77\x23\x1d\xce\x0a\xbe"
> +                         "\x18\x9e\x42\x8b\xbd\x7f\xd6\xf1"
> +                         "\xf1\x6b\xe2\x6d\x7f\x92\x0e\xcb"
> +                         "\xb8\x79\xba\xb4\xac\x7e\x2d\xc0"
> +                         "\x9e\x83\x81\x91\xd5\xea\xc3\x12"
> +                         "\x8d\xa4\x26\x70\xa4\xf9\x71\x0b"
> +                         "\xbd\x2e\xe1\xb3\x80\x42\x25\xb3"
> +                         "\x0b\x31\x99\xe1\x0d\xde\xa6\x90"
> +                         "\xf2\xa3\x10\xf7\xe5\xf3\x83\x1e"
> +                         "\x2c\xfb\x4d\xf0\x45\x3d\x28\x3c"
> +                         "\xb8\xf1\xcb\xbf\x67\xd8\x43\x5a"
> +                         "\x9d\x7b\x73\x29\x88\x0f\x13\x06"
> +                         "\x37\x50\x0d\x7c\xe6\x9b\x07\xdd"
> +                         "\x7e\x01\x1f\x81\x90\x10\x69\xdb"
> +                         "\xa4\xad\x8a\x5e\xac\x30\x72\xf2"
> +                         "\x36\xcd\xe3\x23\x49\x02\x93\xfa"
> +                         "\x3d\xbb\xe2\x98\x83\xeb\xe9\x8d"
> +                         "\xb3\x8f\x11\xaa\x53\xdb\xaf\x2e"
> +                         "\x95\x13\x99\x3d\x71\xbd\x32\x92"
> +                         "\xdd\xfc\x9d\x5e\x6f\x63\x2c\xee"
> +                         "\x91\x1f\x4c\x64\x3d\x87\x55\x0f"
> +                         "\xcc\x3d\x89\x61\x53\x02\x57\x8f"
> +                         "\xe4\x77\x29\x32\xaf\xa6\x2f\x0a"
> +                         "\xae\x3c\x3f\x3f\xf4\xfb\x65\x52"
> +                         "\xc5\xc1\x78\x78\x53\x28\xad\xed"
> +                         "\xd1\x67\x37\xc7\x59\x70\xcd\x0a"
> +                         "\xb8\x0f\x80\x51\x9f\xc0\x12\x5e"
> +                         "\x06\x0a\x7e\xec\x24\x5f\x73\x00"
> +                         "\xb1\x0b\x31\x47\x4f\x73\x8d\xb4"
> +                         "\xce\xf3\x55\x45\x6c\x84\x27\xba"
> +                         "\xb9\x6f\x03\x4a\xeb\x98\x88\x6e"
> +                         "\x53\xed\x25\x19\x0d\x8f\xfe\xca"
> +                         "\x60\xe5\x00\x93\x6e\x3c\xff\x19"
> +                         "\xae\x08\x3b\x8a\xa6\x84\x05\xfe"
> +                         "\x9b\x59\xa0\x8c\xc8\x05\x45\xf5"
> +                         "\x05\x37\xdc\x45\x6f\x8b\x95\x8c"
> +                         "\x4e\x11\x45\x7a\xce\x21\xa5\xf7"
> +                         "\x71\x67\xb9\xce\xd7\xf9\xe9\x5e"
> +                         "\x60\xf5\x53\x7a\xa8\x85\x14\x03"
> +                         "\xa0\x92\xec\xf3\x51\x80\x84\xc4"
> +                         "\xdc\x11\x9e\x57\xce\x4b\x45\xcf"
> +                         "\x90\x95\x85\x0b\x96\xe9\xee\x35"
> +                         "\x10\xb8\x9b\xf2\x59\x4a\xc6\x7e"
> +                         "\x85\xe5\x6f\x38\x51\x93\x40\x0c"
> +                         "\x99\xd7\x7f\x32\xa8\x06\x27\xd1"
> +                         "\x2b\xd5\xb5\x3a\x1a\xe1\x5e\xda"
> +                         "\xcd\x5a\x50\x30\x3c\xc7\xe7\x65"
> +                         "\xa6\x07\x0b\x98\x91\xc6\x20\x27"
> +                         "\x2a\x03\x63\x1b\x1e\x3d\xaf\xc8"
> +                         "\x71\x48\x46\x6a\x64\x28\xf9\x3d"
> +                         "\xd1\x1d\xab\xc8\x40\x76\xc2\x39"
> +                         "\x4e\x00\x75\xd2\x0e\x82\x58\x8c"
> +                         "\xd3\x73\x5a\xea\x46\x89\xbe\xfd"
> +                         "\x4e\x2c\x0d\x94\xaa\x9b\x68\xac"
> +                         "\x86\x87\x30\x7e\xa9\x16\xcd\x59"
> +                         "\xd2\xa6\xbe\x0a\xd8\xf5\xfd\x2d"
> +                         "\x49\x69\xd2\x1a\x90\xd2\x1b\xed"
> +                         "\xff\x71\x04\x87\x87\x21\xc4\xb8"
> +                         "\x1f\x5b\x51\x33\xd0\xd6\x59\x9a"
> +                         "\x03\x0e\xd3\x8b\xfb\x57\x73\xfd"
> +                         "\x5a\x52\x63\x82\xc8\x85\x2f\xcb"
> +                         "\x74\x6d\x4e\xd9\x68\x37\x85\x6a"
> +                         "\xd4\xfb\x94\xed\x8d\xd1\x1a\xaf"
> +                         "\x76\xa7\xb7\x88\xd0\x2b\x4e\xda"
> +                         "\xec\x99\x94\x27\x6f\x87\x8c\xdf"
> +                         "\x4b\x5e\xa6\x66\xdd\xcb\x33\x7b"
> +                         "\x64\x94\x31\xa8\x37\xa6\x1d\xdb"
> +                         "\x0d\x5c\x93\xa4\x40\xf9\x30\x53"
> +                         "\x4b\x74\x8d\xdd\xf6\xde\x3c\xac"
> +                         "\x5c\x80\x01\x3a\xef\xb1\x9a\x02"
> +                         "\x0c\x22\x8e\xe7\x44\x09\x74\x4c"
> +                         "\xf2\x9a\x27\x69\x7f\x12\x32\x36"
> +                         "\xde\x92\xdf\xde\x8f\x5b\x31\xab"
> +                         "\x4a\x01\x26\xe0\xb1\xda\xe8\x37"
> +                         "\x21\x64\xe8\xff\x69\xfc\x9e\x41"
> +                         "\xd2\x96\x2d\x18\x64\x98\x33\x78"
> +                         "\x24\x61\x73\x9b\x47\x29\xf1\xa7"
> +                         "\xcb\x27\x0f\xf0\x85\x6d\x8c\x9d"
> +                         "\x2c\x95\x9e\xe5\xb2\x8e\x30\x29"
> +                         "\x78\x8a\x9d\x65\xb4\x8e\xde\x7b"
> +                         "\xd9\x00\x50\xf5\x7f\x81\xc3\x1b"
> +                         "\x25\x85\xeb\xc2\x8c\x33\x22\x1e"
> +                         "\x68\x38\x22\x30\xd8\x2e\x00\x98"
> +                         "\x85\x16\x06\x56\xb4\x81\x74\x20"
> +                         "\x95\xdb\x1c\x05\x19\xe8\x23\x4d"
> +                         "\x65\x5d\xcc\xd8\x7f\xc4\x2d\x0f"
> +                         "\x57\x26\x71\x07\xad\xaa\x71\x9f"
> +                         "\x19\x76\x2f\x25\x51\x88\xe4\xc0"
> +                         "\x82\x6e\x08\x05\x37\x04\xee\x25"
> +                         "\x23\x90\xe9\x4e\xce\x9b\x16\xc1"
> +                         "\x31\xe7\x6e\x2c\x1b\xe1\x85\x9a"
> +                         "\x0c\x8c\xbb\x12\x1e\x68\x7b\x93"
> +                         "\xa9\x3c\x39\x56\x23\x3e\x6e\xc7"
> +                         "\x77\x84\xd3\xe0\x86\x59\xaa\xb9"
> +                         "\xd5\x53\x58\xc9\x0a\x83\x5f\x85"
> +                         "\xd8\x47\x14\x67\x8a\x3c\x17\xe0"
> +                         "\xab\x02\x51\xea\xf1\xf0\x4f\x30"
> +                         "\x7d\xe0\x92\xc2\x5f\xfb\x19\x5a"
> +                         "\x3f\xbd\xf4\x39\xa4\x31\x0c\x39"
> +                         "\xd1\xae\x4e\xf7\x65\x7f\x1f\xce"
> +                         "\xc2\x39\xd1\x84\xd4\xe5\x02\xe0"
> +                         "\x58\xaa\xf1\x5e\x81\xaf\x7f\x72"
> +                         "\x0f\x08\x99\x43\xb9\xd8\xac\x41"
> +                         "\x35\x55\xf2\xb2\xd4\x98\xb8\x3b"
> +                         "\x2b\x3c\x3e\x16\x06\x31\xfc\x79"
> +                         "\x47\x38\x63\x51\xc5\xd0\x26\xd7"
> +                         "\x43\xb4\x2b\xd9\xc5\x05\xf2\x9d"
> +                         "\x18\xc9\x26\x82\x56\xd2\x11\x05"
> +                         "\xb6\x89\xb4\x43\x9c\xb5\x9d\x11"
> +                         "\x6c\x83\x37\x71\x27\x1c\xae\xbf"
> +                         "\xcd\x57\xd2\xee\x0d\x5a\x15\x26"
> +                         "\x67\x88\x80\x80\x1b\xdc\xc1\x62"
> +                         "\xdd\x4c\xff\x92\x5c\x6c\xe1\xa0"
> +                         "\xe3\x79\xa9\x65\x8c\x8c\x14\x42"
> +                         "\xe5\x11\xd2\x1a\xad\xa9\x56\x6f"
> +                         "\x98\xfc\x8a\x7b\x56\x1f\xc6\xc1"
> +                         "\x52\x12\x92\x9b\x41\x0f\x4b\xae"
> +                         "\x1b\x4a\xbc\xfe\x23\xb6\x94\x70"
> +                         "\x04\x30\x9e\x69\x47\xbe\xb8\x8f"
> +                         "\xca\x45\xd7\x8a\xf4\x78\x3e\xaa"
> +                         "\x71\x17\xd8\x1e\xb8\x11\x8f\xbc"
> +                         "\xc8\x1a\x65\x7b\x41\x89\x72\xc7"
> +                         "\x5f\xbe\xc5\x2a\xdb\x5c\x54\xf9"
> +                         "\x25\xa3\x7a\x80\x56\x9c\x8c\xab"
> +                         "\x26\x19\x10\x36\xa6\xf3\x14\x79"
> +                         "\x40\x98\x70\x68\xb7\x35\xd9\xb9"
> +                         "\x27\xd4\xe7\x74\x5b\x3d\x97\xb4"
> +                         "\xd9\xaa\xd9\xf2\xb5\x14\x84\x1f"
> +                         "\xa9\xde\x12\x44\x5b\x00\xc0\xbc"
> +                         "\xc8\x11\x25\x1b\x67\x7a\x15\x72"
> +                         "\xa6\x31\x6f\xf4\x68\x7a\x86\x9d"
> +                         "\x43\x1c\x5f\x16\xd3\xad\x2e\x52"
> +                         "\xf3\xb4\xc3\xfa\x27\x2e\x68\x6c"
> +                         "\x06\xe7\x4c\x4f\xa2\xe0\xe4\x21"
> +                         "\x5d\x9e\x33\x58\x8d\xbf\xd5\x70"
> +                         "\xf8\x80\xa5\xdd\xe7\x18\x79\xfa"
> +                         "\x7b\xfd\x09\x69\x2c\x37\x32\xa8"
> +                         "\x65\xfa\x8d\x8b\x5c\xcc\xe8\xf3"
> +                         "\x37\xf6\xa6\xc6\x5c\xa2\x66\x79"
> +                         "\xfa\x8a\xa7\xd1\x0b\x2e\x1b\x5e"
> +                         "\x95\x35\x00\x76\xae\x42\xf7\x50"
> +                         "\x51\x78\xfb\xb4\x28\x24\xde\x1a"
> +                         "\x70\x8b\xed\xca\x3c\x5e\xe4\xbd"
> +                         "\x28\xb5\xf3\x76\x4f\x67\x5d\x81"
> +                         "\xb2\x60\x87\xd9\x7b\x19\x1a\xa7"
> +                         "\x79\xa2\xfa\x3f\x9e\xa9\xd7\x25"
> +                         "\x61\xe1\x74\x31\xa2\x77\xa0\x1b"
> +                         "\xf6\xf7\xcb\xc5\xaa\x9e\xce\xf9"
> +                         "\x9b\x96\xef\x51\xc3\x1a\x44\x96"
> +                         "\xae\x17\x50\xab\x29\x08\xda\xcc"
> +                         "\x1a\xb3\x12\xd0\x24\xe4\xe2\xe0"
> +                         "\xc6\xe3\xcc\x82\xd0\xba\x47\x4c"
> +                         "\x3f\x49\xd7\xe8\xb6\x61\xaa\x65"
> +                         "\x25\x18\x40\x2d\x62\x25\x02\x71"
> +                         "\x61\xa2\xc1\xb2\x13\xd2\x71\x3f"
> +                         "\x43\x1a\xc9\x09\x92\xff\xd5\x57"
> +                         "\xf0\xfc\x5e\x1c\xf1\xf5\xf9\xf3"
> +                         "\x5b",
> +               .len    = 1281,
> +               .also_non_np = 1,
> +               .np     = 3,
> +               .tap    = { 1200, 1, 80 },
> +       },
> +};
> +
>  /*
>   * CTS (Cipher Text Stealing) mode tests
>   */
> diff --git a/include/crypto/chacha.h b/include/crypto/chacha.h
> index ae79e9983c72f..3d261f5cd156d 100644
> --- a/include/crypto/chacha.h
> +++ b/include/crypto/chacha.h
> @@ -5,6 +5,11 @@
>   * XChaCha extends ChaCha's nonce to 192 bits, while provably retaining ChaCha's
>   * security.  Here they share the same key size, tfm context, and setkey
>   * function; only their IV size and encrypt/decrypt function differ.
> + *
> + * The ChaCha paper specifies 20, 12, and 8-round variants.  In general, it is
> + * recommended to use the 20-round variant ChaCha20.  However, the other
> + * variants can be needed in some performance-sensitive scenarios.  The generic
> + * ChaCha code currently allows only the 20 and 12-round variants.
>   */
>
>  #ifndef _CRYPTO_CHACHA_H
> @@ -39,6 +44,8 @@ void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv);
>
>  int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
>                            unsigned int keysize);
> +int crypto_chacha12_setkey(struct crypto_skcipher *tfm, const u8 *key,
> +                          unsigned int keysize);
>
>  int crypto_chacha_crypt(struct skcipher_request *req);
>  int crypto_xchacha_crypt(struct skcipher_request *req);
> diff --git a/lib/chacha.c b/lib/chacha.c
> index 0a2c2e5b7b84d..c4d69a83fcd2d 100644
> --- a/lib/chacha.c
> +++ b/lib/chacha.c
> @@ -21,7 +21,7 @@ static void chacha_permute(u32 *x, int nrounds)
>         int i;
>
>         /* whitelist the allowed round counts */
> -       BUG_ON(nrounds != 20);
> +       BUG_ON(nrounds != 20 && nrounds != 12);
>

I didn't spot this until this patch, but BUG_ON() may bring down the
kernel, and so it should really only be used as a last resort. (i.e.,
if this is called from non-process context things may explode rather
painfully)

I didn't look at the entire file [which is a bit cumbersome while
reviewing incremental changes like this] and so I don't really have
another suggestion right now, but please try to come up with something
better if you can.


>         for (i = 0; i < nrounds; i += 2) {
>                 x[0]  += x[4];    x[12] = rol32(x[12] ^ x[0],  16);
> @@ -70,7 +70,7 @@ static void chacha_permute(u32 *x, int nrounds)
>   * chacha_block - generate one keystream block and increment block counter
>   * @state: input state matrix (16 32-bit words)
>   * @stream: output keystream block (64 bytes)
> - * @nrounds: number of rounds (currently must be 20)
> + * @nrounds: number of rounds (20 or 12; 20 is recommended)
>   *
>   * This is the ChaCha core, a function from 64-byte strings to 64-byte strings.
>   * The caller has already converted the endianness of the input.  This function
> @@ -96,7 +96,7 @@ EXPORT_SYMBOL(chacha_block);
>   * hchacha_block - abbreviated ChaCha core, for XChaCha
>   * @in: input state matrix (16 32-bit words)
>   * @out: output (8 32-bit words)
> - * @nrounds: number of rounds (currently must be 20)
> + * @nrounds: number of rounds (20 or 12; 20 is recommended)
>   *
>   * HChaCha is the ChaCha equivalent of HSalsa and is an intermediate step
>   * towards XChaCha (see https://cr.yp.to/snuffle/xsalsa-20081128.pdf).  HChaCha
> --
> 2.19.1.331.ge82ca0e54c-goog
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
