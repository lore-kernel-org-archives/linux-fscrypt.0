Return-Path: <SRS0=IFDd=PS=iki.fi=aaro.koskinen@kernel.org>
Date: Fri, 11 Jan 2019 01:35:14 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: Bug report: unaligned access with ext4 encryption
Message-ID: <20190110233513.GC22416@darkstar.musicnaut.iki.fi>
References: <20190103171659.GA208343@gmail.com>
 <20181230162906.GI27785@darkstar.musicnaut.iki.fi>
 <17391.1546622882@warthog.procyon.org.uk>
 <20190110222928.GB22416@darkstar.musicnaut.iki.fi>
 <20190110230114.GF149637@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110230114.GF149637@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: David Howells <dhowells@redhat.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, keyrings@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On Thu, Jan 10, 2019 at 03:01:14PM -0800, Eric Biggers wrote:
> On Fri, Jan 11, 2019 at 12:29:28AM +0200, Aaro Koskinen wrote:
> > Hi,
> > 
> > On Fri, Jan 04, 2019 at 05:28:02PM +0000, David Howells wrote:
> > > Eric Biggers <ebiggers@kernel.org> wrote:
> > > > Hi Aaro, thanks for the bug report!  I think you're on the right track; it makes
> > > > much more sense to have the keyrings subsystem store the payload with better
> > > > alignment, than to work around the 2-byte alignment in fscrypt.
> > > > 
> > > > But how about '__aligned(__alignof__(u64))' instead?  4 bytes may not be enough.
> > > > 
> > > > David, what do you think?
> > > 
> > > Does that even work?
> > 
> > That should work.
> > 
> > > Might be better to just insert 6 bytes of padding with a comment, but yes I
> > > agree that it's probably better to align it to at least machine word size.
> > 
> > Padding is fragile, e.g. if struct rcu_head changes. Using __aligned should
> > make it always right automatically.
> > 
> > A.
> 
> I agree that __aligned is better.  It should work; see 'struct crypto_tfm' in
> include/linux/crypto.h for another example of a struct that uses __aligned on a
> flexible array at the end.
> 
> Aaro, can you send a formal patch?  If you don't I'll do so, but I figure I'll
> ask first.

Please go ahead; I'd prefer if you send the patch, I will then test it
on SPARC and reply with Tested-by (if it works :).

A.
