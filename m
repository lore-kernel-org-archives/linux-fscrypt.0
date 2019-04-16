Return-Path: <SRS0=RJsC=SS=mit.edu=tytso@kernel.org>
Date: Tue, 16 Apr 2019 18:38:00 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: drop inode argument from fscrypt_get_ctx()
Message-ID: <20190416223800.GA4053@mit.edu>
References: <20190318172333.239937-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190318172333.239937-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 18, 2019 at 10:23:33AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> The only reason the inode is being passed to fscrypt_get_ctx() is to
> verify that the encryption key is available.  However, all callers
> already ensure this because if we get as far as trying to do I/O to an
> encrypted file without the key, there's already a bug.
> 
> Therefore, remove this unnecessary argument.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
