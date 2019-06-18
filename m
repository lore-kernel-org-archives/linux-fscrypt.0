Date: Tue, 18 Jun 2019 09:58:49 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v4 13/16] fs-verity: support builtin file signatures
Message-ID: <20190618165849.GE184520@gmail.com>
References: <20190606155205.2872-1-ebiggers@kernel.org>
 <20190606155205.2872-14-ebiggers@kernel.org>
 <20190615152143.GN6142@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615152143.GN6142@mit.edu>
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Jun 15, 2019 at 11:21:43AM -0400, Theodore Ts'o wrote:
> On Thu, Jun 06, 2019 at 08:52:02AM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > To meet some users' needs, add optional support for having fs-verity
> > handle a portion of the authentication policy in the kernel.  An
> > ".fs-verity" keyring is created to which X.509 certificates can be
> > added; then a sysctl 'fs.verity.require_signatures' can be set to cause
> > the kernel to enforce that all fs-verity files contain a signature of
> > their file measurement by a key in this keyring.
> 
> I think it might be a good idea to allow the require_signatures
> setting to be set on a per-file system basis, via a mount option?  We
> could plumb it in via a flag in fsverity_info, set by the file system.

Perhaps, but this is something that can be added later, so I think we should
hold off on it until someone needs it.

> 
> Other than this feature request, looks good; you can add:
> 
> Reviewed-off-by: Theodore Ts'o <tytso@mit.edu>
> 

I assume you mean "Reviewed-by" :-)

- Eric
