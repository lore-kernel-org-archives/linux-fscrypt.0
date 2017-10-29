Return-Path: <tytso@thunk.org>
Date: Sun, 29 Oct 2017 06:25:32 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: lock mutex before checking for bounce page pool
Message-ID: <20171029102532.cgdcymx7pqjirmbl@thunk.org>
References: <20170706175748.33093-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170706175748.33093-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jul 06, 2017 at 10:57:48AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_initialize(), which allocates the global bounce page pool when
> an encrypted file is first accessed, uses "double-checked locking" to
> try to avoid locking fscrypt_init_mutex.  However, it doesn't use any
> memory barriers, so it's theoretically possible for a thread to observe
> a bounce page pool which has not been fully initialized.  This is a
> classic bug with "double-checked locking".
> 
> While "only a theoretical issue" in the latest kernel, in pre-4.8
> kernels the pointer that was checked was not even the last to be
> initialized, so it was easily possible for a crash (NULL pointer
> dereference) to happen.  This was changed only incidentally by the large
> refactor to use fs/crypto/.
> 
> Solve both problems in a trivial way that can easily be backported: just
> always take the mutex.  It's theoretically less efficient, but it
> shouldn't be noticeable in practice as the mutex is only acquired very
> briefly once per encrypted file.
> 
> Later I'd like to make this use a helper macro like DO_ONCE().  However,
> DO_ONCE() runs in atomic context, so we'd need to add a new macro that
> allows blocking.
> 
> Cc: stable@vger.kernel.org # v4.1+
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.  Sorry for the delay; this slipped through the
cracks, and then I had a crazy travel/conference schedule.

		    	    	       	 - Ted
