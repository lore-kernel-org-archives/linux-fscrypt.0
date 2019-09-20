Return-Path: <fstests-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 0/9] xfstests: add tests for fscrypt key management improvements
Date: Thu, 19 Sep 2019 17:37:44 -0700
Message-Id: <20190920003753.40281-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: fstests-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

This patchset adds xfstests for the new fscrypt ioctls that were merged
for 5.4 (https://git.kernel.org/torvalds/c/734d1ed83e1f9b7b), namely the
new ioctls for managing filesystem encryption keys and the new/updated
ioctls for v2 encryption policy support.  It also includes ciphertext
verification tests for v2 encryption policies.

These tests depend on new xfs_io commands, for which I've sent a
separate patchset for xfsprogs.  They also need a kernel built from the
very latest mainline.  As is usual for xfstests, the tests will skip
themselves if the needed prerequisites aren't met.

Note: currently only ext4, f2fs, and ubifs support encryption.  But I
was told previously that since the fscrypt API is generic and may be
supported by XFS in the future, the command-line wrappers for the
fscrypt ioctls should be in xfs_io rather than in xfstests directly
(https://marc.info/?l=fstests&m=147976255831951&w=2).

This version of the xfstests patchset can also be retrieved from tag
"fscrypt-key-mgmt-improvements_2019-09-19" of
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git

Changes since v1:

- Addressed comments from Eryu Guan regarding
  _require_encryption_policy_support().

- In generic/801, handle the fsgqa user having part of their key quota
  already consumed before beginning the test, in order to avoid a false
  test failure on some systems.

Eric Biggers (9):
  common/encrypt: disambiguate session encryption keys
  common/encrypt: add helper functions that wrap new xfs_io commands
  common/encrypt: support checking for v2 encryption policy support
  common/encrypt: support verifying ciphertext of v2 encryption policies
  generic: add basic test for fscrypt API additions
  generic: add test for non-root use of fscrypt API additions
  generic: verify ciphertext of v2 encryption policies with AES-256
  generic: verify ciphertext of v2 encryption policies with AES-128
  generic: verify ciphertext of v2 encryption policies with Adiantum

 common/encrypt           | 181 +++++++++++++++++++----
 src/fscrypt-crypt-util.c | 304 ++++++++++++++++++++++++++++++++++-----
 tests/ext4/024           |   2 +-
 tests/generic/397        |   4 +-
 tests/generic/398        |   8 +-
 tests/generic/399        |   4 +-
 tests/generic/419        |   4 +-
 tests/generic/421        |   4 +-
 tests/generic/429        |   8 +-
 tests/generic/435        |   4 +-
 tests/generic/440        |   8 +-
 tests/generic/800        | 127 ++++++++++++++++
 tests/generic/800.out    |  91 ++++++++++++
 tests/generic/801        | 144 +++++++++++++++++++
 tests/generic/801.out    |  62 ++++++++
 tests/generic/802        |  43 ++++++
 tests/generic/802.out    |   6 +
 tests/generic/803        |  43 ++++++
 tests/generic/803.out    |   6 +
 tests/generic/804        |  45 ++++++
 tests/generic/804.out    |  11 ++
 tests/generic/group      |   5 +
 22 files changed, 1028 insertions(+), 86 deletions(-)
 create mode 100755 tests/generic/800
 create mode 100644 tests/generic/800.out
 create mode 100755 tests/generic/801
 create mode 100644 tests/generic/801.out
 create mode 100755 tests/generic/802
 create mode 100644 tests/generic/802.out
 create mode 100755 tests/generic/803
 create mode 100644 tests/generic/803.out
 create mode 100755 tests/generic/804
 create mode 100644 tests/generic/804.out

-- 
2.23.0.351.gc4317032e6-goog
