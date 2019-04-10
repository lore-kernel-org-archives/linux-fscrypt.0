Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53580 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726713AbfDJXPu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 10 Apr 2019 19:15:50 -0400
Date: Wed, 10 Apr 2019 16:15:48 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 1/2] vfs: use READ_ONCE() to access ->i_link
Message-ID: <20190410231547.GC120258@gmail.com>
References: <20190410202115.64501-1-ebiggers@kernel.org>
 <20190410202115.64501-2-ebiggers@kernel.org>
 <20190410210657.GA2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410210657.GA2217@ZenIV.linux.org.uk>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 10, 2019 at 10:06:57PM +0100, Al Viro wrote:
> On Wed, Apr 10, 2019 at 01:21:14PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Use 'READ_ONCE(inode->i_link)' to explicitly support filesystems caching
> > the symlink target in ->i_link later if it was unavailable at iget()
> > time, or wasn't easily available.  I'll be doing this in fscrypt, to
> > improve the performance of encrypted symlinks on ext4, f2fs, and ubifs.
> > 
> > ->i_link will start NULL and may later be set to a non-NULL value by a
> > smp_store_release() or cmpxchg_release().  READ_ONCE() is needed on the
> > read side.  smp_load_acquire() is unnecessary because only a data
> > dependency barrier is required.  (Thanks to Al for pointing this out.)
> 
> You've missed vfs_readlink()...

How so?  The patch already updates vfs_readlink().

- Eric
