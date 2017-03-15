Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] generic: test encryption key revocation during concurrent I/O
Date: Tue, 14 Mar 2017 17:25:51 -0700
Message-Id: <20170315002551.9423-1-ebiggers3@gmail.com>
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a test which revokes a keyring key while other processes are
performing I/O on an encrypted file that was "unlocked" using that key.
This crashes unpatched kernels with filesystem encryption enabled, so
place it in the "dangerous" group.

[The patch to fix this is titled "fscrypt: remove broken support for
detecting keyring key revocation" but hasn't been merged yet; we may
want to wait a bit before merging this test.]

Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Michael Halcrow <mhalcrow@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/encrypt        |   8 ++++
 tests/generic/500     | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/500.out |   2 +
 tests/generic/group   |   1 +
 4 files changed, 120 insertions(+)
 create mode 100755 tests/generic/500
 create mode 100644 tests/generic/500.out

diff --git a/common/encrypt b/common/encrypt
index f09104d1..85f71d5b 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -144,3 +144,11 @@ _unlink_encryption_key()
 	local keyid=$($KEYCTL_PROG search @s logon $FSTYP:$keydesc)
 	$KEYCTL_PROG unlink $keyid >>$seqres.full
 }
+
+# Revoke an encryption key from the keyring, given its key descriptor.
+_revoke_encryption_key()
+{
+	local keydesc=$1
+	local keyid=$($KEYCTL_PROG search @s logon $FSTYP:$keydesc)
+	$KEYCTL_PROG revoke $keyid >>$seqres.full
+}
diff --git a/tests/generic/500 b/tests/generic/500
new file mode 100755
index 00000000..44c8e81b
--- /dev/null
+++ b/tests/generic/500
@@ -0,0 +1,109 @@
+#! /bin/bash
+# FS QA Test generic/500
+#
+# Test revoking an encryption key during concurrent I/O.  Regression test for
+# "fscrypt: remove broken support for detecting keyring key revocation".
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
+_supported_fs ext4 f2fs
+_supported_os Linux
+_require_scratch_encryption
+_require_xfs_io_command "set_encpolicy"
+_require_command "$KEYCTL_PROG" keyctl
+
+_new_session_keyring
+_scratch_mkfs_encrypted &>> $seqres.full
+_scratch_mount
+
+dir=$SCRATCH_MNT/encrypted_dir
+file=$dir/file
+
+# 4 processes, 2 MB per process
+nproc=4
+slice=2
+
+# Create an encrypted file and sync its data to disk.
+rm -rf $dir
+mkdir $dir
+keydesc=$(_generate_encryption_key)
+$XFS_IO_PROG -c "set_encpolicy $keydesc" $dir
+$XFS_IO_PROG -f $file -c "pwrite 0 $((nproc*slice))M" -c "fsync" > /dev/null
+
+# Create processes to read from the encrypted file.  Use fadvise to wipe the
+# pagecache before each read, ensuring that each read actually does decryption.
+for ((proc = 0; proc < nproc; proc++)); do
+	(
+		range="$((proc * slice))M ${slice}M"
+		while [ ! -e $tmp.done ]; do
+			$XFS_IO_PROG $file -c "fadvise -d $range" \
+					   -c "pread $range" &> /dev/null
+		done
+	) &
+done
+
+# Wait a second for the readers to start up.
+sleep 1
+
+# Revoke the encryption key.
+keyid=$(_revoke_encryption_key $keydesc)
+
+# Now try to open the file again.  In buggy kernels this caused concurrent
+# readers to crash with a NULL pointer dereference during decryption.
+#
+# Note that the fix also made filenames stop "immediately" reverting to their
+# ciphertext on key revocation.  Therefore, the name of the file we're opening
+# here may be in either plaintext or ciphertext depending on the kernel version,
+# and ciphertext names are unpredictable anyway, so just use 'find' to find it.
+cat $(find $dir -type f) > /dev/null
+
+# Wait for readers to exit
+touch $tmp.done
+wait
+
+# success, all done
+echo "Didn't crash!"
+status=0
+exit
diff --git a/tests/generic/500.out b/tests/generic/500.out
new file mode 100644
index 00000000..b46461f3
--- /dev/null
+++ b/tests/generic/500.out
@@ -0,0 +1,2 @@
+QA output created by 500
+Didn't crash!
diff --git a/tests/generic/group b/tests/generic/group
index f0096bbc..f2c4755c 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -420,3 +420,4 @@
 415 auto clone
 416 auto enospc
 417 auto quick shutdown log
+500 auto quick encrypt dangerous
-- 
2.12.0.367.g23dc2f6d3c-goog
