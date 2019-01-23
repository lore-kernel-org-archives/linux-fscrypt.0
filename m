Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr760124.outbound.protection.outlook.com ([40.107.76.124]:57216
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725899AbfAWFK0 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 23 Jan 2019 00:10:26 -0500
Date: Wed, 23 Jan 2019 00:10:17 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: Proposal: A new fs-verity interface
Message-ID: <20190123051017.GA8785@mit.edu>
References: <20190110051500.GA32361@mit.edu>
 <20190114234101.GQ27534@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190114234101.GQ27534@dastard>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

Apologies for the delay in getting responding; I've been on vacation
last week.

On Tue, Jan 15, 2019 at 10:41:01AM +1100, Dave Chinner wrote:
> > int ioctl(fd, FS_IOC_ENABLE_VERITY, struct fsverity_arg *arg);
> > 
> > struct fsverity_arg {
> >        int fsv_donor_fd;
> >        u64 fsv_offset;
> >        u64 fsv_size;
> > };
> > 
> > fsv_offset and fsz_size must be a multiple of the file system block
> > size.  If the ioctl comples successfully, as a side effect the
> > donor_fd will have a hole punch operation on the specified range.  In
> > other words, the equivalent of operation of fallocate(fsv_donor_fd,
> > FALLOC_FL_PUNCH_HOLE, fsv_offset, fsv_size), and the file specified by
> > fd will be protected using fsverity.
> 
> makes no sense to me. What's in {offset, size} and why do you need
> to call this on that specific range? If it is the equivalent of a
> hole punch, then why wouldn't you just use FALLOC_FL_PUNCH_HOLE?

This is how we transfer the metadata (e.g., the Merkle tree plus a
header block) from userspace to the file system.  In the original
interface, the verity metadata was appended end of the data file, and
then an ioctl would transfer the metadata to the file system.  For
ext4 and f2fs, we actually store the fsverity metadata after the data
blocks and simply adjust i_size visible to userspace so the metadata
blocks are "invisible".

You objected to this interface, because it was too tightly tied to the
implementation used in ext4 and f2fs.  So what Darrick suggested is
that it could be conveyed by passing the metadata via a second file
descriptor.  The offset and size specifies where the metadata can be
fetched from the second file.

As in the original interface, the metadata blocks are "consumed" by
the ioctl, so they disappear from the second file, as if
FALLOC_FL_PUNCH_HOLE.  It's not that they are deallocated; the blocks
in question are simply getting transferred to inode which is being
protected using fs-verity.

> Can you please write the man page for the interface so that the
> description of what it does and how it should be used is crystal
> clear and doesn't assume the reader knows "what darrick proposed"...

I can do that, but I'd like to make sure we have general agreement
approach first.

Cheers,

						- Ted
