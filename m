Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:50644 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726038AbfCDVrZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 4 Mar 2019 16:47:25 -0500
Date: Mon, 4 Mar 2019 13:47:22 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: [GIT PULL] fscrypt updates for v5.1
Message-ID: <20190304214721.GA215807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 49a57857aeea06ca831043acbb0fa5e0f50602fd:

  Linux 5.0-rc3 (2019-01-21 13:14:44 +1300)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt-for-linus

for you to fetch changes up to 129ca2d2a83f44551e73a408fa5e75a7b5169abb:

  MAINTAINERS: add Eric Biggers as an fscrypt maintainer (2019-02-20 15:33:28 -0800)

----------------------------------------------------------------
fscrypt updates for v5.1

First: Ted, Jaegeuk, and I have decided to add me as a co-maintainer for
fscrypt, and we're now using a shared git tree.  So we've updated
MAINTAINERS accordingly, and I'm doing the pull request this time.

The actual changes for v5.1 are:

- Remove the fs-specific kconfig options like CONFIG_EXT4_ENCRYPTION and
  make fscrypt support for all fscrypt-capable filesystems be controlled
  by CONFIG_FS_ENCRYPTION, similar to how CONFIG_QUOTA works.

- Improve error code for rename() and link() into encrypted directories.

- Various cleanups.

----------------------------------------------------------------
Chandan Rajendra (3):
      ext4: use IS_ENCRYPTED() to check encryption status
      f2fs: use IS_ENCRYPTED() to check encryption status
      fscrypt: remove filesystem specific build config option

Eric Biggers (2):
      fscrypt: remove CRYPTO_CTR dependency
      fscrypt: return -EXDEV for incompatible rename or link into encrypted dir

Theodore Ts'o (1):
      MAINTAINERS: add Eric Biggers as an fscrypt maintainer

 Documentation/filesystems/fscrypt.rst   |  16 +-
 MAINTAINERS                             |   3 +-
 arch/mips/configs/generic_defconfig     |   2 +-
 arch/nds32/configs/defconfig            |   2 +-
 arch/s390/configs/debug_defconfig       |   2 +-
 arch/s390/configs/performance_defconfig |   2 +-
 fs/crypto/Kconfig                       |   6 +-
 fs/crypto/fscrypt_private.h             |   1 -
 fs/crypto/hooks.c                       |   6 +-
 fs/crypto/policy.c                      |   3 +-
 fs/ext4/Kconfig                         |  15 --
 fs/ext4/dir.c                           |  10 +-
 fs/ext4/ext4.h                          |  12 +-
 fs/ext4/ext4_jbd2.h                     |   2 +-
 fs/ext4/extents.c                       |   4 +-
 fs/ext4/ialloc.c                        |   2 +-
 fs/ext4/inode.c                         |  24 +-
 fs/ext4/ioctl.c                         |   4 +-
 fs/ext4/move_extent.c                   |   3 +-
 fs/ext4/namei.c                         |  18 +-
 fs/ext4/page-io.c                       |   9 +-
 fs/ext4/readpage.c                      |   5 +-
 fs/ext4/super.c                         |   6 +-
 fs/ext4/sysfs.c                         |   4 +-
 fs/f2fs/Kconfig                         |  12 +-
 fs/f2fs/data.c                          |   4 +-
 fs/f2fs/dir.c                           |  10 +-
 fs/f2fs/f2fs.h                          |  14 +-
 fs/f2fs/file.c                          |  10 +-
 fs/f2fs/inode.c                         |   4 +-
 fs/f2fs/namei.c                         |   6 +-
 fs/f2fs/super.c                         |   8 +-
 fs/f2fs/sysfs.c                         |   4 +-
 fs/ubifs/Kconfig                        |  12 +-
 fs/ubifs/Makefile                       |   2 +-
 fs/ubifs/ioctl.c                        |   4 +-
 fs/ubifs/sb.c                           |   2 +-
 fs/ubifs/super.c                        |   2 +-
 fs/ubifs/ubifs.h                        |   5 +-
 include/linux/fs.h                      |   4 +-
 include/linux/fscrypt.h                 | 420 +++++++++++++++++++++++++++++++-
 include/linux/fscrypt_notsupp.h         | 231 ------------------
 include/linux/fscrypt_supp.h            | 204 ----------------
 43 files changed, 518 insertions(+), 601 deletions(-)
 delete mode 100644 include/linux/fscrypt_notsupp.h
 delete mode 100644 include/linux/fscrypt_supp.h
