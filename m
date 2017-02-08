Return-Path: <tytso@thunk.org>
Date: Wed, 8 Feb 2017 11:17:33 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2] fscrypt: constify struct fscrypt_operations
Message-ID: <20170208161733.3uo4jszw7aer3jop@thunk.org>
References: <20170123201646.GA3417@gmail.com>
 <20170207204210.25971-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207204210.25971-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Feb 07, 2017 at 12:42:10PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> [v2: fix conflict with .key_prefix change]
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> Reviewed-by: Richard Weinberger <richard@nod.at>

Thanks, applied.

					- Ted
