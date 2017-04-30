Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:21:33 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [4/6] ext4: switch to using fscrypt_match_name()
Message-ID: <20170430062133.4bdf5knrh6e72ist@thunk.org>
References: <20170424170013.85175-5-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-5-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 24, 2017 at 10:00:11AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Switch ext4 directory searches to use the fscrypt_match_name() helper
> function.  There should be no functional change.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
