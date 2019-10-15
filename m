Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44092 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389025AbfJOSZ5 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 15 Oct 2019 14:25:57 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v3 9/9] generic: verify ciphertext of v2 encryption policies with Adiantum
Date: Tue, 15 Oct 2019 11:16:43 -0700
Message-Id: <20191015181643.6519-10-ebiggers@kernel.org>
In-Reply-To: <20191015181643.6519-1-ebiggers@kernel.org>
References: <20191015181643.6519-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Verify ciphertext for v2 encryption policies that use Adiantum to
encrypt file contents and file names.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/804     | 45 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/804.out | 11 +++++++++++
 tests/generic/group   |  1 +
 3 files changed, 57 insertions(+)
 create mode 100755 tests/generic/804
 create mode 100644 tests/generic/804.out

diff --git a/tests/generic/804 b/tests/generic/804
new file mode 100755
index 00000000..72e7b025
--- /dev/null
+++ b/tests/generic/804
@@ -0,0 +1,45 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2019 Google LLC
+#
+# FS QA Test generic/804
+#
+# Verify ciphertext for v2 encryption policies that use Adiantum to encrypt file
+# contents and file names.
+#
+# This is the same as generic/550, except using v2 policies.
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
+. ./common/encrypt
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+
+# Test both with and without the DIRECT_KEY flag.
+_verify_ciphertext_for_encryption_policy Adiantum Adiantum v2
+_verify_ciphertext_for_encryption_policy Adiantum Adiantum v2 direct
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/804.out b/tests/generic/804.out
new file mode 100644
index 00000000..726376b2
--- /dev/null
+++ b/tests/generic/804.out
@@ -0,0 +1,11 @@
+QA output created by 804
+
+Verifying ciphertext with parameters:
+	contents_encryption_mode: Adiantum
+	filenames_encryption_mode: Adiantum
+	options: v2
+
+Verifying ciphertext with parameters:
+	contents_encryption_mode: Adiantum
+	filenames_encryption_mode: Adiantum
+	options: v2 direct
diff --git a/tests/generic/group b/tests/generic/group
index 6f5c15b2..3373980d 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -585,3 +585,4 @@
 801 auto quick encrypt
 802 auto quick encrypt
 803 auto quick encrypt
+804 auto quick encrypt
-- 
2.23.0.700.g56cf767bdb-goog
