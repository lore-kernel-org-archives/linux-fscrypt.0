Return-Path: <SRS0=vRm7=PW=fromorbit.com=david@kernel.org>
Date: Tue, 15 Jan 2019 10:41:01 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Proposal: A new fs-verity interface
Message-ID: <20190114234101.GQ27534@dastard>
References: <20190110051500.GA32361@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110051500.GA32361@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 10, 2019 at 12:15:00AM -0500, Theodore Y. Ts'o wrote:
> The following approach is based in Darrick's suggestion:

I do not recall what that was, so this:

> int ioctl(fd, FS_IOC_ENABLE_VERITY, struct fsverity_arg *arg);
> 
> struct fsverity_arg {
>        int fsv_donor_fd;
>        u64 fsv_offset;
>        u64 fsv_size;
> };
> 
> fsv_offset and fsz_size must be a multiple of the file system block
> size.  If the ioctl comples successfully, as a side effect the
> donor_fd will have a hole punch operation on the specified range.  In
> other words, the equivalent of operation of fallocate(fsv_donor_fd,
> FALLOC_FL_PUNCH_HOLE, fsv_offset, fsv_size), and the file specified by
> fd will be protected using fsverity.

makes no sense to me. What's in {offset, size} and why do you need
to call this on that specific range? If it is the equivalent of a
hole punch, then why wouldn't you just use FALLOC_FL_PUNCH_HOLE?

Can you please write the man page for the interface so that the
description of what it does and how it should be used is crystal
clear and doesn't assume the reader knows "what darrick proposed"...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
