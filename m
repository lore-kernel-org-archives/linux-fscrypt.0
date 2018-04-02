Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:35652 "EHLO
        ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754520AbeDBVuD (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 2 Apr 2018 17:50:03 -0400
Date: Tue, 3 Apr 2018 07:49:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] f2fs: reserve bits for fs-verity
Message-ID: <20180402214959.GG18129@dastard>
References: <20180328181509.199870-1-ebiggers@google.com>
 <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
 <20180330164136.GE44823@jaegeuk-macbookpro.roam.corp.google.com>
 <20180330183420.GA180083@google.com>
 <ec343a28-ad47-a494-ea36-c8fef72d3480@huawei.com>
 <20180402184837.GA59810@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180402184837.GA59810@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: Chao Yu <yuchao0@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Apr 02, 2018 at 11:48:37AM -0700, Eric Biggers wrote:
> [+Cc linux-ext4, linux-fsdevel]
> 
> On Mon, Apr 02, 2018 at 06:07:10PM +0800, Chao Yu wrote:
> > Hi Eric and Jaegeuk,
> > 
> > On 2018/3/31 2:34, Eric Biggers wrote:
> > > Hi Chao and Jaegeuk,
> > > 
> > > On Fri, Mar 30, 2018 at 09:41:36AM -0700, Jaegeuk Kim wrote:
> > >> On 03/30, Chao Yu wrote:
> > >>> Hi Eric,
> > >>>
> > >>> On 2018/3/29 2:15, Eric Biggers wrote:
> > >>>> Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
> > >>>> in-development feature that is planned be discussed at LSF/MM 2018 [1].
> > >>>> It will provide file-based integrity and authenticity for read-only
> > >>>> files.  Most code will be in a filesystem-independent module, with
> > >>>> smaller changes needed to individual filesystems that opt-in to
> > >>>> supporting the feature.  An early prototype supporting F2FS is available
> > >>>> [2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
> > >>>> of the prototype from conflicting with other new F2FS features.
> > >>>>
> > >>>> Note that we're reserving the inode flag in f2fs_inode.i_advise, which
> > >>>> isn't really appropriate since it's not a hint or advice.  But
> > >>>> ->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
> > >>>> ->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
> > >>>> used for an F2FS-specific flag without additional work to remove the
> > >>>> assumption that ->i_flags uses the generic flags namespace.
> > >>>
> > >>> At a glance, this is a VFS feature, can we search free slot, and define
> > >>> FS_VERITY_FL like other generic flags, so we can intergrate this flag into
> > >>> f2fs_inode::i_flags?
> > >>
> > >> Do we need to get/set this bit of i_flags to user? And, f2fs doesn't synchronize
> > >> it with inode block update. I think this should be set by internal f2fs
> > >> operations likewise fscrypt.
> > >>
> > > 
> > > The fs-verity inode flag won't be modifiable using FS_IOC_SETFLAGS.  Like
> > 
> > Verity flag can also be wrapped by FS_FL_USER_MODIFIABLE like for FS_ENCRYPT_FL?
> > 
> > > fscrypt, it will only be possible to set it using a dedicated ioctl (tentatively
> > > called FS_IOC_ENABLE_VERITY), and it won't be supported to clear the bit once
> > > set, short of deleting and re-creating the file.  So it doesn't really matter
> > > where the bit goes in the on-disk inode, it just needs to go somewhere.  I'm
> > > just hesitant to reserve a flag in the UAPI flags namespace which is really more
> > > "owned" by ext4 than by f2fs, so has more implications than just f2fs as we
> > > would effectively be reserving the flag for ext4's on-disk format too.
> > 
> > IMO, because this is a VFS feature, it will be better that we can put it in more
> > generic place, also user can check this bit in generic way (via
> > FS_IOC_GETFLAGS), and then for other filesystem who wants add this feature, that
> > will be simple to place this bit.
> > 
> > What I can see is, for encryption feature:
> > 
> > vfs::i_flags
> > #define FS_ENCRYPT_FL                   0x00000800 /* Encrypted file */
> > 
> > ext4:i_flags
> > #define EXT4_ENCRYPT_FL			0x00000800 /* encrypted file */
> > 
> > f2fs::i_advice
> > #define FADVISE_ENCRYPT_BIT	0x04
> > 
> > It's very wired that f2fs didn't use well defined FS_ENCRYPT_FL bit position,
> > result in that we leave a hole in on-disk i_flags, and if we want to show the
> > same 'encrypted' flags status in FS_IOC_GETFLAGS, we need to change more codes.
> > 
> > Anyway, I just ask why not let generic status goes into i_flags, and private
> > status goes into i_advices?
> 
> Ted and others, what would you say about allocating FS_VERITY_FL as one of the
> unused ext4 / "VFS" inode flags like 0x01000000, or maybe 0x00000400 if the
> compression flags aren't being used anymore?
> 
> I do wish that we separated the on-disk flags namespaces from the
> FS_IOC_GETFLAGS/FS_IOC_SETFLAGS namespace though...  Then adding the flag to

Use FS_IOC_{GS}ETXATTR instead?. I'ts not tied to an on-disk format.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
