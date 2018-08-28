Return-Path: <jaegeuk@kernel.org>
Date: Tue, 28 Aug 2018 10:01:42 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH 10/10] f2fs: fs-verity support
Message-ID: <20180828170142.GB62482@jaegeuk-macbookpro.roam.corp.google.com>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-11-ebiggers@kernel.org>
 <b2b6a810-9605-15c8-b905-a4591c0cf3a5@huawei.com>
 <20180826173507.GC728@sol.localdomain>
 <dbc20be8-975d-7bd2-002d-a8f30896da4a@kernel.org>
 <20180828072756.GC29049@jaegeuk-macbookpro.roam.corp.google.com>
 <63a19512-e938-d239-9e3c-f6ecc479478c@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63a19512-e938-d239-9e3c-f6ecc479478c@huawei.com>
To: Chao Yu <yuchao0@huawei.com>
Cc: Chao Yu <chao@kernel.org>, Eric Biggers <ebiggers@kernel.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 08/28, Chao Yu wrote:
> On 2018/8/28 15:27, Jaegeuk Kim wrote:
> > On 08/27, Chao Yu wrote:
> >> Hi Eric,
> >>
> >> On 2018/8/27 1:35, Eric Biggers wrote:
> >>> Hi Chao,
> >>>
> >>> On Sat, Aug 25, 2018 at 01:54:08PM +0800, Chao Yu wrote:
> >>>> On 2018/8/25 0:16, Eric Biggers wrote:
> >>>>> From: Eric Biggers <ebiggers@google.com>
> >>>>>  #ifdef CONFIG_F2FS_CHECK_FS
> >>>>>  #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
> >>>>>  #else
> >>>>> @@ -146,7 +149,7 @@ struct f2fs_mount_info {
> >>>>>  #define F2FS_FEATURE_QUOTA_INO		0x0080
> >>>>>  #define F2FS_FEATURE_INODE_CRTIME	0x0100
> >>>>>  #define F2FS_FEATURE_LOST_FOUND		0x0200
> >>>>> -#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
> >>>>> +#define F2FS_FEATURE_VERITY		0x0400
> >>>>>  
> >>>>>  #define F2FS_HAS_FEATURE(sb, mask)					\
> >>>>>  	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
> >>>>> @@ -598,7 +601,7 @@ enum {
> >>>>>  #define FADVISE_ENC_NAME_BIT	0x08
> >>>>>  #define FADVISE_KEEP_SIZE_BIT	0x10
> >>>>>  #define FADVISE_HOT_BIT		0x20
> >>>>> -#define FADVISE_VERITY_BIT	0x40	/* reserved */
> >>>>> +#define FADVISE_VERITY_BIT	0x40
> >>>>
> >>>> As I suggested before, how about moving f2fs' verity_bit from i_fadvise to more
> >>>> generic i_flags field like ext4, so we can a) remaining more bits for those
> >>>> demands which really need file advise fields. b) using i_flags bits keeping line
> >>>> with ext4. Not sure, if user want to know whether the file is verity one, it
> >>>> will be easy for f2fs to export the status through FS_IOC_SETFLAGS.
> >>>>
> >>>> #define EXT4_VERITY_FL			0x00100000 /* Verity protected inode */
> >>>>
> >>>> #define F2FS_VERITY_FL			0x00100000 /* Verity protected inode */
> >>>>
> >>>
> >>> I don't like using i_advise much either, but I actually don't see either
> >>> location being much better than the other at the moment.  The real problem is an
> >>> artificial one: the i_flags in f2fs's on-disk format are being assumed to use
> >>
> >> Yeah, but since most copied flags from vfs/ext4 are not actually used in f2fs,
> >> also 0x00100000 bit is not used now, so we can just define it now directly for
> >> verity bit.
> >>
> >> Cleanup and remapping in ioctl interface for those unused flags, we can do it
> >> latter?
> > 
> > No, it was reserved by f2fs-tools, 
> 
> That's not a problem, since we didn't use that reserved bit in any of images
> now, there is no backward compatibility issue.

We're using that.

> 
> > and I think this should be aligned to the encryption bit. 
> 
> Alright, we could, but if so, i_advise will run out of space earlier, after that
> we have to add real advice bit into i_inline or i_flags, that would be a little
> weird.
> 
> For encryption bit, as a common vfs feature flag, in the beginning of encryption
> development, it will be better to set it into i_flags, IMO, but now, we have to
> keep it as it was.
> 
> > Moreover, we guarantee i_flags less strictly from power-cut than i_advise.
> 
> IMO, in power-cut scenario, it needs to keep both i_flags and i_advise being
> recoverable strictly. Any condition that we can not recover i_flags?

In __f2fs_ioc_setflags, f2fs_mark_inode_dirty_sync(inode, false);

> 
> Thanks,
> 
> > 
> >>
> >> Thanks,
> >>
> >>> the same numbering scheme as ext4's on-disk format, which makes it seem that
> >>> they have to be in sync, and that all new ext4 flags (say, EA_INODE) also
> >>> reserve bits in f2fs and vice versa, when they in fact do not.  Instead, f2fs
> >>> should use its own numbering for its i_flags, and it should map them to/from
> >>> whatever is needed for common APIs like FS_IOC_{GET,SET}FLAGS and
> >>> FS_IOC_FS{GET,SET}XATTR.
> >>>
> >>> So putting the verity flag in *either* location (i_advise or i_flags) is just
> >>> kicking the can down the road.  If I get around to it I will send a patch that
> >>> cleans up the f2fs flags properly...>
> >>> Thanks,
> >>>
> >>> - Eric
> >>>
> >>> ------------------------------------------------------------------------------
> >>> Check out the vibrant tech community on one of the world's most
> >>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> >>> _______________________________________________
> >>> Linux-f2fs-devel mailing list
> >>> Linux-f2fs-devel@lists.sourceforge.net
> >>> https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
> >>>
> > 
> > .
> > 
