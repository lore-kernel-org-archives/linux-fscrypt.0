Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2] generic: test that encrypted filenames are presented without collisions
Date: Tue, 16 May 2017 15:46:15 -0700
Message-Id: <20170516224615.63974-1-ebiggers3@gmail.com>
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a test which creates many similarly-named files in an encrypted
directory, then verifies they can be deleted without access to the
encryption key.  This is a regression test for two related bugs which
caused presented names to "collide" and point to the wrong inodes.
These bugs were present in the original versions of ext4 and f2fs
encryption, and they were fixed in v4.12-rc1.

Cc: linux-fscrypt@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/500     | 99 +++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/500.out |  4 +++
 tests/generic/group   |  1 +
 3 files changed, 104 insertions(+)
 create mode 100755 tests/generic/500
 create mode 100644 tests/generic/500.out

diff --git a/tests/generic/500 b/tests/generic/500
new file mode 100755
index 00000000..0032fb68
--- /dev/null
+++ b/tests/generic/500
@@ -0,0 +1,99 @@
+#! /bin/bash
+# FS QA Test generic/500
+#
+# Test that without the encryption key for a directory, long filenames are
+# presented in a way which avoids collisions, even though they are abbreviated
+# in order to support names up to NAME_MAX bytes.
+#
+# Regression test for:
+#	6332cd32c829 ("f2fs: check entire encrypted bigname when finding a dentry")
+#	6b06cdee81d6 ("fscrypt: avoid collisions when presenting long encrypted filenames")
+#
+# Even with these two fixes it's still possible to create intentional
+# collisions.  For now this test covers "accidental" collisions only.
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2017 Google, Inc.  All Rights Reserved.
+#
+# Author: Eric Biggers <ebiggers@google.com>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License as
+# published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it would be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write the Free Software Foundation,
+# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+#-----------------------------------------------------------------------
+#
+
+seq=`basename $0`
+seqres=$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=`pwd`
+tmp=/tmp/$$
+status=1	# failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+	cd /
+	rm -f $tmp.*
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+. ./common/encrypt
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+_require_scratch_encryption
+_require_xfs_io_command "set_encpolicy"
+_require_command "$KEYCTL_PROG" keyctl
+
+# set up an encrypted directory
+
+_new_session_keyring
+_scratch_mkfs_encrypted &>> $seqres.full
+_scratch_mount
+mkdir $SCRATCH_MNT/edir
+keydesc=$(_generate_encryption_key)
+# -f 0x2: zero-pad to 16-byte boundary (i.e. encryption block boundary)
+$XFS_IO_PROG -c "set_encpolicy -f 0x2 $keydesc" $SCRATCH_MNT/edir
+
+# Create files with long names (> 32 bytes, long enough to trigger the use of
+# "digested" names) in the encrypted directory.
+#
+# Use 100,000 files so that we have a good chance of detecting buggy filesystems
+# that solely use a 32-bit hash to distinguish files, which f2fs was doing.
+#
+# Furthermore, make the filenames differ only in the last 16-byte encryption
+# block.  This reproduces the bug where it was not accounted for that ciphertext
+# stealing (CTS) causes the last two blocks to appear "flipped".
+seq -f "$SCRATCH_MNT/edir/abcdefghijklmnopqrstuvwxyz012345%.0f" 100000 | xargs touch
+find $SCRATCH_MNT/edir/ -type f | xargs stat -c %i | sort | uniq | wc -l
+
+_unlink_encryption_key $keydesc
+_scratch_cycle_mount
+
+# Verify that every file has a unique inode number and can be removed without
+# error.  With the bug(s), some filenames incorrectly pointed to the same inode,
+# and ext4 reported a "Structure needs cleaning" error when removing files.
+find $SCRATCH_MNT/edir/ -type f | xargs stat -c %i | sort | uniq | wc -l
+rm -rf $SCRATCH_MNT/edir |& head -n 10
+stat $SCRATCH_MNT/edir |& _filter_scratch
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/500.out b/tests/generic/500.out
new file mode 100644
index 00000000..21ee3561
--- /dev/null
+++ b/tests/generic/500.out
@@ -0,0 +1,4 @@
+QA output created by 500
+100000
+100000
+stat: cannot stat 'SCRATCH_MNT/edir': No such file or directory
diff --git a/tests/generic/group b/tests/generic/group
index c4911b86..e754b984 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -437,3 +437,4 @@
 432 auto quick copy
 433 auto quick copy
 434 auto quick copy
+500 auto encrypt
-- 
2.13.0.303.g4ebf302169-goog
