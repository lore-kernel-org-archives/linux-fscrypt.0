Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44218 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726643AbeHZVSU (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 26 Aug 2018 17:18:20 -0400
Date: Sun, 26 Aug 2018 10:35:08 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH 10/10] f2fs: fs-verity support
Message-ID: <20180826173507.GC728@sol.localdomain>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-11-ebiggers@kernel.org>
 <b2b6a810-9605-15c8-b905-a4591c0cf3a5@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b2b6a810-9605-15c8-b905-a4591c0cf3a5@huawei.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chao Yu <yuchao0@huawei.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chao,

On Sat, Aug 25, 2018 at 01:54:08PM +0800, Chao Yu wrote:
> On 2018/8/25 0:16, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> >  #ifdef CONFIG_F2FS_CHECK_FS
> >  #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
> >  #else
> > @@ -146,7 +149,7 @@ struct f2fs_mount_info {
> >  #define F2FS_FEATURE_QUOTA_INO		0x0080
> >  #define F2FS_FEATURE_INODE_CRTIME	0x0100
> >  #define F2FS_FEATURE_LOST_FOUND		0x0200
> > -#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
> > +#define F2FS_FEATURE_VERITY		0x0400
> >  
> >  #define F2FS_HAS_FEATURE(sb, mask)					\
> >  	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
> > @@ -598,7 +601,7 @@ enum {
> >  #define FADVISE_ENC_NAME_BIT	0x08
> >  #define FADVISE_KEEP_SIZE_BIT	0x10
> >  #define FADVISE_HOT_BIT		0x20
> > -#define FADVISE_VERITY_BIT	0x40	/* reserved */
> > +#define FADVISE_VERITY_BIT	0x40
> 
> As I suggested before, how about moving f2fs' verity_bit from i_fadvise to more
> generic i_flags field like ext4, so we can a) remaining more bits for those
> demands which really need file advise fields. b) using i_flags bits keeping line
> with ext4. Not sure, if user want to know whether the file is verity one, it
> will be easy for f2fs to export the status through FS_IOC_SETFLAGS.
> 
> #define EXT4_VERITY_FL			0x00100000 /* Verity protected inode */
> 
> #define F2FS_VERITY_FL			0x00100000 /* Verity protected inode */
> 

I don't like using i_advise much either, but I actually don't see either
location being much better than the other at the moment.  The real problem is an
artificial one: the i_flags in f2fs's on-disk format are being assumed to use
the same numbering scheme as ext4's on-disk format, which makes it seem that
they have to be in sync, and that all new ext4 flags (say, EA_INODE) also
reserve bits in f2fs and vice versa, when they in fact do not.  Instead, f2fs
should use its own numbering for its i_flags, and it should map them to/from
whatever is needed for common APIs like FS_IOC_{GET,SET}FLAGS and
FS_IOC_FS{GET,SET}XATTR.

So putting the verity flag in *either* location (i_advise or i_flags) is just
kicking the can down the road.  If I get around to it I will send a patch that
cleans up the f2fs flags properly...

Thanks,

- Eric
