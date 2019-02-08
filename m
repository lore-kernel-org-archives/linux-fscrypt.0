Return-Path: <SRS0=Me/d=QP=HansenPartnership.com=James.Bottomley@kernel.org>
Message-ID: <1549653008.3647.8.camel@HansenPartnership.com>
Subject: Re: Proposal: Yet another possible fs-verity interface
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 08 Feb 2019 14:10:08 -0500
In-Reply-To: <20190207031101.GA7387@mit.edu>
References: <20190207031101.GA7387@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Mimi Zohar <zohar@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, 2019-02-06 at 22:11 -0500, Theodore Y. Ts'o wrote:
> After doing a lot of thinking and conferring with the other fs-verity
> developers, our current thinking is to simply move the Merkle tree
> creation into the kernel.  The upside of doing this is it completely
> bypasses all of the complaints about how to transfer the Merkle tree
> from userspace to the kernel.  It avoids the complexities of
> redesigning the xattr interface, or creating a magic fd which could
> be lseek'ed, mmap'ed, read, written, etc. to transfer the Merkle
> tree, etc.  Calculating the Merkle tree from a code complexity is
> going to be simpler.

I'm happy with this but, as I asked before when something like this was
proposed: can this now become part of IMA?  We simply write an IMA hash
or signature which is a possibly signed top of merkle tree hash (we'll
need a new IMA hash format for this).  The act of writing the xattr
triggers the merkle tree build, how (or indeed whether) the kernel
caches the tree is a fs dependent detail and if the fs can't cache it,
the tree would be reconstructed on first use after a reboot.

> The downside of this approach is that it can take a lot of CPU time
> in the kernel (it would have to do be done in a kernel thread).  An
> extra bit of complication is worrying about how to handle the
> situationwhere if the kernel crashes.

I think this would be up to the fs, but the semantic expectation could
be that the whole thing gets erased and we retry on next use, or the fs
uses a fs dependent mechanism to cache the partially constructed tree
and completes the construction on next use.

>   The current thinking is that the ioctl which enable fs-verity
> protection on the file will make sure that the file descriptor is not
> otherwise opened for writing, and then set the immutable bit. 

If you simply use standard IMA xattrs, you don't need an ioctl ... you
actually now don't need the file to be immutable (although you could
additionally make it so if you wanted): IMA signed files are
effectively immutable because you must update both the contents and the
signature for the file to verify.

James

> Once the Merkle tree is written and finalized,
> the fs-verity flag would be set and the immutable bit would be
> cleared. The exact mechanisms of crash recovery would be file-system
> dependent, and TBD, but would probably rely on the journalling
> mechanisms available (e.g., ext4 might rely on the orphan list; f2fs
> might use copy-on-write semantics; etc.)

I think all that is per-fs semantics that don't need to be specified
for the generic implementation.  I'd be happy with a write to the file
causing a halt to the construction and a reconstruction not starting
until the xattr is updated.

> This effectively moves the complexity from the interface (which is
> where we seem to be getting hung up) to the implementation, but as
> stated above, the actual code to create a Merkle tree is fairly
> simple.
> 
> Hopefully this will cut through the current complaints of the
> fs-verity API.
