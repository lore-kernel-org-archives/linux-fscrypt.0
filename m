Return-Path: <SRS0=9ysd=QR=linux.ibm.com=zohar@kernel.org>
Subject: Re: Proposal: Yet another possible fs-verity interface
From: Mimi Zohar <zohar@linux.ibm.com>
Date: Sun, 10 Feb 2019 09:06:55 -0500
In-Reply-To: <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
References: <20190207031101.GA7387@mit.edu>
	 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <1549807615.12743.109.camel@linux.ibm.com>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, James Bottomley <James.Bottomley@HansenPartnership.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, 2019-02-09 at 12:38 -0800, Linus Torvalds wrote:
> On Thu, Feb 7, 2019 at 8:10 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
> >
> > After doing a lot of thinking and conferring with the other fs-verity
> > developers, our current thinking is to simply move the Merkle tree
> > creation into the kernel.  The upside of doing this is it completely
> > bypasses all of the complaints about how to transfer the Merkle tree
> > from userspace to the kernel.
> 
> This sounds very sane to me.

One of the more interesting use cases for fs-verity, at least to me,
was remote file systems.  Hopefully support for remote file systems
will be included in the new design.

> 
> In particular, may I suggest that  the interface be made idempotent,
> so that you can do the merkle tree operation several times with the
> same offset/length arguments, and if the merkle tree has already been
> calculated, you just return the resulting root hash directly.
> 
> Why? That allows you to "validate" images on filesystems that don't
> actually have any long-term storage model for the merkle tree. IOW,
> you could do the merkle tree calculation (and verification) every time
> at bootup, and on a filesystem that supports the long-term storage of
> said merkle data, it's a very cheap operation, but on a filesystem
> that doesn't, it would still be *possible* to just calculate the hash
> and mark it "finalized" for that boot (or that mount). IOW, it would
> work for something like ramfs (but you could also make it work for any
> random on-disk filesystem that doesn't support long-term storage).

For which files will the Merkle tree be created?  Is this for all
files on a per file system basis?  Or is there some sort of "flag" or
policy?  The original design was based on an ioctl enabling/disabling
a flag.  In this new design, is there still an ioctl?

> 
> At that point, the merkle tree thing ends up fairly equivalent to the
> IMA "measurement" thing, with the exception that the filesystem *may*
> optimize it to be long-term. Hmm?

Wouldn't fs-verity then be similar to IMA-appraisal?  Instead of
verifying the file hash, fs-verity verifies the Merkle tree file root
hash.  The file "measurement", in this case the Merkle tree file root
hash, could be used to extend the TPM and added to a measurement list
or in TCG terminology an event log.

> 
> Now, since I assume that only the merkle tree root hash would be
> returned by the "enable merkle tree" operation (so that the code
> enabling it can verify that the hash matches the expected value), you
> do have to worry about the preimage attack, and make sure that you
> can't fool the hashing by making the (bad) file contents themselves be
> just the hashes of the (good) blocks. So each level of the merkle tree
> needs to have a hash seeding thing or whatever.

Agreed, but wouldn't the Merkle tree file root hash then be system
specific?

The existing file hashes included in the measurement list and the
audit log, are currently being used for remote attestation, forensics
and security analytics.

Mimi
