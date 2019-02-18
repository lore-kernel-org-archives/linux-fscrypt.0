Return-Path: <SRS0=THX2=QZ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [RFC PATCH 00/10] Consolidate Post read processing code
Date: Mon, 18 Feb 2019 15:49:13 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2149979.e1aSEps7Pq@localhost.localdomain>
To: linux-ext4@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Monday, February 18, 2019 3:34:23 PM IST Chandan Rajendra wrote:
> This patchset moves the "post read processing" code into a file of its
> own and gets the generic do_mpage_readpge() to make use of the
> functionality provided. With these changes in place, the patchset
> changes Ext4 to use mpage_readpage[s] instead of its own custom
> ext4_readpages() function. This is done to reduce duplicity of code
> across filesystems. Based on the reviews provided for this patchset, I
> will change F2FS to use mpage_readpage[s] and post the next version of
> this patchset to linux-fsdevel mailing list.
> 
> The patchset also includes patches from previous postings i.e.
> patches to replace per-filesystem encryption config options with a
> single config option that affects all filesystems making use of
> fscrypt code.

The patchset is based on fsverity_2019-01-30 branch of Eric's git tree. It can
also be obtained from "https://github.com/chandanr/linux.git
use-mpage-readpage-rfc".

> 
> Chandan Rajendra (10):
>   ext4: use IS_ENCRYPTED() to check encryption status
>   f2fs: use IS_ENCRYPTED() to check encryption status
>   fscrypt: remove filesystem specific build config option
>   Consolidate "post read processing" into a new file
>   fsverity: Add call back to decide if verity check has to be performed
>   Introduce REQ_POST_READ_PROC bio flag
>   fsverity: Add call back to determine readpage limit
>   fsverity: Add call back to verify file holes
>   fs/mpage.c: Integrate post read processing
>   ext4: Wire up ext4_readpage[s] to use mpage_readpage[s]
> 
>  Documentation/filesystems/fscrypt.rst   |   4 +-
>  arch/mips/configs/generic_defconfig     |   2 +-
>  arch/nds32/configs/defconfig            |   2 +-
>  arch/s390/configs/debug_defconfig       |   2 +-
>  arch/s390/configs/performance_defconfig |   2 +-
>  fs/Makefile                             |   3 +-
>  fs/crypto/Kconfig                       |   5 +-
>  fs/crypto/bio.c                         |  21 +-
>  fs/crypto/crypto.c                      |   1 +
>  fs/crypto/fscrypt_private.h             |   4 +-
>  fs/ext4/Kconfig                         |  15 -
>  fs/ext4/Makefile                        |   2 +-
>  fs/ext4/dir.c                           |  10 +-
>  fs/ext4/ext4.h                          |  14 +-
>  fs/ext4/ext4_jbd2.h                     |   2 +-
>  fs/ext4/extents.c                       |   4 +-
>  fs/ext4/ialloc.c                        |   2 +-
>  fs/ext4/inode.c                         |  29 +-
>  fs/ext4/ioctl.c                         |   4 +-
>  fs/ext4/move_extent.c                   |   3 +-
>  fs/ext4/namei.c                         |  18 +-
>  fs/ext4/page-io.c                       |   9 +-
>  fs/ext4/readpage.c                      | 444 ------------------------
>  fs/ext4/super.c                         |  43 ++-
>  fs/ext4/sysfs.c                         |   4 +-
>  fs/f2fs/Kconfig                         |  12 +-
>  fs/f2fs/data.c                          |   4 +-
>  fs/f2fs/dir.c                           |  10 +-
>  fs/f2fs/f2fs.h                          |  14 +-
>  fs/f2fs/file.c                          |  10 +-
>  fs/f2fs/inode.c                         |   4 +-
>  fs/f2fs/namei.c                         |   6 +-
>  fs/f2fs/super.c                         |   8 +-
>  fs/f2fs/sysfs.c                         |   4 +-
>  fs/mpage.c                              |  77 +++-
>  fs/post_read_process.c                  | 128 +++++++
>  fs/ubifs/Kconfig                        |  12 +-
>  fs/ubifs/Makefile                       |   2 +-
>  fs/ubifs/ioctl.c                        |   4 +-
>  fs/ubifs/sb.c                           |   2 +-
>  fs/ubifs/super.c                        |   2 +-
>  fs/ubifs/ubifs.h                        |   5 +-
>  fs/verity/verify.c                      |  12 +
>  include/linux/blk_types.h               |   2 +
>  include/linux/fs.h                      |   4 +-
>  include/linux/fscrypt.h                 | 405 ++++++++++++++++++++-
>  include/linux/fscrypt_notsupp.h         | 231 ------------
>  include/linux/fscrypt_supp.h            | 204 -----------
>  include/linux/fsverity.h                |   3 +
>  include/linux/post_read_process.h       |  21 ++
>  50 files changed, 757 insertions(+), 1078 deletions(-)
>  delete mode 100644 fs/ext4/readpage.c
>  create mode 100644 fs/post_read_process.c
>  delete mode 100644 include/linux/fscrypt_notsupp.h
>  delete mode 100644 include/linux/fscrypt_supp.h
>  create mode 100644 include/linux/post_read_process.h
> 
> 


-- 
chandan
