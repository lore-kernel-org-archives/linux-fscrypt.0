Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 0/6] fscrypt: fixes for presentation of long encrypted filenames
Date: Mon, 24 Apr 2017 10:00:07 -0700
Message-Id: <20170424170013.85175-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This series fixes the bugs that have been identified with how filesystems handle
presenting long encrypted filenames without the key.

Patch 1 is Jaegeuk's fix to make f2fs start checking the ciphertext portion of
the digested names.  I made one change to this patch which is that to determine
whether we should use the hash from the fscrypt_name structure rather than
compute the hash, we should check for 'disk_name.name' being NULL rather than
'hash' being nonzero, since 0 is a valid hash value.

Patch 2 fixes the bug found on Chrome OS where the wrong part of the ciphertext
was included in the digested names, causing collisions and undeletable files.

Patches 3-6 clean things up to be less insane and confusing, e.g. by introducing
a shared function for name matching and a struct to represent a digested name.

Patches 1-2 will need to be backported and I think they should be merged into
4.12 through the fscrypt tree.  The other patches are nice to have but it's not
a big deal if they need to wait for next cycle.

This patch series leaves out UBIFS; it can be changed to use the common matching
function once available, if desired.

Eric Biggers (5):
  fscrypt: avoid collisions when presenting long encrypted filenames
  fscrypt: introduce helper function for filename matching
  ext4: switch to using fscrypt_match_name()
  f2fs: switch to using fscrypt_match_name()
  ext4: clean up ext4_match() and callers

Jaegeuk Kim (1):
  f2fs: check entire encrypted bigname when finding a dentry

 fs/crypto/fname.c               |  90 +++++++++++++++++++++++++++--------
 fs/crypto/fscrypt_private.h     |   2 -
 fs/ext4/namei.c                 | 103 ++++++++++++----------------------------
 fs/f2fs/dir.c                   |  25 ++--------
 fs/f2fs/f2fs.h                  |   3 +-
 fs/f2fs/hash.c                  |   7 ++-
 fs/f2fs/inline.c                |   4 +-
 include/linux/fscrypt_notsupp.h |   9 ++++
 include/linux/fscrypt_supp.h    |  78 ++++++++++++++++++++++++++++++
 9 files changed, 202 insertions(+), 119 deletions(-)

-- 
2.12.2.816.g2cccc81164-goog
