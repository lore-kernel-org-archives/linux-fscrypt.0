Return-Path: <SRS0=S0Qi=O4=mit.edu=tytso@kernel.org>
Date: Wed, 19 Dec 2018 14:30:05 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219193005.GB6889@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
To: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Dec 19, 2018 at 01:19:53PM +1100, Dave Chinner wrote:
> Putting metadata in user files beyond EOF doesn't work with XFS's
> post-EOF speculative allocation algorithms.
> 
> i.e. Filesystem design/algorithms often assume that the region
> beyond EOF in user files is a write-only region.  e.g. We can allow
> extents beyond EOF to be uninitialised because they are in a write
> only region of the file and so there's no possibility of stale data
> exposure. Unfortunately, putting filesystem/security metadata beyond
> EOF breaks these assumptions - it's no longer a write-only region.

On Tue, Dec 18, 2018 at 11:14:20PM -0800, Christoph Hellwig wrote:
> Filesystems already use blocks beyond EOF for preallocation, either
> speculative by the file system itself, or explicitly by the user with
> fallocate.  I bet you will run into bugs with your creative abuse
> sooner or later.  Indepnd of that the interface simply is gross, which
> is enough of a reason not to merge it.

Both of these concerns aren't applicable for fs-verity because the
entire file will be read-only.  So there will be no preallocation or
fallocation going on --- or allowed --- for a file which is protected
by fs-verity.  Since no writes are allowed at all, it won't break any
file systems' assumptions about "write-only regions".

As far as whether it's "gross" --- that's a taste question, and I
happen to think it's more "clever" than "gross".  It allows for a very
simple implementation, *leveraging* the fact that the file will never
change --- and especially, grow in length.  So why not use the space
after EOF?

The alternative requires adding Solaris-style alternate data streams
support.  Whether or not ADS is a good idea or just an invitation to
malware authors[1] is something which can be debated, but my position
is it's unnecessary given the requirements of fs-verity.  And avoiding
such complexity is a *good* thing, not a bad thing.

[1] https://www.deepinstinct.com/2018/06/12/the-abuse-of-alternate-data-stream-hasnt-disappeared/

						- Ted
