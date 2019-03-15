Return-Path: <SRS0=vQjS=RS=gmail.com=richard.weinberger@kernel.org>
MIME-Version: 1.0
References: <20190315205503.195400-1-ebiggers@kernel.org>
In-Reply-To: <20190315205503.195400-1-ebiggers@kernel.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Fri, 15 Mar 2019 22:08:02 +0100
Message-ID: <CAFLxGvx3M61E1+Ts38BYRYu93QzmH=XMWoYYrFHTqWXUM7zREg@mail.gmail.com>
Subject: Re: [PATCH] ubifs: remove unnecessary #ifdef around fscrypt_ioctl_get_policy()
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 15, 2019 at 9:55 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> When !CONFIG_FS_ENCRYPTION, fscrypt_ioctl_get_policy() is already
> stubbed out to return -EOPNOTSUPP, so the extra #ifdef is not needed.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/ubifs/ioctl.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
> index 82e4e6a30b04..cd1d4212fc45 100644
> --- a/fs/ubifs/ioctl.c
> +++ b/fs/ubifs/ioctl.c
> @@ -205,13 +205,8 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>                 return -EOPNOTSUPP;
>  #endif
>         }
> -       case FS_IOC_GET_ENCRYPTION_POLICY: {
> -#ifdef CONFIG_FS_ENCRYPTION
> +       case FS_IOC_GET_ENCRYPTION_POLICY:
>                 return fscrypt_ioctl_get_policy(file, (void __user *)arg);
> -#else
> -               return -EOPNOTSUPP;
> -#endif
> -       }
>
>         default:
>                 return -ENOTTY;

Thanks for that one too. :-)

-- 
Thanks,
//richard
