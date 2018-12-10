Return-Path: <fstests-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/7] xfstests: add fs-verity tests
Date: Mon, 10 Dec 2018 14:21:35 -0800
Message-Id: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: fstests-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Add tests for fs-verity, a new feature for read-only file-based
authenticity protection.  fs-verity will be supported by ext4 and f2fs,
and perhaps other filesystems later.  Running these tests requires:

- A kernel with the fs-verity patches from
  https://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git/log/
  (should be merged in 4.21) and configured with CONFIG_FS_VERITY.
- The fsverity utility program, which can be installed from
  https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/fsverity-utils.git/
- e2fsprogs v1.44.4-2 or later for ext4 tests, or f2fs-tools v1.11.0 or
  later for f2fs tests.

Example with kvm-xfstests:

	$ kvm-xfstests -c ext4,f2fs -g verity

See the file Documentation/filesystem/fsverity.rst in the kernel tree
for more information about fs-verity.

Eric Biggers (7):
  common/verity: add common functions for testing fs-verity
  generic: test general behavior of verity files
  generic: test access controls on the fs-verity ioctls
  generic: test fs-verity descriptor validation
  generic: test corrupting verity files
  generic: test that fs-verity is using the correct measurement values
  generic: test using fs-verity and fscrypt simultaneously

 common/config         |   1 +
 common/verity         | 198 ++++++++++++++++++++++++++
 tests/generic/900     | 165 +++++++++++++++++++++
 tests/generic/900.out |  54 +++++++
 tests/generic/901     |  71 ++++++++++
 tests/generic/901.out |  14 ++
 tests/generic/902     | 323 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/902.out | 125 ++++++++++++++++
 tests/generic/903     | 126 ++++++++++++++++
 tests/generic/903.out |  91 ++++++++++++
 tests/generic/904     | 124 ++++++++++++++++
 tests/generic/904.out |   7 +
 tests/generic/905     |  81 +++++++++++
 tests/generic/905.out |  12 ++
 tests/generic/group   |   6 +
 15 files changed, 1398 insertions(+)
 create mode 100644 common/verity
 create mode 100755 tests/generic/900
 create mode 100644 tests/generic/900.out
 create mode 100755 tests/generic/901
 create mode 100644 tests/generic/901.out
 create mode 100755 tests/generic/902
 create mode 100644 tests/generic/902.out
 create mode 100755 tests/generic/903
 create mode 100644 tests/generic/903.out
 create mode 100755 tests/generic/904
 create mode 100644 tests/generic/904.out
 create mode 100755 tests/generic/905
 create mode 100644 tests/generic/905.out

-- 
2.20.0.rc2.403.gdbc3b29805-goog
