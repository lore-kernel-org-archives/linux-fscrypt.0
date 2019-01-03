Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr700111.outbound.protection.outlook.com ([40.107.70.111]:48960
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730901AbfACPbc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 3 Jan 2019 10:31:32 -0500
Date: Thu, 3 Jan 2019 10:31:26 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fsverity for 4.21-rc
Message-ID: <20190103153126.GE6908@mit.edu>
References: <20181231202245.GA13792@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20181231202245.GA13792@mit.edu>
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>


Ping?


On Mon, Dec 31, 2018 at 03:22:45PM -0500, Theodore Y. Ts'o wrote:
> Hi Linus,
> 
> Since I didn't get a reply my last e-mail on the thread to you[1], I'm
> not sure what your current thinking is on fs-verity.  So here's the
> pull request; please pull if you're OK with this.
> 
> [1] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1886004.html
> 
> Thanks,
> 
> 					- Ted
> 
> The following changes since commit 7beb01f74415c56f5992922b5b902b45d365e694:
> 
>   f2fs: clean up f2fs_sb_has_##feature_name (2018-11-26 15:53:55 -0800)
> 
> are available in the Git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fsverity_for_linus
> 
> for you to fetch changes up to 50ee9e5d8e3ef15fc4bed781df9a6b2f708230ff:
> 
>   f2fs: fs-verity support (2018-11-28 18:14:53 -0500)
> 
> ----------------------------------------------------------------
> Add fs-verity support for ext4 and f2fs
> 
> ----------------------------------------------------------------
> Eric Biggers (12):
>       fs-verity: add a documentation file
>       fs-verity: add setup code, UAPI, and Kconfig
>       fs-verity: add MAINTAINERS file entry
>       fs-verity: add data verification hooks for ->readpages()
>       fs-verity: implement FS_IOC_ENABLE_VERITY ioctl
>       fs-verity: implement FS_IOC_MEASURE_VERITY ioctl
>       fs-verity: add SHA-512 support
>       fs-verity: add CRC-32C support
>       fs-verity: support builtin file signatures
>       ext4: add basic fs-verity support
>       ext4: add fs-verity read support
>       f2fs: fs-verity support
> 
>  Documentation/filesystems/fsverity.rst | 583 ++++++++++++++++++++++++++
>  Documentation/filesystems/index.rst    |  11 +
>  Documentation/ioctl/ioctl-number.txt   |   1 +
>  MAINTAINERS                            |  12 +
>  fs/Kconfig                             |   2 +
>  fs/Makefile                            |   1 +
>  fs/ext4/Kconfig                        |  20 +
>  fs/ext4/ext4.h                         |  22 +-
>  fs/ext4/file.c                         |   6 +
>  fs/ext4/inode.c                        |  11 +
>  fs/ext4/ioctl.c                        |  12 +
>  fs/ext4/readpage.c                     | 209 ++++++++--
>  fs/ext4/super.c                        | 100 ++++-
>  fs/ext4/sysfs.c                        |   6 +
>  fs/f2fs/Kconfig                        |  20 +
>  fs/f2fs/data.c                         |  43 +-
>  fs/f2fs/f2fs.h                         |  17 +-
>  fs/f2fs/file.c                         |  58 +++
>  fs/f2fs/inode.c                        |   3 +-
>  fs/f2fs/super.c                        |  30 ++
>  fs/f2fs/sysfs.c                        |  11 +
>  fs/verity/Kconfig                      |  52 +++
>  fs/verity/Makefile                     |   5 +
>  fs/verity/fsverity_private.h           | 135 ++++++
>  fs/verity/hash_algs.c                  | 115 ++++++
>  fs/verity/ioctl.c                      | 164 ++++++++
>  fs/verity/setup.c                      | 908 +++++++++++++++++++++++++++++++++++++++++
>  fs/verity/signature.c                  | 187 +++++++++
>  fs/verity/verify.c                     | 298 ++++++++++++++
>  include/linux/fs.h                     |   9 +
>  include/linux/fsverity.h               | 112 +++++
>  include/uapi/linux/fsverity.h          |  98 +++++
>  32 files changed, 3219 insertions(+), 42 deletions(-)
>  create mode 100644 Documentation/filesystems/fsverity.rst
>  create mode 100644 fs/verity/Kconfig
>  create mode 100644 fs/verity/Makefile
>  create mode 100644 fs/verity/fsverity_private.h
>  create mode 100644 fs/verity/hash_algs.c
>  create mode 100644 fs/verity/ioctl.c
>  create mode 100644 fs/verity/setup.c
>  create mode 100644 fs/verity/signature.c
>  create mode 100644 fs/verity/verify.c
>  create mode 100644 include/linux/fsverity.h
>  create mode 100644 include/uapi/linux/fsverity.h
