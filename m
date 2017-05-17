Return-Path: <ebiggers3@gmail.com>
Date: Wed, 17 May 2017 11:08:50 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v3] fscrypt: Add support for AES-128-CBC
Message-ID: <20170517180850.GA91213@gmail.com>
References: <20170426215616.GA104929@gmail.com>
 <20170517112104.61106-1-david@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170517112104.61106-1-david@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David, thanks for the update!

On Wed, May 17, 2017 at 01:21:04PM +0200, David Gstir wrote:
> From: Daniel Walter <dwalter@sigma-star.at>
> 
> fscrypt provides facilities to use different encryption algorithms which
> are selectable by userspace when setting the encryption policy. Currently,
> only AES-256-XTS for file contents and AES-256-CBC-CTS for file names are
> implemented. This is a clear case of kernel offers the mechanism and
> userspace selects a policy. Similar to what dm-crypt and ecryptfs have.
> 
> This patch adds support for using AES-128-CBC for file contents and
> AES-128-CBC-CTS for file name encryption. To mitigate watermarking
> attacks, IVs are generated using the ESSIV algorithm. While AES-CBC is
> actually slightly less secure than AES-XTS from a security point of view,
> there is more widespread hardware support. Especially low-powered embedded
> devices with crypto accelerators such as CAAM or CESA support only
> AES-CBC-128 with an acceptable speed. Using AES-CBC gives us the acceptable
> performance while still providing a moderate level of security for
> persistent storage.

You covered this briefly in an email, but can you include more detail in the
commit message on the reasoning behind choosing AES-128 instead of AES-256?
Note that this is independent of the decision of CBC vs. XTS.

> @@ -129,27 +136,37 @@ static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
>  				 const char **cipher_str_ret, int *keysize_ret)
>  {
>  	if (S_ISREG(inode->i_mode)) {
> -		if (ci->ci_data_mode == FS_ENCRYPTION_MODE_AES_256_XTS) {
> +		switch (ci->ci_data_mode) {
> +		case FS_ENCRYPTION_MODE_AES_256_XTS:
>  			*cipher_str_ret = "xts(aes)";
>  			*keysize_ret = FS_AES_256_XTS_KEY_SIZE;
>  			return 0;
> +		case FS_ENCRYPTION_MODE_AES_128_CBC:
> +			*cipher_str_ret = "cbc(aes)";
> +			*keysize_ret = FS_AES_128_CBC_KEY_SIZE;
> +			return 0;
> +		default:
> +			pr_warn_once("fscrypto: unsupported contents encryption mode %d for inode %lu\n",
> +				     ci->ci_data_mode, inode->i_ino);
> +			return -ENOKEY;
>  		}
> -		pr_warn_once("fscrypto: unsupported contents encryption mode "
> -			     "%d for inode %lu\n",
> -			     ci->ci_data_mode, inode->i_ino);
> -		return -ENOKEY;
>  	}
>  
>  	if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
> -		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_256_CTS) {
> +		switch (ci->ci_filename_mode) {
> +		case FS_ENCRYPTION_MODE_AES_256_CTS:
>  			*cipher_str_ret = "cts(cbc(aes))";
>  			*keysize_ret = FS_AES_256_CTS_KEY_SIZE;
>  			return 0;
> +		case FS_ENCRYPTION_MODE_AES_128_CTS:
> +			*cipher_str_ret = "cts(cbc(aes))";
> +			*keysize_ret = FS_AES_128_CTS_KEY_SIZE;
> +			return 0;
> +		default:
> +			pr_warn_once("fscrypto: unsupported filenames encryption mode %d for inode %lu\n",
> +				     ci->ci_filename_mode, inode->i_ino);
> +			return -ENOKEY;
>  		}
> -		pr_warn_once("fscrypto: unsupported filenames encryption mode "
> -			     "%d for inode %lu\n",
> -			     ci->ci_filename_mode, inode->i_ino);
> -		return -ENOKEY;
>  	}

With the added call to fscrypt_valid_enc_modes() earlier, the warnings about
unsupported encryption modes are no longer reachable.  IMO, the
fscrypt_valid_enc_modes() check should be moved into this function, a proper
warning message added for it, and the redundant warnings removed.  Also now that
there will be more modes I think it would be appropriate to put the algorithm
names and key sizes in a table, to avoid the ugly switch statements.  Here's
what I came up with:

static const struct {
	const char *cipher_str;
	int keysize;
} available_modes[] = {
	[FS_ENCRYPTION_MODE_AES_256_XTS] = { "xts(aes)",
					     FS_AES_256_XTS_KEY_SIZE },
	[FS_ENCRYPTION_MODE_AES_256_CTS] = { "cts(cbc(aes))",
					     FS_AES_256_CTS_KEY_SIZE },
	[FS_ENCRYPTION_MODE_AES_128_CBC] = { "cbc(aes)",
					     FS_AES_128_CBC_KEY_SIZE },
	[FS_ENCRYPTION_MODE_AES_128_CTS] = { "cts(cbc(aes))",
					     FS_AES_128_CTS_KEY_SIZE },
};

static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
				 const char **cipher_str_ret, int *keysize_ret)
{
	u32 mode;

	if (!fscrypt_valid_enc_modes(ci->ci_data_mode, ci->ci_filename_mode)) {
		pr_warn_ratelimited("fscrypt: inode %lu uses unsupported encryption modes "
				    "(contents mode %d, filenames mode %d)\n",
				    inode->i_ino,
				    ci->ci_data_mode, ci->ci_filename_mode);
		return -EINVAL;
	}

	if (S_ISREG(inode->i_mode)) {
		mode = ci->ci_data_mode;
	} else if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
		mode = ci->ci_filename_mode;
	} else {
		WARN_ONCE(1, "fscrypt: filesystem tried to load encryption info for inode %lu, "
			  "which is not encryptable (file type %d)\n",
			  inode->i_ino, (inode->i_mode & S_IFMT));
		return -EINVAL;
	}

	*cipher_str_ret = available_modes[mode].cipher_str;
	*keysize_ret = available_modes[mode].keysize;
	return 0;
}


