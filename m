Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37466 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2404352AbfGXTy3 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 24 Jul 2019 15:54:29 -0400
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C773A22AEC
        for <linux-fscrypt@vger.kernel.org>; Wed, 24 Jul 2019 19:54:28 +0000 (UTC)
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 3/4] fscrypt: improve warnings for missing crypto API support
Date: Wed, 24 Jul 2019 12:54:21 -0700
Message-Id: <20190724195422.42495-4-ebiggers@kernel.org>
In-Reply-To: <20190724195422.42495-1-ebiggers@kernel.org>
References: <20190724195422.42495-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Users of fscrypt with non-default algorithms will encounter an error
like the following if they fail to include the needed algorithms into
the crypto API when configuring the kernel (as per the documentation):

    Error allocating 'adiantum(xchacha12,aes)' transform: -2

This requires that the user figure out what the "-2" error means.
Make it more friendly by printing a warning like the following instead:

    Missing crypto API support for Adiantum (API name: "adiantum(xchacha12,aes)")

Also upgrade the log level for *other* errors to KERN_ERR.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index e5ab18d98f32a3..b75678587c3a85 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -237,8 +237,13 @@ allocate_skcipher_for_mode(struct fscrypt_mode *mode, const u8 *raw_key,
 
 	tfm = crypto_alloc_skcipher(mode->cipher_str, 0, 0);
 	if (IS_ERR(tfm)) {
-		fscrypt_warn(inode, "Error allocating '%s' transform: %ld",
-			     mode->cipher_str, PTR_ERR(tfm));
+		if (PTR_ERR(tfm) == -ENOENT)
+			fscrypt_warn(inode,
+				     "Missing crypto API support for %s (API name: \"%s\")",
+				     mode->friendly_name, mode->cipher_str);
+		else
+			fscrypt_err(inode, "Error allocating '%s' transform: %ld",
+				    mode->cipher_str, PTR_ERR(tfm));
 		return tfm;
 	}
 	if (unlikely(!mode->logged_impl_name)) {
@@ -384,9 +389,13 @@ static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
 
 		tfm = crypto_alloc_shash("sha256", 0, 0);
 		if (IS_ERR(tfm)) {
-			fscrypt_warn(NULL,
-				     "error allocating SHA-256 transform: %ld",
-				     PTR_ERR(tfm));
+			if (PTR_ERR(tfm) == -ENOENT)
+				fscrypt_warn(NULL,
+					     "Missing crypto API support for SHA-256");
+			else
+				fscrypt_err(NULL,
+					    "Error allocating SHA-256 transform: %ld",
+					    PTR_ERR(tfm));
 			return PTR_ERR(tfm);
 		}
 		prev_tfm = cmpxchg(&essiv_hash_tfm, NULL, tfm);
-- 
2.22.0.657.g960e92d24f-goog
