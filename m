Return-Path: <SRS0=httw=Q3=gmail.com=richard.weinberger@kernel.org>
MIME-Version: 1.0
References: <20190220065249.32099-1-ebiggers@kernel.org> <20190220065249.32099-8-ebiggers@kernel.org>
In-Reply-To: <20190220065249.32099-8-ebiggers@kernel.org>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 21 Feb 2019 00:52:38 +0100
Message-ID: <CAFLxGvy7WsV7Qo42yTbsZf9YnW563a0k6Yx2-NmASNtoektu_Q@mail.gmail.com>
Subject: Re: [RFC PATCH v3 07/18] fscrypt: add FS_IOC_ADD_ENCRYPTION_KEY ioctl
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, "open list:ABI/API" <linux-api@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 20, 2019 at 7:55 AM Eric Biggers <ebiggers@kernel.org> wrote:
> +#define FSCRYPT_FS_KEYRING_DESCRIPTION_SIZE    \
> +       (CONST_STRLEN("fscrypt-") + FIELD_SIZEOF(struct super_block, s_id))
> +
> +#define FSCRYPT_MK_DESCRIPTION_SIZE    (2 * FSCRYPT_KEY_DESCRIPTOR_SIZE + 1)
> +
> +static void format_fs_keyring_description(
> +                       char description[FSCRYPT_FS_KEYRING_DESCRIPTION_SIZE],
> +                       const struct super_block *sb)
> +{
> +       sprintf(description, "fscrypt-%s", sb->s_id);
> +}

I fear ->s_id is not the right thing.
For filesystems such as ext4 ->s_id is the name of the backing block device,
so it is per filesysem instance unique.
But this is not guaranteed. For UBIFS ->s_id is just "ubifs", always.
So the names will clash.

-- 
Thanks,
//richard
