Return-Path: <SRS0=NhUw=SM=ftp.linux.org.uk=viro@kernel.org>
Date: Wed, 10 Apr 2019 05:31:35 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH] fscrypt: cache decrypted symlink target in ->i_link
Message-ID: <20190410043135.GX2217@ZenIV.linux.org.uk>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
 <20190410010425.GU2217@ZenIV.linux.org.uk>
 <20190410012247.GB2454@sol.localdomain>
 <20190410013934.GV2217@ZenIV.linux.org.uk>
 <20190410025808.GA7140@sol.localdomain>
 <20190410034414.GW2217@ZenIV.linux.org.uk>
 <20190410040413.GC7140@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410040413.GC7140@sol.localdomain>
Sender: Al Viro <viro@ftp.linux.org.uk>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 09, 2019 at 09:04:15PM -0700, Eric Biggers wrote:

> > What's to stop you from doing just that right now?  You'd need to take
> > care with barriers, but you'd need that anyway... As soon as ->i_link is set
> > you'll get no more ->get_link() on that sucker, using the cached value
> > from that point on.  IDGI...
> 
> 1.) The VFS won't know to drop of RCU-walk mode, so waiting an RCU grace period
>     before freeing the symlink target becomes mandatory.  (Which I'd like to do
>     for fscrypt anyway, but doing it sanely appears to require implementing
>     .destroy_inode() for ext4, f2fs, and ubifs.  I hoped I could do non-RCU mode
>     as a simpler first step.)

You might want to check those filesystems.  All three you've mentioned *have*
->destroy_inode() already.
 
> 2.) The VFS won't know to use a read memory barrier when loading i_link.
>     The VFS could issue one unconditionally, but it would be unnecessary for
>     regular fast symlinks.

Not really.  All we need on the read side is READ_ONCE(); it will supply
smp_read_barrier_depends() (which is a no-op except for alpha).  On the
write side we need smp_store_release() to set ->i_link (in addition to
whatever serialization we want for actual calculation of the value to
be cached, of course).
