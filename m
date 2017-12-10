Return-Path: <ebiggers3@gmail.com>
Date: Sun, 10 Dec 2017 11:05:47 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Message-ID: <20171210190547.GB1170@zzz.localdomain>
References: <20171208013838.105034-1-ebiggers3@gmail.com>
 <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
 <CAKv+Gu85X5OZWhwQxNrc8RonPL3XdRhzK=JeWcWXLu=8KUsQAg@mail.gmail.com>
 <20171208214213.GA104193@gmail.com>
 <483722360.123210.1512834056036@ichabod.co-bxl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <483722360.123210.1512834056036@ichabod.co-bxl>
To: Geo Kozey <geokozey@mailfence.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-fscrypt@vger.kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, ebiggers@google.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Dec 09, 2017 at 04:40:56PM +0100, Geo Kozey wrote:
> > From: Eric Biggers <ebiggers3@gmail.com>
> > Sent: Fri Dec 08 22:42:13 CET 2017
> > Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
> > 
> > We can't use authenticated encryption for the same reason we can't use random or
> > sequential nonces: there is nowhere to store the additional metadata
> > (authentication tag and nonce) per filesystem block *and* have it updated
> > atomically with respect to the contents of said block. 
> 
> I saw that LUKS/dm-crypt guys are able to do AE regardless of the same issues[1].
> Is it really impossible for fscrypt?
> 
> [1] http://www.saout.de/pipermail/dm-crypt/2017-November/005745.html
> 

dm-crypt only supports authenticated encryption when it is running on top of
dm-integrity, which emulates a block device that has per-sector tags that can be
used to store the integrity information (nonce and authentication tag).

While it is very cool that they've actually gotten this to work, it is really
more of a proof-of-concept because the per-sector tag emulation is really
inefficient.  Primarily, it has to use data journaling to maintain consistency,
which results in all data having to be written twice.  Very few users are
willing to take that performance hit.

Now, it does have a nice design which is that the per-sector tag support is
abstracted out as an integrity profile which it appears could be used by
filesystems.  So we probably could actually support authenticated encryption
pretty easily in fscrypt, but presently it would only work when the filesystem
was formatted on top of dm-integrity, which means almost no one would use it.

Ideally, in the future there will be *hardware* that supports per-sector tags,
which would then provide the "DM-DIF-EXT-TAG" integrity profile rather than
dm-integrity.  That would make authenticated full-disk encryption, as well as
authenticated encryption of file contents on non-CoW filesystems, actually
practical (albeit without rollback protection).

Eric
