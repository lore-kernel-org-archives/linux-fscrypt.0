Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33492 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726011AbfHKVhN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Aug 2019 17:37:13 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/6] fs-verity fixups
Date: Sun, 11 Aug 2019 14:35:51 -0700
Message-Id: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

A few fixes and cleanups for fs-verity.

If there are no objections, I'll fold these into the original patches.

Eric Biggers (6):
  fs-verity: fix crash on read error in build_merkle_tree_level()
  ext4: skip truncate when verity in progress in ->write_begin()
  f2fs: skip truncate when verity in progress in ->write_begin()
  ext4: remove ext4_bio_encrypted()
  ext4: fix comment in ext4_end_enable_verity()
  f2fs: use EFSCORRUPTED in f2fs_get_verity_descriptor()

 fs/ext4/inode.c    |  7 +++++--
 fs/ext4/readpage.c |  9 ---------
 fs/ext4/verity.c   |  2 +-
 fs/f2fs/data.c     |  2 +-
 fs/f2fs/verity.c   |  2 +-
 fs/verity/enable.c | 24 ++++++++++++++++--------
 6 files changed, 24 insertions(+), 22 deletions(-)

-- 
2.22.0
