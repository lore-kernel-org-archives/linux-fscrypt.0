Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr800102.outbound.protection.outlook.com ([40.107.80.102]:2785
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725379AbfAJFPJ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 10 Jan 2019 00:15:09 -0500
Date: Thu, 10 Jan 2019 00:15:00 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Proposal: A new fs-verity interface
Message-ID: <20190110051500.GA32361@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

The following approach is based in Darrick's suggestion:

int ioctl(fd, FS_IOC_ENABLE_VERITY, struct fsverity_arg *arg);

struct fsverity_arg {
       int fsv_donor_fd;
       u64 fsv_offset;
       u64 fsv_size;
};

fsv_offset and fsz_size must be a multiple of the file system block
size.  If the ioctl comples successfully, as a side effect the
donor_fd will have a hole punch operation on the specified range.  In
other words, the equivalent of operation of fallocate(fsv_donor_fd,
FALLOC_FL_PUNCH_HOLE, fsv_offset, fsv_size), and the file specified by
fd will be protected using fsverity.

It will be legal for fsv_donor_fd == fd, so this interface is a
superset of the original FS_IOC_ENABLE_VERITY ioctl.

This will hopefully make Christoph and Dave happy because the
interface does not presuppose how ext4 and f2fs will implement
fsverity behind the scenes.  However, it does not forbid it, and the
net cost is that ext4 and f2fs will have to implement code which
transplants the blocks from the donor_fd to fd in the case where
donor_fd != fd --- and in the case where blocks are encrypted using
fscrypt, we will have to decrypt the blocks from donor_fd and possibly
re-encrypt then in fd's per-file key, which means we'll have to add
extra complexity to implement the decrypt and re-encrypt passing
through the page cache.

But if this helps resolve Christoph and Dave's objections, it
shouldn't be _too_ much extra complexity.  Before we go ahead an
implement it, though, I'd appreciate a confirmation that this will
indeed actually resolve their complaints.

Thanks,

					- Ted
