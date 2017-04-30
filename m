Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:16:18 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: fscrypt: remove fscrypt_symlink_data_len()
Message-ID: <20170430061618.67itsaz56fez2ya4@thunk.org>
References: <20170404214334.113915-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404214334.113915-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 04, 2017 at 02:43:34PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_symlink_data_len() is never called and can be removed.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> Reviewed-by: Richard Weinberger <richard@nod.at>

Thanks, applied.

				- Ted
