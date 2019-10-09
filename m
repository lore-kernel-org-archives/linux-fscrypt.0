Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42190 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730815AbfJIXoO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 9 Oct 2019 19:44:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: avoid data race on fscrypt_mode::logged_impl_name
Date: Wed,  9 Oct 2019 16:43:37 -0700
Message-Id: <20191009234337.225469-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The access to logged_impl_name is technically a data race, which tools
like KCSAN could complain about in the future.  See:
https://github.com/google/ktsan/wiki/READ_ONCE-and-WRITE_ONCE

Fix by using xchg(), which also ensures that only one thread does the
logging.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keysetup.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index 8eb5a0e762ec6..df3e1c8653884 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -81,15 +81,13 @@ struct crypto_skcipher *fscrypt_allocate_skcipher(struct fscrypt_mode *mode,
 			    mode->cipher_str, PTR_ERR(tfm));
 		return tfm;
 	}
-	if (unlikely(!mode->logged_impl_name)) {
+	if (!xchg(&mode->logged_impl_name, true)) {
 		/*
 		 * fscrypt performance can vary greatly depending on which
 		 * crypto algorithm implementation is used.  Help people debug
 		 * performance problems by logging the ->cra_driver_name the
-		 * first time a mode is used.  Note that multiple threads can
-		 * race here, but it doesn't really matter.
+		 * first time a mode is used.
 		 */
-		mode->logged_impl_name = true;
 		pr_info("fscrypt: %s using implementation \"%s\"\n",
 			mode->friendly_name,
 			crypto_skcipher_alg(tfm)->base.cra_driver_name);
-- 
2.23.0.581.g78d2f28ef7-goog
