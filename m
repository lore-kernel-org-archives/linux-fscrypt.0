Return-Path: <ebiggers3@gmail.com>
Date: Tue, 25 Apr 2017 13:10:01 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2] fscrypt: Add support for AES-128-CBC
Message-ID: <20170425201001.GA133970@gmail.com>
References: <20170330173840.72909-1-david@sigma-star.at>
 <20170425144100.11484-1-david@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425144100.11484-1-david@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Daniel and David,

On Tue, Apr 25, 2017 at 04:41:00PM +0200, David Gstir wrote:
> @@ -147,17 +148,28 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
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
>  	int res = 0;
> +	u8 *iv = (u8 *)&blk_desc;
>  
>  	BUG_ON(len == 0);
>  
> +	BUILD_BUG_ON(sizeof(blk_desc) != FS_IV_SIZE);
> +	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
> +	blk_desc.index = cpu_to_le64(lblk_num);
> +	memset(blk_desc.padding, 0, sizeof(blk_desc.padding));
> +
> +	if (ci->ci_essiv_tfm != NULL) {
> +		memset(iv, 0, sizeof(blk_desc));
> +		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv, iv);
> +	}
> +
>  	req = skcipher_request_alloc(tfm, gfp_flags);
>  	if (!req) {
>  		printk_ratelimited(KERN_ERR
> @@ -170,15 +182,11 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
>  		req, CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
>  		page_crypt_complete, &ecr);
>  
> -	BUILD_BUG_ON(sizeof(xts_tweak) != FS_XTS_TWEAK_SIZE);
> -	xts_tweak.index = cpu_to_le64(lblk_num);
> -	memset(xts_tweak.padding, 0, sizeof(xts_tweak.padding));
> -
>  	sg_init_table(&dst, 1);
>  	sg_set_page(&dst, dest_page, len, offs);
>  	sg_init_table(&src, 1);
>  	sg_set_page(&src, src_page, len, offs);
> -	skcipher_request_set_crypt(req, &src, &dst, len, &xts_tweak);
> +	skcipher_request_set_crypt(req, &src, &dst, len, &iv);
>  	if (rw == FS_DECRYPT)
>  		res = crypto_skcipher_decrypt(req);
>  	else

There are two critical bugs here.  First the IV is being zeroed before being
encrypted with the ESSIV tfm, so the resulting IV will always be the same for a
given file.  It should be encrypting the block number instead.  Second what's
actually being passed into the crypto API is '&iv' where IV is a pointer to
something on the stack... I really doubt that does what's intended :)

Probably the cleanest way to do this correctly is to just have the struct be the
'iv', so there's no extra pointer to deal with:

	struct {
		__le64 index;
		u8 padding[FS_IV_SIZE - sizeof(__le64)];
	} iv;

	[...]

	BUILD_BUG_ON(sizeof(iv) != FS_IV_SIZE);
	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
	iv.index = cpu_to_le64(lblk_num);
	memset(iv.padding, 0, sizeof(iv.padding));

	if (ci->ci_essiv_tfm != NULL) {
		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, (u8 *)&iv,
					  (u8 *)&iv);
	}

	[...]

	skcipher_request_set_crypt(req, &src, &dst, len, &iv);

