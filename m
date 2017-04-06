Return-Path: <linux-fsdevel-owner@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <20170404224040.63624-1-joerichey94@gmail.com>
References: <20170404224040.63624-1-joerichey94@gmail.com>
From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 6 Apr 2017 21:17:09 +0200
Message-ID: <CAFLxGvwm_ebqB0J0epCiasE0HzQjCgfmsf9fpAsYbBrpFTAPmg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: Remove __packed from fscrypt_policy
Content-Type: text/plain; charset=UTF-8
Sender: linux-fsdevel-owner@vger.kernel.org
To: Joe Richey <joerichey94@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, "open list:ABI/API" <linux-api@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Joe Richey <joerichey@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 5, 2017 at 12:40 AM, Joe Richey <joerichey94@gmail.com> wrote:
> From: Joe Richey <joerichey@google.com>
>
> This commit removes __packed from fscrypt_policy as it does not contain
> any implicit padding and does not refer to an on-disk structure. Even
> though this is a change to a UAPI file, no users will be broken as the
> structure doesn't change.
>
> Change-Id: I6075696cee284c3bd4aefa3e9e2dae735602c583

Please remove this internal id.

> Signed-off-by: Joe Richey <joerichey@google.com>
> ---
>  include/uapi/linux/fs.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index 048a85e9f017..f6e1c54ac5e2 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -279,7 +279,7 @@ struct fscrypt_policy {
>         __u8 filenames_encryption_mode;
>         __u8 flags;
>         __u8 master_key_descriptor[FS_KEY_DESCRIPTOR_SIZE];
> -} __packed;
> +};

Reviewed-by: Richard Weinberger <richard@nod.at>

-- 
Thanks,
//richard
