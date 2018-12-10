Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53510 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729596AbeLJWZt (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Dec 2018 17:25:49 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 2/7] generic: test general behavior of verity files
Date: Mon, 10 Dec 2018 14:21:37 -0800
Message-Id: <20181210222142.222342-3-ebiggers@kernel.org>
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This is a basic fs-verity test which verifies:

- conditions for enabling verity
- verity files have expected contents and size
- can't write to verity files
- can retrieve a verity file's measurement via FS_IOC_MEASURE_VERITY

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/900     | 165 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/900.out |  54 ++++++++++++++
 tests/generic/group   |   1 +
 3 files changed, 220 insertions(+)
 create mode 100755 tests/generic/900
 create mode 100644 tests/generic/900.out

diff --git a/tests/generic/900 b/tests/generic/900
new file mode 100755
index 00000000..0553b80d
--- /dev/null
+++ b/tests/generic/900
@@ -0,0 +1,165 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/900
+#
+# This is a basic fs-verity test which verifies:
+#
+# - conditions for enabling verity
+# - verity files have correct contents and size
+# - can't write to verity files
+# - can retrieve a verity file's measurement via FS_IOC_MEASURE_VERITY
+#
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
+. ./common/verity
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+_require_scratch_verity
+
+_scratch_mkfs_verity &>> $seqres.full
+_scratch_mount
+fsv_orig_file=$SCRATCH_MNT/file
+fsv_file=$SCRATCH_MNT/file.fsv
+
+verify_data_readable()
+{
+	local file=$1
+
+	md5sum $file > /dev/null
+}
+
+verify_data_unreadable()
+{
+	local file=$1
+
+	# try both reading just the first data block, and reading until EOF
+	head -c $FSV_BLOCK_SIZE $file 2>&1 >/dev/null | _filter_scratch
+	md5sum $file |& _filter_scratch
+}
+
+_fsv_begin_subtest "Enabling fs-verity on directory fails with EISDIR"
+mkdir $SCRATCH_MNT/dir
+_fsv_enable $SCRATCH_MNT/dir |& _filter_scratch
+
+_fsv_begin_subtest "Enabling fs-verity on file open for writing fails with ETXTBSY"
+_fsv_create_setup_file $fsv_file >> $seqres.full
+exec 3<> "$fsv_file"
+_fsv_enable $fsv_file |& _filter_scratch
+exec 3<&-
+verify_data_readable $fsv_file
+
+_fsv_begin_subtest "Enabling fs-verity on file on read-only filesystem fails with EROFS"
+_fsv_create_setup_file $fsv_file >> $seqres.full
+_scratch_remount ro
+_fsv_enable $fsv_file |& _filter_scratch
+_scratch_remount rw
+
+_fsv_begin_subtest "Enabling fs-verity on a file twice fails with EEXIST"
+_fsv_create_setup_file $fsv_file >> $seqres.full
+_fsv_enable $fsv_file
+echo "(trying again)"
+_fsv_enable $fsv_file |& _filter_scratch
+
+_fsv_begin_subtest "fs-verity file can't be opened for writing"
+_fsv_create_enable_file $fsv_file >> $seqres.full
+echo "* reading"
+$XFS_IO_PROG -r $fsv_file -c ''
+echo "* xfs_io writing, should be O_RDWR"
+$XFS_IO_PROG $fsv_file -c '' |& _filter_scratch
+echo "* bash >>, should be O_APPEND"
+bash -c "echo >> $fsv_file" |& _filter_scratch
+echo "* bash >, should be O_WRONLY|O_CREAT|O_TRUNC"
+bash -c "echo > $fsv_file" |& _filter_scratch
+
+_fsv_begin_subtest "fs-verity file can be read"
+_fsv_create_enable_file $fsv_file >> $seqres.full
+verify_data_readable $fsv_file
+
+_fsv_begin_subtest "fs-verity file reports measurement calculated earlier"
+head -c 100000 /dev/urandom > $fsv_orig_file
+expected_hash=$(_fsv_setup $fsv_orig_file $fsv_file)
+_fsv_enable $fsv_file
+actual_hash=$(_fsv_measure $fsv_file)
+if [ "$expected_hash" != "$actual_hash" ]; then
+        echo "Measurement changed: $expected_hash => $actual_hash"
+fi
+
+_fsv_begin_subtest "fs-verity file has correct contents"
+head -c 100000 /dev/urandom > $fsv_orig_file
+_fsv_setup $fsv_orig_file $fsv_file >> $seqres.full
+_fsv_enable $fsv_file
+cmp $fsv_file $fsv_orig_file
+
+_fsv_begin_subtest "Trying to measure non-verity file fails with ENODATA"
+_fsv_create_setup_file $fsv_file >> $seqres.full
+_fsv_measure $fsv_file |& _filter_scratch
+verify_data_readable $fsv_file
+
+_fsv_begin_subtest "fs-verity file has adjusted i_size"
+head -c 100000 /dev/zero > $fsv_orig_file
+measurement=$(_fsv_setup $fsv_orig_file $fsv_file)
+stat -c %s $fsv_file
+_fsv_enable $fsv_file
+stat -c %s $fsv_file
+_scratch_cycle_mount
+stat -c %s $fsv_file
+
+# This verifies that the adjusted i_size is not written to the real on-disk
+# i_size, preventing the fs-verity header from being found again.
+_fsv_begin_subtest "fs-verity file can still be read after mount cycle"
+head -c 100000 /dev/urandom > $fsv_orig_file
+measurement=$(_fsv_setup $fsv_orig_file $fsv_file)
+_fsv_enable $fsv_file
+cmp $fsv_file $fsv_orig_file
+echo "(chmod file)"
+# make the inode dirty, so it gets written
+chmod 444 $fsv_file
+chmod 400 $fsv_file
+echo "(cycle mount)"
+_scratch_cycle_mount
+echo "(read file)"
+cmp $fsv_file $fsv_orig_file
+
+# Test files <= 1 block in size.  These are a bit of a special case since there
+# are no hash blocks, so the root hash has to be calculated over the data block.
+for size in 1 4095 4096; do
+	_fsv_begin_subtest "fs-verity on $size-byte file"
+	head -c $size /dev/urandom > $fsv_orig_file
+	measurement=$(_fsv_setup $fsv_orig_file $fsv_file)
+	_fsv_enable $fsv_file
+	cmp $fsv_orig_file $fsv_file && echo "Files matched"
+	rm -f $fsv_file
+done
+
+_fsv_begin_subtest "fs-verity on 100M file (multiple levels in hash tree)"
+head -c 100000000 /dev/urandom > $fsv_orig_file
+_fsv_setup $fsv_orig_file $fsv_file >> $seqres.full
+_fsv_enable $fsv_file
+cmp $fsv_orig_file $fsv_file && echo "Files matched"
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/900.out b/tests/generic/900.out
new file mode 100644
index 00000000..833b0d8d
--- /dev/null
+++ b/tests/generic/900.out
@@ -0,0 +1,54 @@
+QA output created by 900
+
+# Enabling fs-verity on directory fails with EISDIR
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/dir': Is a directory
+
+# Enabling fs-verity on file open for writing fails with ETXTBSY
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Text file busy
+
+# Enabling fs-verity on file on read-only filesystem fails with EROFS
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Read-only file system
+
+# Enabling fs-verity on a file twice fails with EEXIST
+(trying again)
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': File exists
+
+# fs-verity file can't be opened for writing
+* reading
+* xfs_io writing, should be O_RDWR
+SCRATCH_MNT/file.fsv: Operation not permitted
+* bash >>, should be O_APPEND
+bash: SCRATCH_MNT/file.fsv: Operation not permitted
+* bash >, should be O_WRONLY|O_CREAT|O_TRUNC
+bash: SCRATCH_MNT/file.fsv: Operation not permitted
+
+# fs-verity file can be read
+
+# fs-verity file reports measurement calculated earlier
+
+# fs-verity file has correct contents
+
+# Trying to measure non-verity file fails with ENODATA
+ERROR: FS_IOC_MEASURE_VERITY failed on 'SCRATCH_MNT/file.fsv': No data available
+
+# fs-verity file has adjusted i_size
+106620
+100000
+100000
+
+# fs-verity file can still be read after mount cycle
+(chmod file)
+(cycle mount)
+(read file)
+
+# fs-verity on 1-byte file
+Files matched
+
+# fs-verity on 4095-byte file
+Files matched
+
+# fs-verity on 4096-byte file
+Files matched
+
+# fs-verity on 100M file (multiple levels in hash tree)
+Files matched
diff --git a/tests/generic/group b/tests/generic/group
index ea5aa7aa..2a9109ac 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -525,3 +525,4 @@
 520 auto quick log
 521 soak long_rw
 522 soak long_rw
+900 auto quick verity
-- 
2.20.0.rc2.403.gdbc3b29805-goog
