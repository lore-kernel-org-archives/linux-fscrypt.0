Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53820 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726742AbfHLR6s (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Aug 2019 13:58:48 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 7/9] generic: verify ciphertext of v2 encryption policies with AES-256
Date: Mon, 12 Aug 2019 10:58:07 -0700
Message-Id: <20190812175809.34810-8-ebiggers@kernel.org>
In-Reply-To: <20190812175809.34810-1-ebiggers@kernel.org>
References: <20190812175809.34810-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Verify ciphertext for v2 encryption policies that use AES-256-XTS to
encrypt file contents and AES-256-CTS-CBC to encrypt file names.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/802     | 43 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/802.out |  6 ++++++
 tests/generic/group   |  1 +
 3 files changed, 50 insertions(+)
 create mode 100755 tests/generic/802
 create mode 100644 tests/generic/802.out

diff --git a/tests/generic/802 b/tests/generic/802
new file mode 100755
index 00000000..457260b2
--- /dev/null
+++ b/tests/generic/802
@@ -0,0 +1,43 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2019 Google LLC
+#
+# FS QA Test generic/802
+#
+# Verify ciphertext for v2 encryption policies that use AES-256-XTS to encrypt
+# file contents and AES-256-CTS-CBC to encrypt file names.
+#
+# This is the same as generic/548, except using v2 policies.
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
+_verify_ciphertext_for_encryption_policy AES-256-XTS AES-256-CTS-CBC v2
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/802.out b/tests/generic/802.out
new file mode 100644
index 00000000..c0930809
--- /dev/null
+++ b/tests/generic/802.out
@@ -0,0 +1,6 @@
+QA output created by 802
+
+Verifying ciphertext with parameters:
+	contents_encryption_mode: AES-256-XTS
+	filenames_encryption_mode: AES-256-CTS-CBC
+	options: v2
diff --git a/tests/generic/group b/tests/generic/group
index 4bc4772a..29c9af30 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -570,3 +570,4 @@
 565 auto quick copy_range
 800 auto quick encrypt
 801 auto quick encrypt
+802 auto quick encrypt
-- 
2.23.0.rc1.153.gdeed80330f-goog
