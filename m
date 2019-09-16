Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Sun, 15 Sep 2019 22:20:53 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190916052053.GB8269@sol.localdomain>
MIME-Version: 1.0
Content-Disposition: inline
Subject: [f2fs-dev] [GIT PULL] fs-verity for 5.4
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 609488bc979f99f805f34e9a32c1e3b71179d10b:

  Linux 5.3-rc2 (2019-07-28 12:47:02 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fsverity-for-linus

for you to fetch changes up to 95ae251fe82838b85c6d37e5a1775006e2a42ae0:

  f2fs: add fs-verity support (2019-08-12 19:33:51 -0700)

----------------------------------------------------------------
Hi Linus,

Please consider pulling fs-verity for 5.4.

fs-verity is a filesystem feature that provides Merkle tree based
hashing (similar to dm-verity) for individual readonly files, mainly for
the purpose of efficient authenticity verification.

This pull request includes:

(a) The fs/verity/ support layer and documentation.

(b) fs-verity support for ext4 and f2fs.

Compared to the original fs-verity patchset from last year, the UAPI to
enable fs-verity on a file has been greatly simplified.  Lots of other
things were cleaned up too.

fs-verity is planned to be used by two different projects on Android;
most of the userspace code is in place already.  Another userspace tool
("fsverity-utils"), and xfstests, are also available.  e2fsprogs and
f2fs-tools already have fs-verity support.  Other people have shown
interest in using fs-verity too.

I've tested this on ext4 and f2fs with xfstests, both the existing tests
and the new fs-verity tests.  This has also been in linux-next since
July 30 with no reported issues except a couple minor ones I found
myself and folded in fixes for.

Ted and I will be co-maintaining fs-verity.


There will be some fairly straightforward merge conflicts with the ext4
and f2fs trees.  I've tested the resolution of these in linux-next.

This will also "silently" conflict (compiler warning only) with the key
ACLs patchset, if you merge it again this cycle.  The resolution is to
translate the key permissions to an ACL in fs/verity/signature.c.  I
suggest using the resolution in linux-next, which I've tested.  This
resolution avoids making any behavior changes; note that some of the old
permissions map to multiple new permissions.

----------------------------------------------------------------
Eric Biggers (17):
      fs-verity: add a documentation file
      fs-verity: add MAINTAINERS file entry
      fs-verity: add UAPI header
      fs: uapi: define verity bit for FS_IOC_GETFLAGS
      fs-verity: add Kconfig and the helper functions for hashing
      fs-verity: add inode and superblock fields
      fs-verity: add the hook for file ->open()
      fs-verity: add the hook for file ->setattr()
      fs-verity: add data verification hooks for ->readpages()
      fs-verity: implement FS_IOC_ENABLE_VERITY ioctl
      fs-verity: implement FS_IOC_MEASURE_VERITY ioctl
      fs-verity: add SHA-512 support
      fs-verity: support builtin file signatures
      ext4: add basic fs-verity support
      ext4: add fs-verity read support
      ext4: update on-disk format documentation for fs-verity
      f2fs: add fs-verity support

 Documentation/filesystems/ext4/inodes.rst   |   6 +-
 Documentation/filesystems/ext4/overview.rst |   1 +
 Documentation/filesystems/ext4/super.rst    |   2 +
 Documentation/filesystems/ext4/verity.rst   |  41 ++
 Documentation/filesystems/fsverity.rst      | 726 ++++++++++++++++++++++++++++
 Documentation/filesystems/index.rst         |   1 +
 Documentation/ioctl/ioctl-number.rst        |   1 +
 MAINTAINERS                                 |  12 +
 fs/Kconfig                                  |   2 +
 fs/Makefile                                 |   1 +
 fs/ext4/Makefile                            |   1 +
 fs/ext4/ext4.h                              |  23 +-
 fs/ext4/file.c                              |   4 +
 fs/ext4/inode.c                             |  55 ++-
 fs/ext4/ioctl.c                             |  13 +
 fs/ext4/readpage.c                          | 211 ++++++--
 fs/ext4/super.c                             |  18 +-
 fs/ext4/sysfs.c                             |   6 +
 fs/ext4/verity.c                            | 367 ++++++++++++++
 fs/f2fs/Makefile                            |   1 +
 fs/f2fs/data.c                              |  75 ++-
 fs/f2fs/f2fs.h                              |  20 +-
 fs/f2fs/file.c                              |  43 +-
 fs/f2fs/inode.c                             |   5 +-
 fs/f2fs/super.c                             |   3 +
 fs/f2fs/sysfs.c                             |  11 +
 fs/f2fs/verity.c                            | 247 ++++++++++
 fs/f2fs/xattr.h                             |   2 +
 fs/verity/Kconfig                           |  55 +++
 fs/verity/Makefile                          |  10 +
 fs/verity/enable.c                          | 377 +++++++++++++++
 fs/verity/fsverity_private.h                | 185 +++++++
 fs/verity/hash_algs.c                       | 280 +++++++++++
 fs/verity/init.c                            |  61 +++
 fs/verity/measure.c                         |  57 +++
 fs/verity/open.c                            | 356 ++++++++++++++
 fs/verity/signature.c                       | 157 ++++++
 fs/verity/verify.c                          | 281 +++++++++++
 include/linux/fs.h                          |  11 +
 include/linux/fsverity.h                    | 211 ++++++++
 include/uapi/linux/fs.h                     |   1 +
 include/uapi/linux/fsverity.h               |  40 ++
 42 files changed, 3910 insertions(+), 70 deletions(-)
 create mode 100644 Documentation/filesystems/ext4/verity.rst
 create mode 100644 Documentation/filesystems/fsverity.rst
 create mode 100644 fs/ext4/verity.c
 create mode 100644 fs/f2fs/verity.c
 create mode 100644 fs/verity/Kconfig
 create mode 100644 fs/verity/Makefile
 create mode 100644 fs/verity/enable.c
 create mode 100644 fs/verity/fsverity_private.h
 create mode 100644 fs/verity/hash_algs.c
 create mode 100644 fs/verity/init.c
 create mode 100644 fs/verity/measure.c
 create mode 100644 fs/verity/open.c
 create mode 100644 fs/verity/signature.c
 create mode 100644 fs/verity/verify.c
 create mode 100644 include/linux/fsverity.h
 create mode 100644 include/uapi/linux/fsverity.h


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
