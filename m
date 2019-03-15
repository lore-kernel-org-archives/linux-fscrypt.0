Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:34090 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726653AbfCOUzI (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 15 Mar 2019 16:55:08 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] ubifs: remove unnecessary #ifdef around fscrypt_ioctl_get_policy()
Date: Fri, 15 Mar 2019 13:55:03 -0700
Message-Id: <20190315205503.195400-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

When !CONFIG_FS_ENCRYPTION, fscrypt_ioctl_get_policy() is already
stubbed out to return -EOPNOTSUPP, so the extra #ifdef is not needed.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/ioctl.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index 82e4e6a30b04..cd1d4212fc45 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -205,13 +205,8 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return -EOPNOTSUPP;
 #endif
 	}
-	case FS_IOC_GET_ENCRYPTION_POLICY: {
-#ifdef CONFIG_FS_ENCRYPTION
+	case FS_IOC_GET_ENCRYPTION_POLICY:
 		return fscrypt_ioctl_get_policy(file, (void __user *)arg);
-#else
-		return -EOPNOTSUPP;
-#endif
-	}
 
 	default:
 		return -ENOTTY;
-- 
2.21.0.360.g471c308f928-goog
