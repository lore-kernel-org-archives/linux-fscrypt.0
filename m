Return-Path: <tytso@thunk.org>
Date: Sun, 30 Apr 2017 02:18:07 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [3/4] f2fs: sync f2fs_lookup() with ext4_lookup()
Message-ID: <20170430061807.nr3umyjvzb2ofvoq@thunk.org>
References: <20170407175840.95740-4-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407175840.95740-4-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Apr 07, 2017 at 10:58:39AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> As for ext4, now that fscrypt_has_permitted_context() correctly handles
> the case where we have the key for the parent directory but not the
> child, f2fs_lookup() no longer has to work around it.  Also add the same
> warning message that ext4 uses.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