Note that I changed the 'invalid file type' warning to a WARN_ONCE(), since it
indicates a filesystem bug, unlike the 'unsupported encryption modes' warning
which can be triggered by unrecognized stuff on-disk.

>  
>  	pr_warn_once("fscrypto: unsupported file type %d for inode %lu\n",
> @@ -163,9 +180,75 @@ static void put_crypt_info(struct fscrypt_info *ci)
>  		return;
>  
>  	crypto_free_skcipher(ci->ci_ctfm);
> +	crypto_free_cipher(ci->ci_essiv_tfm);
>  	kmem_cache_free(fscrypt_info_cachep, ci);
>  }
>  
> +static int derive_essiv_salt(u8 *key, int keysize, u8 *salt)
> +{

const u8 *key

> +	int err;
> +
> +	/* init hash transform on demand */
> +	if (unlikely(essiv_hash_tfm == NULL)) {
> +		mutex_lock(&essiv_hash_lock);
> +		if (essiv_hash_tfm == NULL) {
> +			essiv_hash_tfm = crypto_alloc_shash("sha256", 0, 0);
> +			if (IS_ERR(essiv_hash_tfm)) {
> +				pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld\n",
> +						    PTR_ERR(essiv_hash_tfm));
> +				err = PTR_ERR(essiv_hash_tfm);
> +				essiv_hash_tfm = NULL;
> +				mutex_unlock(&essiv_hash_lock);
> +				return err;
> +			}
> +		}
> +		mutex_unlock(&essiv_hash_lock);
> +	}

There is a bug here: a thread can set essiv_hash_tfm to an ERR_PTR(), and
another thread can use it before it's set back to NULL.  Did you consider using
a cmpxchg-based solution instead, similar to what fscrypt_get_encryption_info()
does with ->i_crypt_info?  Then there would be no need for a mutex.  Something
like this:

