Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:16:02 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: fscrypt: remove unnecessary checks for NULL operations
Message-ID: <20170430061602.gzmagwz7z7pc2guy@thunk.org>
References: <20170404213941.113427-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404213941.113427-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 04, 2017 at 02:39:41PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> The functions in fs/crypto/*.c are only called by filesystems configured
> with encryption support.  Since the ->get_context(), ->set_context(),
> and ->empty_dir() operations are always provided in that case (and must
> be, otherwise there would be no way to get/set encryption policies, or
> in the case of ->get_context() even access encrypted files at all),
> there is no need to check for these operations being NULL and we can
> remove these unneeded checks.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> Reviewed-by: Richard Weinberger <richard@nod.at>

Thanks, applied.

						- Ted
