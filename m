Return-Path: <mhalcrow@google.com>
Return-Path: <mhalcrow@google.com>
Date: Fri, 14 Jul 2017 08:36:15 -0700
From: Michael Halcrow <mhalcrow@google.com>
Subject: Re: [PATCH 2/6] fscrypt: rename ->ci_master_key to
 ->ci_master_key_descriptor
Message-ID: <20170714153615.GA25453@google.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-3-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712210035.51534-3-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 12, 2017 at 02:00:31PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> In struct fscrypt_info, ->ci_master_key is the master key descriptor,
> not the master key itself.  In preparation for introducing a struct
> fscrypt_master_key and making ->ci_master_key point to it, rename the
> existing ->ci_master_key to ->ci_master_key_descriptor.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Acked-by: Michael Halcrow <mhalcrow@google.com>

> ---
>  fs/crypto/fscrypt_private.h | 2 +-
>  fs/crypto/keyinfo.c         | 4 ++--
>  fs/crypto/policy.c          | 5 +++--
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> index ef6909035823..5470aac82cab 100644
> --- a/fs/crypto/fscrypt_private.h
> +++ b/fs/crypto/fscrypt_private.h
> @@ -107,7 +107,7 @@ struct fscrypt_info {
>  	u8 ci_data_mode;
>  	u8 ci_filename_mode;
>  	u8 ci_flags;
> -	u8 ci_master_key[FS_KEY_DESCRIPTOR_SIZE];
> +	u8 ci_master_key_descriptor[FS_KEY_DESCRIPTOR_SIZE];
>  };
>  
>  typedef enum {
> diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> index 7e664a11340a..5591fd24e4b2 100644
> --- a/fs/crypto/keyinfo.c
> +++ b/fs/crypto/keyinfo.c
> @@ -293,8 +293,8 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
>  	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
>  	crypt_info->ci_flags = ctx.flags;
> -	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
> -				sizeof(crypt_info->ci_master_key));
> +	memcpy(crypt_info->ci_master_key_descriptor, ctx.master_key_descriptor,
> +	       FS_KEY_DESCRIPTOR_SIZE);
>  
>  	res = determine_cipher_type(crypt_info, inode, &cipher_str, &keysize);
>  	if (res)
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index 044f23fadb5a..81c59f8e45c0 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -224,7 +224,8 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
>  	child_ci = child->i_crypt_info;
>  
>  	if (parent_ci && child_ci) {
> -		return memcmp(parent_ci->ci_master_key, child_ci->ci_master_key,
> +		return memcmp(parent_ci->ci_master_key_descriptor,
> +			      child_ci->ci_master_key_descriptor,
>  			      FS_KEY_DESCRIPTOR_SIZE) == 0 &&
>  			(parent_ci->ci_context_version ==
>  			 child_ci->ci_context_version) &&
> @@ -282,7 +283,7 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
>  	ctx.contents_encryption_mode = ci->ci_data_mode;
>  	ctx.filenames_encryption_mode = ci->ci_filename_mode;
>  	ctx.flags = ci->ci_flags;
> -	memcpy(ctx.master_key_descriptor, ci->ci_master_key,
> +	memcpy(ctx.master_key_descriptor, ci->ci_master_key_descriptor,
>  	       FS_KEY_DESCRIPTOR_SIZE);
>  	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
>  	if (ctx.version != FSCRYPT_CONTEXT_V1)
> -- 
> 2.13.2.932.g7449e964c-goog
> 