static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
{
        /* init hash transform on demand */
        struct crypto_shash *tfm = READ_ONCE(essiv_hash_tfm);

        if (unlikely(!tfm)) {
                struct crypto_shash *prev;

                tfm = crypto_alloc_shash("sha256", 0, 0);
                if (IS_ERR(tfm)) {
			pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld\n",
					    PTR_ERR(tfm));
                        return PTR_ERR(tfm);
                }
                prev = cmpxchg(&essiv_hash_tfm, NULL, tfm);
                if (prev) {
                        crypto_free_shash(tfm);
                        tfm = prev;
                }
        }

        {
                SHASH_DESC_ON_STACK(desc, tfm);
                desc->tfm = tfm;
                desc->flags = 0;

                return crypto_shash_digest(desc, key, keysize, salt);
        }
}

> +static int init_essiv_generator(struct fscrypt_info *ci, u8 *raw_key,
> +				int keysize)

const u8 *raw_key

> +{
> +	int err;
> +	struct crypto_cipher *essiv_tfm;
> +	u8 salt[SHA256_DIGEST_SIZE];
> +
> +	if (WARN_ON_ONCE(keysize > sizeof(salt)))
> +		return -EINVAL;
> +
> +	essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
> +	if (IS_ERR(essiv_tfm))
> +		return PTR_ERR(essiv_tfm);
> +
> +	ci->ci_essiv_tfm = essiv_tfm;
> +
> +	err = derive_essiv_salt(raw_key, keysize, salt);
> +	if (err)
> +		goto out;
> +
> +	err = crypto_cipher_setkey(essiv_tfm, salt, SHA256_DIGEST_SIZE);
> +	if (err)
> +		goto out;

sizeof(salt) instead of hardcoding SHA256_DIGEST_SIZE.

I think there should also be a brief comment explaining that the ESSIV cipher
uses AES-256 so that its key size matches the size of the hash, even though the
"real" encryption may use AES-128.

> +void fscrypt_essiv_cleanup(void)
> +{
> +	crypto_free_shash(essiv_hash_tfm);
> +	essiv_hash_tfm = NULL;
> +}

This is called from fscrypt_destroy(), which is a little weird because
fscrypt_destroy() is meant to clean up only from "fscrypt_initialize()", which
only allocates certain things.  I think it should be called from
"fscrypt_exit()" instead.  Then you could also add the __exit annotation, and
remove setting essiv_hash_tfm to NULL which would clearly be unnecessary.

> +
>  int fscrypt_get_encryption_info(struct inode *inode)
>  {
>  	struct fscrypt_info *crypt_info;
> @@ -204,6 +287,10 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
>  		return -EINVAL;
>  
> +	if (!fscrypt_valid_enc_modes(ctx.contents_encryption_mode,
> +				     ctx.filenames_encryption_mode))
> +		return -EINVAL;
> +

As noted earlier I think this should be moved into determine_cipher_type(), to
avoid redundancy when interpreting the encryption modes.

> diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
> index 0a30c106c1e5..982c08c4f2ac 100644
> --- a/include/linux/fscrypt_common.h
> +++ b/include/linux/fscrypt_common.h
> @@ -91,14 +91,13 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
>  	return false;
>  }
>  
> -static inline bool fscrypt_valid_contents_enc_mode(u32 mode)
> +static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
> +					u32 filenames_mode)
>  {
> -	return (mode == FS_ENCRYPTION_MODE_AES_256_XTS);
> -}
> -
> -static inline bool fscrypt_valid_filenames_enc_mode(u32 mode)
> -{
> -	return (mode == FS_ENCRYPTION_MODE_AES_256_CTS);
> +	return ((contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
> +		 filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS) ||
> +		(contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
> +		 filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS));
>  }
>  

IMO, make these 'if' statements, to discourage people from turning this
expression into more of a mess when they add more modes:

static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
                                        u32 filenames_mode)
{
        if (contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
            filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
                return true;

        if (contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
            filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS)
                return true;

        return false;
}

Eric
