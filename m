Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44296 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2404303AbfEXWEn (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 24 May 2019 18:04:43 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 3/7] common/encrypt: support requiring other encryption settings
Date: Fri, 24 May 2019 15:04:21 -0700
Message-Id: <20190524220425.201170-4-ebiggers@kernel.org>
In-Reply-To: <20190524220425.201170-1-ebiggers@kernel.org>
References: <20190524220425.201170-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Update _require_scratch_encryption() to support checking for kernel
support for contents and filenames encryption modes besides the default.
This will be used by some of the ciphertext verification tests.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/encrypt | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 58 insertions(+)

diff --git a/common/encrypt b/common/encrypt
index cbe0b73d..a4ffc531 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -4,6 +4,15 @@
 #
 # Functions for setting up and testing file encryption
 
+#
+# _require_scratch_encryption [-c CONTENTS_MODE] [-n FILENAMES_MODE]
+#
+# Require encryption support on the scratch device.
+#
+# This checks for support for the default type of encryption policy (AES-256-XTS
+# and AES-256-CTS).  Options can be specified to also require support for a
+# different type of encryption policy.
+#
 _require_scratch_encryption()
 {
 	_require_scratch
@@ -44,9 +53,58 @@ _require_scratch_encryption()
 		_notrun "kernel does not support $FSTYP encryption"
 	fi
 	rmdir $SCRATCH_MNT/tmpdir
+
+	# If required, check for support for the specific type of encryption
+	# policy required by the test.
+	if [ $# -ne 0 ]; then
+		_require_encryption_policy_support $SCRATCH_MNT "$@"
+	fi
+
 	_scratch_unmount
 }
 
+_require_encryption_policy_support()
+{
+	local mnt=$1
+	local dir=$mnt/tmpdir
+	local set_encpolicy_args=""
+	local c
+
+	OPTIND=2
+	while getopts "c:n:" c; do
+		case $c in
+		c|n)
+			set_encpolicy_args+=" -$c $OPTARG"
+			;;
+		*)
+			_fail "Unrecognized option '$c'"
+			;;
+		esac
+	done
+	set_encpolicy_args=${set_encpolicy_args# }
+
+	echo "Checking whether kernel supports encryption policy: $set_encpolicy_args" \
+		>> $seqres.full
+
+	mkdir $dir
+	_require_command "$KEYCTL_PROG" keyctl
+	_new_session_keyring
+	local keydesc=$(_generate_encryption_key)
+	if _set_encpolicy $dir $keydesc $set_encpolicy_args \
+		2>&1 >>$seqres.full | egrep -q 'Invalid argument'; then
+		_notrun "kernel does not support encryption policy: '$set_encpolicy_args'"
+	fi
+	# fscrypt allows setting policies with modes it knows about, even
+	# without kernel crypto API support.  E.g. a policy using Adiantum
+	# encryption can be set on a kernel without CONFIG_CRYPTO_ADIANTUM.
+	# But actually trying to use such an encrypted directory will fail.
+	if ! touch $dir/file; then
+		_notrun "encryption policy '$set_encpolicy_args' is unusable; probably missing kernel crypto API support"
+	fi
+	$KEYCTL_PROG clear @s
+	rm -r $dir
+}
+
 _scratch_mkfs_encrypted()
 {
 	case $FSTYP in
-- 
2.22.0.rc1.257.g3120a18244-goog
