Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Subject: Re: [PATCH v2] fscrypt: Remove __packed from fscrypt_policy
References: <20170406231428.154187-1-joerichey94@gmail.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <d6e1c40b-ad3d-bf8f-5adc-d0d123e7a28e@nod.at>
Date: Fri, 7 Apr 2017 11:22:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170406231428.154187-1-joerichey94@gmail.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: linux-fsdevel-owner@vger.kernel.org
To: Joe Richey <joerichey94@gmail.com>, linux-fsdevel@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-api@vger.kernel.org, Richard Weinberger <richard.weinberger@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Joe Richey <joerichey@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am 07.04.2017 um 01:14 schrieb Joe Richey:
> From: Joe Richey <joerichey@google.com>
> 
> This commit removes __packed from fscrypt_policy as it does not contain
> any implicit padding and does not refer to an on-disk structure. Even
> though this is a change to a UAPI file, no users will be broken as the
> structure doesn't change.
> 
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
>  	__u8 filenames_encryption_mode;
>  	__u8 flags;
>  	__u8 master_key_descriptor[FS_KEY_DESCRIPTOR_SIZE];
> -} __packed;
> +};

Both patches are fine, just keep my Reviewed-by. :)

Thanks,
//richard
