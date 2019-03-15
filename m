Return-Path: <SRS0=vQjS=RS=gmail.com=richard.weinberger@kernel.org>
MIME-Version: 1.0
References: <20190315205432.195263-1-ebiggers@kernel.org>
In-Reply-To: <20190315205432.195263-1-ebiggers@kernel.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Fri, 15 Mar 2019 22:05:59 +0100
Message-ID: <CAFLxGvw1ETyuLf0yV_MqGyTKmUkxLu0vvZLh2QfLgvYExTosWQ@mail.gmail.com>
Subject: Re: [PATCH] ubifs: remove unnecessary calls to set up directory key
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 15, 2019 at 9:55 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> In ubifs_unlink() and ubifs_rmdir(), remove the call to
> fscrypt_get_encryption_info() that precedes fscrypt_setup_filename().
> This call was unnecessary, because fscrypt_setup_filename() already
> tries to set up the directory's encryption key.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/ubifs/dir.c | 12 ------------
>  1 file changed, 12 deletions(-)
>
> diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
> index 5767b373a8ff..c3311ea68fe5 100644
> --- a/fs/ubifs/dir.c
> +++ b/fs/ubifs/dir.c
> @@ -792,12 +792,6 @@ static int ubifs_unlink(struct inode *dir, struct dentry *dentry)
>                 dentry, inode->i_ino,
>                 inode->i_nlink, dir->i_ino);
>
> -       if (ubifs_crypt_is_encrypted(dir)) {
> -               err = fscrypt_get_encryption_info(dir);
> -               if (err && err != -ENOKEY)
> -                       return err;
> -       }
> -
>         err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
>         if (err)
>                 return err;
> @@ -902,12 +896,6 @@ static int ubifs_rmdir(struct inode *dir, struct dentry *dentry)
>         if (err)
>                 return err;
>
> -       if (ubifs_crypt_is_encrypted(dir)) {
> -               err = fscrypt_get_encryption_info(dir);
> -               if (err && err != -ENOKEY)
> -                       return err;
> -       }
> -
>         err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
>         if (err)
>                 return err;

Thanks for the cleanup, Eric!

-- 
Thanks,
//richard
