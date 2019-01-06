Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr800118.outbound.protection.outlook.com ([40.107.80.118]:47055
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726336AbfAFNtV (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 6 Jan 2019 08:49:21 -0500
Date: Sun, 6 Jan 2019 08:49:12 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: [GIT PULL] fscrypt update for 4.21
Message-ID: <20190106134912.GA27028@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

The following changes since commit 7beb01f74415c56f5992922b5b902b45d365e694:

  f2fs: clean up f2fs_sb_has_##feature_name (2018-11-26 15:53:55 -0800)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to 8094c3ceb21ad93896fd4d238e8ba41911932eaf:

  fscrypt: add Adiantum support (2019-01-06 08:36:21 -0500)

----------------------------------------------------------------
Add Adiantum support for fscrypt

----------------------------------------------------------------
Eric Biggers (1):
      fscrypt: add Adiantum support

 Documentation/filesystems/fscrypt.rst | 179 ++++++++++++---------
 fs/crypto/crypto.c                    |  28 ++--
 fs/crypto/fname.c                     |  22 +--
 fs/crypto/fscrypt_private.h           |  67 +++++++-
 fs/crypto/keyinfo.c                   | 351 ++++++++++++++++++++++++++++++++----------
 fs/crypto/policy.c                    |   5 +-
 include/uapi/linux/fs.h               |   4 +-
 7 files changed, 468 insertions(+), 188 deletions(-)
