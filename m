Return-Path: <SRS0=q1Ic=NA=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20181015175424.97147-8-ebiggers@kernel.org>
References: <20181015175424.97147-1-ebiggers@kernel.org> <20181015175424.97147-8-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 20 Oct 2018 11:36:15 +0800
Message-ID: <CAKv+Gu91O99D48Dr-2UKrXdPrzGSFDGr_qH9zLpbvqDwd50DAw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 07/12] crypto: arm/chacha - add XChaCha12 support
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> Now that the 32-bit ARM NEON implementation of ChaCha20 and XChaCha20
> has been refactored to support varying the number of rounds, add support
> for XChaCha12.  This is identical to XChaCha20 except for the number of
> rounds, which is 12 instead of 20.
>
> XChaCha12 is faster than XChaCha20 but has a lower security margin,
> though still greater than AES-256's since the best known attacks make it
> through only 7 rounds.  See the patch "crypto: chacha - add XChaCha12
> support" for more details about why we need XChaCha12 support.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  arch/arm/crypto/Kconfig            |  2 +-
>  arch/arm/crypto/chacha-neon-glue.c | 21 ++++++++++++++++++++-
>  2 files changed, 21 insertions(+), 2 deletions(-)
>
> diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
> index 0aa1471f27d2e..cc932d9bba561 100644
> --- a/arch/arm/crypto/Kconfig
> +++ b/arch/arm/crypto/Kconfig
> @@ -117,7 +117,7 @@ config CRYPTO_CRC32_ARM_CE
>         select CRYPTO_HASH
>
>  config CRYPTO_CHACHA20_NEON
> -       tristate "NEON accelerated ChaCha20 stream cipher algorithms"
> +       tristate "NEON accelerated ChaCha stream cipher algorithms"
>         depends on KERNEL_MODE_NEON
>         select CRYPTO_BLKCIPHER
>         select CRYPTO_CHACHA20
> diff --git a/arch/arm/crypto/chacha-neon-glue.c b/arch/arm/crypto/chacha-neon-glue.c
> index b236af4889c61..0b1b238227707 100644
> --- a/arch/arm/crypto/chacha-neon-glue.c
> +++ b/arch/arm/crypto/chacha-neon-glue.c
> @@ -1,5 +1,6 @@
>  /*
> - * ChaCha20 (RFC7539) and XChaCha20 stream ciphers, NEON accelerated
> + * ARM NEON accelerated ChaCha and XChaCha stream ciphers,
> + * including ChaCha20 (RFC7539)
>   *
>   * Copyright (C) 2016 Linaro, Ltd. <ard.biesheuvel@linaro.org>
>   *
> @@ -160,6 +161,22 @@ static struct skcipher_alg algs[] = {
>                 .setkey                 = crypto_chacha20_setkey,
>                 .encrypt                = xchacha_neon,
>                 .decrypt                = xchacha_neon,
> +       }, {
> +               .base.cra_name          = "xchacha12",
> +               .base.cra_driver_name   = "xchacha12-neon",
> +               .base.cra_priority      = 300,
> +               .base.cra_blocksize     = 1,
> +               .base.cra_ctxsize       = sizeof(struct chacha_ctx),
> +               .base.cra_module        = THIS_MODULE,
> +
> +               .min_keysize            = CHACHA_KEY_SIZE,
> +               .max_keysize            = CHACHA_KEY_SIZE,
> +               .ivsize                 = XCHACHA_IV_SIZE,
> +               .chunksize              = CHACHA_BLOCK_SIZE,
> +               .walksize               = 4 * CHACHA_BLOCK_SIZE,
> +               .setkey                 = crypto_chacha12_setkey,
> +               .encrypt                = xchacha_neon,
> +               .decrypt                = xchacha_neon,
>         }
>  };
>
> @@ -186,3 +203,5 @@ MODULE_ALIAS_CRYPTO("chacha20");
>  MODULE_ALIAS_CRYPTO("chacha20-neon");
>  MODULE_ALIAS_CRYPTO("xchacha20");
>  MODULE_ALIAS_CRYPTO("xchacha20-neon");
> +MODULE_ALIAS_CRYPTO("xchacha12");
> +MODULE_ALIAS_CRYPTO("xchacha12-neon");
> --
> 2.19.1.331.ge82ca0e54c-goog
>
