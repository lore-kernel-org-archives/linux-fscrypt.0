Return-Path: <ebiggers3@gmail.com>
Date: Wed, 17 Jan 2018 16:39:49 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 1/2] fscrypt: add support for the encrypted key type
Message-ID: <20180118003949.snqq64wdbc2zgq3o@gmail.com>
References: <20180111040022.GA943@zzz.localdomain>
 <20180117141319.8060-1-git@andred.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180117141319.8060-1-git@andred.net>
To: =?iso-8859-1?Q?Andr=E9?= Draszik <git@andred.net>
Cc: linux-kernel@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Andr�,

On Wed, Jan 17, 2018 at 02:13:18PM +0000, Andr� Draszik wrote:
> We now try to acquire the key according to the
> encryption policy from both key types, 'logon'
> as well as 'encrypted'.
> 
> Signed-off-by: Andr� Draszik <git@andred.net>
> Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: linux-fscrypt@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Eric Biggers <ebiggers@google.com>
> 
> ---
> changes in v2:
> * dropped the previously added 'fscrypt' encrypted-key,
>   and just use the 'default' format

The commit message needs to explain the purpose of the change, not just what the
change is.  It might also be helpful to combine this with the documentation
patch, as some of the explanation can be in the documentation.

Can you please also keep the keyrings mailing list and encrypted-keys
maintainers Cc'ed on this series?  I know it doesn't touch the keyrings code
directly anymore, but people may still be interested.  Historically there have
also been a lot of bugs in code using the keyrings API, e.g. not using correct
locking.

> ---
>  fs/crypto/keyinfo.c | 72 +++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 50 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> index 5e6e846f5a24..925af599f954 100644
> --- a/fs/crypto/keyinfo.c
> +++ b/fs/crypto/keyinfo.c
> @@ -10,6 +10,7 @@
>   */
>  
>  #include <keys/user-type.h>
> +#include <keys/encrypted-type.h>
>  #include <linux/scatterlist.h>
>  #include <linux/ratelimit.h>
>  #include <crypto/aes.h>
> @@ -66,14 +67,20 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
>  	return res;
>  }
>  
> -static int validate_user_key(struct fscrypt_info *crypt_info,
> +static inline struct key *fscrypt_get_encrypted_key(const char *sig)
> +{

Call this 'description', not 'sig'.  I think you copied the 'sig' naming from
eCryptfs, but it doesn't make sense for fscrypt.


> +	if (IS_ENABLED(CONFIG_ENCRYPTED_KEYS))
> +		return request_key(&key_type_encrypted, sig, NULL);
> +	return ERR_PTR(-ENOKEY);
> +}
> +
> +static int validate_keyring_key(struct fscrypt_info *crypt_info,
>  			struct fscrypt_context *ctx, u8 *raw_key,
>  			const char *prefix, int min_keysize)
>  {
>  	char *description;
>  	struct key *keyring_key;
> -	struct fscrypt_key *master_key;
> -	const struct user_key_payload *ukp;
> +	struct fscrypt_key *master_key, master_key_;
>  	int res;
>  
>  	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
> @@ -83,28 +90,45 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
>  		return -ENOMEM;
>  
>  	keyring_key = request_key(&key_type_logon, description, NULL);
> +	if (IS_ERR(keyring_key))
> +		keyring_key = fscrypt_get_encrypted_key(description);

I think the fallback to the "encrypted" key type should only happen if
request_key() returns ERR_PTR(-ENOKEY), indicating that the "logon" key isn't
present.  Otherwise it will fall back for other types of errors as well which
doesn't really make sense.

>  	kfree(description);
>  	if (IS_ERR(keyring_key))
>  		return PTR_ERR(keyring_key);
>  	down_read(&keyring_key->sem);
>  
> -	if (keyring_key->type != &key_type_logon) {
> +	if (keyring_key->type == &key_type_logon) {
> +		const struct user_key_payload *ukp;
> +
> +		ukp = user_key_payload_locked(keyring_key);
> +		if (!ukp) {
> +			/* key was revoked before we acquired its semaphore */
> +			res = -EKEYREVOKED;
> +			goto out;
> +		}
> +		if (ukp->datalen != sizeof(struct fscrypt_key)) {
> +			res = -EINVAL;
> +			goto out;
> +		}
> +		master_key = (struct fscrypt_key *)ukp->data;
> +	} else if (keyring_key->type == &key_type_encrypted) {
> +		const struct encrypted_key_payload *ekp;
> +
> +		ekp = keyring_key->payload.data[0];
> +		master_key = &master_key_;
> +
> +		master_key->mode = 0;
> +		memcpy (master_key->raw, ekp->decrypted_data,
> +			min (sizeof (master_key->raw),
> +			     (size_t) ekp->decrypted_datalen));
> +		master_key->size = ekp->decrypted_datalen;
> +	} else {
>  		printk_once(KERN_WARNING
> -				"%s: key type must be logon\n", __func__);
> +				"%s: key type must be logon or encrypted\n",
> +				__func__);
>  		res = -ENOKEY;
>  		goto out;
>  	}
> -	ukp = user_key_payload_locked(keyring_key);
> -	if (!ukp) {
> -		/* key was revoked before we acquired its semaphore */
> -		res = -EKEYREVOKED;
> -		goto out;
> -	}
> -	if (ukp->datalen != sizeof(struct fscrypt_key)) {
> -		res = -EINVAL;
> -		goto out;
> -	}
> -	master_key = (struct fscrypt_key *)ukp->data;
>  	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
>  
>  	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
> @@ -113,9 +137,13 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
>  				"%s: key size incorrect: %d\n",
>  				__func__, master_key->size);
>  		res = -ENOKEY;
> -		goto out;
> +		goto out_clear_key;
>  	}
>  	res = derive_key_aes(ctx->nonce, master_key, raw_key);
> +
> +out_clear_key:
> +	if (master_key == &master_key_)
> +		memzero_explicit(master_key->raw, sizeof (master_key->raw));
>  out:
>  	up_read(&keyring_key->sem);
>  	key_put(keyring_key);
> @@ -302,12 +330,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (!raw_key)
>  		goto out;

No need for the temporary 'struct fscrypt_key', just use ekp->decrypted_data and
ekp->decrypted_datalen directly.

Eric
