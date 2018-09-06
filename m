Return-Path: <SRS0=a1Z3=LU=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180905192400.71160-1-ebiggers@kernel.org>
References: <20180905192400.71160-1-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 6 Sep 2018 12:43:41 +0200
Message-ID: <CAKv+Gu8=dDk+bes8O7oOQ3zTgPHyVi49-gwH1btwdys-vgfyqg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: remove CRYPTO_CTR dependency
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5 September 2018 at 21:24, Eric Biggers <ebiggers@kernel.org> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> fscrypt doesn't use the CTR mode of operation for anything, so there's
> no need to select CRYPTO_CTR.  It was added by commit 71dea01ea2ed
> ("ext4 crypto: require CONFIG_CRYPTO_CTR if ext4 encryption is
> enabled").  But, I've been unable to identify the arm64 crypto bug it
> was supposedly working around.
>
> I suspect the issue was seen only on some old Android device kernel
> (circa 3.10?).  So if the fix wasn't mistaken, the real bug is probably
> already fixed.  Or maybe it was actually a bug in a non-upstream crypto
> driver.
>
> So, remove the dependency.  If it turns out there's actually still a
> bug, we'll fix it properly.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This may be related to

11e3b725cfc2 crypto: arm64/aes-blk - honour iv_out requirement in CBC
and CTR modes

given that the commit in question mentions CTS. How it actually works
around the issue is unclear to me, though.




> ---
>  fs/crypto/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> index 02b7d91c92310..284b589b4774d 100644
> --- a/fs/crypto/Kconfig
> +++ b/fs/crypto/Kconfig
> @@ -6,7 +6,6 @@ config FS_ENCRYPTION
>         select CRYPTO_ECB
>         select CRYPTO_XTS
>         select CRYPTO_CTS
> -       select CRYPTO_CTR
>         select CRYPTO_SHA256
>         select KEYS
>         help
> --
> 2.19.0.rc2.392.g5ba43deb5a-goog
>
