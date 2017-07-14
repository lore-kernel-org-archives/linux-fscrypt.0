Return-Path: <mhalcrow@google.com>
Return-Path: <mhalcrow@google.com>
Date: Fri, 14 Jul 2017 10:11:14 -0700
From: Michael Halcrow <mhalcrow@google.com>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode
 encryption keys
Message-ID: <20170714171114.GD25453@google.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-4-ebiggers3@gmail.com>
 <20170714162440.GB25453@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714162440.GB25453@google.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 14, 2017 at 09:24:40AM -0700, Michael Halcrow wrote:
> On Wed, Jul 12, 2017 at 02:00:32PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > By design, the keys which userspace provides in the keyring are not used
> > to encrypt data directly.  Instead, a KDF (Key Derivation Function) is
> > used to derive a unique encryption key for each inode, given a "master"
> > key and a nonce.  The current KDF encrypts the master key with
> > AES-128-ECB using the nonce as the AES key.  This KDF is ad-hoc and is
> > not specified in any standard.  While it does generate unique derived
> > keys with sufficient entropy, it has several disadvantages:
> > 
> > - It's reversible: an attacker who compromises a derived key, e.g. using
> >   a side channel attack, can "decrypt" it to get back to the master key.
> > 
> > - It's not very extensible because it cannot easily be used to derive
> >   other key material that may be needed and it ties the length of the
> >   derived key closely to the length of the master key.
> > 
> > - It doesn't evenly distribute the entropy from the master key.  For
> >   example, the first 16 bytes of each derived key depend only on the
> >   first 16 bytes of the master key.
> > 
> > - It uses a public value as an AES key, which is unusual.  Ciphers are
> >   rarely evaluated under a threat model where the keys are public and
> >   the messages are secret.
> > 
> > Solve all these problems for v2 encryption policies by changing the KDF
> > to HKDF with SHA-512 as the underlying hash function.  To derive each
> > inode's encryption key, HKDF is executed with the master key as the
> > input key material, a fixed salt, and the per-inode nonce prefixed with
> > a context byte as the application-specific information string.  Unlike
> > the current KDF, HKDF has been formally published and standardized
> > [1][2], is nonreversible, can be used to derive any number and length of
> > secret and/or non-secret keys, and evenly distributes the entropy from
> > the master key (excepting limits inherent to not using a random salt).
> > 
> > Note that this introduces a dependency on the security and
> > implementation of SHA-512, whereas before we were using only AES for
> > both key derivation and encryption.  However, by using HMAC rather than
> > the hash function directly, HKDF is designed to remain secure even if
> > various classes of attacks, e.g. collision attacks, are found against
> > the underlying unkeyed hash function.  Even HMAC-MD5 is still considered
> > secure in practice, despite MD5 itself having been heavily compromised.
> > 
> > We *could* avoid introducing a hash function by instantiating
> > HKDF-Expand with CMAC-AES256 as the pseudorandom function rather than
> > HMAC-SHA512.  This would work; however, the HKDF specification doesn't
> > explicitly allow a non-HMAC pseudorandom function, so it would be less
> > standard.  It would also require skipping HKDF-Extract and changing the
> > API to accept only 32-byte master keys (since otherwise HKDF-Extract
> > using CMAC-AES would produce a pseudorandom key only 16 bytes long which
> > is only enough for AES-128, not AES-256).
> > 
> > HKDF-SHA512 can require more "crypto work" per key derivation when
> > compared to the current KDF.  However, later in this series, we'll start
> > caching the HMAC transform for each master key, which will actually make
> > the real-world performance about the same or even significantly better
> > than the AES-based KDF as currently implemented.  Also, each KDF can
> > actually be executed on the order of 1 million times per second, so KDF
> > performance probably isn't actually the bottleneck in practice anyway.
> > 
> > References:
> >   [1] Krawczyk (2010). "Cryptographic Extraction and Key Derivation: The
> >       HKDF Scheme".  https://eprint.iacr.org/2010/264.pdf
> > 
> >   [2] RFC 5869. "HMAC-based Extract-and-Expand Key Derivation Function
> >       (HKDF)".  https://tools.ietf.org/html/rfc5869
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/crypto/Kconfig           |   2 +
> >  fs/crypto/fscrypt_private.h |  14 ++
> >  fs/crypto/keyinfo.c         | 485 +++++++++++++++++++++++++++++++++++---------
> >  3 files changed, 405 insertions(+), 96 deletions(-)
> > 
> > diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> > index 02b7d91c9231..bbd4e38b293c 100644
> > --- a/fs/crypto/Kconfig
> > +++ b/fs/crypto/Kconfig
> > @@ -8,6 +8,8 @@ config FS_ENCRYPTION
> >  	select CRYPTO_CTS
> >  	select CRYPTO_CTR
> >  	select CRYPTO_SHA256
> > +	select CRYPTO_SHA512
> > +	select CRYPTO_HMAC
> >  	select KEYS
> >  	help
> >  	  Enable encryption of files and directories.  This
> > diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> > index 5470aac82cab..095e7c16483a 100644
> > --- a/fs/crypto/fscrypt_private.h
> > +++ b/fs/crypto/fscrypt_private.h
> > @@ -86,6 +86,14 @@ fscrypt_valid_context_format(const struct fscrypt_context *ctx, int size)
> >  	return size >= 1 && size == fscrypt_context_size(ctx);
> >  }
> >  
> > +/*
> > + * fscrypt_master_key - an in-use master key
> > + */
> > +struct fscrypt_master_key {
> > +	struct crypto_shash	*mk_hmac;
> > +	unsigned int		mk_size;
> > +};
> > +
> >  /*
> >   * fscrypt_info - the "encryption key" for an inode
> >   *
> > @@ -99,6 +107,12 @@ struct fscrypt_info {
> >  	struct crypto_skcipher *ci_ctfm;
> >  	struct crypto_cipher *ci_essiv_tfm;
> >  
> > +	/*
> > +	 * The master key with which this inode was "unlocked"
> > +	 * (only set for inodes that use a v2+ encryption policy)
> > +	 */
> > +	struct fscrypt_master_key *ci_master_key;
> > +
> >  	/*
> >  	 * Cached fields from the fscrypt_context needed for encryption policy
> >  	 * inheritance and enforcement
> > diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> > index 5591fd24e4b2..7ed1a7fb1308 100644
> > --- a/fs/crypto/keyinfo.c
> > +++ b/fs/crypto/keyinfo.c
> > @@ -6,17 +6,312 @@
> >   * This contains encryption key functions.
> >   *
> >   * Written by Michael Halcrow, Ildar Muslukhov, and Uday Savagaonkar, 2015.
> > + * HKDF support added by Eric Biggers, 2017.
> > + *
> > + * The implementation and usage of HKDF should conform to RFC-5869 ("HMAC-based
> > + * Extract-and-Expand Key Derivation Function").
> >   */
> >  
> >  #include <keys/user-type.h>
> >  #include <linux/scatterlist.h>
> >  #include <linux/ratelimit.h>
> >  #include <crypto/aes.h>
> > +#include <crypto/hash.h>
> >  #include <crypto/sha.h>
> >  #include "fscrypt_private.h"
> >  
> >  static struct crypto_shash *essiv_hash_tfm;
> >  
> > +/*
> > + * Any unkeyed cryptographic hash algorithm can be used with HKDF, but we use
> > + * SHA-512 because it is reasonably secure and efficient; and since it produces
> > + * a 64-byte digest, deriving an AES-256-XTS key preserves all 64 bytes of
> > + * entropy from the master key and requires only one iteration of HKDF-Expand.
> > + */
> > +#define HKDF_HMAC_ALG		"hmac(sha512)"
> > +#define HKDF_HASHLEN		SHA512_DIGEST_SIZE
> > +
> > +/*
> > + * The list of contexts in which we use HKDF to derive additional keys from a
> > + * master key.  The values in this list are used as the first byte of the
> > + * application-specific info string to guarantee that info strings are never
> > + * repeated between contexts.
> > + *
> > + * Keys derived with different info strings are cryptographically isolated from
> > + * each other --- knowledge of one derived key doesn't reveal any others.
> > + */
> > +#define HKDF_CONTEXT_PER_FILE_KEY	1
> > +
> > +/*
> > + * HKDF consists of two steps:
> > + *
> > + * 1. HKDF-Extract: extract a fixed-length pseudorandom key from the
> > + *    input keying material and optional salt.
> > + * 2. HDKF-Expand: expand the pseudorandom key into output keying material of
> > + *    any length, parameterized by an application-specific info string.
> > + *
> > + * HKDF-Extract can be skipped if the input is already a good pseudorandom key
> > + * that is at least as long as the hash.  While the fscrypt master keys should
> > + * already be good pseudorandom keys, when using encryption algorithms that use
> > + * short keys (e.g. AES-128-CBC) we'd like to permit the master key to be
> > + * shorter than HKDF_HASHLEN bytes.  Thus, we still must do HKDF-Extract.
> > + *
> > + * Ideally, HKDF-Extract would be passed a random salt for each distinct input
> > + * key.  Details about the advantages of a random salt can be found in the HKDF
> > + * paper (Krawczyk, 2010; "Cryptographic Extraction and Key Derivation: The HKDF
> > + * Scheme").  However, we do not have the ability to store a salt on a
> > + * per-master-key basis.  Thus, we have to use a fixed salt.  This is sufficient
> > + * as long as the master keys are already pseudorandom and are long enough to
> > + * make dictionary attacks infeasible.  This should be the case if userspace
> > + * used a cryptographically secure random number generator, e.g. /dev/urandom,
> 
> Modulo entropy gathered since boot.
> 
> > + * to generate the master keys.
> > + *
> > + * For the fixed salt we use "fscrypt_hkdf_salt" rather than default of all 0's
> > + * defined by RFC-5869.  This is only to be slightly more robust against
> > + * userspace (unwisely) reusing the master keys for different purposes.
> > + * Logically, it's more likely that the keys would be passed to unsalted
> > + * HKDF-SHA512 than specifically to "fscrypt_hkdf_salt"-salted HKDF-SHA512.
> > + * (Of course, a random salt would be better for this purpose.)
> > + */
> > +
> > +#define HKDF_SALT		"fscrypt_hkdf_salt"
> > +#define HKDF_SALT_LEN		(sizeof(HKDF_SALT) - 1)
> > +
> > +/*
> > + * HKDF-Extract (RFC-5869 section 2.2).  This extracts a pseudorandom key 'prk'
> > + * from the input key material 'ikm' and a salt.  (See explanation above for why
> > + * we use a fixed salt.)
> > + */
> > +static int hkdf_extract(struct crypto_shash *hmac,
> > +			const u8 *ikm, unsigned int ikmlen,
> > +			u8 prk[HKDF_HASHLEN])
> > +{
> > +	SHASH_DESC_ON_STACK(desc, hmac);
> > +	int err;
> > +
> > +	desc->tfm = hmac;
> > +	desc->flags = 0;
> > +
> > +	err = crypto_shash_setkey(hmac, HKDF_SALT, HKDF_SALT_LEN);
> > +	if (err)
> > +		goto out;
> > +
> > +	err = crypto_shash_digest(desc, ikm, ikmlen, prk);
> > +out:
> > +	shash_desc_zero(desc);
> > +	return err;
> > +}
> > +
> > +/*
> > + * HKDF-Expand (RFC-5869 section 2.3).  This expands the pseudorandom key, which
> > + * has already been keyed into 'hmac', into 'okmlen' bytes of output keying
> > + * material, parameterized by the application-specific information string of
> > + * 'info' prefixed with the 'context' byte.  ('context' isn't part of the HKDF
> > + * specification; it's just a prefix we add to our application-specific info
> > + * strings to guarantee that we don't accidentally repeat an info string when
> > + * using HKDF for different purposes.)
> > + */
> > +static int hkdf_expand(struct crypto_shash *hmac, u8 context,
> > +		       const u8 *info, unsigned int infolen,
> > +		       u8 *okm, unsigned int okmlen)
> > +{
> > +	SHASH_DESC_ON_STACK(desc, hmac);
> > +	int err;
> > +	const u8 *prev = NULL;
> > +	unsigned int i;
> > +	u8 counter = 1;
> > +	u8 tmp[HKDF_HASHLEN];
> > +
> > +	desc->tfm = hmac;
> > +	desc->flags = 0;
> > +
> > +	if (unlikely(okmlen > 255 * HKDF_HASHLEN))
> > +		return -EINVAL;
> > +
> > +	for (i = 0; i < okmlen; i += HKDF_HASHLEN) {
> > +
> > +		err = crypto_shash_init(desc);
> > +		if (err)
> > +			goto out;
> > +
> > +		if (prev) {
> > +			err = crypto_shash_update(desc, prev, HKDF_HASHLEN);
> > +			if (err)
> > +				goto out;
> > +		}
> > +
> > +		err = crypto_shash_update(desc, &context, 1);
> 
> One potential shortcut would be to just increment context on each
> iteration rather than maintain the counter.
> 
> > +		if (err)
> > +			goto out;
> > +
> > +		err = crypto_shash_update(desc, info, infolen);
> > +		if (err)
> > +			goto out;
> > +
> > +		if (okmlen - i < HKDF_HASHLEN) {
> > +			err = crypto_shash_finup(desc, &counter, 1, tmp);
> > +			if (err)
> > +				goto out;
> > +			memcpy(&okm[i], tmp, okmlen - i);
> > +			memzero_explicit(tmp, sizeof(tmp));
> > +		} else {
> > +			err = crypto_shash_finup(desc, &counter, 1, &okm[i]);
> > +			if (err)
> > +				goto out;
> > +		}
> > +		counter++;
> > +		prev = &okm[i];
> > +	}
> > +	err = 0;
> > +out:
> > +	shash_desc_zero(desc);
> > +	return err;
> > +}
> > +
> > +static void put_master_key(struct fscrypt_master_key *k)
> > +{
> > +	if (!k)
> > +		return;
> > +
> > +	crypto_free_shash(k->mk_hmac);
> > +	kzfree(k);
> > +}
> > +
> > +/*
> > + * Allocate a fscrypt_master_key, given the keyring key payload.  This includes
> > + * allocating and keying an HMAC transform so that we can efficiently derive
> 
> a HMAC?
> 
> an fscrypt_master_key?
> 
> > + * the per-inode encryption keys with HKDF-Expand later.
> > + */
> > +static struct fscrypt_master_key *
> > +alloc_master_key(const struct fscrypt_key *payload)
> > +{
> > +	struct fscrypt_master_key *k;
> > +	int err;
> > +	u8 prk[HKDF_HASHLEN];
> > +
> > +	k = kzalloc(sizeof(*k), GFP_NOFS);
> > +	if (!k)
> > +		return ERR_PTR(-ENOMEM);
> > +	k->mk_size = payload->size;
> > +
> > +	k->mk_hmac = crypto_alloc_shash(HKDF_HMAC_ALG, 0, 0);
> > +	if (IS_ERR(k->mk_hmac)) {
> > +		err = PTR_ERR(k->mk_hmac);
> > +		k->mk_hmac = NULL;
> > +		pr_warn("fscrypt: error allocating " HKDF_HMAC_ALG ": %d\n",
> > +			err);
> > +		goto fail;
> > +	}
> > +
> > +	BUG_ON(crypto_shash_digestsize(k->mk_hmac) != sizeof(prk));
> > +
> > +	err = hkdf_extract(k->mk_hmac, payload->raw, payload->size, prk);
> > +	if (err)
> > +		goto fail;
> > +
> > +	err = crypto_shash_setkey(k->mk_hmac, prk, sizeof(prk));
> > +	if (err)
> > +		goto fail;
> 
> Why not memzero prk?

Scratch that thought. My brain apparently doesn't always jump
backwards very well.

I might suggest reworking so that goto only moves forward, if that can
be done sanely.

> > +out:
> > +	memzero_explicit(prk, sizeof(prk));
> > +	return k;
> > +
> > +fail:
> > +	put_master_key(k);
> > +	k = ERR_PTR(err);
> > +	goto out;
> > +}
> > +
> > +static void release_keyring_key(struct key *keyring_key)
> > +{
> > +	up_read(&keyring_key->sem);
> > +	key_put(keyring_key);
> > +}
> > +
> > +/*
> > + * Find, lock, and validate the master key with the keyring description
> > + * prefix:descriptor.  It must be released with release_keyring_key() later.
> > + */
> > +static struct key *
> > +find_and_lock_keyring_key(const char *prefix,
> > +			  const u8 descriptor[FS_KEY_DESCRIPTOR_SIZE],
> > +			  unsigned int min_keysize,
> > +			  const struct fscrypt_key **payload_ret)
> > +{
> > +	char *description;
> > +	struct key *keyring_key;
> > +	const struct user_key_payload *ukp;
> > +	const struct fscrypt_key *payload;
> > +
> > +	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
> > +				FS_KEY_DESCRIPTOR_SIZE, descriptor);
> > +	if (!description)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	keyring_key = request_key(&key_type_logon, description, NULL);
> > +	if (IS_ERR(keyring_key))
> > +		goto out;
> > +
> > +	down_read(&keyring_key->sem);
> > +	ukp = user_key_payload_locked(keyring_key);
> > +	payload = (const struct fscrypt_key *)ukp->data;
> > +
> > +	if (ukp->datalen != sizeof(struct fscrypt_key) ||
> > +	    payload->size == 0 || payload->size > FS_MAX_KEY_SIZE) {
> > +		pr_warn_ratelimited("fscrypt: key '%s' has invalid payload\n",
> > +				    description);
> > +		goto invalid;
> > +	}
> > +
> > +	/*
> > +	 * With the legacy AES-based KDF the master key must be at least as long
> > +	 * as the derived key.  With HKDF we could accept a shorter master key;
> > +	 * however, that would mean the derived key wouldn't contain as much
> > +	 * entropy as intended.  So don't allow it in either case.
> > +	 */
> > +	if (payload->size < min_keysize) {
> > +		pr_warn_ratelimited("fscrypt: key '%s' is too short (got %u bytes, wanted %u+ bytes)\n",
> > +				    description, payload->size, min_keysize);
> > +		goto invalid;
> > +	}
> > +
> > +	*payload_ret = payload;
> > +out:
> > +	kfree(description);
> > +	return keyring_key;
> > +
> > +invalid:
> > +	release_keyring_key(keyring_key);
> > +	keyring_key = ERR_PTR(-ENOKEY);
> > +	goto out;
> > +}
> > +
> > +static struct fscrypt_master_key *
> > +load_master_key_from_keyring(const struct inode *inode,
> > +			     const u8 descriptor[FS_KEY_DESCRIPTOR_SIZE],
> > +			     unsigned int min_keysize)
> > +{
> > +	struct key *keyring_key;
> > +	const struct fscrypt_key *payload;
> > +	struct fscrypt_master_key *master_key;
> > +
> > +	keyring_key = find_and_lock_keyring_key(FS_KEY_DESC_PREFIX, descriptor,
> > +						min_keysize, &payload);
> > +	if (keyring_key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
> > +		keyring_key = find_and_lock_keyring_key(
> > +					inode->i_sb->s_cop->key_prefix,
> > +					descriptor, min_keysize, &payload);
> > +	}
> > +	if (IS_ERR(keyring_key))
> > +		return ERR_CAST(keyring_key);
> > +
> > +	master_key = alloc_master_key(payload);
> > +
> > +	release_keyring_key(keyring_key);
> > +
> > +	return master_key;
> > +}
> > +
> >  static void derive_crypt_complete(struct crypto_async_request *req, int rc)
> >  {
> >  	struct fscrypt_completion_result *ecr = req->data;
> > @@ -28,107 +323,100 @@ static void derive_crypt_complete(struct crypto_async_request *req, int rc)
> >  	complete(&ecr->completion);
> >  }
> >  
> > -/**
> > - * derive_key_aes() - Derive a key using AES-128-ECB
> > - * @deriving_key: Encryption key used for derivation.
> > - * @source_key:   Source key to which to apply derivation.
> > - * @derived_raw_key:  Derived raw key.
> > - *
> > - * Return: Zero on success; non-zero otherwise.
> > +/*
> > + * Legacy key derivation function.  This generates the derived key by encrypting
> > + * the master key with AES-128-ECB using the nonce as the AES key.  This
> > + * provides a unique derived key for each inode, but it's nonstandard, isn't
> > + * very extensible, and has the weakness that it's trivially reversible: an
> > + * attacker who compromises a derived key, e.g. with a side channel attack, can
> > + * "decrypt" it to get back to the master key, then derive any other key.
> >   */
> > -static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
> > -				const struct fscrypt_key *source_key,
> > -				u8 derived_raw_key[FS_MAX_KEY_SIZE])
> > +static int derive_key_aes(const struct fscrypt_key *master_key,
> > +			  const struct fscrypt_context *ctx,
> > +			  u8 *derived_key, unsigned int derived_keysize)
> >  {
> > -	int res = 0;
> > +	int err;
> >  	struct skcipher_request *req = NULL;
> >  	DECLARE_FS_COMPLETION_RESULT(ecr);
> >  	struct scatterlist src_sg, dst_sg;
> > -	struct crypto_skcipher *tfm = crypto_alloc_skcipher("ecb(aes)", 0, 0);
> > +	struct crypto_skcipher *tfm;
> > +
> > +	tfm = crypto_alloc_skcipher("ecb(aes)", 0, 0);
> > +	if (IS_ERR(tfm))
> > +		return PTR_ERR(tfm);
> >  
> > -	if (IS_ERR(tfm)) {
> > -		res = PTR_ERR(tfm);
> > -		tfm = NULL;
> > -		goto out;
> > -	}
> >  	crypto_skcipher_set_flags(tfm, CRYPTO_TFM_REQ_WEAK_KEY);
> >  	req = skcipher_request_alloc(tfm, GFP_NOFS);
> >  	if (!req) {
> > -		res = -ENOMEM;
> > +		err = -ENOMEM;
> >  		goto out;
> >  	}
> >  	skcipher_request_set_callback(req,
> >  			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
> >  			derive_crypt_complete, &ecr);
> > -	res = crypto_skcipher_setkey(tfm, deriving_key,
> > -					FS_AES_128_ECB_KEY_SIZE);
> > -	if (res < 0)
> > +
> > +	BUILD_BUG_ON(sizeof(ctx->nonce) != FS_AES_128_ECB_KEY_SIZE);
> > +	err = crypto_skcipher_setkey(tfm, ctx->nonce, sizeof(ctx->nonce));
> > +	if (err)
> >  		goto out;
> >  
> > -	sg_init_one(&src_sg, source_key->raw, source_key->size);
> > -	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
> > -	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
> > +	sg_init_one(&src_sg, master_key->raw, derived_keysize);
> > +	sg_init_one(&dst_sg, derived_key, derived_keysize);
> > +	skcipher_request_set_crypt(req, &src_sg, &dst_sg, derived_keysize,
> >  				   NULL);
> > -	res = crypto_skcipher_encrypt(req);
> > -	if (res == -EINPROGRESS || res == -EBUSY) {
> > +	err = crypto_skcipher_encrypt(req);
> > +	if (err == -EINPROGRESS || err == -EBUSY) {
> >  		wait_for_completion(&ecr.completion);
> > -		res = ecr.res;
> > +		err = ecr.res;
> >  	}
> >  out:
> >  	skcipher_request_free(req);
> >  	crypto_free_skcipher(tfm);
> > -	return res;
> > +	return err;
> >  }
> >  
> > -static int validate_user_key(struct fscrypt_info *crypt_info,
> > -			struct fscrypt_context *ctx, u8 *raw_key,
> > -			const char *prefix, int min_keysize)
> > +/*
> > + * HKDF-based key derivation function.  This uses HKDF-SHA512 to derive a unique
> > + * encryption key for each inode, using the inode's nonce prefixed with a
> > + * context byte as the application-specific information string.  This is more
> > + * flexible than the legacy AES-based KDF and has the advantage that it's
> > + * non-reversible: an attacker who compromises a derived key cannot calculate
> > + * the master key or any other derived keys.
> > + */
> > +static int derive_key_hkdf(const struct fscrypt_master_key *master_key,
> > +			   const struct fscrypt_context *ctx,
> > +			   u8 *derived_key, unsigned int derived_keysize)
> >  {
> > -	char *description;
> > -	struct key *keyring_key;
> > -	struct fscrypt_key *master_key;
> > -	const struct user_key_payload *ukp;
> > -	int res;
> > +	return hkdf_expand(master_key->mk_hmac, HKDF_CONTEXT_PER_FILE_KEY,
> > +			   ctx->nonce, sizeof(ctx->nonce),
> > +			   derived_key, derived_keysize);
> > +}
> >  
> > -	description = kasprintf(GFP_NOFS, "%s%*phN", prefix,
> > -				FS_KEY_DESCRIPTOR_SIZE,
> > -				ctx->master_key_descriptor);
> > -	if (!description)
> > -		return -ENOMEM;
> > +static int find_and_derive_key_v1(const struct inode *inode,
> > +				  const struct fscrypt_context *ctx,
> > +				  u8 *derived_key, unsigned int derived_keysize)
> > +{
> > +	struct key *keyring_key;
> > +	const struct fscrypt_key *payload;
> > +	int err;
> >  
> > -	keyring_key = request_key(&key_type_logon, description, NULL);
> > -	kfree(description);
> > +	keyring_key = find_and_lock_keyring_key(FS_KEY_DESC_PREFIX,
> > +						ctx->master_key_descriptor,
> > +						derived_keysize, &payload);
> > +	if (keyring_key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
> > +		keyring_key = find_and_lock_keyring_key(
> > +					inode->i_sb->s_cop->key_prefix,
> > +					ctx->master_key_descriptor,
> > +					derived_keysize, &payload);
> > +	}
> >  	if (IS_ERR(keyring_key))
> >  		return PTR_ERR(keyring_key);
> > -	down_read(&keyring_key->sem);
> >  
> > -	if (keyring_key->type != &key_type_logon) {
> > -		printk_once(KERN_WARNING
> > -				"%s: key type must be logon\n", __func__);
> > -		res = -ENOKEY;
> > -		goto out;
> > -	}
> > -	ukp = user_key_payload_locked(keyring_key);
> > -	if (ukp->datalen != sizeof(struct fscrypt_key)) {
> > -		res = -EINVAL;
> > -		goto out;
> > -	}
> > -	master_key = (struct fscrypt_key *)ukp->data;
> > -	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
> > -
> > -	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
> > -	    || master_key->size % AES_BLOCK_SIZE != 0) {
> > -		printk_once(KERN_WARNING
> > -				"%s: key size incorrect: %d\n",
> > -				__func__, master_key->size);
> > -		res = -ENOKEY;
> > -		goto out;
> > -	}
> > -	res = derive_key_aes(ctx->nonce, master_key, raw_key);
> > -out:
> > -	up_read(&keyring_key->sem);
> > -	key_put(keyring_key);
> > -	return res;
> > +	err = derive_key_aes(payload, ctx, derived_key, derived_keysize);
> > +
> > +	release_keyring_key(keyring_key);
> > +
> > +	return err;
> >  }
> >  
> >  static const struct {
> > @@ -179,6 +467,7 @@ static void put_crypt_info(struct fscrypt_info *ci)
> >  
> >  	crypto_free_skcipher(ci->ci_ctfm);
> >  	crypto_free_cipher(ci->ci_essiv_tfm);
> > +	put_master_key(ci->ci_master_key);
> >  	kmem_cache_free(fscrypt_info_cachep, ci);
> >  }
> >  
> > @@ -254,8 +543,8 @@ int fscrypt_get_encryption_info(struct inode *inode)
> >  	struct fscrypt_context ctx;
> >  	struct crypto_skcipher *ctfm;
> >  	const char *cipher_str;
> > -	int keysize;
> > -	u8 *raw_key = NULL;
> > +	unsigned int derived_keysize;
> > +	u8 *derived_key = NULL;
> >  	int res;
> >  
> >  	if (inode->i_crypt_info)
> > @@ -296,33 +585,40 @@ int fscrypt_get_encryption_info(struct inode *inode)
> >  	memcpy(crypt_info->ci_master_key_descriptor, ctx.master_key_descriptor,
> >  	       FS_KEY_DESCRIPTOR_SIZE);
> >  
> > -	res = determine_cipher_type(crypt_info, inode, &cipher_str, &keysize);
> > +	res = determine_cipher_type(crypt_info, inode, &cipher_str,
> > +				    &derived_keysize);
> >  	if (res)
> >  		goto out;
> >  
> >  	/*
> > -	 * This cannot be a stack buffer because it is passed to the scatterlist
> > -	 * crypto API as part of key derivation.
> > +	 * This cannot be a stack buffer because it may be passed to the
> > +	 * scatterlist crypto API during key derivation.
> >  	 */
> >  	res = -ENOMEM;
> > -	raw_key = kmalloc(FS_MAX_KEY_SIZE, GFP_NOFS);
> > -	if (!raw_key)
> > +	derived_key = kmalloc(FS_MAX_KEY_SIZE, GFP_NOFS);
> > +	if (!derived_key)
> >  		goto out;
> >  
> > -	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
> > -				keysize);
> > -	if (res && inode->i_sb->s_cop->key_prefix) {
> > -		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
> > -					     inode->i_sb->s_cop->key_prefix,
> > -					     keysize);
> > -		if (res2) {
> > -			if (res2 == -ENOKEY)
> > -				res = -ENOKEY;
> > +	if (ctx.version == FSCRYPT_CONTEXT_V1) {
> > +		res = find_and_derive_key_v1(inode, &ctx, derived_key,
> > +					     derived_keysize);
> 
> Why not make this consistent with the else clause, i.e. doing
> load_master_key_from_keyring() followed by derive_key_v1()?
> 
> > +	} else {
> > +		crypt_info->ci_master_key =
> > +			load_master_key_from_keyring(inode,
> > +						     ctx.master_key_descriptor,
> > +						     derived_keysize);
> > +		if (IS_ERR(crypt_info->ci_master_key)) {
> > +			res = PTR_ERR(crypt_info->ci_master_key);
> > +			crypt_info->ci_master_key = NULL;
> >  			goto out;
> >  		}
> > -	} else if (res) {
> > -		goto out;
> > +
> > +		res = derive_key_hkdf(crypt_info->ci_master_key, &ctx,
> > +				      derived_key, derived_keysize);
> >  	}
> > +	if (res)
> > +		goto out;
> > +
> >  	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
> >  	if (!ctfm || IS_ERR(ctfm)) {
> >  		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
> > @@ -333,17 +629,14 @@ int fscrypt_get_encryption_info(struct inode *inode)
> >  	crypt_info->ci_ctfm = ctfm;
> >  	crypto_skcipher_clear_flags(ctfm, ~0);
> >  	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
> > -	/*
> > -	 * if the provided key is longer than keysize, we use the first
> > -	 * keysize bytes of the derived key only
> > -	 */
> > -	res = crypto_skcipher_setkey(ctfm, raw_key, keysize);
> > +	res = crypto_skcipher_setkey(ctfm, derived_key, derived_keysize);
> >  	if (res)
> >  		goto out;
> >  
> >  	if (S_ISREG(inode->i_mode) &&
> >  	    crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
> > -		res = init_essiv_generator(crypt_info, raw_key, keysize);
> > +		res = init_essiv_generator(crypt_info, derived_key,
> > +					   derived_keysize);
> >  		if (res) {
> >  			pr_debug("%s: error %d (inode %lu) allocating essiv tfm\n",
> >  				 __func__, res, inode->i_ino);
> > @@ -356,7 +649,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
> >  	if (res == -ENOKEY)
> >  		res = 0;
> >  	put_crypt_info(crypt_info);
> > -	kzfree(raw_key);
> > +	kzfree(derived_key);
> >  	return res;
> >  }
> >  EXPORT_SYMBOL(fscrypt_get_encryption_info);
> > -- 
> > 2.13.2.932.g7449e964c-goog
> > 
