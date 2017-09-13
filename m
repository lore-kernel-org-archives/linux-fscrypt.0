Return-Path: <ebiggers3@gmail.com>
Date: Tue, 12 Sep 2017 22:22:52 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: lock mutex before checking for bounce page pool
Message-ID: <20170913052252.GA16966@zzz.localdomain>
References: <20170706175748.33093-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170706175748.33093-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jul 06, 2017 at 10:57:48AM -0700, Eric Biggers wrote:
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

Ted, can you take this patch?  On Android this bug has been causing a NULL
pointer dereference in ext4_get_encryption_info on boot.  Granted, due to the
way the code has been moved around it no longer would happen in practice in the
latest kernel, but we still need something to backport to 4.4, etc.

Eric
