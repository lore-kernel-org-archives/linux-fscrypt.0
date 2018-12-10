Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53542 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729671AbeLJWZu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Dec 2018 17:25:50 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 7/7] generic: test using fs-verity and fscrypt simultaneously
Date: Mon, 10 Dec 2018 14:21:42 -0800
Message-Id: <20181210222142.222342-8-ebiggers@kernel.org>
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This primarily verifies correct ordering of the hooks for each feature:
fscrypt needs to be first.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/905     | 81 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/905.out | 12 +++++++
 tests/generic/group   |  1 +
 3 files changed, 94 insertions(+)
 create mode 100755 tests/generic/905
 create mode 100644 tests/generic/905.out

diff --git a/tests/generic/905 b/tests/generic/905
new file mode 100755
index 00000000..18d10d50
--- /dev/null
+++ b/tests/generic/905
@@ -0,0 +1,81 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/905
+#
+# Test using fs-verity and fscrypt simultaneously.  This primarily verifies
+# correct ordering of the hooks for each feature: fscrypt needs to be first.
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
+. ./common/encrypt
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+_require_scratch_verity
+_require_scratch_encryption
+_require_xfs_io_command "set_encpolicy"
+_require_command "$KEYCTL_PROG" keyctl
+
+_scratch_mkfs_encrypted_verity &>> $seqres.full
+_scratch_mount
+
+fsv_orig_file=$tmp.file
+edir=$SCRATCH_MNT/edir
+fsv_file=$edir/file.fsv
+
+# Set up an encrypted directory.
+_new_session_keyring
+keydesc=$(_generate_encryption_key)
+mkdir $edir
+$XFS_IO_PROG -c "set_encpolicy $keydesc" $edir
+
+# Set up an fs-verity file within the encrypted directory.
+# Verity that it actually has an encryption policy.
+head -c 100000 /dev/zero > $fsv_orig_file
+_fsv_setup $fsv_orig_file $fsv_file >> $seqres.full
+_fsv_enable $fsv_file
+echo
+$XFS_IO_PROG -r -c "get_encpolicy" $fsv_file |& _filter_scratch \
+	| sed 's/Master key descriptor:.*/Master key descriptor: 0000000000000000/'
+echo
+
+# Verify that the file contents are as expected.  This should be going through
+# both the decryption and verity I/O paths.
+cmp $fsv_orig_file $fsv_file && echo "Files matched"
+
+# Just in case, try again after a mount cycle to empty the page cache.
+_scratch_cycle_mount
+cmp $fsv_orig_file $fsv_file && echo "Files matched"
+
+# Corrupt some bytes as a sanity check that fs-verity is really working.
+# This also verifies that the data on-disk is really encrypted, since otherwise
+# the data being written here would be identical to the old data.
+head -c 1000 /dev/zero | _fsv_corrupt_bytes $fsv_file 50000
+md5sum $fsv_file |& _filter_scratch
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/905.out b/tests/generic/905.out
new file mode 100644
index 00000000..62418f7e
--- /dev/null
+++ b/tests/generic/905.out
@@ -0,0 +1,12 @@
+QA output created by 905
+
+Encryption policy for SCRATCH_MNT/edir/file.fsv:
+	Policy version: 0
+	Master key descriptor: 0000000000000000
+	Contents encryption mode: 1 (AES-256-XTS)
+	Filenames encryption mode: 4 (AES-256-CTS)
+	Flags: 0x02
+
+Files matched
+Files matched
+md5sum: SCRATCH_MNT/edir/file.fsv: Input/output error
diff --git a/tests/generic/group b/tests/generic/group
index c7e5098f..5668c046 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -530,3 +530,4 @@
 902 auto quick verity
 903 auto quick verity
 904 auto quick verity
+905 auto quick verity encrypt
-- 
2.20.0.rc2.403.gdbc3b29805-goog
