Return-Path: <SRS0=pbj0=OV=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Wed, 12 Dec 2018 12:26:10 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181212202609.GA193967@gmail.com>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212091406.GA31723@infradead.org>
Sender: linux-integrity-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Christoph,

On Wed, Dec 12, 2018 at 01:14:06AM -0800, Christoph Hellwig wrote:
> As this apparently got merged despite no proper reviews from VFS
> level persons:

fs-verity has been out for review since August, and Cc'ed to all relevant
mailing lists including linux-fsdevel, linux-ext4, linux-f2fs-devel,
linux-fscrypt, linux-integrity, and linux-kernel.  There are tests,
documentation (since v2), and a userspace tool.  It's also been presented at
multiple conferences, and has been covered by LWN multiple times.  If more
people want to review it, then they should do so; there's nothing stopping them.

> 
> NAK - the ioctl format that expects the verifycation hash in the file
> data data with padding after the real data is simply not acceptable,
> we can't just transform the data in the file itself based on a magic
> calls like this.
> 

Can you elaborate on the actual problems you think the current solution has, and
exactly what solution you'd prefer instead?  Keep in mind that (1) for large
files the Merkle tree can be gigabytes long, (2) Linux doesn't have an API for
file streams, and (3) when fs-verity is combined with fscrypt, it's important
that the hashes be encrypted, so as to not leak information about the plaintext.

> Also the core code should not depend on this as a storage format,
> which is a rather bad idea.  In any modern file system you can
> store data like this out of line in something like the attr fork
> in XFS, or the attr items in btrfs.

As explained in the documentation, the core code uses the "metadata after EOF"
format for the API, but not necessarily the on-disk format.  I.e.,
FS_IOC_ENABLE_VERITY requires it, but during the ioctl the filesystem can choose
to move the metadata into a different location, such as a file stream.

We'd just need to update fsverity_read_metadata_page() and
compute_tree_depth_and_offsets() to call out to the filesystem's
fsverity_operations to read a metadata page and get the offset of the first
metadata page, respectively.  The rest of fs/verity/ will still work.  I'd be
glad to add those two fsverity_operations now, though they're not needed for
ext4 and f2fs, if it would help clarify things further.

Thanks,

- Eric
