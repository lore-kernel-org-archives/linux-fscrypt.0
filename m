Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 20:02:50 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: inline fscrypt_free_filename()
Message-ID: <20170624000250.kx7o7dwfun2akvw4@thunk.org>
References: <20170523011406.32718-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523011406.32718-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 22, 2017 at 06:14:06PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_free_filename() only needs to do a kfree() of crypto_buf.name,
> which works well as an inline function.  We can skip setting the various
> pointers to NULL, since no user cares about it (the name is always freed
> just before it goes out of scope).
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
