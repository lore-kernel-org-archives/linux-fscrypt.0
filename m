Return-Path: <ebiggers3@gmail.com>
Date: Wed, 19 Jul 2017 10:32:37 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode
 encryption keys
Message-ID: <20170719173237.GA78811@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-4-ebiggers3@gmail.com>
 <20170714162440.GB25453@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714162440.GB25453@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 14, 2017 at 09:24:40AM -0700, Michael Halcrow wrote:
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

That's not a good idea because then it wouldn't be standard HKDF, and it would
be relying on the "feedback" mode to keep the HMAC inputs unique which isn't
guaranteed to be sufficient.

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

struct fscrypt_master_key contains the HMAC transform but not the raw master
key.  For the v1 key derivation we need the raw master key.  We could put it in
the fscrypt_master_key and then try to allow fscrypt_master_key's both with and
without HMAC transforms depending on the policy versions they are used for, but
there's no point in doing so currently.

Eric
