Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 9 Apr 2019 21:04:15 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190410040413.GC7140@sol.localdomain>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
 <20190410010425.GU2217@ZenIV.linux.org.uk>
 <20190410012247.GB2454@sol.localdomain>
 <20190410013934.GV2217@ZenIV.linux.org.uk>
 <20190410025808.GA7140@sol.localdomain>
 <20190410034414.GW2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190410034414.GW2217@ZenIV.linux.org.uk>
Subject: Re: [f2fs-dev] [PATCH] fscrypt: cache decrypted symlink target in
 ->i_link
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 10, 2019 at 04:44:14AM +0100, Al Viro wrote:
> On Tue, Apr 09, 2019 at 07:58:08PM -0700, Eric Biggers wrote:
> 
> > It could check a flag IOP_GET_LINK in ->i_opflags instead, so it would be the
> > same number of checks.  See patch below.
> 
> With that patch ->i_link is completely unused if ->get_link() is non-NULL,
> so you get a method call on each traversal...
> 

.get_link would be left NULL in all inode_operations that currently use
simple_get_link, then simple_get_link() would be removed.  My example patch just
changed it in ext4 as an example.

> > Benefits are that we get code that isn't actively misleading (via
> > simple_get_link() existing but actually never being called), and filesystems can
> > cache a symlink target in ->i_link if it becomes available later, i.e. if it's
> > not immediately available at iget() time.  Otherwise a filesystem-private field
> > has to be used instead.  (For fscrypt, I'd probably use fscrypt_info::ci_link.)
> 
> What's to stop you from doing just that right now?  You'd need to take
> care with barriers, but you'd need that anyway... As soon as ->i_link is set
> you'll get no more ->get_link() on that sucker, using the cached value
> from that point on.  IDGI...

1.) The VFS won't know to drop of RCU-walk mode, so waiting an RCU grace period
    before freeing the symlink target becomes mandatory.  (Which I'd like to do
    for fscrypt anyway, but doing it sanely appears to require implementing
    .destroy_inode() for ext4, f2fs, and ubifs.  I hoped I could do non-RCU mode
    as a simpler first step.)

2.) The VFS won't know to use a read memory barrier when loading i_link.
    The VFS could issue one unconditionally, but it would be unnecessary for
    regular fast symlinks.

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
