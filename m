Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:19:22 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [1/6] f2fs: check entire encrypted bigname when finding a dentry
Message-ID: <20170430061922.djpzcguihke4o4lo@thunk.org>
References: <20170424170013.85175-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424170013.85175-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 24, 2017 at 10:00:08AM -0700, Eric Biggers wrote:
> From: Jaegeuk Kim <jaegeuk@kernel.org>
> 
> If user has no key under an encrypted dir, fscrypt gives digested dentries.
> Previously, when looking up a dentry, f2fs only checks its hash value with
> first 4 bytes of the digested dentry, which didn't handle hash collisions fully.
> This patch enhances to check entire dentry bytes likewise ext4.
> 
> Eric reported how to reproduce this issue by:
> 
>  # seq -f "edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
>  # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 100000
>  # sync
>  # echo 3 > /proc/sys/vm/drop_caches
>  # keyctl new_session
>  # find edir -type f | xargs stat -c %i | sort | uniq | wc -l
> 99999
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Eric Biggers <ebiggers@google.com>
> Signed-off-by: Jaegeuk Kim <jaegeuk@kernel.org>
> (fixed f2fs_dentry_hash() to work even when the hash is 0)
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied to the fscrypt tree.

					- Ted
