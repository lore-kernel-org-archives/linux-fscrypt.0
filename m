Return-Path: <tytso@thunk.org>
Date: Thu, 11 Jan 2018 23:33:38 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2 00/11] fscrypt: symlink helpers and fscrypt.h cleanup
Message-ID: <20180112043338.GA8249@thunk.org>
References: <20180105184502.48473-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180105184502.48473-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

I've taken the v2 version of this series, plus the ext4-specific
patches to use the new symlink helpers (from the v1 patch series).
After testing and validating them, I included the patches to convert
f2fs and ubifs to use the symlink helpers, so I could also grab the
cleanup patches from the V1 series.

Jaeguk, Richard, please let me know if you are OK with my taking the
f2fs and ubifs changes in the fscrypt tree.  It seems like it would
keep things simpler if we did that.

Cheers,

						- Ted
