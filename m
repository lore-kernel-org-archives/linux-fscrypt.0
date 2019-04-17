Return-Path: <SRS0=Zw4/=ST=mit.edu=tytso@kernel.org>
Date: Wed, 17 Apr 2019 12:55:56 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 2/2] fscrypt: cache decrypted symlink target in
 ->i_link
Message-ID: <20190417165556.GI4686@mit.edu>
References: <20190410202115.64501-1-ebiggers@kernel.org>
 <20190410202115.64501-3-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410202115.64501-3-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 10, 2019 at 01:21:15PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Path lookups that traverse encrypted symlink(s) are very slow because
> each encrypted symlink needs to be decrypted each time it's followed.
> This also involves dropping out of rcu-walk mode.
> 
> Make encrypted symlinks faster by caching the decrypted symlink target
> in ->i_link.  The first call to fscrypt_get_symlink() sets it.  Then,
> the existing VFS path lookup code uses the non-NULL ->i_link to take the
> fast path where ->get_link() isn't called, and lookups in rcu-walk mode
> remain in rcu-walk mode.
> 
> Also set ->i_link immediately when a new encrypted symlink is created.
> 
> To safely free the symlink target after an RCU grace period has elapsed,
> introduce a new function fscrypt_free_inode(), and make the relevant
> filesystems call it just before actually freeing the inode.
> 
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
