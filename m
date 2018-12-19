Return-Path: <SRS0=FB5v=O4=fromorbit.com=david@kernel.org>
Date: Thu, 20 Dec 2018 08:35:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219213552.GO6311@dastard>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219193005.GB6889@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Dec 19, 2018 at 02:30:05PM -0500, Theodore Y. Ts'o wrote:
> On Wed, Dec 19, 2018 at 01:19:53PM +1100, Dave Chinner wrote:
> > Putting metadata in user files beyond EOF doesn't work with XFS's
> > post-EOF speculative allocation algorithms.
> > 
> > i.e. Filesystem design/algorithms often assume that the region
> > beyond EOF in user files is a write-only region.  e.g. We can allow
> > extents beyond EOF to be uninitialised because they are in a write
> > only region of the file and so there's no possibility of stale data
> > exposure. Unfortunately, putting filesystem/security metadata beyond
> > EOF breaks these assumptions - it's no longer a write-only region.
> 
> On Tue, Dec 18, 2018 at 11:14:20PM -0800, Christoph Hellwig wrote:
> > Filesystems already use blocks beyond EOF for preallocation, either
> > speculative by the file system itself, or explicitly by the user with
> > fallocate.  I bet you will run into bugs with your creative abuse
> > sooner or later.  Indepnd of that the interface simply is gross, which
> > is enough of a reason not to merge it.
> 
> Both of these concerns aren't applicable for fs-verity because the
> entire file will be read-only.  So there will be no preallocation or
> fallocation going on --- or allowed --- for a file which is protected
> by fs-verity.  Since no writes are allowed at all, it won't break any
> file systems' assumptions about "write-only regions".

The file has to be written before it has been protected, which means
it may very well have user space allocated beyond EOF before the
merkle tree needs to be written. And, well, the fact that it is all
read only after creation is a feature implementation detail that
allows fsverity to "get away with" storing it's metadata in file
data space.

But whether or not fsverity is enabled on the filesystem, the fact
is that the kernel code now has to support storing and reading data
from beyond EOF. Every user, whether they are using fsverity or not,
is now exposed to that code and a filesystem that no longer
considers the user data region beyond EOF as write only. i.e. it
doesn't matter if fsverity is in use, then ext4/f2fs code now
allows reading of information beyond EOF from user data files

i.e. you've completely changed the way files appear to /everyone/,
not just the users of fsverity. Not only that, you now have file
data that has a specific metadata on-disk format encoded into file
data space. That greatly complicates filesystem checking and
scrubbing which typically /doesn't even look at the contents of
user data/. So yeah, this hack might make the merkle tree
verification "simple" but it greatly complicates everything else the
filesystem has to do.

That's the problem here - fsverity completely redefines the layout
of user data files for everyone, not just fsverity, and not just the
filesystems that implement fsverity. You've taken an ext4 fsverity
implementation feature and promoted it to being a linux-wide 
file data layout standard that is encoded into the kernel/user
ABI/API forever more.

And you're trying to force this into the tree on everyone without
adequate review because "a product is already shipping with this
code in it". Didn't we learn the lessons of failing to "upstream
first" new features more than 15 years ago?

> As far as whether it's "gross" --- that's a taste question, and I
> happen to think it's more "clever" than "gross". 

You think it's clever because it's a neat hack that makes what you
need simple to implement, and so you can ship it in phones quickly
and without needing to involve upstream in more complex design
discussions.

I think it's gross because it bleeds implementation details all over
the API and globally redefines the user data file layout for
everyone, kernel wide in a manner that is incompatible with existing
filesystem implementations.

> It allows for a very
> simple implementation, *leveraging* the fact that the file will never
> change --- and especially, grow in length.  So why not use the space
> after EOF?

There have been many technical reasons given for why it's a bad interfaces,
yet you only address entirely subjective arguments and claim that
you have "good taste" in APIs because it is "clever".

> The alternative requires adding Solaris-style alternate data streams
> support.

No, it does not. It simply requires a different userspace API to
move the merkle tree data into the kernel, and a different
implemetnation abstraction that allows filesystems to provide the
merkle tree data pages on request. Darrick and Christoph have
already suggested alternative user APIs that would work just fine,
and they don't ahve a requirement that the merkle tree is held in
the user data space beyond EOF.

How filesystems store and retrieve merkle tree data should be a
filesystem internal detail. If how metadata is stored in th e
filesystem is defined by the userspace API or the kernel library
code that implements the verification feature, then it lacks the
necessary abstraction to be a generic Linux filesystem feature.
IOWs, it needs to be redesigned and reworked before we should
consider it for merging.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
