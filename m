Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: add memory barrier when loading essiv_hash_tfm
Date: Mon, 18 Mar 2019 10:24:54 -0700
Message-Id: <20190318172454.240412-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fsdevel-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Load 'essiv_hash_tfm' using smp_load_acquire() to guarantee that the
struct crypto_shash is seen as fully initialized before being used.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keyinfo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index ba74dafa18a3..d1f0f8369d51 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -379,7 +379,7 @@ fscrypt_get_master_key(const struct fscrypt_info *ci, struct fscrypt_mode *mode,
 
 static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
 {
-	struct crypto_shash *tfm = READ_ONCE(essiv_hash_tfm);
+	struct crypto_shash *tfm = smp_load_acquire(&essiv_hash_tfm);
 
 	/* init hash transform on demand */
 	if (unlikely(!tfm)) {
-- 
2.21.0.225.g810b269d1ac-goog
