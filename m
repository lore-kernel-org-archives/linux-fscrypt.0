Return-Path: <david@sigma-star.at>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2] fscrypt: Add support for AES-128-CBC
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20170425201001.GA133970@gmail.com>
Date: Wed, 26 Apr 2017 08:18:51 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <451DF465-A8CA-4F54-9EC1-67B49B522D0B@sigma-star.at>
References: <20170330173840.72909-1-david@sigma-star.at>
 <20170425144100.11484-1-david@sigma-star.at>
 <20170425201001.GA133970@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric!

Thanks for the feedback!

> On 25 Apr 2017, at 22:10, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi Daniel and David,
>=20
> On Tue, Apr 25, 2017 at 04:41:00PM +0200, David Gstir wrote:
>> @@ -147,17 +148,28 @@ int fscrypt_do_page_crypto(const struct inode =
*inode, fscrypt_direction_t rw,
>> {
>> 	struct {
>> 		__le64 index;
>> -		u8 padding[FS_XTS_TWEAK_SIZE - sizeof(__le64)];
>> -	} xts_tweak;
>> +		u8 padding[FS_IV_SIZE - sizeof(__le64)];
>> +	} blk_desc;
>> 	struct skcipher_request *req =3D NULL;
>> 	DECLARE_FS_COMPLETION_RESULT(ecr);
>> 	struct scatterlist dst, src;
>> 	struct fscrypt_info *ci =3D inode->i_crypt_info;
>> 	struct crypto_skcipher *tfm =3D ci->ci_ctfm;
>> 	int res =3D 0;
>> +	u8 *iv =3D (u8 *)&blk_desc;
>>=20
>> 	BUG_ON(len =3D=3D 0);
>>=20
>> +	BUILD_BUG_ON(sizeof(blk_desc) !=3D FS_IV_SIZE);
>> +	BUILD_BUG_ON(AES_BLOCK_SIZE !=3D FS_IV_SIZE);
>> +	blk_desc.index =3D cpu_to_le64(lblk_num);
>> +	memset(blk_desc.padding, 0, sizeof(blk_desc.padding));
>> +
>> +	if (ci->ci_essiv_tfm !=3D NULL) {
>> +		memset(iv, 0, sizeof(blk_desc));
>> +		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv, iv);
>> +	}
>> +
>> 	req =3D skcipher_request_alloc(tfm, gfp_flags);
>> 	if (!req) {
>> 		printk_ratelimited(KERN_ERR
>> @@ -170,15 +182,11 @@ int fscrypt_do_page_crypto(const struct inode =
*inode, fscrypt_direction_t rw,
>> 		req, CRYPTO_TFM_REQ_MAY_BACKLOG | =
CRYPTO_TFM_REQ_MAY_SLEEP,
>> 		page_crypt_complete, &ecr);
>>=20
>> -	BUILD_BUG_ON(sizeof(xts_tweak) !=3D FS_XTS_TWEAK_SIZE);
>> -	xts_tweak.index =3D cpu_to_le64(lblk_num);
>> -	memset(xts_tweak.padding, 0, sizeof(xts_tweak.padding));
>> -
>> 	sg_init_table(&dst, 1);
>> 	sg_set_page(&dst, dest_page, len, offs);
>> 	sg_init_table(&src, 1);
>> 	sg_set_page(&src, src_page, len, offs);
>> -	skcipher_request_set_crypt(req, &src, &dst, len, &xts_tweak);
>> +	skcipher_request_set_crypt(req, &src, &dst, len, &iv);
>> 	if (rw =3D=3D FS_DECRYPT)
>> 		res =3D crypto_skcipher_decrypt(req);
>> 	else
>=20
> There are two critical bugs here.  First the IV is being zeroed before =
being
> encrypted with the ESSIV tfm, so the resulting IV will always be the =
same for a
> given file.  It should be encrypting the block number instead.  Second =
what's
> actually being passed into the crypto API is '&iv' where IV is a =
pointer to
> something on the stack... I really doubt that does what's intended :)
>=20
> Probably the cleanest way to do this correctly is to just have the =
struct be the
> 'iv', so there's no extra pointer to deal with:
>=20
> 	struct {
> 		__le64 index;
> 		u8 padding[FS_IV_SIZE - sizeof(__le64)];
> 	} iv;
>=20
> 	[...]
>=20
> 	BUILD_BUG_ON(sizeof(iv) !=3D FS_IV_SIZE);
> 	BUILD_BUG_ON(AES_BLOCK_SIZE !=3D FS_IV_SIZE);
> 	iv.index =3D cpu_to_le64(lblk_num);
> 	memset(iv.padding, 0, sizeof(iv.padding));
>=20
> 	if (ci->ci_essiv_tfm !=3D NULL) {
> 		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, (u8 *)&iv,
> 					  (u8 *)&iv);
> 	}
>=20
> 	[...]
>=20
> 	skcipher_request_set_crypt(req, &src, &dst, len, &iv);

You are totally right. Somehow I completely missed that. :-/



>=20
>> +static int derive_essiv_salt(u8 *raw_key, int keysize, u8 =
**salt_out,
>> +			unsigned int *saltsize)
>> +{
>> +	int res;
>> +	struct crypto_ahash *hash_tfm;
>> +	unsigned int digestsize;
>> +	u8 *salt =3D NULL;
>> +	struct scatterlist sg;
>> +	struct ahash_request *req =3D NULL;
>> +
>> +	hash_tfm =3D crypto_alloc_ahash("sha256", 0, 0);
>> +	if (IS_ERR(hash_tfm))
>> +		return PTR_ERR(hash_tfm);
>> +
>> +	digestsize =3D crypto_ahash_digestsize(hash_tfm);
>> +	salt =3D kzalloc(digestsize, GFP_NOFS);
>> +	if (!salt) {
>> +		res =3D -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	req =3D ahash_request_alloc(hash_tfm, GFP_NOFS);
>> +	if (!req) {
>> +		kfree(salt);
>> +		res =3D -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	sg_init_one(&sg, raw_key, keysize);
>> +	ahash_request_set_callback(req,
>> +			CRYPTO_TFM_REQ_MAY_BACKLOG | =
CRYPTO_TFM_REQ_MAY_SLEEP,
>> +			NULL, NULL);
>> +	ahash_request_set_crypt(req, &sg, salt, keysize);
>> +
>> +	res =3D crypto_ahash_digest(req);
>> +	if (res) {
>> +		kfree(salt);
>> +		goto out;
>> +	}
>> +
>> +	*salt_out =3D salt;
>> +	*saltsize =3D digestsize;
>> +
>> +out:
>> +	crypto_free_ahash(hash_tfm);
>> +	ahash_request_free(req);
>> +	return res;
>> +}
>> +
>> +static int init_essiv_generator(struct fscrypt_info *ci, u8 =
*raw_key,
>> +				int keysize)
>> +{
>> +	int res;
>> +	struct crypto_cipher *essiv_tfm;
>> +	u8 *salt =3D NULL;
>> +	unsigned int saltsize;
>> +
>> +	/* init ESSIV generator */
>> +	essiv_tfm =3D crypto_alloc_cipher("aes", 0, 0);
>> +	if (!essiv_tfm || IS_ERR(essiv_tfm)) {
>> +		res =3D essiv_tfm ? PTR_ERR(essiv_tfm) : -ENOMEM;
>> +		goto err;
>> +	}
>> +
>> +	res =3D derive_essiv_salt(raw_key, keysize, &salt, &saltsize);
>> +	if (res)
>> +		goto err;
>> +
>> +	res =3D crypto_cipher_setkey(essiv_tfm, salt, saltsize);
>> +	if (res)
>> +		goto err;
>> +
>> +	ci->ci_essiv_tfm =3D essiv_tfm;
>> +
>> +	return 0;
>> +
>> +err:
>> +	if (essiv_tfm && !IS_ERR(essiv_tfm))
>> +		crypto_free_cipher(essiv_tfm);
>> +
>> +	kzfree(salt);
>> +	return res;
>> +}
>=20
> There are a few issues with how the ESSIV generator is initialized:
>=20
> 1.) It's allocating a possibly asynchronous SHA-256 implementation but =
then not
>    handling it actually being asynchronous.  I suggest using the =
'shash' API
>    which is easier to use.
> 2.) No one is going to change the digest size of SHA-256; it's fixed =
at 32
>    bytes.  So just #include <crypto/sha.h> and allocate a 'u8
>    salt[SHA256_DIGEST_SIZE];' on the stack.  Make sure to do
>    memzero_explicit(salt, sizeof(salt)) in all cases.
> 3.) It's always keying the ESSIV transform using a 256-bit AES key.  =
It's still
>    secure of course, but I'm not sure it's what you intended, given =
that it's
>    used in combination with AES-128.  I really think that someone =
who's more of
>    an expert on ESSIV really should weigh in, but my intuition is that =
you
>    really only need to be using AES-128, using the first 'keysize' =
bytes of the
>    hash.

