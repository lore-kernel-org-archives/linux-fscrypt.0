Return-Path: <SRS0=NhUw=SM=ftp.linux.org.uk=viro@kernel.org>
Date: Wed, 10 Apr 2019 22:06:57 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 1/2] vfs: use READ_ONCE() to access ->i_link
Message-ID: <20190410210657.GA2217@ZenIV.linux.org.uk>
References: <20190410202115.64501-1-ebiggers@kernel.org>
 <20190410202115.64501-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410202115.64501-2-ebiggers@kernel.org>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 10, 2019 at 01:21:14PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Use 'READ_ONCE(inode->i_link)' to explicitly support filesystems caching
> the symlink target in ->i_link later if it was unavailable at iget()
> time, or wasn't easily available.  I'll be doing this in fscrypt, to
> improve the performance of encrypted symlinks on ext4, f2fs, and ubifs.
> 
> ->i_link will start NULL and may later be set to a non-NULL value by a
> smp_store_release() or cmpxchg_release().  READ_ONCE() is needed on the
> read side.  smp_load_acquire() is unnecessary because only a data
> dependency barrier is required.  (Thanks to Al for pointing this out.)

You've missed vfs_readlink()...
