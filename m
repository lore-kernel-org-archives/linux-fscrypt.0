Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:42622 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbdHFT1F (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 6 Aug 2017 15:27:05 -0400
Date: Sun, 6 Aug 2017 15:27:03 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] ext4 bug fixes for 4.13
Message-ID: <20170806192703.5xelufkwd2a4jkha@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 16f73eb02d7e1765ccab3d2018e0bd98eb93d973:

  Linux 4.13-rc3 (2017-07-30 12:40:36 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git tags/ext4_for_linus_stable

for you to fetch changes up to 4e5620132144666ab41fc2799fbc055830187b7e:

  ext4: fix copy paste error in ext4_swap_extents() (2017-08-06 01:33:07 -0400)

----------------------------------------------------------------
A large number of ext4 bug fixes and cleanups for v4.13

----------------------------------------------------------------
Andreas Dilger (1):
      ext4: fix dir_nlink behaviour

Arnd Bergmann (1):
      ext4: fix warning about stack corruption

Daeho Jeong (1):
      ext4: release discard bio after sending discard commands

Dan Carpenter (1):
      ext4: silence array overflow warning

Emoly Liu (1):
      ext4: error should be cleared if ea_inode isn't added to the cache

Eric Whitney (2):
      ext4: correct comment references to ext4_ext_direct_IO()
      ext4: remove unused metadata accounting variables

Ernesto A. Fern�ndez (1):
      ext4: preserve i_mode if __ext4_set_acl() fails

Jan Kara (2):
      ext4: Don't clear SGID when inheriting ACLs
      ext4: fix SEEK_HOLE/SEEK_DATA for blocksize < pagesize

Jeff Layton (1):
      ext4: convert swap_inode_data() over to use swap() on most of the fields

Jerry Lee (1):
      ext4: fix overflow caused by missing cast in ext4_resize_fs()

Maninder Singh (1):
      ext4: fix copy paste error in ext4_swap_extents()

Miao Xie (4):
      ext4: fix forgetten xattr lock protection in ext4_expand_extra_isize
      ext4: restructure ext4_expand_extra_isize
      ext4: cleanup ext4_expand_extra_isize_ea()
      ext4, project: expand inode extra size if possible

Tahsin Erdogan (3):
      ext4: remove unused mode parameter
      ext4: inplace xattr block update fails to deduplicate blocks
      ext4: make xattr inode reads faster

 fs/ext4/acl.c               |  25 +++++---
 fs/ext4/ext4.h              |  13 ++--
 fs/ext4/ext4_jbd2.h         |   3 +
 fs/ext4/extents.c           |  11 ++--
 fs/ext4/file.c              |   3 +
 fs/ext4/inode.c             | 198 ++++++++++++++++++++++++++++++++++++++++++++++---------------
 fs/ext4/ioctl.c             |  27 +++++----
 fs/ext4/mballoc.c           |  15 +++--
 fs/ext4/namei.c             |  64 ++++++++------------
 fs/ext4/resize.c            |   3 +-
 fs/ext4/super.c             |   2 -
 fs/ext4/xattr.c             |  87 ++++++++++++++-------------
 include/trace/events/ext4.h |  35 +++--------
 13 files changed, 290 insertions(+), 196 deletions(-)
