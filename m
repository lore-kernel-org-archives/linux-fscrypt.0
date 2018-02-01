Return-Path: <tytso@thunk.org>
Date: Thu, 1 Feb 2018 10:52:28 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fs/crypto/hooks.c: fix build with pre-4.6 gcc versions
Message-ID: <20180201155228.GA6927@thunk.org>
References: <20180119214524.222850-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119214524.222850-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jan 19, 2018 at 01:45:24PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> gcc versions prior to 4.6 require an extra level of braces when using a
> designated initializer for a member in an anonymous struct or union.
> This caused a compile error with the 'struct qstr' initialization in
> __fscrypt_encrypt_symlink().
> 
> Fix it by using QSTR_INIT().
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Fixes: 76e81d6d5048 ("fscrypt: new helper functions for ->symlink()")
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
