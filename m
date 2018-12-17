Return-Path: <SRS0=r8po=O2=oracle.com=darrick.wong@kernel.org>
Date: Mon, 17 Dec 2018 12:00:39 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181217200039.GD8111@magnolia>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214044802.GA681@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 13, 2018 at 08:48:03PM -0800, Eric Biggers wrote:
> Hi Christoph,
> 
> On Thu, Dec 13, 2018 at 12:22:49PM -0800, Christoph Hellwig wrote:
> > On Wed, Dec 12, 2018 at 12:26:10PM -0800, Eric Biggers wrote:
> > > > As this apparently got merged despite no proper reviews from VFS
> > > > level persons:
> > > 
> > > fs-verity has been out for review since August, and Cc'ed to all relevant
> > > mailing lists including linux-fsdevel, linux-ext4, linux-f2fs-devel,
> > > linux-fscrypt, linux-integrity, and linux-kernel.  There are tests,
> > > documentation (since v2), and a userspace tool.  It's also been presented at
> > > multiple conferences, and has been covered by LWN multiple times.  If more
> > > people want to review it, then they should do so; there's nothing stopping them.
> > 
> > But you did not got a review from someone like Al, Linus, Andrew or me,
> > did you?
> 
> Sure, those specific people (modulo you just now) haven't responded to the
> fs-verity patches yet.  But again, the patches have been out for review for
> months.  Of course, we always prefer more reviews over fewer, and we strongly
> encourage anyone interested to review fs-verity!  (The Documentation/ file may
> be a good place to start.)  But ultimately we cannot force reviews, and as you
> know kernel reviews can be very hard to come by.  Yet, people still need
> fs-verity anyway; it isn't just some toy.  And we're committed to maintaining
> it, similar to fscrypt.  The ext4 and f2fs maintainers are also satisfied with
> the current approach to storing the verity metadata past EOF; in fact it was
> even originally Ted's idea, I think.
> 
> > 
> > > Can you elaborate on the actual problems you think the current solution has, and
> > > exactly what solution you'd prefer instead?  Keep in mind that (1) for large
> > > files the Merkle tree can be gigabytes long, (2) Linux doesn't have an API for
> > > file streams, and (3) when fs-verity is combined with fscrypt, it's important
> > > that the hashes be encrypted, so as to not leak information about the plaintext.
> > 
> > Given that you alread use an ioctl as the interface what is the problem
> > of passing this data through the ioctl?
> 
> Do you mean pass the verity metadata in a buffer?  That cannot work in general,
> because it may be too large to fit into memory.
> 
> Or do you mean pass it via a second file descriptor?  That could work, but it
> doesn't seem better than the current approach.  It would force every filesystem
> to move the metadata around, whereas currently ext4 and f2fs can simply leave it
> in place.  If you meant this, are there advantages you have in mind that would
> outweigh this?

FWIW, if I were (hypothetically) working on an xfs implementation, I
likely would have settled on passing a reference to a merkle tree
through a (fd, length) pair, because that allows us plenty of options
on the back end:

b) we could remap the tree into a new inode fork for merkle trees, or
a) remap it as posteof blocks like ext4/f2fs does, or
c) remap the blocks into the attribute fork as an (unusually large)
extended attribute value.

If the merkle_fd isn't on the same filesystem as the fd we could at
least use generic_copy_file_range (i.e. page cache copying) to land the
merkle tree wherever we want.

Granted, it's not like we can't do any of those three things given the
current interface.  I gather most of the grumbling has to do with
feeling like we're associating the on-disk format to the ioctl interface
too closely?

I certainly can see why you'd want to avoid having to run a whole bunch
of SWAPEXT operations to set up a verity file, though.

Anyhow, that's just my 2 cents.  :)

--D

> We also considered generating the Merkle tree in the kernel, in which case
> FS_IOC_ENABLE_VERITY would just take a small structure similar to the current
> fsverity_descriptor.  But that would add extra complexity to the kernel, and
> generating a Merkle tree over a large file is the type of parallelizable, CPU
> intensive work that really should be done in userspace.  Also, having userspace
> provide the Merkle tree allows for it to be pre-generated and distributed with
> the file, e.g. provided in a package to be installed on many systems.
> 
> But please do let us know if you have any better ideas.
> 
> Thanks!
> 
> - Eric
