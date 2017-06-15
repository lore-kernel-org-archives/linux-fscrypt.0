Return-Path: <ebiggers3@gmail.com>
Date: Thu, 15 Jun 2017 13:48:41 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v4] fscrypt: Add support for AES-128-CBC
Message-ID: <20170615204841.GA66403@gmail.com>
References: <20170517180850.GA91213@gmail.com>
 <20170523051120.15698-1-david@sigma-star.at>
 <20170615204129.GA23647@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170615204129.GA23647@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: David Gstir <david@sigma-star.at>, tytso@mit.edu, jaegeuk@kernel.org, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 15, 2017 at 01:41:29PM -0700, Michael Halcrow wrote:
> >  static int validate_user_key(struct fscrypt_info *crypt_info,
> >  			struct fscrypt_context *ctx, u8 *raw_key,
> > -			const char *prefix)
> > +			const char *prefix, int min_keysize)
> >  {
> >  	char *description;
> >  	struct key *keyring_key;
> > @@ -111,50 +116,60 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
> >  	master_key = (struct fscrypt_key *)ukp->data;
> >  	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
> >  
> > -	if (master_key->size != FS_AES_256_XTS_KEY_SIZE) {
> > +	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
> > +	    || master_key->size % AES_BLOCK_SIZE != 0) {
> 
> I suggest validating the provided key size directly against the mode.
> Else, it looks to me that this code will accept a 128-bit key for
> AES-256.
> 

It's doing that already; min_keysize depends on the mode.

Eric
