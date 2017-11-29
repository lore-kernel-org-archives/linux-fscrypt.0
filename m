Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 0/5] f2fs: switch to new fscrypt helper functions
Date: Wed, 29 Nov 2017 12:35:27 -0800
Message-Id: <20171129203532.87729-1-ebiggers3@gmail.com>
To: linux-f2fs-devel@lists.sourceforge.net
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This series switches f2fs to use the fscrypt helper functions for
open/link/rename/lookup/setattr introduced in v4.15.

These patches were originally sent in "[PATCH 00/25] fscrypt: add some
higher-level helper functions".  I've rebased them onto v4.15-rc1.

Eric Biggers (5):
  f2fs: switch to fscrypt_file_open()
  f2fs: switch to fscrypt_prepare_link()
  f2fs: switch to fscrypt_prepare_rename()
  f2fs: switch to fscrypt_prepare_lookup()
  f2fs: switch to fscrypt_prepare_setattr()

 fs/f2fs/file.c  | 30 +++++++-----------------------
 fs/f2fs/namei.c | 54 +++++++++++++-----------------------------------------
 2 files changed, 20 insertions(+), 64 deletions(-)

-- 
2.15.0.531.g2ccb3012c9-goog
