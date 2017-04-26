Return-Path: <ebiggers3@gmail.com>
Date: Wed, 26 Apr 2017 14:56:16 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2] fscrypt: Add support for AES-128-CBC
Message-ID: <20170426215616.GA104929@gmail.com>
References: <20170330173840.72909-1-david@sigma-star.at>
 <20170425144100.11484-1-david@sigma-star.at>
 <20170425201001.GA133970@gmail.com>
 <451DF465-A8CA-4F54-9EC1-67B49B522D0B@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <451DF465-A8CA-4F54-9EC1-67B49B522D0B@sigma-star.at>
To: David Gstir <david@sigma-star.at>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Wed, Apr 26, 2017 at 08:18:51AM +0200, David Gstir wrote:
> > 3.) It's always keying the ESSIV transform using a 256-bit AES key.  It's still
> >    secure of course, but I'm not sure it's what you intended, given that it's
> >    used in combination with AES-128.  I really think that someone who's more of
> >    an expert on ESSIV really should weigh in, but my intuition is that you
> >    really only need to be using AES-128, using the first 'keysize' bytes of the
> >    hash.
> 
> My intention is to use all 256 bits we get from the hash. Yes, this will then use
> AES-256 for the IV generation, but this will still yield just a 128 bit IV for
> file contents encryption since the block size of AES is the same. So this is
> just a case of using AES with a 256 bit key over a 128 bit one which is then
> used for AES-128 computations.
> 
> On the other hand, as you pointed out, truncating the hash and using AES-128 *should*
> suffice too. Especially since we are using AES-128 everywhere else!
> 
> I'm also no export on ESSIV, so I'm not a 100% sure if there is something we're
> missing here. If using AES-128 is okay, I'll change it to truncate the hash.
> 

After thinking about it some more I'm actually slightly leaning towards AES-256,
since it matches the size of the message digest being used.  I think that's how
ESSIV was designed to work, since message digests are not necessarily designed
to be truncated.  Also I doubt there would be any noticable performance
difference from using AES-256 instead of AES-128, given that it's just for the
IV generation and not for the "real" encryption.

On the other hand, the message digest *is* hard-coded to SHA-256, and the
SHA-256 specification actually states that it can be truncated, with the
collision resistance decreased in the expected way.

> 
> One optimization Richard pointed out is that we should do the
> crypto_alloc_shash("sha256", 0, 0) just once and reuse hash_tfm for all sha256 computations.
> This will save us some alloc/frees in derive_essiv_salt.
> 

Yes, I had the same idea too.  I suggest allocating it only the first time it's
used rather than always doing it in fscrypt_init(), since not everyone will be
needing it.

- Eric
