Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 00/11] fscrypt: add some higher-level helper functions
Date: Mon,  9 Oct 2017 12:15:33 -0700
Message-Id: <20171009191544.43656-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This series prepares to reduce code duplication among ext4, f2fs, and
ubifs by introducing a S_ENCRYPTED inode flag (so we don't have to call
back into the filesystem to test the filesystem-specific inode flag),
then introducing new helper functions that are called at the beginning
of the open, link, rename, lookup, and setattr operations.

In the future we maybe should even call these new helpers from the VFS
so that each individual filesystem doesn't have to do it.  But that's
not possible currently because fs/crypto/ can be built as a module.

The patches to switch the filesystems over to use the helper functions
were included in v1 of this patchset.  They are not included now since
I'm planning to get them picked up by the individual filesystem
maintainers after this goes in.

Changes since v1:
    - Added Dave Chinner's patch to make fscrypt.h include
      fscrypt_supp.h or fscrypt_notsupp.h, then reorganized the helpers
      so that most are defined in fscrypt.h.
    - As noted above, for now omitted the patches to switch the
      individual filesystems over to the new helpers.

Dave Chinner (1):
  fscrypt: clean up include file mess

Eric Biggers (10):
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

 fs/crypto/Makefile              |   2 +-
 fs/crypto/crypto.c              |   2 +-
 fs/crypto/fname.c               |   3 +-
 fs/crypto/fscrypt_private.h     |   3 +-
 fs/crypto/hooks.c               | 112 +++++++++++++++
 fs/crypto/keyinfo.c             |   2 +-
 fs/crypto/policy.c              |   6 +-
 fs/ext4/ext4.h                  |   8 +-
 fs/ext4/inode.c                 |   7 +-
 fs/ext4/super.c                 |  15 +-
 fs/f2fs/f2fs.h                  |   9 +-
 fs/f2fs/inode.c                 |   5 +-
 fs/f2fs/super.c                 |   7 +-
 fs/ubifs/crypto.c               |   1 -
 fs/ubifs/ioctl.c                |   5 +-
 fs/ubifs/super.c                |   8 +-
 fs/ubifs/ubifs.h                |  18 +--
 fs/ubifs/xattr.c                |   1 +
 include/linux/fs.h              |   2 +
 include/linux/fscrypt.h         | 293 ++++++++++++++++++++++++++++++++++++++++
 include/linux/fscrypt_common.h  | 141 -------------------
 include/linux/fscrypt_notsupp.h |  39 +++++-
 include/linux/fscrypt_supp.h    |  17 ++-
 23 files changed, 505 insertions(+), 201 deletions(-)
 create mode 100644 fs/crypto/hooks.c
 create mode 100644 include/linux/fscrypt.h
 delete mode 100644 include/linux/fscrypt_common.h

-- 
2.14.2.920.gcf0c67979c-goog
