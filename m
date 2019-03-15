Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45356 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726130AbfCOVRG (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 15 Mar 2019 17:17:06 -0400
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 777852186A
        for <linux-fscrypt@vger.kernel.org>; Fri, 15 Mar 2019 21:17:05 +0000 (UTC)
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: remove WARN_ON_ONCE() when decryption fails
Date: Fri, 15 Mar 2019 14:16:32 -0700
Message-Id: <20190315211632.231638-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

If decrypting a block fails, fscrypt did a WARN_ON_ONCE().  But WARN is
meant for kernel bugs, which this isn't; this could be hit by fuzzers
using fault injection, for example.  Also, there is already a proper
warning message logged in fscrypt_do_page_crypto(), so the WARN doesn't
add much.

Just remove the unnessary WARN.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 5759bcd018cd..d7ad74818b2b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -37,12 +37,10 @@ static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
 
-		if (ret) {
-			WARN_ON_ONCE(1);
+		if (ret)
 			SetPageError(page);
-		} else if (done) {
+		else if (done)
 			SetPageUptodate(page);
-		}
 		if (done)
 			unlock_page(page);
 	}
-- 
2.21.0.360.g471c308f928-goog
