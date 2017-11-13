Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:38030 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751043AbdKMBwD (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 12 Nov 2017 20:52:03 -0500
Date: Sun, 12 Nov 2017 20:52:01 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 4.15
Message-ID: <20171113015201.flarnbi57gsqb5ol@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 9e66317d3c92ddaab330c125dfe9d06eee268aff:

  Linux 4.14-rc3 (2017-10-01 14:54:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt-for-linus

for you to fetch changes up to a0b3bc855374c50b5ea85273553485af48caf2f7:

  fscrypt: lock mutex before checking for bounce page pool (2017-10-31 13:49:25 -0400)

----------------------------------------------------------------
fscrypt: lots of cleanups, mostly courtesy by Eric Biggers

----------------------------------------------------------------
Dave Chinner (1):
      fscrypt: clean up include file mess

Eric Biggers (17):
      fs, fscrypt: add an S_ENCRYPTED inode flag
      fscrypt: switch from ->is_encrypted() to IS_ENCRYPTED()
      fscrypt: remove ->is_encrypted()
      fscrypt: remove unneeded empty fscrypt_operations structs
      fscrypt: new helper function - fscrypt_require_key()
      fscrypt: new helper function - fscrypt_file_open()
      fscrypt: new helper function - fscrypt_prepare_link()
      fscrypt: new helper function - fscrypt_prepare_rename()
      fscrypt: new helper function - fscrypt_prepare_lookup()
      fscrypt: new helper function - fscrypt_prepare_setattr()
      ext4: switch to fscrypt_file_open()
      ext4: switch to fscrypt_prepare_link()
      ext4: switch to fscrypt_prepare_rename()
      ext4: switch to fscrypt_prepare_lookup()
      ext4: switch to fscrypt_prepare_setattr()
      fscrypt: add a documentation file for filesystem-level encryption
      fscrypt: lock mutex before checking for bounce page pool

 Documentation/filesystems/fscrypt.rst | 610 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Documentation/filesystems/index.rst   |  11 ++
 MAINTAINERS                           |   1 +
 fs/crypto/Makefile                    |   2 +-
 fs/crypto/crypto.c                    |   9 +-
 fs/crypto/fname.c                     |   3 +-
 fs/crypto/fscrypt_private.h           |   3 +-
 fs/crypto/hooks.c                     | 112 ++++++++++++
 fs/crypto/keyinfo.c                   |   2 +-
 fs/crypto/policy.c                    |   6 +-
 fs/ext4/ext4.h                        |   8 +-
 fs/ext4/file.c                        |  23 +--
 fs/ext4/inode.c                       |  19 +--
 fs/ext4/namei.c                       |  62 ++-----
 fs/ext4/super.c                       |  15 +-
 fs/f2fs/f2fs.h                        |   9 +-
 fs/f2fs/inode.c                       |   5 +-
 fs/f2fs/super.c                       |   7 +-
 fs/ubifs/crypto.c                     |   1 -
 fs/ubifs/ioctl.c                      |   5 +-
 fs/ubifs/super.c                      |   8 +-
 fs/ubifs/ubifs.h                      |  18 +-
 fs/ubifs/xattr.c                      |   1 +
 include/linux/fs.h                    |   2 +
 include/linux/fscrypt.h               | 293 ++++++++++++++++++++++++++++++++
 include/linux/fscrypt_common.h        | 141 ----------------
 include/linux/fscrypt_notsupp.h       |  39 ++++-
 include/linux/fscrypt_supp.h          |  17 +-
 28 files changed, 1154 insertions(+), 278 deletions(-)
 create mode 100644 Documentation/filesystems/fscrypt.rst
 create mode 100644 fs/crypto/hooks.c
 create mode 100644 include/linux/fscrypt.h
 delete mode 100644 include/linux/fscrypt_common.h
