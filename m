Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:41862 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726091AbfEGXar (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 May 2019 19:30:47 -0400
Date: Tue, 7 May 2019 19:30:42 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 5.2
Message-ID: <20190507233042.GA28476@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit dc4060a5dc2557e6b5aa813bf5b73677299d62d2:

  Linux 5.1-rc5 (2019-04-14 15:17:41 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to 2c58d548f5706d085c4b009f6abb945220460632:

  fscrypt: cache decrypted symlink target in ->i_link (2019-04-17 12:43:29 -0400)

----------------------------------------------------------------
Clean up fscrypt's dcache revalidation support, and other
miscellaneous cleanups.

----------------------------------------------------------------
Eric Biggers (10):
      fscrypt: drop inode argument from fscrypt_get_ctx()
      fscrypt: remove WARN_ON_ONCE() when decryption fails
      fscrypt: use READ_ONCE() to access ->i_crypt_info
      fscrypt: clean up and improve dentry revalidation
      fscrypt: fix race allowing rename() and link() of ciphertext dentries
      fs, fscrypt: clear DCACHE_ENCRYPTED_NAME when unaliasing directory
      fscrypt: only set dentry_operations on ciphertext dentries
      fscrypt: fix race where ->lookup() marks plaintext dentry as ciphertext
      vfs: use READ_ONCE() to access ->i_link
      fscrypt: cache decrypted symlink target in ->i_link

 fs/crypto/bio.c         |  8 +++-----
 fs/crypto/crypto.c      | 74 ++++++++++++++++++++++++++++++++++-------------------------------------
 fs/crypto/fname.c       |  5 +++--
 fs/crypto/hooks.c       | 68 +++++++++++++++++++++++++++++++++++++++++++++++++----------------
 fs/crypto/keyinfo.c     | 25 ++++++++++++++++++++++--
 fs/crypto/policy.c      |  6 +++---
 fs/dcache.c             |  2 ++
 fs/ext4/ext4.h          | 62 ++++++++++++++++++++++++++++++++++++++++++++---------------
 fs/ext4/namei.c         | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++-----------------------
 fs/ext4/readpage.c      |  2 +-
 fs/ext4/super.c         |  3 +++
 fs/f2fs/namei.c         | 17 ++++++++++-------
 fs/f2fs/super.c         |  3 +++
 fs/namei.c              |  4 ++--
 fs/ubifs/dir.c          |  8 +++-----
 fs/ubifs/super.c        |  3 +++
 include/linux/dcache.h  |  2 +-
 include/linux/fscrypt.h | 74 ++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 18 files changed, 298 insertions(+), 144 deletions(-)
