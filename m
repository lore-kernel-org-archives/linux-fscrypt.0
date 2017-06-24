Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 20:12:50 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: fscrypt: make ->dummy_context() return bool
Message-ID: <20170624001250.lvw37hnli2xo7j2j@thunk.org>
References: <20170622191440.82025-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622191440.82025-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 22, 2017 at 12:14:40PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> This makes it consistent with ->is_encrypted(), ->empty_dir(), and
> fscrypt_dummy_context_enabled().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
