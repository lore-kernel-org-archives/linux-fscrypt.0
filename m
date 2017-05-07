Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:55508 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752150AbdEGWuC (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 7 May 2017 18:50:02 -0400
Date: Sun, 7 May 2017 14:09:43 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 4.12
Message-ID: <20170507180943.kov5t4o32whivkvz@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 39da7c509acff13fc8cb12ec1bb20337c988ed36:

  Linux 4.11-rc6 (2017-04-09 09:49:44 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to 6f9d696f016f5b42f6c6e8c9f723f8d3380e5903:

  fscrypt: correct collision claim for digested names (2017-05-04 11:44:41 -0400)

----------------------------------------------------------------
Only bug fixes and cleanups for this merge window.

----------------------------------------------------------------
Eric Biggers (13):
      fscrypt: remove unnecessary checks for NULL operations
      fscrypt: remove fscrypt_symlink_data_len()
      fscrypt: fix context consistency check when key(s) unavailable
      ext4: remove "nokey" check from ext4_lookup()
      f2fs: sync f2fs_lookup() with ext4_lookup()
      ubifs: check for consistent encryption contexts in ubifs_lookup()
      fscrypt: avoid collisions when presenting long encrypted filenames
      fscrypt: introduce helper function for filename matching
      ext4: switch to using fscrypt_match_name()
      f2fs: switch to using fscrypt_match_name()
      ext4: clean up ext4_match() and callers
      MAINTAINERS: fscrypt: update mailing list, patchwork, and git
      fscrypt: correct collision claim for digested names

Jaegeuk Kim (1):
      f2fs: check entire encrypted bigname when finding a dentry

Joe Richey (2):
      fscrypt: Move key structure and constants to uapi
      fscrypt: Remove __packed from fscrypt_policy

 MAINTAINERS                     |   6 ++-
 fs/crypto/fname.c               |  90 ++++++++++++++++++++++++++++++++++----------
 fs/crypto/fscrypt_private.h     |  13 -------
 fs/crypto/keyinfo.c             |   3 --
 fs/crypto/policy.c              |  98 ++++++++++++++++++++++++++++++++++--------------
 fs/ext4/namei.c                 | 112 +++++++++++++++----------------------------------------
 fs/f2fs/dir.c                   |  25 +++----------
 fs/f2fs/f2fs.h                  |   3 +-
 fs/f2fs/hash.c                  |   7 +++-
 fs/f2fs/inline.c                |   4 +-
 fs/f2fs/namei.c                 |   7 ++--
 fs/ubifs/dir.c                  |  11 ++++++
 include/linux/fscrypt_common.h  |  11 ------
 include/linux/fscrypt_notsupp.h |   9 +++++
 include/linux/fscrypt_supp.h    |  74 ++++++++++++++++++++++++++++++++++++
 include/uapi/linux/fs.h         |  15 +++++++-
 16 files changed, 301 insertions(+), 187 deletions(-)
