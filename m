Return-Path: <jaegeuk@kernel.org>
Date: Fri, 5 Jan 2018 12:40:09 -0800
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH v2 05/11] fscrypt: split fscrypt_dummy_context_enabled()
 into supp/notsupp versions
Message-ID: <20180105204009.GA72343@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180105184502.48473-1-ebiggers3@gmail.com>
 <20180105184502.48473-6-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105184502.48473-6-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 01/05, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_dummy_context_enabled() accesses ->s_cop, which now is only set
> when the filesystem is built with encryption support.  This didn't
> actually matter because no filesystems called it.  However, it will
> start being used soon, so fix it by moving it from fscrypt.h to
> fscrypt_supp.h and stubbing it out in fscrypt_notsupp.h.

Ted, do we have a chance to get rid of this dummy_context? If there exists
backward compatibility issue, please never mind tho.

Thanks,

> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  include/linux/fscrypt.h         | 8 --------
>  include/linux/fscrypt_notsupp.h | 5 +++++
>  include/linux/fscrypt_supp.h    | 6 ++++++
>  3 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
> index 0f94d087a6d1..b671a4eef47f 100644
> --- a/include/linux/fscrypt.h
> +++ b/include/linux/fscrypt.h
> @@ -75,14 +75,6 @@ struct fscrypt_operations {
>  /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
>  #define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
>  
> -static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
> -{
> -	if (inode->i_sb->s_cop->dummy_context &&
> -				inode->i_sb->s_cop->dummy_context(inode))
> -		return true;
> -	return false;
> -}
> -
>  static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
>  					u32 filenames_mode)
>  {
> diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
> index 812dc701a5b3..81e02201b215 100644
> --- a/include/linux/fscrypt_notsupp.h
> +++ b/include/linux/fscrypt_notsupp.h
> @@ -19,6 +19,11 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
>  	return false;
>  }
>  
> +static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
> +{
> +	return false;
> +}
> +
>  /* crypto.c */
>  static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
>  						  gfp_t gfp_flags)
> diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
> index fd6ee089ced0..e7dfa2974906 100644
> --- a/include/linux/fscrypt_supp.h
> +++ b/include/linux/fscrypt_supp.h
> @@ -31,6 +31,12 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
>  	return (inode->i_crypt_info != NULL);
>  }
>  
> +static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
> +{
> +	return inode->i_sb->s_cop->dummy_context &&
> +		inode->i_sb->s_cop->dummy_context(inode);
> +}
> +
>  /* crypto.c */
>  extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
>  extern void fscrypt_release_ctx(struct fscrypt_ctx *);
> -- 
> 2.16.0.rc0.223.g4a4ac83678-goog
