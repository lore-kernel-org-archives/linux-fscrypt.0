Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:34268 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728591AbfGARNo (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 1 Jul 2019 13:13:44 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] common/encrypt: check that contents encryption is usable
Date: Mon,  1 Jul 2019 10:12:55 -0700
Message-Id: <20190701171255.253336-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In _require_encryption_policy_support(), when checking whether the
encryption policy is usable, try creating a nonempty file rather than an
empty one.  This ensures that both the contents and filenames encryption
modes are available, rather than just the filenames mode.

On f2fs this makes generic/549 be correctly skipped, rather than failed,
when run on a kernel built from the latest fscrypt.git tree with
CONFIG_CRYPTO_SHA256=n.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/encrypt | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/common/encrypt b/common/encrypt
index 13098d7f..06a56ed9 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -98,7 +98,9 @@ _require_encryption_policy_support()
 	# without kernel crypto API support.  E.g. a policy using Adiantum
 	# encryption can be set on a kernel without CONFIG_CRYPTO_ADIANTUM.
 	# But actually trying to use such an encrypted directory will fail.
-	if ! touch $dir/file; then
+	# To reliably check for availability of both the contents and filenames
+	# encryption modes, try creating a nonempty file.
+	if ! echo foo > $dir/file; then
 		_notrun "encryption policy '$set_encpolicy_args' is unusable; probably missing kernel crypto API support"
 	fi
 	$KEYCTL_PROG clear @s
-- 
2.22.0.410.gd8fdbe21b5-goog
