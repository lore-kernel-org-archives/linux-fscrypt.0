Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:22:06 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [6/6] ext4: clean up ext4_match() and callers
Message-ID: <20170430062206.o2mi4r4pwe6dq3wt@thunk.org>
References: <20170424170013.85175-7-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-7-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 24, 2017 at 10:00:13AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> When ext4 encryption was originally merged, we were encrypting the
> user-specified filename in ext4_match(), introducing a lot of additional
> complexity into ext4_match() and its callers.  This has since been
> changed to encrypt the filename earlier, so we can remove the gunk
> that's no longer needed.  This more or less reverts ext4_search_dir()
> and ext4_find_dest_de() to the way they were in the v4.0 kernel.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

						- Ted
