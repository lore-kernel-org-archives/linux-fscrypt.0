Return-Path: <SRS0=Lk93=UT=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190620181505.225232-1-ebiggers@kernel.org>
In-Reply-To: <20190620181505.225232-1-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 20 Jun 2019 21:56:58 +0200
Message-ID: <CAKv+Gu_D3hO1boyL3sYcZaUTCxw8fb+O6KTAEa2SmWRa-nOkew@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: remove selection of CONFIG_CRYPTO_SHA256
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Richard Weinberger <richard@nod.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 20 Jun 2019 at 20:16, Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> fscrypt only uses SHA-256 for AES-128-CBC-ESSIV, which isn't the default
> and is only recommended on platforms that have hardware accelerated
> AES-CBC but not AES-XTS.  There's no link-time dependency, since SHA-256
> is requested via the crypto API on first use.
>
> To reduce bloat, we should limit FS_ENCRYPTION to selecting the default
> algorithms only.  SHA-256 by itself isn't that much bloat, but it's
> being discussed to move ESSIV into a crypto API template, which would
> incidentally bring in other things like "authenc" support, which would
> all end up being built-in since FS_ENCRYPTION is now a bool.
>
> For Adiantum encryption we already just document that users who want to
> use it have to enable CONFIG_CRYPTO_ADIANTUM themselves.  So, let's do
> the same for AES-128-CBC-ESSIV and CONFIG_CRYPTO_SHA256.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

> ---
>  Documentation/filesystems/fscrypt.rst | 4 +++-
>  fs/crypto/Kconfig                     | 1 -
>  2 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> index 08c23b60e01647..87d4e266ffc86d 100644
> --- a/Documentation/filesystems/fscrypt.rst
> +++ b/Documentation/filesystems/fscrypt.rst
> @@ -191,7 +191,9 @@ Currently, the following pairs of encryption modes are supported:
>  If unsure, you should use the (AES-256-XTS, AES-256-CTS-CBC) pair.
>
>  AES-128-CBC was added only for low-powered embedded devices with
> -crypto accelerators such as CAAM or CESA that do not support XTS.
> +crypto accelerators such as CAAM or CESA that do not support XTS.  To
> +use AES-128-CBC, CONFIG_CRYPTO_SHA256 (or another SHA-256
> +implementation) must be enabled so that ESSIV can be used.
>
>  Adiantum is a (primarily) stream cipher-based mode that is fast even
>  on CPUs without dedicated crypto instructions.  It's also a true
> diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> index 24ed99e2eca0b2..5fdf24877c1785 100644
> --- a/fs/crypto/Kconfig
> +++ b/fs/crypto/Kconfig
> @@ -7,7 +7,6 @@ config FS_ENCRYPTION
>         select CRYPTO_ECB
>         select CRYPTO_XTS
>         select CRYPTO_CTS
> -       select CRYPTO_SHA256
>         select KEYS
>         help
>           Enable encryption of files and directories.  This
> --
> 2.22.0.410.gd8fdbe21b5-goog
>
