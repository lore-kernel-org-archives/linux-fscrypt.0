Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47038 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726014AbfDJU0J (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 10 Apr 2019 16:26:09 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 0/2] fscrypt: improve encrypted symlink performance
Date: Wed, 10 Apr 2019 13:21:13 -0700
Message-Id: <20190410202115.64501-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

This series improves the performance of following encrypted symlinks on
ext4, f2fs, and ubifs.

Eric Biggers (2):
  vfs: use READ_ONCE() to access ->i_link
  fscrypt: cache decrypted symlink target in ->i_link

 fs/crypto/hooks.c       | 40 +++++++++++++++++++++++++++++++++-------
 fs/crypto/keyinfo.c     | 21 +++++++++++++++++++++
 fs/ext4/super.c         |  3 +++
 fs/f2fs/super.c         |  3 +++
 fs/namei.c              |  4 ++--
 fs/ubifs/super.c        |  3 +++
 include/linux/fscrypt.h |  5 +++++
 7 files changed, 70 insertions(+), 9 deletions(-)

-- 
2.21.0.392.gf8f6787159e-goog
