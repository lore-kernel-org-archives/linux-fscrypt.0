Return-Path: <SRS0=2Gp4=VY=mit.edu=tytso@kernel.org>
Date: Sat, 27 Jul 2019 16:39:54 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 10/17] fs-verity: implement FS_IOC_ENABLE_VERITY ioctl
Message-ID: <20190727203954.GB1499@mit.edu>
References: <20190722165101.12840-1-ebiggers@kernel.org>
 <20190722165101.12840-11-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722165101.12840-11-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 22, 2019 at 09:50:54AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a function for filesystems to call to implement the
> FS_IOC_ENABLE_VERITY ioctl.  This ioctl enables fs-verity on a file.
> 
> See the "FS_IOC_ENABLE_VERITY" section of
> Documentation/filesystems/fsverity.rst for the documentation.
> 
> Reviewed-by: Jaegeuk Kim <jaegeuk@kernel.org>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good.  You can add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

						- Ted
