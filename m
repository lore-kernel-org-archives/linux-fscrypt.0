Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53534 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729633AbeLJWZu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Dec 2018 17:25:50 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 5/7] generic: test corrupting verity files
Date: Mon, 10 Dec 2018 14:21:40 -0800
Message-Id: <20181210222142.222342-6-ebiggers@kernel.org>
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This test zaps various parts of the contents of a verity file, or parts
of its Merkle tree, by writing directly to the block device.  It
verifies that this causes I/O errors when the relevant part of the
contents is later read by any means.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/903     | 126 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/903.out |  91 ++++++++++++++++++++++++++++++
 tests/generic/group   |   1 +
 3 files changed, 218 insertions(+)
 create mode 100755 tests/generic/903
 create mode 100644 tests/generic/903.out

diff --git a/tests/generic/903 b/tests/generic/903
new file mode 100755
index 00000000..8176d6e0
--- /dev/null
+++ b/tests/generic/903
@@ -0,0 +1,126 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/903
+#
+# Test corrupting verity files.  This test zaps various parts of the contents of
+# a verity file, or parts of its Merkle tree, by writing directly to the block
+# device.  It verifies that this causes I/O errors when the relevant part of the
+# contents is later read by any means.
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
+setup_zeroed_file()
+{
+	local len=$1
+
+	head -c $len /dev/zero > $fsv_orig_file
+	_fsv_setup $fsv_orig_file $fsv_file >> $seqres.full
+	_fsv_enable $fsv_file
+	md5sum $fsv_file |& _filter_scratch 1>&2
+}
+
+filter_sigbus()
+{
+	sed -e 's/.*Bus error.*/Bus error/'
+}
+
+page_boundary()
+{
+	local n=$1
+	local page_size=$(getconf PAGE_SIZE)
+
+	echo $(( (n + page_size - 1) & ~(page_size - 1) ))
+}
+
+corruption_test()
+{
+	local file_len=$1
+	local zap_offset=$2
+	local zap_len=$3
+	local metadata_offset=$(page_boundary $file_len)
+	local measurement
+
+	_fsv_begin_subtest "Corruption test: file_len=$file_len zap_offset=$zap_offset zap_len=$zap_len"
+	setup_zeroed_file $file_len
+	cmp $fsv_file $fsv_orig_file
+	echo "Corrupting bytes..."
+	head -c $zap_len /dev/zero | tr '\0' X \
+		| _fsv_corrupt_bytes $fsv_file $zap_offset
+
+	echo "Validating corruption (reading full file)..."
+	_scratch_cycle_mount
+	md5sum $fsv_file |& _filter_scratch
+
+	echo "Validating corruption (direct I/O)..."
+	_scratch_cycle_mount
+	dd if=$fsv_file bs=$FSV_BLOCK_SIZE iflag=direct status=none \
+		of=/dev/null |& _filter_scratch
+
+	if (( zap_offset < metadata_offset )); then
+		echo "Validating corruption (reading just corrupted part)..."
+		dd if=$fsv_file bs=1 skip=$zap_offset count=$zap_len \
+			of=/dev/null status=none |& _filter_scratch
+	fi
+
+	echo "Validating corruption (reading full file via mmap)..."
+	bash -c "trap '' SIGBUS; $XFS_IO_PROG -r $fsv_file \
+		-c 'mmap -r 0 $metadata_offset' \
+		-c 'mread 0 $file_len'" |& filter_sigbus
+
+	if (( zap_offset < metadata_offset )); then
+		echo "Validating corruption (reading just corrupted part via mmap)..."
+		bash -c "trap '' SIGBUS; $XFS_IO_PROG -r $fsv_file \
+			-c 'mmap -r 0 $metadata_offset' \
+			-c 'mread $zap_offset $zap_len'" |& filter_sigbus
+	fi
+}
+
+corruption_test 131072 0 1
+corruption_test 131072 4095 1
+corruption_test 131072 65536 65536
+corruption_test 131072 131071 1
+
+# Non-zeroed bytes in the final partial block beyond EOF should cause reads to
+# fail too.  Such bytes would be visible via mmap().
+corruption_test 129999 131000 72
+
+# Hash tree corruption
+corruption_test 1048576 1052672 4096
+corruption_test 1048576 1056767 1
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/903.out b/tests/generic/903.out
new file mode 100644
index 00000000..2006cf67
--- /dev/null
+++ b/tests/generic/903.out
@@ -0,0 +1,91 @@
+QA output created by 903
+
+# Corruption test: file_len=131072 zap_offset=0 zap_len=1
+0dfbe8aa4c20b52e1b8bf3cb6cbdf193  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading just corrupted part)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+Validating corruption (reading just corrupted part via mmap)...
+Bus error
+
+# Corruption test: file_len=131072 zap_offset=4095 zap_len=1
+0dfbe8aa4c20b52e1b8bf3cb6cbdf193  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading just corrupted part)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+Validating corruption (reading just corrupted part via mmap)...
+Bus error
+
+# Corruption test: file_len=131072 zap_offset=65536 zap_len=65536
+0dfbe8aa4c20b52e1b8bf3cb6cbdf193  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading just corrupted part)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+Validating corruption (reading just corrupted part via mmap)...
+Bus error
+
+# Corruption test: file_len=131072 zap_offset=131071 zap_len=1
+0dfbe8aa4c20b52e1b8bf3cb6cbdf193  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading just corrupted part)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+Validating corruption (reading just corrupted part via mmap)...
+Bus error
+
+# Corruption test: file_len=129999 zap_offset=131000 zap_len=72
+0ed66e88b29ce0c585cedf35ee127213  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading just corrupted part)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+Validating corruption (reading just corrupted part via mmap)...
+Bus error
+
+# Corruption test: file_len=1048576 zap_offset=1052672 zap_len=4096
+b6d81b360a5672d80c27430f39153e2c  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
+
+# Corruption test: file_len=1048576 zap_offset=1056767 zap_len=1
+b6d81b360a5672d80c27430f39153e2c  SCRATCH_MNT/file.fsv
+Corrupting bytes...
+Validating corruption (reading full file)...
+md5sum: SCRATCH_MNT/file.fsv: Input/output error
+Validating corruption (direct I/O)...
+dd: error reading 'SCRATCH_MNT/file.fsv': Input/output error
+Validating corruption (reading full file via mmap)...
+Bus error
diff --git a/tests/generic/group b/tests/generic/group
index f8f67918..0d7e0177 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -528,3 +528,4 @@
 900 auto quick verity
 901 auto quick verity
 902 auto quick verity
+903 auto quick verity
-- 
2.20.0.rc2.403.gdbc3b29805-goog
