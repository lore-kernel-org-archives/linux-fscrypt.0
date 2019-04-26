Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45106 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726957AbfDZUpm (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 26 Apr 2019 16:45:42 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 7/7] generic: verify ciphertext of v1 encryption policies with Adiantum
Date: Fri, 26 Apr 2019 13:41:53 -0700
Message-Id: <20190426204153.101861-8-ebiggers@kernel.org>
In-Reply-To: <20190426204153.101861-1-ebiggers@kernel.org>
References: <20190426204153.101861-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Verify ciphertext for v1 encryption policies that use Adiantum to
encrypt file contents and file names.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/702     | 43 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/702.out | 10 ++++++++++
 tests/generic/group   |  1 +
 3 files changed, 54 insertions(+)
 create mode 100755 tests/generic/702
 create mode 100644 tests/generic/702.out

diff --git a/tests/generic/702 b/tests/generic/702
new file mode 100755
index 00000000..c7ac7be4
--- /dev/null
+++ b/tests/generic/702
@@ -0,0 +1,43 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2019 Google LLC
+#
+# FS QA Test generic/702
+#
+# Verify ciphertext for v1 encryption policies that use Adiantum to encrypt file
+# contents and file names.
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
+_verify_ciphertext_for_encryption_policy Adiantum Adiantum
+_verify_ciphertext_for_encryption_policy Adiantum Adiantum direct
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/702.out b/tests/generic/702.out
new file mode 100644
index 00000000..0dd80dae
--- /dev/null
+++ b/tests/generic/702.out
@@ -0,0 +1,10 @@
+QA output created by 702
+
+Verifying ciphertext with parameters:
+	contents_encryption_mode: Adiantum
+	filenames_encryption_mode: Adiantum
+
+Verifying ciphertext with parameters:
+	contents_encryption_mode: Adiantum
+	filenames_encryption_mode: Adiantum
+	options: direct
diff --git a/tests/generic/group b/tests/generic/group
index 6bb793cb..f6672b93 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -549,3 +549,4 @@
 544 auto quick clone
 700 auto quick encrypt
 701 auto quick encrypt
+702 auto quick encrypt
-- 
2.21.0.593.g511ec345e18-goog
