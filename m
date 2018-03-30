Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35907 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751938AbeC3SeZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Mar 2018 14:34:25 -0400
Received: by mail-it0-f49.google.com with SMTP id 15-v6so2004715itl.1
        for <linux-fscrypt@vger.kernel.org>; Fri, 30 Mar 2018 11:34:24 -0700 (PDT)
Date: Fri, 30 Mar 2018 11:34:20 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH] f2fs: reserve bits for fs-verity
Message-ID: <20180330183420.GA180083@google.com>
References: <20180328181509.199870-1-ebiggers@google.com>
 <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
 <20180330164136.GE44823@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330164136.GE44823@jaegeuk-macbookpro.roam.corp.google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chao and Jaegeuk,

On Fri, Mar 30, 2018 at 09:41:36AM -0700, Jaegeuk Kim wrote:
> On 03/30, Chao Yu wrote:
> > Hi Eric,
> > 
> > On 2018/3/29 2:15, Eric Biggers wrote:
> > > Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
> > > in-development feature that is planned be discussed at LSF/MM 2018 [1].
> > > It will provide file-based integrity and authenticity for read-only
> > > files.  Most code will be in a filesystem-independent module, with
> > > smaller changes needed to individual filesystems that opt-in to
> > > supporting the feature.  An early prototype supporting F2FS is available
> > > [2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
> > > of the prototype from conflicting with other new F2FS features.
> > > 
> > > Note that we're reserving the inode flag in f2fs_inode.i_advise, which
> > > isn't really appropriate since it's not a hint or advice.  But
> > > ->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
> > > ->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
> > > used for an F2FS-specific flag without additional work to remove the
> > > assumption that ->i_flags uses the generic flags namespace.
> > 
> > At a glance, this is a VFS feature, can we search free slot, and define
> > FS_VERITY_FL like other generic flags, so we can intergrate this flag into
> > f2fs_inode::i_flags?
> 
> Do we need to get/set this bit of i_flags to user? And, f2fs doesn't synchronize
> it with inode block update. I think this should be set by internal f2fs
> operations likewise fscrypt.
> 

The fs-verity inode flag won't be modifiable using FS_IOC_SETFLAGS.  Like
fscrypt, it will only be possible to set it using a dedicated ioctl (tentatively
called FS_IOC_ENABLE_VERITY), and it won't be supported to clear the bit once
set, short of deleting and re-creating the file.  So it doesn't really matter
where the bit goes in the on-disk inode, it just needs to go somewhere.  I'm
just hesitant to reserve a flag in the UAPI flags namespace which is really more
"owned" by ext4 than by f2fs, so has more implications than just f2fs as we
would effectively be reserving the flag for ext4's on-disk format too.

I do think the flag *should* go in i_flags rather than i_advise, but I think the
assumption that f2fs's inode flags namespace matches ext4's would first need to
be removed so as to not tie the on-disk formats of different filesystems
together.

> > 
> > And how about applying this patch inside the patchset of new fsverity feature?
> > Since once fsverity feature has some design modification, I worry about that may
> > be we need to change this bit? result in disk layout incompatibility.
> 
> The whole body is not fully mergeable, so once reserving the bits first, we can
> support it f2fs-tools and prepare the feature in advance. Based on previous
> fscrypt experience, I don't expect we need to modify or drop these dramatically
> later.
> 
> Any thoughts?
> 

Yep, the full patchset isn't ready to be merged upstream yet.  Other parts of
the API/ABI such as the fs-verity metadata format, the ioctl numbers, and the
semantics of accessing such files is subject to change.  We know we'll need a
superblock feature flag and a per-inode bit in any case, though.  Personally I'd
prefer to wait for the full patchset too, but we have people who want to start
using the prototype of the feature already, so having f2fs-tools support the
feature flag and having the bits not conflict with other f2fs features will be
helpful.

Thanks,

Eric
