Return-Path: <ebiggers3@gmail.com>
Date: Mon, 9 Oct 2017 13:53:00 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: lock mutex before checking for bounce page pool
Message-ID: <20171009205300.GE67463@gmail.com>
References: <20170706175748.33093-1-ebiggers3@gmail.com>
 <20170913052252.GA16966@zzz.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913052252.GA16966@zzz.localdomain>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Sep 12, 2017 at 10:22:52PM -0700, Eric Biggers wrote:
> On Thu, Jul 06, 2017 at 10:57:48AM -0700, Eric Biggers wrote:
> > fscrypt_initialize(), which allocates the global bounce page pool when
> > an encrypted file is first accessed, uses "double-checked locking" to
> > try to avoid locking fscrypt_init_mutex.  However, it doesn't use any
> > memory barriers, so it's theoretically possible for a thread to observe
> > a bounce page pool which has not been fully initialized.  This is a
> > classic bug with "double-checked locking".
> > 
> > While "only a theoretical issue" in the latest kernel, in pre-4.8
> > kernels the pointer that was checked was not even the last to be
> > initialized, so it was easily possible for a crash (NULL pointer
> > dereference) to happen.  This was changed only incidentally by the large
> > refactor to use fs/crypto/.
> > 
> > Solve both problems in a trivial way that can easily be backported: just
> > always take the mutex.  It's theoretically less efficient, but it
> > shouldn't be noticeable in practice as the mutex is only acquired very
> > briefly once per encrypted file.
> > 
> 
> Ted, can you take this patch?  On Android this bug has been causing a NULL
> pointer dereference in ext4_get_encryption_info on boot.  Granted, due to the
> way the code has been moved around it no longer would happen in practice in the
> latest kernel, but we still need something to backport to 4.4, etc.
> 
> Eric

Ping.  Ted, can you take this through the fscrypt tree?  Or should I sent a
similar patch just for 4.4-stable (and earlier), then do something fancier with
smp_store_release, smp_load_acquire, etc. for the latest version?  Personally
I'd prefer starting with the trivial fix, as it can be optimized later.

Eric
