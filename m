Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6720 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754211AbeDBKH3 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 2 Apr 2018 06:07:29 -0400
Subject: Re: [PATCH] f2fs: reserve bits for fs-verity
References: <20180328181509.199870-1-ebiggers@google.com>
 <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
 <20180330164136.GE44823@jaegeuk-macbookpro.roam.corp.google.com>
 <20180330183420.GA180083@google.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <ec343a28-ad47-a494-ea36-c8fef72d3480@huawei.com>
Date: Mon, 2 Apr 2018 18:07:10 +0800
MIME-Version: 1.0
In-Reply-To: <20180330183420.GA180083@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric and Jaegeuk,

On 2018/3/31 2:34, Eric Biggers wrote:
> Hi Chao and Jaegeuk,
> 
> On Fri, Mar 30, 2018 at 09:41:36AM -0700, Jaegeuk Kim wrote:
>> On 03/30, Chao Yu wrote:
>>> Hi Eric,
>>>
>>> On 2018/3/29 2:15, Eric Biggers wrote:
>>>> Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
>>>> in-development feature that is planned be discussed at LSF/MM 2018 [1].
>>>> It will provide file-based integrity and authenticity for read-only
>>>> files.  Most code will be in a filesystem-independent module, with
>>>> smaller changes needed to individual filesystems that opt-in to
>>>> supporting the feature.  An early prototype supporting F2FS is available
>>>> [2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
>>>> of the prototype from conflicting with other new F2FS features.
>>>>
>>>> Note that we're reserving the inode flag in f2fs_inode.i_advise, which
>>>> isn't really appropriate since it's not a hint or advice.  But
>>>> ->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
>>>> ->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
>>>> used for an F2FS-specific flag without additional work to remove the
>>>> assumption that ->i_flags uses the generic flags namespace.
>>>
>>> At a glance, this is a VFS feature, can we search free slot, and define
>>> FS_VERITY_FL like other generic flags, so we can intergrate this flag into
>>> f2fs_inode::i_flags?
>>
>> Do we need to get/set this bit of i_flags to user? And, f2fs doesn't synchronize
>> it with inode block update. I think this should be set by internal f2fs
>> operations likewise fscrypt.
>>
> 
> The fs-verity inode flag won't be modifiable using FS_IOC_SETFLAGS.  Like

Verity flag can also be wrapped by FS_FL_USER_MODIFIABLE like for FS_ENCRYPT_FL?

> fscrypt, it will only be possible to set it using a dedicated ioctl (tentatively
> called FS_IOC_ENABLE_VERITY), and it won't be supported to clear the bit once
> set, short of deleting and re-creating the file.  So it doesn't really matter
> where the bit goes in the on-disk inode, it just needs to go somewhere.  I'm
> just hesitant to reserve a flag in the UAPI flags namespace which is really more
> "owned" by ext4 than by f2fs, so has more implications than just f2fs as we
> would effectively be reserving the flag for ext4's on-disk format too.

IMO, because this is a VFS feature, it will be better that we can put it in more
generic place, also user can check this bit in generic way (via
FS_IOC_GETFLAGS), and then for other filesystem who wants add this feature, that
will be simple to place this bit.

What I can see is, for encryption feature:

vfs::i_flags
#define FS_ENCRYPT_FL                   0x00000800 /* Encrypted file */

ext4:i_flags
#define EXT4_ENCRYPT_FL			0x00000800 /* encrypted file */

f2fs::i_advice
#define FADVISE_ENCRYPT_BIT	0x04

It's very wired that f2fs didn't use well defined FS_ENCRYPT_FL bit position,
result in that we leave a hole in on-disk i_flags, and if we want to show the
same 'encrypted' flags status in FS_IOC_GETFLAGS, we need to change more codes.

Anyway, I just ask why not let generic status goes into i_flags, and private
status goes into i_advices?

> 
> I do think the flag *should* go in i_flags rather than i_advise, but I think the
> assumption that f2fs's inode flags namespace matches ext4's would first need to
> be removed so as to not tie the on-disk formats of different filesystems
> together.
> 
>>>
>>> And how about applying this patch inside the patchset of new fsverity feature?
>>> Since once fsverity feature has some design modification, I worry about that may
>>> be we need to change this bit? result in disk layout incompatibility.
>>
>> The whole body is not fully mergeable, so once reserving the bits first, we can
>> support it f2fs-tools and prepare the feature in advance. Based on previous
>> fscrypt experience, I don't expect we need to modify or drop these dramatically
>> later.
>>
>> Any thoughts?

Since I don't know current progress of this feature development, I hope this
feature will not be against by vfs developers or suffer design change after we
reserved bit for it. :)

>>
> 
> Yep, the full patchset isn't ready to be merged upstream yet.  Other parts of
> the API/ABI such as the fs-verity metadata format, the ioctl numbers, and the
> semantics of accessing such files is subject to change.  We know we'll need a
> superblock feature flag and a per-inode bit in any case, though.  Personally I'd
> prefer to wait for the full patchset too, but we have people who want to start
> using the prototype of the feature already, so having f2fs-tools support the
> feature flag and having the bits not conflict with other f2fs features will be
> helpful.

Oh, so we want a stable on-disk layout, so image for experience will contain
fsverity bit in stable position, after formal android released, image with
fsverity feature can still be valid, right?

Thanks,

> 
> Thanks,
> 
> Eric
> 
> .
> 

