Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 0/4] fscrypt context consistency check fixes
Date: Fri,  7 Apr 2017 10:58:36 -0700
Message-Id: <20170407175840.95740-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This patchset fixes fscrypt_has_permitted_context() to correctly handle cases
where one or both encryption keys are missing, then updates the ->lookup()
methods for ext4, f2fs, and ubifs to be consistent in how they handle the
encryption context consistency check.

Eric Biggers (4):
  fscrypt: fix context consistency check when key(s) unavailable
  ext4: remove "nokey" check from ext4_lookup()
  f2fs: sync f2fs_lookup() with ext4_lookup()
  ubifs: check for consistent encryption contexts in ubifs_lookup()

 fs/crypto/policy.c | 87 ++++++++++++++++++++++++++++++++++++++++++------------
 fs/ext4/namei.c    |  9 +-----
 fs/f2fs/namei.c    |  7 +++--
 fs/ubifs/dir.c     | 11 +++++++
 4 files changed, 84 insertions(+), 30 deletions(-)

-- 
2.12.2.715.g7642488e1d-goog
