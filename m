Date: Thu, 11 Apr 2019 14:37:10 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: add memory barrier when loading essiv_hash_tfm
Message-ID: <20190411213710.GF225654@gmail.com>
References: <20190318172454.240412-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190318172454.240412-1-ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 18, 2019 at 10:24:54AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Load 'essiv_hash_tfm' using smp_load_acquire() to guarantee that the
> struct crypto_shash is seen as fully initialized before being used.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/keyinfo.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> index ba74dafa18a3..d1f0f8369d51 100644
> --- a/fs/crypto/keyinfo.c
> +++ b/fs/crypto/keyinfo.c
> @@ -379,7 +379,7 @@ fscrypt_get_master_key(const struct fscrypt_info *ci, struct fscrypt_mode *mode,
>  
>  static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
>  {
> -	struct crypto_shash *tfm = READ_ONCE(essiv_hash_tfm);
> +	struct crypto_shash *tfm = smp_load_acquire(&essiv_hash_tfm);
>  
>  	/* init hash transform on demand */
>  	if (unlikely(!tfm)) {
> -- 
> 2.21.0.225.g810b269d1ac-goog
> 

Actually I think we only need a data dependency barrier here, so this patch
isn't needed.  See discussion of similar case at
https://marc.info/?l=linux-fsdevel&m=155487269904655&w=2

- Eric
