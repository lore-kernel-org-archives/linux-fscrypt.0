Return-Path: <SRS0=c4i6=UO=mit.edu=tytso@kernel.org>
Date: Sat, 15 Jun 2019 10:42:07 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v4 07/16] fs-verity: add the hook for file ->open()
Message-ID: <20190615144207.GH6142@mit.edu>
References: <20190606155205.2872-1-ebiggers@kernel.org>
 <20190606155205.2872-8-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606155205.2872-8-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 06, 2019 at 08:51:56AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add the fsverity_file_open() function, which prepares an fs-verity file
> to be read from.  If not already done, it loads the fs-verity descriptor
> from the filesystem and sets up an fsverity_info structure for the inode
> which describes the Merkle tree and contains the file measurement.  It
> also denies all attempts to open verity files for writing.
> 
> This commit also begins the include/linux/fsverity.h header, which
> declares the interface between fs/verity/ and filesystems.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good; you can add:

Reviewed-off-by: Theodore Ts'o <tytso@mit.edu>

						- Ted

> +/*
> + * Validate the given fsverity_descriptor and create a new fsverity_info from
> + * it.  The signature (if present) is also checked.
> + */
> +struct fsverity_info *fsverity_create_info(const struct inode *inode,
> +					   const void *_desc, size_t desc_size)

Well, technically it's not checked (yet).  It doesn't get checked
until [PATCH 13/16]: support builtin file signatures.  If we want to
be really nit-picky, that portion of the comment could be moved to
later in the series.
