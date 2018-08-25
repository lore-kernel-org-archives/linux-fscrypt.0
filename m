Return-Path: <SRS0=MtDF=LI=huawei.com=yuchao0@kernel.org>
Subject: Re: [f2fs-dev] [RFC PATCH 10/10] f2fs: fs-verity support
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-11-ebiggers@kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <b2b6a810-9605-15c8-b905-a4591c0cf3a5@huawei.com>
Date: Sat, 25 Aug 2018 13:54:08 +0800
MIME-Version: 1.0
In-Reply-To: <20180824161642.1144-11-ebiggers@kernel.org>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi
List-ID: <linux-fscrypt@vger.kernel.org>

On 2018/8/25 0:16, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
>  #ifdef CONFIG_F2FS_CHECK_FS
>  #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
>  #else
> @@ -146,7 +149,7 @@ struct f2fs_mount_info {
>  #define F2FS_FEATURE_QUOTA_INO		0x0080
>  #define F2FS_FEATURE_INODE_CRTIME	0x0100
>  #define F2FS_FEATURE_LOST_FOUND		0x0200
> -#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
> +#define F2FS_FEATURE_VERITY		0x0400
>  
>  #define F2FS_HAS_FEATURE(sb, mask)					\
>  	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
> @@ -598,7 +601,7 @@ enum {
>  #define FADVISE_ENC_NAME_BIT	0x08
>  #define FADVISE_KEEP_SIZE_BIT	0x10
>  #define FADVISE_HOT_BIT		0x20
> -#define FADVISE_VERITY_BIT	0x40	/* reserved */
> +#define FADVISE_VERITY_BIT	0x40

As I suggested before, how about moving f2fs' verity_bit from i_fadvise to more
generic i_flags field like ext4, so we can a) remaining more bits for those
demands which really need file advise fields. b) using i_flags bits keeping line
with ext4. Not sure, if user want to know whether the file is verity one, it
will be easy for f2fs to export the status through FS_IOC_SETFLAGS.

#define EXT4_VERITY_FL			0x00100000 /* Verity protected inode */

#define F2FS_VERITY_FL			0x00100000 /* Verity protected inode */

Thanks,
