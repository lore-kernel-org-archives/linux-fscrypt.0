Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6714 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751251AbeC3Js0 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Mar 2018 05:48:26 -0400
Subject: Re: [PATCH] f2fs: reserve bits for fs-verity
References: <20180328181509.199870-1-ebiggers@google.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <9ccabf5b-46ef-aa46-bdb8-6fcd96792ed0@huawei.com>
Date: Fri, 30 Mar 2018 17:48:17 +0800
MIME-Version: 1.0
In-Reply-To: <20180328181509.199870-1-ebiggers@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 2018/3/29 2:15, Eric Biggers wrote:
> Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
> in-development feature that is planned be discussed at LSF/MM 2018 [1].
> It will provide file-based integrity and authenticity for read-only
> files.  Most code will be in a filesystem-independent module, with
> smaller changes needed to individual filesystems that opt-in to
> supporting the feature.  An early prototype supporting F2FS is available
> [2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
> of the prototype from conflicting with other new F2FS features.
> 
> Note that we're reserving the inode flag in f2fs_inode.i_advise, which
> isn't really appropriate since it's not a hint or advice.  But
> ->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
> ->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
> used for an F2FS-specific flag without additional work to remove the
> assumption that ->i_flags uses the generic flags namespace.

At a glance, this is a VFS feature, can we search free slot, and define
FS_VERITY_FL like other generic flags, so we can intergrate this flag into
f2fs_inode::i_flags?

And how about applying this patch inside the patchset of new fsverity feature?
Since once fsverity feature has some design modification, I worry about that may
be we need to change this bit? result in disk layout incompatibility.

Thanks,

> 
> [1] https://marc.info/?l=linux-fsdevel&m=151690752225644
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git/log/?h=fs-verity-dev
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/f2fs/f2fs.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
> index ae69dc358401..96d7809c4541 100644
> --- a/fs/f2fs/f2fs.h
> +++ b/fs/f2fs/f2fs.h
> @@ -146,6 +146,7 @@ struct f2fs_mount_info {
>  #define F2FS_FEATURE_QUOTA_INO		0x0080
>  #define F2FS_FEATURE_INODE_CRTIME	0x0100
>  #define F2FS_FEATURE_LOST_FOUND		0x0200
> +#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
>  
>  #define F2FS_HAS_FEATURE(sb, mask)					\
>  	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
> @@ -598,6 +599,7 @@ enum {
>  #define FADVISE_ENC_NAME_BIT	0x08
>  #define FADVISE_KEEP_SIZE_BIT	0x10
>  #define FADVISE_HOT_BIT		0x20
> +#define FADVISE_VERITY_BIT	0x40	/* reserved */
>  
>  #define file_is_cold(inode)	is_file(inode, FADVISE_COLD_BIT)
>  #define file_wrong_pino(inode)	is_file(inode, FADVISE_LOST_PINO_BIT)
> 