> +static int derive_essiv_salt(u8 *raw_key, int keysize, u8 **salt_out,
> +			unsigned int *saltsize)
> +{
> +	int res;
> +	struct crypto_ahash *hash_tfm;
> +	unsigned int digestsize;
> +	u8 *salt = NULL;
> +	struct scatterlist sg;
> +	struct ahash_request *req = NULL;
> +
> +	hash_tfm = crypto_alloc_ahash("sha256", 0, 0);
> +	if (IS_ERR(hash_tfm))
> +		return PTR_ERR(hash_tfm);
> +
> +	digestsize = crypto_ahash_digestsize(hash_tfm);
> +	salt = kzalloc(digestsize, GFP_NOFS);
> +	if (!salt) {
> +		res = -ENOMEM;
> +		goto out;
> +	}
> +
> +	req = ahash_request_alloc(hash_tfm, GFP_NOFS);
> +	if (!req) {
> +		kfree(salt);
> +		res = -ENOMEM;
> +		goto out;
> +	}
> +
> +	sg_init_one(&sg, raw_key, keysize);
> +	ahash_request_set_callback(req,
> +			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
> +			NULL, NULL);
> +	ahash_request_set_crypt(req, &sg, salt, keysize);
> +
> +	res = crypto_ahash_digest(req);
> +	if (res) {
> +		kfree(salt);
> +		goto out;
> +	}
> +
> +	*salt_out = salt;
> +	*saltsize = digestsize;
> +
> +out:
> +	crypto_free_ahash(hash_tfm);
> +	ahash_request_free(req);
> +	return res;
> +}
> +
> +static int init_essiv_generator(struct fscrypt_info *ci, u8 *raw_key,
> +				int keysize)
> +{
> +	int res;
> +	struct crypto_cipher *essiv_tfm;
> +	u8 *salt = NULL;
> +	unsigned int saltsize;
> +
> +	/* init ESSIV generator */
> +	essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
> +	if (!essiv_tfm || IS_ERR(essiv_tfm)) {
> +		res = essiv_tfm ? PTR_ERR(essiv_tfm) : -ENOMEM;
> +		goto err;
> +	}
> +
> +	res = derive_essiv_salt(raw_key, keysize, &salt, &saltsize);
> +	if (res)
> +		goto err;
> +
> +	res = crypto_cipher_setkey(essiv_tfm, salt, saltsize);
> +	if (res)
> +		goto err;
> +
> +	ci->ci_essiv_tfm = essiv_tfm;
> +
> +	return 0;
> +
> +err:
> +	if (essiv_tfm && !IS_ERR(essiv_tfm))
> +		crypto_free_cipher(essiv_tfm);
> +
> +	kzfree(salt);
> +	return res;
> +}

There are a few issues with how the ESSIV generator is initialized:

1.) It's allocating a possibly asynchronous SHA-256 implementation but then not
    handling it actually being asynchronous.  I suggest using the 'shash' API
    which is easier to use.
2.) No one is going to change the digest size of SHA-256; it's fixed at 32
    bytes.  So just #include <crypto/sha.h> and allocate a 'u8
    salt[SHA256_DIGEST_SIZE];' on the stack.  Make sure to do
    memzero_explicit(salt, sizeof(salt)) in all cases.
3.) It's always keying the ESSIV transform using a 256-bit AES key.  It's still
    secure of course, but I'm not sure it's what you intended, given that it's
    used in combination with AES-128.  I really think that someone who's more of
    an expert on ESSIV really should weigh in, but my intuition is that you
    really only need to be using AES-128, using the first 'keysize' bytes of the
    hash.

You also don't really need to handle freeing the essiv_tfm on errors, as long as
you assign it to the fscrypt_info first.  Also crypto_alloc_cipher() returns an
ERR_PTR(), never NULL.

Also, fs/crypto/Kconfig needs a 'select CRYPTO_SHA256' now.

Here's a revised version to consider, not actually tested though:

static int derive_essiv_salt(const u8 *raw_key, int keysize,
			     u8 salt[SHA256_DIGEST_SIZE])
{
	struct crypto_shash *hash_tfm;

	hash_tfm = crypto_alloc_shash("sha256", 0, 0);
	if (IS_ERR(hash_tfm)) {
		pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld",
				    PTR_ERR(hash_tfm));
		return PTR_ERR(hash_tfm);
	} else {
		SHASH_DESC_ON_STACK(desc, hash_tfm);
		int err;

		desc->tfm = hash_tfm;
		desc->flags = 0;

		BUG_ON(crypto_shash_digestsize(hash_tfm) != SHA256_DIGEST_SIZE);

		err = crypto_shash_digest(desc, raw_key, keysize, salt);
		crypto_free_shash(hash_tfm);
		return err;
	}
}

