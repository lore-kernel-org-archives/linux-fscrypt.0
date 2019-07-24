Return-Path: <SRS0=R/Gl=VV=gmail.com=baijiaju1990@kernel.org>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [PATCH] fs: crypto: keyinfo: Fix a possible null-pointer dereference in derive_key_aes()
Date: Wed, 24 Jul 2019 18:02:04 +0800
Message-Id: <20190724100204.2009-1-baijiaju1990@gmail.com>
To: tytso@mit.edu, jaegeuk@kernel.org, ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

In derive_key_aes(), tfm is assigned to NULL on line 46, and then
crypto_free_skcipher(tfm) is executed.

crypto_free_skcipher(tfm)
    crypto_skcipher_tfm(tfm)
        return &tfm->base;

Thus, a possible null-pointer dereference may occur.

To fix this bug, tfm is checked before calling crypto_free_skcipher().

This bug is found by a static analysis tool STCheck written by us.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
---
 fs/crypto/keyinfo.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 207ebed918c1..b419720cac54 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -66,7 +66,8 @@ static int derive_key_aes(const u8 *master_key,
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 out:
 	skcipher_request_free(req);
-	crypto_free_skcipher(tfm);
+	if (tfm)
+		crypto_free_skcipher(tfm);
 	return res;
 }
 
-- 
2.17.0
