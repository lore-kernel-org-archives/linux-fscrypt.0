Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:20:44 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [3/6] fscrypt: introduce helper function for filename matching
Message-ID: <20170430062044.ot34sdj7p4kc2x2a@thunk.org>
References: <20170424170013.85175-4-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-4-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 24, 2017 at 10:00:10AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Introduce a helper function fscrypt_match_name() which tests whether a
> fscrypt_name matches a directory entry.  Also clean up the magic numbers
> and document things properly.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
