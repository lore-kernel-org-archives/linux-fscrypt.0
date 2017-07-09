Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:60062 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751654AbdGICu6 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 8 Jul 2017 22:50:58 -0400
Date: Sat, 8 Jul 2017 22:50:55 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: [GIT PULL] fscrypt updates for 4.13
Message-ID: <20170709025054.77apuvywuhkwbcbn@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 3c2993b8c6143d8a5793746a54eba8f86f95240f:

  Linux 4.12-rc4 (2017-06-04 16:47:43 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to c250b7dd8e73b5f7d88d231fbaac92e3360a7234:

  fscrypt: make ->dummy_context() return bool (2017-06-23 20:11:50 -0400)

----------------------------------------------------------------
Add support for 128-bit AES and some cleanups to fscrypt

----------------------------------------------------------------
Daniel Walter (1):
      fscrypt: add support for AES-128-CBC

Eric Biggers (2):
      fscrypt: inline fscrypt_free_filename()
      fscrypt: make ->dummy_context() return bool

 fs/crypto/Kconfig              |   1 +
 fs/crypto/crypto.c             |  23 +++++++---
 fs/crypto/fname.c              |   9 ----
 fs/crypto/fscrypt_private.h    |   9 +++-
 fs/crypto/keyinfo.c            | 173 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----------------
 fs/crypto/policy.c             |   8 +---
 fs/ext4/super.c                |   2 +-
 include/linux/fscrypt_common.h |  18 +++++---
 include/linux/fscrypt_supp.h   |   7 ++-
 include/uapi/linux/fs.h        |   2 +
 10 files changed, 182 insertions(+), 70 deletions(-)
