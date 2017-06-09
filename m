Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] generic: test for buggy fscrypt context consistency check
Date: Fri,  9 Jun 2017 15:36:33 -0700
Message-Id: <20170609223633.24882-1-ebiggers3@gmail.com>
To: fstests@vger.kernel.org
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a regression test for a bug where ->lookup() in an encrypted
directory would incorrectly return EPERM, depending on which inodes
happened to have their keys still cached in memory following removal of
the keyring key.  This bug was fixed in v4.12-rc1, v4.9.29, and v4.4.70.

Cc: linux-fscrypt@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/500     | 114 ++++++++++++++++++++++++++++++++++++++++++++++++++
 tests/generic/500.out |  13 ++++++
 tests/generic/group   |   1 +
 3 files changed, 128 insertions(+)
 create mode 100755 tests/generic/500
 create mode 100644 tests/generic/500.out

diff --git a/tests/generic/500 b/tests/generic/500
new file mode 100755
index 00000000..01af62a1
--- /dev/null
+++ b/tests/generic/500
@@ -0,0 +1,114 @@
+#! /bin/bash
+# FS QA Test generic/500
+#
+# Test that when the filesystem tries to enforce that all files in a directory
+# tree use the same encryption policy, it doesn't get confused and incorrectly
+# return EPERM in cases where the parent's key is cached but not the child's, or
+# vice versa.  Such situations can arise following removal of the master key
+# from the keyring.  Regression test for:
+#	272f98f68462 ("fscrypt: fix context consistency check when key(s) unavailable")
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
+# Set up an encryption-capable filesystem and an encryption key.
+_new_session_keyring
+_scratch_mkfs_encrypted &>> $seqres.full
+_scratch_mount
+keydesc=$(_generate_key_descriptor)
+raw_key=$(_generate_raw_encryption_key)
+_add_encryption_key $keydesc $raw_key
+
+# Set up an encrypted directory containing a regular file, a subdirectory, and a
+# symlink.
+mkdir $SCRATCH_MNT/edir
+$XFS_IO_PROG -c "set_encpolicy $keydesc" $SCRATCH_MNT/edir
+mkdir $SCRATCH_MNT/edir/subdir
+ln -s target $SCRATCH_MNT/edir/symlink
+echo contents > $SCRATCH_MNT/edir/file
+
+# Starting from a fresh mount (no inodes have their encryption key cached),
+# reproduce the situation where an encrypted file *without* its key cached is
+# looked up or opened from within a directory *with* its key cached, and no key
+# is in the keyring.  Try with a regular file, a directory, and a symlink.
+_scratch_cycle_mount
+echo
+echo "***** Parent has key, but child doesn't *****"
+exec 3< $SCRATCH_MNT/edir # pin inode with cached key in memory
+ls $SCRATCH_MNT/edir | sort
+_unlink_encryption_key $keydesc
+cat $SCRATCH_MNT/edir/file |& _filter_scratch
+ls $SCRATCH_MNT/edir/subdir
+cat $SCRATCH_MNT/edir/symlink |& _filter_scratch
+exec 3>&-
+
+# Now, the inverse: an encrypted file *with* its key cached is looked up or
+# opened from within a directory *without* its key cached, and no key is in the
+# keyring.  This is most easily reproducible using a hard link.  Note: the
+# expected behavior (at least, until we have a real API for revoking filesystem
+# encryption keys) is that we should still be able to open the file and read its
+# plaintext contents, even though its filename is shown in ciphertext!
+echo
+echo "***** Child has key, but parent doesn't *****"
+_add_encryption_key $keydesc $raw_key
+mkdir $SCRATCH_MNT/edir2
+$XFS_IO_PROG -c "set_encpolicy $keydesc" $SCRATCH_MNT/edir2
+ln $SCRATCH_MNT/edir/file $SCRATCH_MNT/edir2/link
+_scratch_cycle_mount
+cat $SCRATCH_MNT/edir2/link
+exec 3< $SCRATCH_MNT/edir2/link # pin inode with cached key in memory
+_unlink_encryption_key $keydesc
+stat $SCRATCH_MNT/edir/file |& _filter_scratch
+cat "$(find $SCRATCH_MNT/edir/ -type f)"
+exec 3>&-
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/500.out b/tests/generic/500.out
new file mode 100644
index 00000000..fcbbc109
--- /dev/null
+++ b/tests/generic/500.out
@@ -0,0 +1,13 @@
+QA output created by 500
+
+***** Parent has key, but child doesn't *****
+file
+subdir
+symlink
+cat: SCRATCH_MNT/edir/file: Required key not available
+cat: SCRATCH_MNT/edir/symlink: No such file or directory
+
+***** Child has key, but parent doesn't *****
+contents
+stat: cannot stat 'SCRATCH_MNT/edir/file': No such file or directory
+contents
diff --git a/tests/generic/group b/tests/generic/group
index 5d3e4dcf..e35bb99a 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -442,3 +442,4 @@
 437 auto quick
 438 auto
 439 auto quick punch
+500 auto quick encrypt
-- 
2.13.1.508.gb3defc5cc-goog
