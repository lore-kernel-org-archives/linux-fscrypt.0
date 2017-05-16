Return-Path: <ebiggers3@gmail.com>
Date: Tue, 16 May 2017 15:07:09 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: Question on fscrypt_d_revalidate() and fstest generic/429
Message-ID: <20170516220709.GB113464@gmail.com>
References: <e2d845a3-a863-1506-a0de-576049c84e81@nod.at>
 <20170515194553.GA20264@gmail.com>
 <489e1437-990f-3e88-d426-b47b82441009@nod.at>
 <20170515232556.GA46783@gmail.com>
 <fbf20418-0819-b980-7b68-089e0d1c3d18@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fbf20418-0819-b980-7b68-089e0d1c3d18@nod.at>
To: Richard Weinberger <richard@nod.at>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>, David Gstir <david@sigma-star.at>, David Oberhollenzer <david.oberhollenzer@sigma-star.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Artem Bityutskiy <dedekind1@gmail.com>, Adrian Hunter <adrian.hunter@intel.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, May 16, 2017 at 08:47:43AM +0200, Richard Weinberger wrote:
> Eric,
> 
> Am 16.05.2017 um 01:25 schrieb Eric Biggers:
> > On Mon, May 15, 2017 at 09:51:03PM +0200, Richard Weinberger wrote:
> >>>
> >>> The test is repeatedly creating and removing a directory "dir" while lookups are
> >>> being done in it.  It seems the problem is that many dentries are being created
> >>> for "dir", and they pin many different inodes, all at the same time.  This
> >>> actually happens for ext4 too; it just doesn't cause an observable error.
> >>>
> >>> I doubt it's the right solution to make fscrypt_d_revalidate() look at
> >>> ->i_nlink, since ->d_revalidate() is meant to validate the filename, not the
> >>> inode.  I think there is probably a VFS bug that is causing the dentries to not
> >>> be freed.
> >>
> >> Not sure. Al? :-)
> >>
> > 
> > I can reproduce this on an unencrypted directory after updating path_init() in
> > fs/namei.c to always clear LOOKUP_RCU, so that all path lookups are done in
> > ref-walk mode.  So I think fscrypt_d_revalidate() was only relevant because it
> > causes all path lookups to drop out of rcu-walk mode.
> 
> On ext4 or UBIFS?
> 
> Thanks,
> //richard

Both; the inode "leak" isn't filesystem-specific, beyond the fact that UBIFS
apparently limits the number of inodes on its orphan list while ext4 does not.
(How do I know it happens on ext4 then?  /proc/slabinfo shows that lots of ext4
inodes have been allocated, and after an unclean shutdown and remounting, it's
reported that 50,000+ orphan inodes were deleted.)

There are lots of cases in which path lookups switch from rcu-walk mode into
ref-walk mode, so the fact that it was being caused by ->d_revalidate() in this
specific situation isn't really important, IMO.

I think the actual fix would be something along the lines of making vfs_rmdir()
unhash any negative child dentries, so that they get "killed" by dput() later.

Eric
