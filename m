Return-Path: <tytso@thunk.org>
Date: Mon, 6 Feb 2017 23:39:39 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: split supp and notsupp declarations into their
 own headers
Message-ID: <20170207043938.52b4ta3pt6xyjlel@thunk.org>
References: <20170124185806.125261-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124185806.125261-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jan 24, 2017 at 10:58:06AM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Previously, each filesystem configured without encryption support would
> define all the public fscrypt functions to their notsupp_* stubs.  This
> list of #defines had to be updated in every filesystem whenever a change
> was made to the public fscrypt functions.  To make things more
> maintainable now that we have three filesystems using fscrypt, split the
> old header fscrypto.h into several new headers.  fscrypt_supp.h contains
> the real declarations and is included by filesystems when configured
> with encryption support, whereas fscrypt_notsupp.h contains the inline
> stubs and is included by filesystems when configured without encryption
> support.  fscrypt_common.h contains common declarations needed by both.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Nice.  Thanks, applied.

					- Ted
