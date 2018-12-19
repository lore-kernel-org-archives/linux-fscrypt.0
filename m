Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Date: Wed, 19 Dec 2018 13:19:53 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219021953.GD31274@dastard>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia>
 <20181219001603.GD25775@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219001603.GD25775@mit.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 18, 2018 at 07:16:03PM -0500, Theodore Y. Ts'o wrote:
> On Mon, Dec 17, 2018 at 12:00:39PM -0800, Darrick J. Wong wrote:
> > FWIW, if I were (hypothetically) working on an xfs implementation, I
> > likely would have settled on passing a reference to a merkle tree
> > through a (fd, length) pair, because that allows us plenty of options
> > on the back end:
> > 
> > b) we could remap the tree into a new inode fork for merkle trees, or
> > a) remap it as posteof blocks like ext4/f2fs does, or
> > c) remap the blocks into the attribute fork as an (unusually large)
> > extended attribute value.
> 
> Sure, but what would be the benefit of doing different things on the
> back end?  I think this is a really more of a philophical objection
> than anything else.

Putting metadata in user files beyond EOF doesn't work with XFS's
post-EOF speculative allocation algorithms.

i.e. Filesystem design/algorithms often assume that the region
beyond EOF in user files is a write-only region.  e.g. We can allow
extents beyond EOF to be uninitialised because they are in a write
only region of the file and so there's no possibility of stale data
exposure. Unfortunately, putting filesystem/security metadata beyond
EOF breaks these assumptions - it's no longer a write-only region.

IOWs, all these existing assumptions and implementation details are
exposed to a new attack surface involving tricking the filesystem
into thinking it has readable data beyond EOF. And because it can
now read from the "write only" region beyond EOF (because that's the
mechanism by which fsverity does it's verification) we no longer
have a clear line of protection against exposing such data to
userspace.

Putting the merkel tree somewhere else in the filesystem metadata
and providing a separate API to manipulate it avoids this problem.
It allows filesystems to keep their internal metadata and
security-related verification information in a separate channel (and
trust path) that is completely out of user data/access scope.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
