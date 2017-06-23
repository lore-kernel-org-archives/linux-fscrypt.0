Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 19:46:27 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 1/4] ext4: don't bother checking for encryption key in
 ->mmap()
Message-ID: <20170623234627.ok4ge3lldrieknq4@thunk.org>
References: <20170523003945.14279-1-ebiggers3@gmail.com>
 <20170523003945.14279-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523003945.14279-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 22, 2017 at 05:39:42PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Since only an open file can be mmap'ed, and we only allow open()ing an
> encrypted file when its key is available, there is no need to check for
> the key again before permitting each mmap().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
