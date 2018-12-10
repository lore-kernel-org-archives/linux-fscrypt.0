Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53514 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729482AbeLJWZu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Dec 2018 17:25:50 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6/7] generic: test that fs-verity is using the correct measurement values
Date: Mon, 10 Dec 2018 14:21:41 -0800
Message-Id: <20181210222142.222342-7-ebiggers@kernel.org>
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This test verifies that fs-verity is doing its Merkle tree-based hashing
correctly, i.e. that it hasn't been broken by a change.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/904     | 124 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/904.out |   7 +++
 tests/generic/group   |   1 +
 3 files changed, 132 insertions(+)
 create mode 100755 tests/generic/904
 create mode 100644 tests/generic/904.out

diff --git a/tests/generic/904 b/tests/generic/904
new file mode 100755
index 00000000..57e0683e
--- /dev/null
+++ b/tests/generic/904
@@ -0,0 +1,124 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/904
+#
+# Test that fs-verity is using the correct measurement values.  This test
+# verifies that fs-verity is doing its Merkle tree-based hashing correctly,
+# i.e. that it hasn't been broken by a change.
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
+have_hash_algorithm()
+{
+	local alg=$1
+
+	head -c 4096 /dev/zero > $fsv_file
+	if ! _fsv_setup --hash=$alg $fsv_file &>> $seqres.full; then
+		# no userspace tool support
+		return 1
+	fi
+	if ! _fsv_enable $fsv_file &>> $seqres.full; then
+		# no kernel support
+		return 1
+	fi
+	rm -f $fsv_file
+	return 0
+}
+
+algs=(sha256 sha512 crc32c)
+file_sizes=(4096 65536 100000000)
+
+# The expected values are here rather than in the expected output file because
+# not all hash algorithms may be available.
+sha256_vals=(
+sha256:47b92f80eedc47a224cc4f922de978c8933bc205844a7fd06da848d2c37471ab
+sha256:8f6f7df7c0babebacc1b4a158ba9d40ecfe3ad5e66647d1aaf715244ae882a80
+sha256:66fcfdf105061a621b13da383ff57d0ac63c61311215b46c1f4fc4959db69ef6
+)
+sha512_vals=(
+sha512:2709f8fc180abb2444b6a57143442737ab3ece8d6e463e1bf328a78e5b0a902f0031cc7ac58797e40c6cfbb29e3005c4730800932308bc549df5375fb1859d37
+sha512:bfdcd4c1a9493c830e2e175da7fda02e60e2deeb21f2787cea3a70e545fd34b9d0266738cbe2435f81bc5a44f58d8ae404f9e5f835c8b989a7a0b234e4cadffa
+sha512:f08e75b685b65f43d9ffa71b85e400cbdc67215cfa755c126237d8dc96ba9570225387586ee47f97d552aeba9e73a318fcb65c6b27ffc58106d803f0acea29e3
+)
+crc32c_vals=(
+crc32c:91806377
+crc32c:cf55a43e
+crc32c:d672241e
+)
+
+test_alg()
+{
+	local alg=$1
+	local -n vals=${alg}_vals
+	local i
+	local file_size
+	local expected actual
+
+	_fsv_begin_subtest "Check for expected measurement values ($alg)"
+
+	if ! have_hash_algorithm $alg; then
+		if [ "$alg" = sha256 ]; then
+			_fail "Something is wrong - sha256 hash should always be available"
+		fi
+		return 0
+	fi
+
+	for i in ${!file_sizes[@]}; do
+		file_size=${file_sizes[$i]}
+		expected=${vals[$i]}
+
+		head -c $file_size /dev/zero > $fsv_orig_file
+		actual=$(_fsv_setup --hash=$alg $fsv_orig_file $fsv_file)
+		if [ "$actual" != "$expected" ]; then
+			echo "Mismatch: expected $expected, 'fsverity setup' calculated $actual (file_size=$file_size)"
+		fi
+		_fsv_enable $fsv_file
+		actual=$(_fsv_measure $fsv_file)
+		if [ "$actual" != "$expected" ]; then
+			echo "Mismatch: expected $expected, kernel calculated $actual (file_size=$file_size)"
+		fi
+		cmp $fsv_orig_file $fsv_file
+		rm -f $fsv_file
+	done
+}
+
+for alg in ${algs[@]}; do
+	test_alg $alg
+done
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/904.out b/tests/generic/904.out
new file mode 100644
index 00000000..fc1c7015
--- /dev/null
+++ b/tests/generic/904.out
@@ -0,0 +1,7 @@
+QA output created by 904
+
+# Check for expected measurement values (sha256)
+
+# Check for expected measurement values (sha512)
+
+# Check for expected measurement values (crc32c)
diff --git a/tests/generic/group b/tests/generic/group
index 0d7e0177..c7e5098f 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -529,3 +529,4 @@
 901 auto quick verity
 902 auto quick verity
 903 auto quick verity
+904 auto quick verity
-- 
2.20.0.rc2.403.gdbc3b29805-goog
