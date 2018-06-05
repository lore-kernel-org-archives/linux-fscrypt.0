Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:37682 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751701AbeFEPHx (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 11:07:53 -0400
Date: Tue, 5 Jun 2018 11:07:51 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 4.18
Message-ID: <20180605150751.GA9436@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 75bc37fefc4471e718ba8e651aa74673d4e0a9eb:

  Linux 4.17-rc4 (2018-05-06 16:57:38 -1000)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to 4f2f76f751433908364ccff82f437a57d0e6e9b7:

  ext4: fix fencepost error in check for inode count overflow during resize (2018-05-25 12:51:25 -0400)

----------------------------------------------------------------
Add bunch of cleanups, and add support for the Speck128/256
algorithms.  Yes, Speck is contrversial, but the intention is to use
them only for the lowest end Android devices, where the alternative
*really* is no encryption at all for data stored at rest.

----------------------------------------------------------------
Amir Goldstein (3):
      vfs: add the sb_start_intwrite_trylock() helper
      ext4: factor out helper ext4_sample_last_mounted()
      ext4: do not update s_last_mounted of a frozen fs

Eryu Guan (2):
      ext4: use XATTR_CREATE in ext4_initxattrs()
      ext4: use raw i_version value for ea_inode

Jaegeuk Kim (1):
      ext4: handle errors on ext4_commit_super

Jan Kara (2):
      ext4: fix hole length detection in ext4_ind_map_blocks()
      ext4: fix fencepost error in check for inode count overflow during resize

Konstantin Khlebnikov (1):
      ext4: report delalloc reserve as non-free in statfs for project quota

Luis R. Rodriguez (1):
      ext4: add verifier check for symlink with append/immutable flags

Lukas Czerner (1):
      ext4: update mtime in ext4_punch_hole even if no blocks are released

Mathieu Malaterre (1):
      ext4: make function ‘ext4_getfsmap_find_fixed_metadata’ static

Sean Fu (1):
      ext4: remove NULL check before calling kmem_cache_destroy()

Souptick Joarder (1):
      fs: ext4: add new return type vm_fault_t

Theodore Ts'o (3):
      ext4: do not allow external inodes for inline data
      ext4: bubble errors from ext4_find_inline_data_nolock() up to ext4_iget()
      ext4: correctly handle a zero-length xattr with a non-zero e_value_offs

Wang Long (1):
      jbd2: remove NULL check before calling kmem_cache_destroy()

Wang Shilong (5):
      ext4: fix wrong return value in ext4_read_inode_bitmap()
      ext4: add new ext4_mark_group_bitmap_corrupted() helper
      ext4: mark inode bitmap corrupted when found
      ext4: mark block bitmap corrupted when found
      jbd2: remove bunch of empty lines with jbd2 debug

 fs/ext4/balloc.c         | 33 +++++++-------------
 fs/ext4/ext4.h           |  7 +++++
 fs/ext4/extents_status.c |  3 +-
 fs/ext4/file.c           | 93 ++++++++++++++++++++++++++++++++-----------------------
 fs/ext4/fsmap.c          |  4 +--
 fs/ext4/ialloc.c         | 35 +++++++++------------
 fs/ext4/indirect.c       | 14 ++++++---
 fs/ext4/inline.c         |  6 ++++
 fs/ext4/inode.c          | 77 +++++++++++++++++++++++++++++++--------------
 fs/ext4/mballoc.c        | 23 +++++++-------
 fs/ext4/resize.c         |  2 +-
 fs/ext4/super.c          | 68 +++++++++++++++++++++++++++++++---------
 fs/ext4/xattr.c          |  2 +-
 fs/ext4/xattr_security.c |  2 +-
 fs/jbd2/journal.c        | 20 +++++-------
 fs/jbd2/revoke.c         | 12 +++----
 fs/jbd2/transaction.c    |  6 ++--
 include/linux/fs.h       |  5 +++
 18 files changed, 245 insertions(+), 167 deletions(-)
