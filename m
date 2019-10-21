Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45356 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730052AbfJUUtQ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Oct 2019 16:49:16 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2] fscrypt: avoid data race on fscrypt_mode::logged_impl_name
Date: Mon, 21 Oct 2019 13:49:03 -0700
Message-Id: <20191021204903.56528-1-ebiggers@kernel.org>
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

This also required switching from bool to int, to avoid a build error on
the RISC-V architecture which doesn't implement xchg on bytes.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h | 2 +-
 fs/crypto/keysetup.c        | 6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index dacf8fcbac3be..d9a3e8614049f 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -435,7 +435,7 @@ struct fscrypt_mode {
 	const char *cipher_str;
 	int keysize;
 	int ivsize;
-	bool logged_impl_name;
+	int logged_impl_name;
 };
 
 static inline bool
diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index b03b33643e4b2..28bc2da9be3c7 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -81,15 +81,13 @@ struct crypto_skcipher *fscrypt_allocate_skcipher(struct fscrypt_mode *mode,
 			    mode->cipher_str, PTR_ERR(tfm));
 		return tfm;
 	}
-	if (unlikely(!mode->logged_impl_name)) {
+	if (!xchg(&mode->logged_impl_name, 1)) {
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
2.23.0.866.gb869b98d4c-goog
