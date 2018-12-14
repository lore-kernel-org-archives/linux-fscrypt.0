Return-Path: <SRS0=aThg=OX=thunk.org=tytso@kernel.org>
Date: Fri, 14 Dec 2018 00:17:22 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181214051722.GF20880@thunk.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213202249.GA3797@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 13, 2018 at 12:22:49PM -0800, Christoph Hellwig wrote:
> On Wed, Dec 12, 2018 at 12:26:10PM -0800, Eric Biggers wrote:
> > > As this apparently got merged despite no proper reviews from VFS
> > > level persons:
> > 
> > fs-verity has been out for review since August, and Cc'ed to all relevant
> > mailing lists including linux-fsdevel, linux-ext4, linux-f2fs-devel,
> > linux-fscrypt, linux-integrity, and linux-kernel.  There are tests,
> > documentation (since v2), and a userspace tool.  It's also been presented at
> > multiple conferences, and has been covered by LWN multiple times.  If more
> > people want to review it, then they should do so; there's nothing stopping them.
> 
> But you did not got a review from someone like Al, Linus, Andrew or me,
> did you?

I don't consider fs-verity to be part of core VFS, but rather a
library that happens to be used by ext4 and f2fs.  This is much like
fscrypt, which was originally an ext4-only thing, but the code was
always set up so it could be used by other file systems, and when f2fs
was interested in using it, we moved it to fs/crypto.  As such the
fscrypto code never got a review from Al, Andrew, or you, and when I
pushed it to Linus, he accepted the pull request.

The difference this time is that ext4 and f2fs are interested in using
common code from the beginning.

> > Can you elaborate on the actual problems you think the current solution has, and
> > exactly what solution you'd prefer instead?  Keep in mind that (1) for large
> > files the Merkle tree can be gigabytes long, (2) Linux doesn't have an API for
> > file streams, and (3) when fs-verity is combined with fscrypt, it's important
> > that the hashes be encrypted, so as to not leak information about the plaintext.
> 
> Given that you alread use an ioctl as the interface what is the problem
> of passing this data through the ioctl?

The size of the Merkle tree is roughly size/129.  So for a 100MB file
(and there can be Android APK files that bug), the Merkle tree could
be almost 800k.  That's not really a size that we would want to push
through an ioctl.

We could treat the ioctl as write-like interface, but using write(2)
seemed to make a lot more sense.  Also, the fscrypt common code
leveraged by f2fs and ext4 assume that the verity tree will be stored
after the data blocks.

Given that the semantics of a verity-protected file is that it is
immutable, you *could* store the Merkle tree in a separate file
stream, but it really doesn't buy you anything --- by definition, you
can't append to a fs-verity protected file.  Furthermore, it would
require extra complexity in the common fsverity code --- which looks
for the Merkle tree at the end of file data --- for no real benefit.

Cheers,

						- Ted

P.S.  And if you've purchased a Pixel 3 device, it's already using the
fsverity code, so it's quite well tested (and yes, we have xfstests).
