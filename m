Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Date: Thu, 24 Jan 2019 18:22:37 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: Proposal: A new fs-verity interface
Message-ID: <20190124232237.GH8785@mit.edu>
References: <20190110051500.GA32361@mit.edu>
 <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu>
 <20190124212544.GS6173@dastard>
 <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 25, 2019 at 10:40:31AM +1300, Linus Torvalds wrote:
> 
> I _assume_ (but it's exactly that - just an assumption) this whole
> design decision comes from basically having a transport layer that is
> entirely unaware of the merle data, so the data  is brought in some
> entirely traditional way that can only transfer regular file contents
> (ie tar/zip/ar kind of thing, but presumably actually just in the form
> of an android APK). And then the new interface is just a way to
> "convert" that into the actual final security model.

How the transport layer is going to send the merkle data is really
unrelated (e.g., it's not necessarily going to be at the end of the
file data).

> One thing that is also unclear to me is whether that "secure" model
> needs to be stable on disk (ie is this considered an actual write that
> *modifies* the underlying filesystem, and the merkle tree data ends up
> being associated long-term and over reboots), or whether it would be
> acceptable to just have it be a temporary "view" of the file where the
> filesystem itself can be read-only, and all that happens is that now
> the merkle tree is associated with that file as long as the filesystem
> is mounted (or until it is disassociated).

It's the first.  We need to keep the Merkle tree and associated
metadata information (which might include a PKCS 7 digital signature)
permanently associated with the file.  So it has to be stored in the
file; it's associated metadata.

> Maybe this was answered in some of the earlier email threads that (at
> least for me) were then somewhat overshadowed by the merge window work
> and the holidays. So it's possible that I repeat myself. But I do have
> to say that I think I'd *still* prefer this to be something more like
> an xattr, and that maybe we'd be better off actually improving out
> "write to xattr" interface or something.

The main issue is that for a 129 MB file, the Merkle data is going to
be a Megabyte.  So using a set/get interface, ala our current xattr
interface, seems awkward.  Also, currently for most file systems,
xattrs are limited in size to around 4k to 32k, and most xattrs
relatively small (e.g., SELinux labels, ACL's).  So even if we used
the xattr interface, for many file systems, for something that might
be 1 megabyte (for a 129 MB file to be protected by fs-verity), it
would almost certainly be stored in a different location than other
xattrs.  So similarly, changing our attr interfaces for big blobs,
when the vast majority of xattrs are small ones, doesn't seem to be a
great use of time.

The other thing I'll point out is that file system developers
generally have frowned on using setting xattrs having magic side
effects, since that would mean making the xattr set/get interface
acting more lke an ioctl.  When we make an file to become fs-verity
protected, it does have a side-effect of making the file immutable.
That's not a huge side-effect, but that's another reason where it
feels like the xattr interface seems like the wrong effort.

> I understand that you don't want to load the whole merkle tree into
> memory, and that is the reason that you want to point to some "stable
> on disk" area, but the hole punching does seem to be a particularly
> nasty part of it. It would be much better to have the merkle data in
> some place where it doesn't then need to be hidden again, no?

It's not really a "hole punch", but we are moving the data around.
That's because Dave Chinner and Christoph demanded it.  The original
approach was to put it at the end of the file, and then hide it.  If
the question is "why hide the metadata", it's because it's metadata.
We certainly don't want to make it be visible as part of the file
stream.

We could store the metadata somewhere else --- for example, we could
store it in another inode.  But inodes have overhead, and that would
mean using two inodes for every fs-verity protected files --- and we
don't need all of the other metadata (mtime, ctime, etc.) for the
Merkle tree.  So that's how we got to where we were.  I think the
approach of storing it using the same extent tree where we map logical
block numbers to physical block numbers make a lot of sense for ext4
and f2fs.

It seems that some file system (which may never even implement
fs-verity) their developers hate that particular approach.  So that's
where the suggestion of using a separate file descriptor to convey the
Merkle tree data to the file system came from.  It wasn't my first
choice.

						- Ted
