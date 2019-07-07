Return-Path: <SRS0=ZK/q=VE=mit.edu=tytso@kernel.org>
Date: Sun, 7 Jul 2019 14:54:18 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v6 15/17] ext4: add fs-verity read support
Message-ID: <20190707185418.GD19775@mit.edu>
References: <20190701153237.1777-1-ebiggers@kernel.org>
 <20190701153237.1777-16-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701153237.1777-16-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 01, 2019 at 08:32:35AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Make ext4_mpage_readpages() verify data as it is read from fs-verity
> files, using the helper functions from fs/verity/.
> 
> To support both encryption and verity simultaneously, this required
> refactoring the decryption workflow into a generic "post-read
> processing" workflow which can do decryption, verification, or both.
> 
> The case where the ext4 block size is not equal to the PAGE_SIZE is not
> supported yet, since in that case ext4_mpage_readpages() sometimes falls
> back to block_read_full_page(), which does not support fs-verity yet.
> 
> Co-developed-by: Theodore Ts'o <tytso@mit.edu>
> Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good.  Since there's a S-o-B, some might claim that a
Reviewed-by: is not necessary, but to the extent that you modified
this code as well:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

							- Ted
