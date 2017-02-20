Return-Path: <linux-fsdevel-owner@vger.kernel.org>
Date: Mon, 20 Feb 2017 15:27:03 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] fscrypt update for 4.11
Message-ID: <20170220202703.yw4cri7gloicu34j@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux FS Dev Mailing List <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 42d97eb0ade31e1bc537d086842f5d6e766d9d51:

  fscrypt: fix renaming and linking special files (2016-12-31 00:47:05 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt-for-linus

for you to fetch changes up to 6f69f0ed6136c302976f8e8f859b73d47f0c0c5c:

  fscrypt: constify struct fscrypt_operations (2017-02-08 10:59:57 -0500)

----------------------------------------------------------------
Various cleanups for the file system encryption feature.

----------------------------------------------------------------
Colin Ian King (1):
      fscrypt: remove redundant assignment of res

Eric Biggers (9):
      fscrypt: use ENOKEY when file cannot be created w/o key
      fscrypt: use ENOTDIR when setting encryption policy on nondirectory
      fscrypt: use EEXIST when file already uses different policy
      fscrypt: remove user-triggerable warning messages
      fscrypt: pass up error codes from ->get_context()
      fscrypt: remove unused 'mode' member of fscrypt_ctx
      fscrypt: make fscrypt_operations.key_prefix a string
      fscrypt: split supp and notsupp declarations into their own headers
      fscrypt: constify struct fscrypt_operations

Richard Weinberger (2):
      fscrypt: factor out bio specific functions
      fscrypt: properly declare on-stack completion

Theodore Ts'o (2):
      fscrypt: make test_dummy_encryption require a keyring key
      ext4: don't allow encrypted operations without keys

 MAINTAINERS                     |   2 +-
 fs/crypto/Kconfig               |   1 -
 fs/crypto/Makefile              |   1 +
 fs/crypto/bio.c                 | 145 ++++++++++++++++++++++++++++++
 fs/crypto/crypto.c              | 157 ++++----------------------------
 fs/crypto/fname.c               |   4 +-
 fs/crypto/fscrypt_private.h     |  20 ++++-
 fs/crypto/keyinfo.c             |  45 ++++------
 fs/crypto/policy.c              |  95 +++++++-------------
 fs/ext4/ext4.h                  |  39 ++------
 fs/ext4/ialloc.c                |   2 +-
 fs/ext4/namei.c                 |  16 +++-
 fs/ext4/page-io.c               |   1 -
 fs/ext4/super.c                 |  17 +---
 fs/f2fs/dir.c                   |   5 +-
 fs/f2fs/f2fs.h                  |  39 ++------
 fs/f2fs/namei.c                 |   4 +-
 fs/f2fs/super.c                 |  18 +---
 fs/ubifs/crypto.c               |  13 +--
 fs/ubifs/super.c                |   2 +-
 fs/ubifs/ubifs.h                |  30 ++-----
 include/linux/fscrypt_common.h  | 146 ++++++++++++++++++++++++++++++
 include/linux/fscrypt_notsupp.h | 168 ++++++++++++++++++++++++++++++++++
 include/linux/fscrypt_supp.h    |  66 ++++++++++++++
 include/linux/fscrypto.h        | 345 ----------------------------------------------------------------------
 25 files changed, 659 insertions(+), 722 deletions(-)
 create mode 100644 fs/crypto/bio.c
 create mode 100644 include/linux/fscrypt_common.h
 create mode 100644 include/linux/fscrypt_notsupp.h
 create mode 100644 include/linux/fscrypt_supp.h
 delete mode 100644 include/linux/fscrypto.h
