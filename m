Return-Path: <richard.weinberger@gmail.com>
MIME-Version: 1.0
In-Reply-To: <20170404214334.113915-1-ebiggers3@gmail.com>
References: <20170404214334.113915-1-ebiggers3@gmail.com>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 6 Apr 2017 21:22:35 +0200
Message-ID: <CAFLxGvzWALC5L7hKLVb7s17VuFeO5V509aoPC5gMtb7X64-47w@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: remove fscrypt_symlink_data_len()
Content-Type: text/plain; charset=UTF-8
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 4, 2017 at 11:43 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> fscrypt_symlink_data_len() is never called and can be removed.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  include/linux/fscrypt_common.h | 11 -----------
>  1 file changed, 11 deletions(-)
>
> diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
> index 10c1abfbac6c..0a30c106c1e5 100644
> --- a/include/linux/fscrypt_common.h
> +++ b/include/linux/fscrypt_common.h
> @@ -46,17 +46,6 @@ struct fscrypt_symlink_data {
>         char encrypted_path[1];
>  } __packed;
>
> -/**
> - * This function is used to calculate the disk space required to
> - * store a filename of length l in encrypted symlink format.
> - */
> -static inline u32 fscrypt_symlink_data_len(u32 l)
> -{
> -       if (l < FS_CRYPTO_BLOCK_SIZE)
> -               l = FS_CRYPTO_BLOCK_SIZE;
> -       return (l + sizeof(struct fscrypt_symlink_data) - 1);
> -}
> -

Reviewed-by: Richard Weinberger <richard@nod.at>

-- 
Thanks,
//richard
