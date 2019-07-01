Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42056 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726329AbfGAS12 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 1 Jul 2019 14:27:28 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v3 1/8] common/filter: add _filter_xfs_io_fiemap()
Date: Mon,  1 Jul 2019 11:25:40 -0700
Message-Id: <20190701182547.165856-2-ebiggers@kernel.org>
In-Reply-To: <20190701182547.165856-1-ebiggers@kernel.org>
References: <20190701182547.165856-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add _filter_xfs_io_fiemap() to clean up the output of
'xfs_io -c fiemap'.  This will be used by a function in common/verity.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/filter | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/common/filter b/common/filter
index ed082d24..9ad43ff4 100644
--- a/common/filter
+++ b/common/filter
@@ -541,6 +541,30 @@ _filter_filefrag()
 	      $flags, "\n"'
 }
 
+# Clean up the extents list output of 'xfs_io -c fiemap', e.g.
+#
+#	file:
+#		0: [0..79]: 628365312..628365391
+#		1: [80..159]: hole
+#		2: [160..319]: 628365472..628365631
+# =>
+#	0  79   628365312  628365391
+#	160  319   628365472  628365631
+#
+# The fields are:
+#
+#	first_logical_block last_logical_block first_physical_block last_physical_block
+#
+# Blocks are 512 bytes, and holes are omitted.
+#
+_filter_xfs_io_fiemap()
+{
+	 grep -E '^[[:space:]]+[0-9]+:' \
+		 | grep -v '\<hole\>' \
+		 | sed -E 's/^[[:space:]]+[0-9]+://' \
+		 | tr '][.:' ' '
+}
+
 # We generate WARNINGs on purpose when applications mix buffered/mmap IO with
 # direct IO on the same file. This is a helper for _check_dmesg() to filter out
 # such warnings.
-- 
2.22.0.410.gd8fdbe21b5-goog
