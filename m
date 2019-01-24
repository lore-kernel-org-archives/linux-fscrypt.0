Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-eopbgr680133.outbound.protection.outlook.com ([40.107.68.133]:13184
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726347AbfAXVmj (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 24 Jan 2019 16:42:39 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: [PATCH] MAINTAINER: add Eric Biggers as an fscrypt maintainer
Date: Thu, 24 Jan 2019 16:42:24 -0500
Message-ID: <20190124214224.18563-1-tytso@mit.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

Also update the location of the git tree as we will be using a shared
git tree.

Signed-off-by: Theodore Ts'o <tytso@mit.edu>
---

(This is assuming we get the git tree location that I requested in the
ticket to Konstantin and his team, of course.)

 MAINTAINERS | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 51029a425dbe..419b326e711a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6193,9 +6193,10 @@ F:	include/linux/fscache*.h
 FSCRYPT: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
 M:	Theodore Y. Ts'o <tytso@mit.edu>
 M:	Jaegeuk Kim <jaegeuk@kernel.org>
+M:	Eric Biggers <ebiggers@kernel.org>
 L:	linux-fscrypt@vger.kernel.org
 Q:	https://patchwork.kernel.org/project/linux-fscrypt/list/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
+T:	git git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git
 S:	Supported
 F:	fs/crypto/
 F:	include/linux/fscrypt*.h
-- 
2.19.1