static int init_essiv_generator(struct fscrypt_info *ci,
				const u8 *raw_key, int keysize)
{
	struct crypto_cipher *essiv_tfm;
	u8 salt[SHA256_DIGEST_SIZE];
	int err;

	if (WARN_ON_ONCE(keysize > sizeof(salt)))
		return -EINVAL;

	essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
	if (IS_ERR(essiv_tfm))
		return PTR_ERR(essiv_tfm);

	ci->ci_essiv_tfm = essiv_tfm;

	err = derive_essiv_salt(raw_key, keysize, salt);
	if (err)
		goto out;

	err = crypto_cipher_setkey(essiv_tfm, salt, keysize);
out:
	memzero_explicit(salt, sizeof(salt));
	return err;
}

> +
>  int fscrypt_get_encryption_info(struct inode *inode)
>  {
>  	struct fscrypt_info *crypt_info;
>  	struct fscrypt_context ctx;
>  	struct crypto_skcipher *ctfm;
> +
>  	const char *cipher_str;
>  	int keysize;
>  	u8 *raw_key = NULL;
> @@ -207,6 +306,10 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
>  		return -EINVAL;
>  
> +	if (!fscrypt_valid_enc_modes(ctx.contents_encryption_mode,
> +				ctx.filenames_encryption_mode))
> +		return -EINVAL;
> +

Indent this properly

>  	crypt_info = kmem_cache_alloc(fscrypt_info_cachep, GFP_NOFS);
>  	if (!crypt_info)
>  		return -ENOMEM;
> @@ -215,6 +318,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
>  	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
>  	crypt_info->ci_ctfm = NULL;
> +	crypt_info->ci_essiv_tfm = NULL;
>  	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
>  				sizeof(crypt_info->ci_master_key));
>  
> @@ -231,10 +335,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (!raw_key)
>  		goto out;
>  
> -	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX);
> +	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
> +				keysize);
>  	if (res && inode->i_sb->s_cop->key_prefix) {
>  		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
> -					     inode->i_sb->s_cop->key_prefix);
> +					     inode->i_sb->s_cop->key_prefix,
> +					     keysize);
>  		if (res2) {
>  			if (res2 == -ENOKEY)
>  				res = -ENOKEY;
> @@ -246,9 +352,9 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
>  	if (!ctfm || IS_ERR(ctfm)) {
>  		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
> -		printk(KERN_DEBUG
> -		       "%s: error %d (inode %u) allocating crypto tfm\n",
> -		       __func__, res, (unsigned) inode->i_ino);
> +		pr_debug(
> +		      "%s: error %d (inode %u) allocating crypto tfm\n",
> +		      __func__, res, (unsigned int) inode->i_ino);
>  		goto out;

If you're changing this line just make it print i_ino as an 'unsigned long', no
need to cast it.  Same below.

>  	}
>  	crypt_info->ci_ctfm = ctfm;
> @@ -258,6 +364,15 @@ int fscrypt_get_encryption_info(struct inode *inode)
>  	if (res)
>  		goto out;
>  
> +	if (crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> +		res = init_essiv_generator(crypt_info, raw_key, keysize);
> +		if (res) {
> +			pr_debug(
> +			     "%s: error %d (inode %u) allocating essiv tfm\n",
> +			     __func__, res, (unsigned int) inode->i_ino);
> +			goto out;
> +		}
> +	}
>  	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
>  		crypt_info = NULL;
>  out:
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index 4908906d54d5..bac8009245f2 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -41,11 +41,8 @@ static int create_encryption_context_from_policy(struct inode *inode,
>  	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
>  					FS_KEY_DESCRIPTOR_SIZE);
>  
> -	if (!fscrypt_valid_contents_enc_mode(
> -				policy->contents_encryption_mode))
> -		return -EINVAL;
> -
> -	if (!fscrypt_valid_filenames_enc_mode(
> +	if (!fscrypt_valid_enc_modes(
> +				policy->contents_encryption_mode,
>  				policy->filenames_encryption_mode))
>  		return -EINVAL;

Indent properly:

	if (!fscrypt_valid_enc_modes(policy->contents_encryption_mode,
				     policy->filenames_encryption_mode))

- Eric
