Return-Path: <SRS0=ZK/q=VE=mit.edu=tytso@kernel.org>
Date: Sun, 7 Jul 2019 14:47:11 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v6 13/17] fs-verity: support builtin file signatures
Message-ID: <20190707184711.GB19775@mit.edu>
References: <20190701153237.1777-1-ebiggers@kernel.org>
 <20190701153237.1777-14-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701153237.1777-14-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jul 01, 2019 at 08:32:33AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> To meet some users' needs, add optional support for having fs-verity
> handle a portion of the authentication policy in the kernel.  An
> ".fs-verity" keyring is created to which X.509 certificates can be
> added; then a sysctl 'fs.verity.require_signatures' can be set to cause
> the kernel to enforce that all fs-verity files contain a signature of
> their file measurement by a key in this keyring.
> 
> See the "Built-in signature verification" section of
> Documentation/filesystems/fsverity.rst for the full documentation.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, you can add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
