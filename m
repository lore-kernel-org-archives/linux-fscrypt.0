Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40404 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726585AbfDKR2s (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 11 Apr 2019 13:28:48 -0400
Date: Thu, 11 Apr 2019 10:28:45 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 1/2] vfs: use READ_ONCE() to access ->i_link
Message-ID: <20190411172844.GA225654@gmail.com>
References: <20190410202115.64501-1-ebiggers@kernel.org>
 <20190410202115.64501-2-ebiggers@kernel.org>
 <20190410210657.GA2217@ZenIV.linux.org.uk>
 <20190410231547.GC120258@gmail.com>
 <20190411022514.GC2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411022514.GC2217@ZenIV.linux.org.uk>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 11, 2019 at 03:25:15AM +0100, Al Viro wrote:
> On Wed, Apr 10, 2019 at 04:15:48PM -0700, Eric Biggers wrote:
> > On Wed, Apr 10, 2019 at 10:06:57PM +0100, Al Viro wrote:
> > > On Wed, Apr 10, 2019 at 01:21:14PM -0700, Eric Biggers wrote:
> > > > From: Eric Biggers <ebiggers@google.com>
> > > > 
> > > > Use 'READ_ONCE(inode->i_link)' to explicitly support filesystems caching
> > > > the symlink target in ->i_link later if it was unavailable at iget()
> > > > time, or wasn't easily available.  I'll be doing this in fscrypt, to
> > > > improve the performance of encrypted symlinks on ext4, f2fs, and ubifs.
> > > > 
> > > > ->i_link will start NULL and may later be set to a non-NULL value by a
> > > > smp_store_release() or cmpxchg_release().  READ_ONCE() is needed on the
> > > > read side.  smp_load_acquire() is unnecessary because only a data
> > > > dependency barrier is required.  (Thanks to Al for pointing this out.)
> > > 
> > > You've missed vfs_readlink()...
> > 
> > How so?  The patch already updates vfs_readlink().
> 
> Huh?  Right you are - fsck knows how have I managed to misread that...
> Anyway, I can pick that READ_ONCE() patch through vfs.git if you wish,
> or it can go through your tree with my Acked-by - up to you...

Unless you expect merge conflicts, it's easier for me to take it through the
fscrypt tree, since it's a small patch and the second patch technically isn't
correct without it.  I'll add your Acked-by.

Are you planning to review the second patch too?

Thanks!

- Eric
