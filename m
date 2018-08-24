Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41380 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726484AbeHXT6q (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 24 Aug 2018 15:58:46 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 00/10] fs-verity: filesystem-level integrity protection
Date: Fri, 24 Aug 2018 09:16:32 -0700
Message-Id: <20180824161642.1144-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

This RFC patchset implements fs-verity for ext4 and f2fs.  fs-verity is
similar to dm-verity, but implemented on a per-file basis: a Merkle tree
hidden past the end of the file is used to verify the file's data as it
is paged in.  Most of the code is in fs/verity/, and not too many
filesystem-specific changes are needed.  The Merkle tree is written by
userspace before calling an ioctl to mark the file as a verity file; the
file then becomes read-only and the tree is hidden from userspace.

Note: on Monday, Michael Halcrow and I will be giving a talk about
fs-verity at the Linux Security Summit.  fs-verity was also previously
discussed at LSFMM 2018; see https://lwn.net/Articles/752614/.  It was
also previously discussed on linux-fsdevel here:
https://www.spinics.net/lists/linux-fsdevel/msg121182.html

Since fs-verity provides the Merkle tree root hash in constant time and
verifies data blocks on-demand, it is useful for efficiently verifying
the authenticity of, or "appraising", large files of which only a small
portion may be accessed -- such as Android application (APK) files.  It
can also be useful in "audit" use cases where file hashes are logged.
fs-verity also provides better protection against malicious disk
firmware than an ahead-of-time hash, since fs-verity re-verifies data
each time it's paged in.

This patchset doesn't yet include IMA support for fs-verity file
measurements; this is planned and we'd like to collaborate with the IMA
maintainers.  Although fs-verity can be used on its own without IMA,
fs-verity is primarily a lower level feature (think of it as a way of
hashing a file), so some users will probably still need IMA's policy
mechanism.  The patchset *does* include an optional means of including a
signature in the fs-verity metadata and verifying it against the
certificates in an fs-verity keyring; though, this might need to be
re-assessed if it turns out IMA works just as well for that use case.

For now this patchset only supports the case where the fs-verity block
sizes are equal to PAGE_SIZE.  However, the fs-verity block sizes can be
different from the filesystem's block size.

A documentation file in Documentation/filesystems/ is planned but not
yet included.

This patchset is based on Linux v4.18.  It can also be found in git at
tag "fsverity_2018-08-24" of:

	https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git

A userspace utility for fs-verity can be found at:

	https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git

See the README.md file in the userspace utility source tree for examples.

Tests for fs-verity can be found at branch "fsverity" of:

	https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git

On ext4 and f2fs, using fs-verity requires setting the verity feature
flag on your filesystem.  The verity feature flag is supported since
e2fsprogs 1.44.4-2 and f2fs-tools 1.11.0.

Warning: besides the feature bit and inode flag, fs-verity's on-disk
format is not yet stable, i.e. it can still be changed.  Please don't
use this patchset "in production" yet!

Feedback on the design and implementation is greatly appreciated.

Thanks!

Eric Biggers (8):
  fs-verity: add setup code, UAPI, and Kconfig
  fs-verity: add data verification hooks for ->readpages()
  fs-verity: implement FS_IOC_ENABLE_VERITY ioctl
  fs-verity: implement FS_IOC_MEASURE_VERITY ioctl
  fs-verity: add SHA-512 support
  fs-verity: add CRC-32C support
  fs-verity: support builtin file signatures
  f2fs: fs-verity support

Theodore Ts'o (2):
  ext4: add basic fs-verity support
  ext4: add fs-verity read support

 fs/Kconfig                    |   2 +
 fs/Makefile                   |   1 +
 fs/ext4/Kconfig               |  20 +
 fs/ext4/ext4.h                |  22 +-
 fs/ext4/file.c                |   6 +
 fs/ext4/inode.c               |  11 +
 fs/ext4/ioctl.c               |  12 +
 fs/ext4/readpage.c            | 207 ++++++--
 fs/ext4/super.c               |  87 ++++
 fs/ext4/sysfs.c               |   6 +
 fs/f2fs/Kconfig               |  20 +
 fs/f2fs/data.c                |  43 +-
 fs/f2fs/f2fs.h                |  17 +-
 fs/f2fs/file.c                |  58 +++
 fs/f2fs/inode.c               |   3 +-
 fs/f2fs/super.c               |  22 +
 fs/f2fs/sysfs.c               |  11 +
 fs/verity/Kconfig             |  53 ++
 fs/verity/Makefile            |   5 +
 fs/verity/fsverity_private.h  | 136 +++++
 fs/verity/hash_algs.c         | 115 +++++
 fs/verity/ioctl.c             | 170 +++++++
 fs/verity/setup.c             | 931 ++++++++++++++++++++++++++++++++++
 fs/verity/signature.c         | 187 +++++++
 fs/verity/verify.c            | 310 +++++++++++
 include/linux/fs.h            |   9 +
 include/linux/fsverity.h      | 102 ++++
 include/uapi/linux/fsverity.h |  98 ++++
 28 files changed, 2623 insertions(+), 41 deletions(-)
 create mode 100644 fs/verity/Kconfig
 create mode 100644 fs/verity/Makefile
 create mode 100644 fs/verity/fsverity_private.h
 create mode 100644 fs/verity/hash_algs.c
 create mode 100644 fs/verity/ioctl.c
 create mode 100644 fs/verity/setup.c
 create mode 100644 fs/verity/signature.c
 create mode 100644 fs/verity/verify.c
 create mode 100644 include/linux/fsverity.h
 create mode 100644 include/uapi/linux/fsverity.h

-- 
2.18.0
