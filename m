Return-Path: <SRS0=Gb8R=QQ=linuxfoundation.org=torvalds@kernel.org>
MIME-Version: 1.0
References: <20190207031101.GA7387@mit.edu>
In-Reply-To: <20190207031101.GA7387@mit.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 9 Feb 2019 12:38:05 -0800
Message-ID: <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
Subject: Re: Proposal: Yet another possible fs-verity interface
Content-Type: text/plain; charset="UTF-8"
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Feb 7, 2019 at 8:10 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> After doing a lot of thinking and conferring with the other fs-verity
> developers, our current thinking is to simply move the Merkle tree
> creation into the kernel.  The upside of doing this is it completely
> bypasses all of the complaints about how to transfer the Merkle tree
> from userspace to the kernel.

This sounds very sane to me.

In particular, may I suggest that  the interface be made idempotent,
so that you can do the merkle tree operation several times with the
same offset/length arguments, and if the merkle tree has already been
calculated, you just return the resulting root hash directly.

Why? That allows you to "validate" images on filesystems that don't
actually have any long-term storage model for the merkle tree. IOW,
you could do the merkle tree calculation (and verification) every time
at bootup, and on a filesystem that supports the long-term storage of
said merkle data, it's a very cheap operation, but on a filesystem
that doesn't, it would still be *possible* to just calculate the hash
and mark it "finalized" for that boot (or that mount). IOW, it would
work for something like ramfs (but you could also make it work for any
random on-disk filesystem that doesn't support long-term storage).

At that point, the merkle tree thing ends up fairly equivalent to the
IMA "measurement" thing, with the exception that the filesystem *may*
optimize it to be long-term. Hmm?

Now, since I assume that only the merkle tree root hash would be
returned by the "enable merkle tree" operation (so that the code
enabling it can verify that the hash matches the expected value), you
do have to worry about the preimage attack, and make sure that you
can't fool the hashing by making the (bad) file contents themselves be
just the hashes of the (good) blocks. So each level of the merkle tree
needs to have a hash seeding thing or whatever.

              Linus
