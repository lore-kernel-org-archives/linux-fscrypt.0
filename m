Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Mon, 30 Sep 2019 14:15:49 -0700
Message-Id: <20190930211553.64208-5-ebiggers@kernel.org>
In-Reply-To: <20190930211553.64208-1-ebiggers@kernel.org>
References: <20190930211553.64208-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v4 4/8] generic: test access controls on the
 fs-verity ioctls
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: fstests@vger.kernel.org
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Test access controls on the fs-verity ioctls.  FS_IOC_MEASURE_VERITY is
allowed on any file, whereas FS_IOC_ENABLE_VERITY requires write access.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/901     | 73 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/901.out | 14 +++++++++
 tests/generic/group   |  1 +
 3 files changed, 88 insertions(+)
 create mode 100755 tests/generic/901
 create mode 100644 tests/generic/901.out

diff --git a/tests/generic/901 b/tests/generic/901
new file mode 100755
index 00000000..56dab587
--- /dev/null
+++ b/tests/generic/901
@@ -0,0 +1,73 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/901
+#
+# Test access controls on the fs-verity ioctls.  FS_IOC_MEASURE_VERITY is
+# allowed on any file, whereas FS_IOC_ENABLE_VERITY requires write access.
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
+_require_user
+_require_chattr ia
+
+_scratch_mkfs_verity &>> $seqres.full
+_scratch_mount
+fsv_file=$SCRATCH_MNT/file.fsv
+
+_fsv_scratch_begin_subtest "FS_IOC_ENABLE_VERITY doesn't require root"
+echo foo > $fsv_file
+chmod 666 $fsv_file
+_user_do "$FSVERITY_PROG enable $fsv_file"
+
+_fsv_scratch_begin_subtest "FS_IOC_ENABLE_VERITY requires write access"
+echo foo > $fsv_file >> $seqres.full
+chmod 444 $fsv_file
+_user_do "$FSVERITY_PROG enable $fsv_file" |& _filter_scratch
+
+_fsv_scratch_begin_subtest "FS_IOC_ENABLE_VERITY requires !append-only"
+echo foo > $fsv_file >> $seqres.full
+$CHATTR_PROG +a $fsv_file
+$FSVERITY_PROG enable $fsv_file |& _filter_scratch
+$CHATTR_PROG -a $fsv_file
+
+_fsv_scratch_begin_subtest "FS_IOC_ENABLE_VERITY requires !immutable"
+echo foo > $fsv_file >> $seqres.full
+$CHATTR_PROG +i $fsv_file
+$FSVERITY_PROG enable $fsv_file |& _filter_scratch
+$CHATTR_PROG -i $fsv_file
+
+_fsv_scratch_begin_subtest "FS_IOC_MEASURE_VERITY doesn't require root"
+_fsv_create_enable_file $fsv_file >> $seqres.full
+chmod 444 $fsv_file
+su $qa_user -c "$FSVERITY_PROG measure $fsv_file" >> $seqres.full
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/901.out b/tests/generic/901.out
new file mode 100644
index 00000000..a9e4c364
--- /dev/null
+++ b/tests/generic/901.out
@@ -0,0 +1,14 @@
+QA output created by 901
+
+# FS_IOC_ENABLE_VERITY doesn't require root
+
+# FS_IOC_ENABLE_VERITY requires write access
+Permission denied
+
+# FS_IOC_ENABLE_VERITY requires !append-only
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Operation not permitted
+
+# FS_IOC_ENABLE_VERITY requires !immutable
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Operation not permitted
+
+# FS_IOC_MEASURE_VERITY doesn't require root
diff --git a/tests/generic/group b/tests/generic/group
index 8c5212a1..a0450d42 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -571,3 +571,4 @@
 566 auto quick quota metadata
 567 auto quick rw punch
 900 auto quick verity
+901 auto quick verity
-- 
2.23.0.444.g18eeb5a265-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
