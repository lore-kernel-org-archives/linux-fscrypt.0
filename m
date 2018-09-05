Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43708 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727575AbeIEX4f (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 5 Sep 2018 19:56:35 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: remove CRYPTO_CTR dependency
Date: Wed,  5 Sep 2018 12:24:00 -0700
Message-Id: <20180905192400.71160-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-crypto@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt doesn't use the CTR mode of operation for anything, so there's
no need to select CRYPTO_CTR.  It was added by commit 71dea01ea2ed
("ext4 crypto: require CONFIG_CRYPTO_CTR if ext4 encryption is
enabled").  But, I've been unable to identify the arm64 crypto bug it
was supposedly working around.

I suspect the issue was seen only on some old Android device kernel
(circa 3.10?).  So if the fix wasn't mistaken, the real bug is probably
already fixed.  Or maybe it was actually a bug in a non-upstream crypto
driver.

So, remove the dependency.  If it turns out there's actually still a
bug, we'll fix it properly.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index 02b7d91c92310..284b589b4774d 100644
--- a/fs/crypto/Kconfig
+++ b/fs/crypto/Kconfig
@@ -6,7 +6,6 @@ config FS_ENCRYPTION
 	select CRYPTO_ECB
 	select CRYPTO_XTS
 	select CRYPTO_CTS
-	select CRYPTO_CTR
 	select CRYPTO_SHA256
 	select KEYS
 	help
-- 
2.19.0.rc2.392.g5ba43deb5a-goog
