Return-Path: <ebiggers3@gmail.com>
Date: Thu, 30 Mar 2017 23:21:49 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: Add support for AES-128-CBC
Message-ID: <20170331062149.GA32409@zzz>
References: <20170330173840.72909-1-david@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330173840.72909-1-david@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

[+Cc linux-fscrypt]

Hi David and Daniel,

On Thu, Mar 30, 2017 at 07:38:40PM +0200, David Gstir wrote:
> From: Daniel Walter <dwalter@sigma-star.at>
> 
> fscrypt provides facilities to use different encryption algorithms which are
> selectable by userspace when setting the encryption policy. Currently, only
> AES-256-XTS for file contents and AES-256-CBC-CTS for file names are implemented.
> Which is a clear case of kernel offers the mechanism and userspace selects a
> policy. Similar to what dm-crypt and ecryptfs have.
> 
> This patch adds support for using AES-128-CBC for file contents and
> AES-128-CBC-CTS for file name encryption. To mitigate watermarking attacks, IVs
> are generated using the ESSIV algorithm. While AES-CBC is actually slightly
> less secure than AES-XTS from a security point of view, there is more
> widespread hardware support. Especially low-powered embedded devices crypto
> accelerators such as CAAM or CESA support only AES-CBC-128 with an acceptable
> speed. Using AES-CBC gives us the acceptable performance while still providing
> a moderate level of security for persistent storage.
> 

Thanks for sending this!  I can't object too much to adding AES-CBC-128 if you
find it useful, though of course AES-256-XTS will remain the recommendation for
general use.  And I don't suppose AES-256-CBC is an option for you?

Anyway, more comments below:

> @@ -147,17 +148,31 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
>  {
>  	struct {
>  		__le64 index;
> -		u8 padding[FS_XTS_TWEAK_SIZE - sizeof(__le64)];
> -	} xts_tweak;
> +		u8 padding[FS_IV_SIZE - sizeof(__le64)];
> +	} blk_desc;
>  	struct skcipher_request *req = NULL;
>  	DECLARE_FS_COMPLETION_RESULT(ecr);
>  	struct scatterlist dst, src;
>  	struct fscrypt_info *ci = inode->i_crypt_info;
>  	struct crypto_skcipher *tfm = ci->ci_ctfm;
> +	u8 iv[FS_IV_SIZE];
>  	int res = 0;
>  
>  	BUG_ON(len == 0);
>  
> +	BUILD_BUG_ON(sizeof(blk_desc) != FS_IV_SIZE);
> +	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
> +	blk_desc.index = cpu_to_le64(lblk_num);
> +	memset(blk_desc.padding, 0, sizeof(blk_desc.padding));
> +
> +	if (ci->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> +		BUG_ON(ci->ci_essiv_tfm == NULL);
> +		memset(iv, 0, sizeof(iv));
> +		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv, (u8 *)&blk_desc);
> +	} else {
> +		memcpy(iv, &blk_desc, sizeof(iv));
> +	}
> +

The ESSIV cipher operation should be done in-place, so that only one IV buffer
is needed.  See what dm-crypt does in crypt_iv_essiv_gen(), for example.

Also, it can just use ESSIV 'if (ci->ci_essiv_tfm != NULL)'.  That would avoid
the awkward BUG_ON() and hardcoding of a specific cipher mode.

> @@ -27,13 +28,13 @@ static void derive_crypt_complete(struct crypto_async_request *req, int rc)
>   * derive_key_aes() - Derive a key using AES-128-ECB
>   * @deriving_key: Encryption key used for derivation.
>   * @source_key:   Source key to which to apply derivation.
> - * @derived_key:  Derived key.
> + * @derived_key_raw:  Derived raw key.
>   *
>   * Return: Zero on success; non-zero otherwise.
>   */
>  static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
> -				u8 source_key[FS_AES_256_XTS_KEY_SIZE],
> -				u8 derived_key[FS_AES_256_XTS_KEY_SIZE])
> +				struct fscrypt_key *source_key,
> +				u8 derived_raw_key[FS_MAX_KEY_SIZE])

'const struct fscrypt_key *'.

