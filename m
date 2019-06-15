Return-Path: <SRS0=c4i6=UO=mit.edu=tytso@kernel.org>
Date: Sat, 15 Jun 2019 11:11:36 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v4 12/16] fs-verity: add SHA-512 support
Message-ID: <20190615151136.GM6142@mit.edu>
References: <20190606155205.2872-1-ebiggers@kernel.org>
 <20190606155205.2872-13-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606155205.2872-13-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 06, 2019 at 08:52:01AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add SHA-512 support to fs-verity.  This is primarily a demonstration of
> the trivial changes needed to support a new hash algorithm in fs-verity;
> most users will still use SHA-256, due to the smaller space required to
> store the hashes.  But some users may prefer SHA-512.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good; you can add:

Reviewed-off-by: Theodore Ts'o <tytso@mit.edu>

						- Ted
