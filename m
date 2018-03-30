Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42558 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbeC3Qlh (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Mar 2018 12:41:37 -0400
Date: Fri, 30 Mar 2018 09:41:36 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH] f2fs: reserve bits for fs-verity
Message-ID: <20180330164136.GE44823@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180328181509.199870-1-ebiggers@google.com>
 <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chao Yu <yuchao0@huawei.com>
Cc: Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On 03/30, Chao Yu wrote:
> Hi Eric,
> 
> On 2018/3/29 2:15, Eric Biggers wrote:
> > Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
> > in-development feature that is planned be discussed at LSF/MM 2018 [1].
> > It will provide file-based integrity and authenticity for read-only
> > files.  Most code will be in a filesystem-independent module, with
> > smaller changes needed to individual filesystems that opt-in to
> > supporting the feature.  An early prototype supporting F2FS is available
> > [2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
> > of the prototype from conflicting with other new F2FS features.
> > 
> > Note that we're reserving the inode flag in f2fs_inode.i_advise, which
> > isn't really appropriate since it's not a hint or advice.  But
> > ->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
> > ->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
> > used for an F2FS-specific flag without additional work to remove the
> > assumption that ->i_flags uses the generic flags namespace.
> 
> At a glance, this is a VFS feature, can we search free slot, and define
> FS_VERITY_FL like other generic flags, so we can intergrate this flag into
> f2fs_inode::i_flags?

Do we need to get/set this bit of i_flags to user? And, f2fs doesn't synchronize
it with inode block update. I think this should be set by internal f2fs
operations likewise fscrypt.

> 
> And how about applying this patch inside the patchset of new fsverity feature?
> Since once fsverity feature has some design modification, I worry about that may
> be we need to change this bit? result in disk layout incompatibility.

The whole body is not fully mergeable, so once reserving the bits first, we can
support it f2fs-tools and prepare the feature in advance. Based on previous
fscrypt experience, I don't expect we need to modify or drop these dramatically
later.

Any thoughts?

> 
> Thanks,
> 
> > 
> > [1] https://marc.info/?l=linux-fsdevel&m=151690752225644
> > [2] https://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git/log/?h=fs-verity-dev
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/f2fs/f2fs.h | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
> > index ae69dc358401..96d7809c4541 100644
> > --- a/fs/f2fs/f2fs.h
> > +++ b/fs/f2fs/f2fs.h
> > @@ -146,6 +146,7 @@ struct f2fs_mount_info {
> >  #define F2FS_FEATURE_QUOTA_INO		0x0080
> >  #define F2FS_FEATURE_INODE_CRTIME	0x0100
> >  #define F2FS_FEATURE_LOST_FOUND		0x0200
> > +#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
> >  
> >  #define F2FS_HAS_FEATURE(sb, mask)					\
> >  	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
> > @@ -598,6 +599,7 @@ enum {
> >  #define FADVISE_ENC_NAME_BIT	0x08
> >  #define FADVISE_KEEP_SIZE_BIT	0x10
> >  #define FADVISE_HOT_BIT		0x20
> > +#define FADVISE_VERITY_BIT	0x40	/* reserved */
> >  
> >  #define file_is_cold(inode)	is_file(inode, FADVISE_COLD_BIT)
> >  #define file_wrong_pino(inode)	is_file(inode, FADVISE_LOST_PINO_BIT)
> > 