>  {
>  	int res = 0;
>  	struct skcipher_request *req = NULL;
> @@ -60,10 +61,10 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
>  	if (res < 0)
>  		goto out;
>  
> -	sg_init_one(&src_sg, source_key, FS_AES_256_XTS_KEY_SIZE);
> -	sg_init_one(&dst_sg, derived_key, FS_AES_256_XTS_KEY_SIZE);
> -	skcipher_request_set_crypt(req, &src_sg, &dst_sg,
> -					FS_AES_256_XTS_KEY_SIZE, NULL);
> +	sg_init_one(&src_sg, source_key->raw, source_key->size);
> +	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
> +	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
> +			NULL);
>  	res = crypto_skcipher_encrypt(req);
>  	if (res == -EINPROGRESS || res == -EBUSY) {
>  		wait_for_completion(&ecr.completion);
> @@ -75,9 +76,28 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
>  	return res;
>  }
>  
> +static bool valid_key_size(struct fscrypt_info *ci, struct fscrypt_key *key,
> +			int reg_file)
> +{
> +	if (reg_file) {
> +		switch(ci->ci_data_mode) {
> +		case FS_ENCRYPTION_MODE_AES_256_XTS:
> +			return key->size >= FS_AES_256_XTS_KEY_SIZE;
> +		case FS_ENCRYPTION_MODE_AES_128_CBC:
> +			return key->size >= FS_AES_128_CBC_KEY_SIZE;
> +		}
> +	} else {
> +		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
> +			return key->size >= FS_AES_256_CTS_KEY_SIZE;
> +		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_128_CTS)
> +			return key->size >= FS_AES_128_CTS_KEY_SIZE;
> +	}
> +	return false;
> +}
> +

This is redundant with how the key size is determined in
determine_cipher_type().  How about passing the expected key size to
validate_user_key() (instead of 'reg_file') and verifying that key->size >=
keysize?

Also, it should be verified that key->size <= FS_MAX_KEY_SIZE (since that's how
large the buffer in fscrypt_key is) and key->size % AES_BLOCK_SIZE == 0 (since
derive_key_aes() assumes the key is evenly divisible into AES blocks).

> @@ -134,6 +154,11 @@ static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
>  			*keysize_ret = FS_AES_256_XTS_KEY_SIZE;
>  			return 0;
>  		}
> +		if (ci->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> +			*cipher_str_ret = "cbc(aes)";
> +			*keysize_ret = FS_AES_128_CBC_KEY_SIZE;
> +			return 0;
> +		}

switch (ci->ci_data_mode) {
...
}

> +		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_128_CTS) {
> +			*cipher_str_ret = "cts(cbc(aes))";
> +			*keysize_ret = FS_AES_128_CTS_KEY_SIZE;
> +			return 0;
> +		}

switch (ci->ci_filename_mode) {
...
}

> +	if (ci->ci_essiv_tfm)
> +		crypto_free_cipher(ci->ci_essiv_tfm);

No need to check for NULL before calling crypto_free_cipher().

> +	if (ctx.contents_encryption_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
> +	    ctx.filenames_encryption_mode != FS_ENCRYPTION_MODE_AES_128_CTS)
> +		return -EINVAL;
> +

I think for now we should only allow the two pairs:

	contents_encryption_mode=FS_ENCRYPTION_MODE_AES_256_XTS
	filenames_encryption_mode=FS_ENCRYPTION_MODE_AES_256_CTS

and

	contents_encryption_mode=FS_ENCRYPTION_MODE_AES_128_CBC
	filenames_encryption_mode=FS_ENCRYPTION_MODE_AES_128_CTS

Other combinations like AES-256-XTS paired with AES-128-CTS should be forbidden.

This also needs to be enforced in create_encryption_context_from_policy() so
that FS_IOC_SET_ENCRYPTION_POLICY fails with bad combinations.

> +	if (crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> +		/* init ESSIV generator */
> +		essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
> +		if (!essiv_tfm || IS_ERR(essiv_tfm)) {
> +			res = essiv_tfm ? PTR_ERR(essiv_tfm) : -ENOMEM;
> +			printk(KERN_DEBUG
> +			       "%s: error %d (inode %u) allocating essiv tfm\n",
> +			       __func__, res, (unsigned) inode->i_ino);
> +			goto out;
> +		}
> +		/* calc sha of key for essiv generation */
> +		memset(sha_ws, 0, sizeof(sha_ws));
> +		sha_init(essiv_key);
> +		sha_transform(essiv_key, raw_key, sha_ws);
> +		res = crypto_cipher_setkey(essiv_tfm, (u8 *)essiv_key, keysize);
> +		if (res)
> +			goto out;
> +
> +		crypt_info->ci_essiv_tfm = essiv_tfm;
> +	}

I think the ESSIV hash should be SHA-256 not SHA-1.  SHA-1 is becoming more and
more obsolete these days.  Another issue with SHA-1 is that it only produces a
20 byte hash, which means it couldn't be used if someone ever wanted to add
AES-256-CBC as another mode.

Also, the hash should be called through the crypto API.

Also, please factor creating the essiv_tfm into its own function.
fscrypt_get_encryption_info() is long enough already.

Something else to consider (probably for the future; this doesn't necessarily
have to be done yet) is that you really only need one essiv_tfm per *key*, not
one per inode.  To deduplicate them you'd need a hash table or LRU queue or
something to keep track of the keys in use.

- Eric
