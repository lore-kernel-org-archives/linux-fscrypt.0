Return-Path: <ebiggers3@gmail.com>
Date: Wed, 19 Jul 2017 10:37:44 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 5/6] fscrypt: cache the HMAC transform for each master key
Message-ID: <20170719173744.GB78811@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-6-ebiggers3@gmail.com>
 <20170717174551.GA32282@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170717174551.GA32282@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 17, 2017 at 10:45:51AM -0700, Michael Halcrow wrote:
> > +/*
> > + * Get the fscrypt_master_key identified by the specified v2+ encryption
> > + * context, or create it if not found.
> > + *
> > + * Returns the fscrypt_master_key with a reference taken, or an ERR_PTR().
> > + */
> > +static struct fscrypt_master_key *
> > +find_or_create_master_key(const struct inode *inode,
> > +			  const struct fscrypt_context *ctx,
> > +			  unsigned int min_keysize)
> > +{
> > +	struct fscrypt_master_key *master_key;
> > +
> > +	if (WARN_ON(ctx->version < FSCRYPT_CONTEXT_V2))
> > +		return ERR_PTR(-EINVAL);
> 
> Isn't this a programming error?  If so, consider either BUG_ON() or
> omit the check.
> 

Yes, but BUG_ON() is discouraged in cases where there is a straightforward way
to recover from the error.  checkpatch actually warns about using it these days.

Eric
