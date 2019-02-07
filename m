Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr730110.outbound.protection.outlook.com ([40.107.73.110]:59120
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726171AbfBGQKR (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 7 Feb 2019 11:10:17 -0500
Date: Wed, 6 Feb 2019 22:11:01 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Proposal: Yet another possible fs-verity interface
Message-ID: <20190207031101.GA7387@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

After doing a lot of thinking and conferring with the other fs-verity
developers, our current thinking is to simply move the Merkle tree
creation into the kernel.  The upside of doing this is it completely
bypasses all of the complaints about how to transfer the Merkle tree
from userspace to the kernel.  It avoids the complexities of
redesigning the xattr interface, or creating a magic fd which could be
lseek'ed, mmap'ed, read, written, etc. to transfer the Merkle tree,
etc.  Calculating the Merkle tree from a code complexity is going to
be simpler.

The downside of this approach is that it can take a lot of CPU time in
the kernel (it would have to do be done in a kernel thread).  An extra
bit of complication is worrying about how to handle the situation
where if the kernel crashes.  The current thinking is that the ioctl
which enable fs-verity protection on the file will make sure that the
file descriptor is not otherwise opened for writing, and then set the
immutable bit.  Once the Merkle tree is written and finalized, the
fs-verity flag would be set and the immutable bit would be cleared.
The exact mechanisms of crash recovery would be file-system dependent,
and TBD, but would probably rely on the journalling mechanisms
available (e.g., ext4 might rely on the orphan list; f2fs might use
copy-on-write semantics; etc.)

This effectively moves the complexity from the interface (which is
where we seem to be getting hung up) to the implementation, but as
stated above, the actual code to create a Merkle tree is fairly simple.

Hopefully this will cut through the current complaints of the
fs-verity API.

Cheers,

					- Ted
