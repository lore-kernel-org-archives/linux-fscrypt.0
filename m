Return-Path: <SRS0=RJsC=SS=mit.edu=tytso@kernel.org>
Date: Tue, 16 Apr 2019 18:57:25 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2] fscrypt: use READ_ONCE() to access ->i_crypt_info
Message-ID: <20190416225725.GA14623@mit.edu>
References: <20190411213215.163929-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411213215.163929-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 11, 2019 at 02:32:15PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> ->i_crypt_info starts out NULL and may later be locklessly set to a
> non-NULL value by the cmpxchg() in fscrypt_get_encryption_info().
> 
> But ->i_crypt_info is used directly, which technically is incorrect.
> It's a data race, and it doesn't include the data dependency barrier
> needed to safely dereference the pointer on at least one architecture.
> 
> Fix this by using READ_ONCE() instead.  Note: we don't need to use
> smp_load_acquire(), since dereferencing the pointer only requires a data
> dependency barrier, which is already included in READ_ONCE().  We also
> don't need READ_ONCE() in places where ->i_crypt_info is unconditionally
> dereferenced, since it must have already been checked.
> 
> Also downgrade the cmpxchg() to cmpxchg_release(), since RELEASE
> semantics are sufficient on the write side.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
