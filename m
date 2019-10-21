Date: Mon, 21 Oct 2019 13:28:36 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: zeroize fscrypt_info before freeing
Message-ID: <20191021202836.GC122863@gmail.com>
References: <20191009234442.225847-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191009234442.225847-1-ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 09, 2019 at 04:44:42PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> memset the struct fscrypt_info to zero before freeing.  This isn't
> really needed currently, since there's no secret key directly in the
> fscrypt_info.  But there's a decent chance that someone will add such a
> field in the future, e.g. in order to use an API that takes a raw key
> such as siphash().  So it's good to do this as a hardening measure.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/keysetup.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
> index df3e1c8653884..0ba33e010312f 100644
> --- a/fs/crypto/keysetup.c
> +++ b/fs/crypto/keysetup.c
> @@ -325,6 +325,7 @@ static void put_crypt_info(struct fscrypt_info *ci)
>  			key_invalidate(key);
>  		key_put(key);
>  	}
> +	memzero_explicit(ci, sizeof(*ci));
>  	kmem_cache_free(fscrypt_info_cachep, ci);
>  }
>  
> -- 
> 2.23.0.581.g78d2f28ef7-goog
> 

Applied to fscrypt.git for 5.5.

- Eric