My intention is to use all 256 bits we get from the hash. Yes, this will =
then use
AES-256 for the IV generation, but this will still yield just a 128 bit =
IV for
file contents encryption since the block size of AES is the same. So =
this is
just a case of using AES with a 256 bit key over a 128 bit one which is =
then
used for AES-128 computations.

On the other hand, as you pointed out, truncating the hash and using =
AES-128 *should*
suffice too. Especially since we are using AES-128 everywhere else!

I'm also no export on ESSIV, so I'm not a 100% sure if there is =
something we're
missing here. If using AES-128 is okay, I'll change it to truncate the =
hash.


> You also don't really need to handle freeing the essiv_tfm on errors, =
as long as
> you assign it to the fscrypt_info first.  Also crypto_alloc_cipher() =
returns an
> ERR_PTR(), never NULL.
>=20
> Also, fs/crypto/Kconfig needs a 'select CRYPTO_SHA256' now.
>=20
> Here's a revised version to consider, not actually tested though:
>=20
> static int derive_essiv_salt(const u8 *raw_key, int keysize,
> 			     u8 salt[SHA256_DIGEST_SIZE])
> {
> 	struct crypto_shash *hash_tfm;
>=20
> 	hash_tfm =3D crypto_alloc_shash("sha256", 0, 0);
> 	if (IS_ERR(hash_tfm)) {
> 		pr_warn_ratelimited("fscrypt: error allocating SHA-256 =
transform: %ld",
> 				    PTR_ERR(hash_tfm));
> 		return PTR_ERR(hash_tfm);
> 	} else {
> 		SHASH_DESC_ON_STACK(desc, hash_tfm);
> 		int err;
>=20
> 		desc->tfm =3D hash_tfm;
> 		desc->flags =3D 0;
>=20
> 		BUG_ON(crypto_shash_digestsize(hash_tfm) !=3D =
SHA256_DIGEST_SIZE);
>=20
> 		err =3D crypto_shash_digest(desc, raw_key, keysize, =
salt);
> 		crypto_free_shash(hash_tfm);
> 		return err;
> 	}
> }
>=20
> static int init_essiv_generator(struct fscrypt_info *ci,
> 				const u8 *raw_key, int keysize)
> {
> 	struct crypto_cipher *essiv_tfm;
> 	u8 salt[SHA256_DIGEST_SIZE];
> 	int err;
>=20
> 	if (WARN_ON_ONCE(keysize > sizeof(salt)))
> 		return -EINVAL;
>=20
> 	essiv_tfm =3D crypto_alloc_cipher("aes", 0, 0);
> 	if (IS_ERR(essiv_tfm))
> 		return PTR_ERR(essiv_tfm);
>=20
> 	ci->ci_essiv_tfm =3D essiv_tfm;
>=20
> 	err =3D derive_essiv_salt(raw_key, keysize, salt);
> 	if (err)
> 		goto out;
>=20
> 	err =3D crypto_cipher_setkey(essiv_tfm, salt, keysize);
> out:
> 	memzero_explicit(salt, sizeof(salt));
> 	return err;
> }

Thanks a lot for that! Using shash and SHA256_DIGEST_SIZE makes this =
much cleaner.
I'll redo that for v3.

One optimization Richard pointed out is that we should do the
crypto_alloc_shash("sha256", 0, 0) just once and reuse hash_tfm for all =
sha256 computations.
This will save us some alloc/frees in derive_essiv_salt.

Thanks!
David=
