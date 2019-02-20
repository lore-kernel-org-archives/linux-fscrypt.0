Return-Path: <SRS0=httw=Q3=gmail.com=richard.weinberger@kernel.org>
MIME-Version: 1.0
References: <20190220065249.32099-1-ebiggers@kernel.org> <20190220065249.32099-5-ebiggers@kernel.org>
In-Reply-To: <20190220065249.32099-5-ebiggers@kernel.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 21 Feb 2019 00:19:54 +0100
Message-ID: <CAFLxGvxLYL1raaXZPyyMS7CUUak3L6GncZ_GKYz2SSsGHEHpnQ@mail.gmail.com>
Subject: Re: [RFC PATCH v3 04/18] fs: add ->s_master_keys to struct super_block
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, "open list:ABI/API" <linux-api@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 20, 2019 at 7:55 AM Eric Biggers <ebiggers@kernel.org> wrote:
>
> From: Eric Biggers <ebiggers@google.com>
>
> Add an ->s_master_keys keyring to 'struct super_block'.  New fscrypt
> ioctls will allow adding and removing encryption keys from this keyring.
> This will enable solving multiple interrelated problems with how fscrypt
> keys are provided and managed currently, including:
>
> - Making the key status (which is currently per-process) match the
>   filesystem-level status of which encrypted files are "unlocked".
>
> - Supporting a proper API to remove encryption keys, "locking" the
>   corresponding encrypted files.
>
> - Caching an HMAC transform for each master key, allowing the use of
>   HKDF while still retaining good performance.
>
> - Preventing denial of service via keyctl_invalidate().
>
> Similar to the existing ->s_cop, the keyring is added to the VFS-level
> superblock struct rather than separately to the ext4, f2fs, and ubifs
> superblock structs so that it can be used by the shared code in
> fs/crypto/.  To minimize overhead, the keyring will only be allocated if
> userspace actually adds a key; otherwise will stay NULL.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/super.c         | 3 +++
>  include/linux/fs.h | 1 +
>  2 files changed, 4 insertions(+)
>
> diff --git a/fs/super.c b/fs/super.c
> index 48e25eba8465..7ca05dda905c 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -291,6 +291,9 @@ static void __put_super(struct super_block *s)
>                 security_sb_free(s);
>                 put_user_ns(s->s_user_ns);
>                 kfree(s->s_subtype);
> +#ifdef CONFIG_FS_ENCRYPTION
> +               key_put(s->s_master_keys);
> +#endif

Please wrap this in a static inline function such that you can get rid
of the ifdef here.
Just like put_user_ns() does.

-- 
Thanks,
//richard
