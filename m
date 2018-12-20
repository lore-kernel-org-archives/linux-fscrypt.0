Return-Path: <SRS0=V1rS=O5=mit.edu=tytso@kernel.org>
Date: Thu, 20 Dec 2018 17:01:58 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181220220158.GC2360@mit.edu>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219213552.GO6311@dastard>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 20, 2018 at 08:35:52AM +1100, Dave Chinner wrote:
> 
> The file has to be written before it has been protected, which means
> it may very well have user space allocated beyond EOF before the
> merkle tree needs to be written.

Sure, and every file system knows how to truncate a file.  This isn't
hard.

> But whether or not fsverity is enabled on the filesystem, the fact
> is that the kernel code now has to support storing and reading data
> from beyond EOF. Every user, whether they are using fsverity or not,
> is now exposed to that code and a filesystem that no longer
> considers the user data region beyond EOF as write only.

That's simply not true.  Number one, fsverity is not mandatory for all
file systems to implement.  If XFS doesn't want to implement fscrypt
or fsverity, it doesn't have to.  Number two, we're not *making* any
changes to the kernel code; nothing in mm/filemap.c, et. al.  So
saying that we are making changes that are impacted by /everyone/ just
doesn't make any sense.

> How filesystems store and retrieve merkle tree data should be a
> filesystem internal detail. If how metadata is stored in th e
> filesystem is defined by the userspace API or the kernel library
> code that implements the verification feature, then it lacks the
> necessary abstraction to be a generic Linux filesystem feature.
> IOWs, it needs to be redesigned and reworked before we should
> consider it for merging.

I disagree with your aesthetics that the interface has to be
completely isolated from the implementation.  If you don't want to
call it a generic file system feature, fine.  It can just be something
that f2fs and ext4 uses.

					- Ted
