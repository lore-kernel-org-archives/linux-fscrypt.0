Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:34250 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752193AbeBDAfj (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 3 Feb 2018 19:35:39 -0500
Date: Sat, 3 Feb 2018 19:35:32 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 4.16
Message-ID: <20180204003532.GA13997@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Note: there will be a merge conflict; please just take the chunk
which calls fscrypt_encrypt_symlink() from the fscrypt tree.  This
will end up dropping the kzalloc() -> f2fs_kzalloc() change, which
means the fscrypt-specific allocation won't get tested by f2fs's
kmalloc error injection system; which is fine.

The ubifs and f2fs changes have been reviewed by their respective
maintainers and I got their approval to run all of these changes
through the fscrypt tree.

	      			      	 - Ted
					 
The following changes since commit 1291a0d5049dbc06baaaf66a9ff3f53db493b19b:

  Linux 4.15-rc4 (2017-12-17 18:59:59 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to 0b1dfa4cc6c60052b2c30ead316fa84c46d3c43c:

  fscrypt: fix build with pre-4.6 gcc versions (2018-02-01 10:51:18 -0500)

----------------------------------------------------------------
Refactor support for encrypted symlinks to move common code to fscrypt.

----------------------------------------------------------------
Eric Biggers (26):
      fscrypt: move fscrypt_has_encryption_key() to supp/notsupp headers
      fscrypt: move fscrypt_control_page() to supp/notsupp headers
      fscrypt: move fscrypt_info_cachep declaration to fscrypt_private.h
      fscrypt: move fscrypt_ctx declaration to fscrypt_supp.h
      fscrypt: split fscrypt_dummy_context_enabled() into supp/notsupp versions
      fscrypt: move fscrypt_operations declaration to fscrypt_supp.h
      fscrypt: move fscrypt_valid_enc_modes() to fscrypt_private.h
      fscrypt: move fscrypt_is_dot_dotdot() to fs/crypto/fname.c
      fscrypt: trim down fscrypt.h includes
      fscrypt: new helper functions for ->symlink()
      fscrypt: new helper function - fscrypt_get_symlink()
      ext4: switch to fscrypt ->symlink() helper functions
      ext4: switch to fscrypt_get_symlink()
      f2fs: switch to fscrypt ->symlink() helper functions
      f2fs: switch to fscrypt_get_symlink()
      ubifs: free the encrypted symlink target
      ubifs: switch to fscrypt ->symlink() helper functions
      ubifs: switch to fscrypt_get_symlink()
      fscrypt: remove fscrypt_fname_usr_to_disk()
      fscrypt: move fscrypt_symlink_data to fscrypt_private.h
      fscrypt: calculate NUL-padding length in one place only
      fscrypt: define fscrypt_fname_alloc_buffer() to be for presented names
      fscrypt: fix up fscrypt_fname_encrypted_size() for internal use
      fscrypt: document symlink length restriction
      fscrypt: remove 'ci' parameter from fscrypt_put_encryption_info()
      fscrypt: fix build with pre-4.6 gcc versions

 Documentation/filesystems/fscrypt.rst |  10 ++++-
 fs/crypto/crypto.c                    |   1 +
 fs/crypto/fname.c                     | 140 +++++++++++++++++++++++++++----------------------------------
 fs/crypto/fscrypt_private.h           |  31 ++++++++++++++
 fs/crypto/hooks.c                     | 158 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/crypto/keyinfo.c                   |  17 ++------
 fs/ext4/namei.c                       |  58 +++++++-------------------
 fs/ext4/super.c                       |   4 +-
 fs/ext4/symlink.c                     |  43 +++----------------
 fs/f2fs/inode.c                       |   2 +-
 fs/f2fs/namei.c                       | 132 +++++++++++----------------------------------------------
 fs/ubifs/dir.c                        |  63 +++++++---------------------
 fs/ubifs/file.c                       |  36 +---------------
 fs/ubifs/super.c                      |   4 +-
 include/linux/fscrypt.h               | 174 +++++++++++++++++++++++++++++-----------------------------------------------
 include/linux/fscrypt_notsupp.h       |  59 ++++++++++++++++++--------
 include/linux/fscrypt_supp.h          |  68 +++++++++++++++++++++++++++---
 17 files changed, 500 insertions(+), 500 deletions(-)
