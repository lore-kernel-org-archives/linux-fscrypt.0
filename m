Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:39761 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162205AbeBNSoQ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Feb 2018 13:44:16 -0500
Received: by mail-io0-f196.google.com with SMTP id b198so26202293iof.6
        for <linux-fscrypt@vger.kernel.org>; Wed, 14 Feb 2018 10:44:16 -0800 (PST)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v3 2/5] crypto: speck - export common helpers
Date: Wed, 14 Feb 2018 10:42:20 -0800
Message-Id: <20180214184223.254359-3-ebiggers@google.com>
In-Reply-To: <20180214184223.254359-1-ebiggers@google.com>
References: <20180214184223.254359-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Export the Speck constants and transform context and the ->setkey(),
->encrypt(), and ->decrypt() functions so that they can be reused by the
ARM NEON implementation of Speck-XTS.  The generic key expansion code
will be reused because it is not performance-critical and is not
vectorizable, while the generic encryption and decryption functions are
needed as fallbacks and for the XTS tweak encryption.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 crypto/speck.c         | 90 +++++++++++++++++++++++-------------------
 include/crypto/speck.h | 62 +++++++++++++++++++++++++++++
 2 files changed, 111 insertions(+), 41 deletions(-)
 create mode 100644 include/crypto/speck.h

diff --git a/crypto/speck.c b/crypto/speck.c
index 4e80ad76bcd7..58aa9f7f91f7 100644
--- a/crypto/speck.c
+++ b/crypto/speck.c
@@ -24,6 +24,7 @@
  */
 
 #include <asm/unaligned.h>
+#include <crypto/speck.h>
 #include <linux/bitops.h>
 #include <linux/crypto.h>
 #include <linux/init.h>
@@ -31,22 +32,6 @@
 
 /* Speck128 */
 
-#define SPECK128_BLOCK_SIZE	16
-
-#define SPECK128_128_KEY_SIZE	16
-#define SPECK128_128_NROUNDS	32
-
-#define SPECK128_192_KEY_SIZE	24
-#define SPECK128_192_NROUNDS	33
-
-#define SPECK128_256_KEY_SIZE	32
-#define SPECK128_256_NROUNDS	34
-
-struct speck128_tfm_ctx {
-	u64 round_keys[SPECK128_256_NROUNDS];
-	int nrounds;
-};
-
 static __always_inline void speck128_round(u64 *x, u64 *y, u64 k)
 {
 	*x = ror64(*x, 8);
@@ -65,9 +50,9 @@ static __always_inline void speck128_unround(u64 *x, u64 *y, u64 k)
 	*x = rol64(*x, 8);
 }
 
-static void speck128_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+void crypto_speck128_encrypt(const struct speck128_tfm_ctx *ctx,
+			     u8 *out, const u8 *in)
 {
-	const struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u64 y = get_unaligned_le64(in);
 	u64 x = get_unaligned_le64(in + 8);
 	int i;
@@ -78,10 +63,16 @@ static void speck128_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 	put_unaligned_le64(y, out);
 	put_unaligned_le64(x, out + 8);
 }
+EXPORT_SYMBOL_GPL(crypto_speck128_encrypt);
 
-static void speck128_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+static void speck128_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	crypto_speck128_encrypt(crypto_tfm_ctx(tfm), out, in);
+}
+
+void crypto_speck128_decrypt(const struct speck128_tfm_ctx *ctx,
+			     u8 *out, const u8 *in)
 {
-	const struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u64 y = get_unaligned_le64(in);
 	u64 x = get_unaligned_le64(in + 8);
 	int i;
@@ -92,11 +83,16 @@ static void speck128_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 	put_unaligned_le64(y, out);
 	put_unaligned_le64(x, out + 8);
 }
+EXPORT_SYMBOL_GPL(crypto_speck128_decrypt);
 
-static int speck128_setkey(struct crypto_tfm *tfm, const u8 *key,
+static void speck128_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	crypto_speck128_decrypt(crypto_tfm_ctx(tfm), out, in);
+}
+
+int crypto_speck128_setkey(struct speck128_tfm_ctx *ctx, const u8 *key,
 			   unsigned int keylen)
 {
-	struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u64 l[3];
 	u64 k;
 	int i;
@@ -138,21 +134,15 @@ static int speck128_setkey(struct crypto_tfm *tfm, const u8 *key,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(crypto_speck128_setkey);
 
-/* Speck64 */
-
-#define SPECK64_BLOCK_SIZE	8
-
-#define SPECK64_96_KEY_SIZE	12
-#define SPECK64_96_NROUNDS	26
-
-#define SPECK64_128_KEY_SIZE	16
-#define SPECK64_128_NROUNDS	27
+static int speck128_setkey(struct crypto_tfm *tfm, const u8 *key,
+			   unsigned int keylen)
+{
+	return crypto_speck128_setkey(crypto_tfm_ctx(tfm), key, keylen);
+}
 
-struct speck64_tfm_ctx {
-	u32 round_keys[SPECK64_128_NROUNDS];
-	int nrounds;
-};
+/* Speck64 */
 
 static __always_inline void speck64_round(u32 *x, u32 *y, u32 k)
 {
@@ -172,9 +162,9 @@ static __always_inline void speck64_unround(u32 *x, u32 *y, u32 k)
 	*x = rol32(*x, 8);
 }
 
-static void speck64_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+void crypto_speck64_encrypt(const struct speck64_tfm_ctx *ctx,
+			    u8 *out, const u8 *in)
 {
-	const struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u32 y = get_unaligned_le32(in);
 	u32 x = get_unaligned_le32(in + 4);
 	int i;
@@ -185,10 +175,16 @@ static void speck64_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 	put_unaligned_le32(y, out);
 	put_unaligned_le32(x, out + 4);
 }
+EXPORT_SYMBOL_GPL(crypto_speck64_encrypt);
 
-static void speck64_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+static void speck64_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	crypto_speck64_encrypt(crypto_tfm_ctx(tfm), out, in);
+}
+
+void crypto_speck64_decrypt(const struct speck64_tfm_ctx *ctx,
+			    u8 *out, const u8 *in)
 {
-	const struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u32 y = get_unaligned_le32(in);
 	u32 x = get_unaligned_le32(in + 4);
 	int i;
@@ -199,11 +195,16 @@ static void speck64_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
 	put_unaligned_le32(y, out);
 	put_unaligned_le32(x, out + 4);
 }
+EXPORT_SYMBOL_GPL(crypto_speck64_decrypt);
 
-static int speck64_setkey(struct crypto_tfm *tfm, const u8 *key,
+static void speck64_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	crypto_speck64_decrypt(crypto_tfm_ctx(tfm), out, in);
+}
+
+int crypto_speck64_setkey(struct speck64_tfm_ctx *ctx, const u8 *key,
 			  unsigned int keylen)
 {
-	struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
 	u32 l[3];
 	u32 k;
 	int i;
@@ -236,6 +237,13 @@ static int speck64_setkey(struct crypto_tfm *tfm, const u8 *key,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(crypto_speck64_setkey);
+
+static int speck64_setkey(struct crypto_tfm *tfm, const u8 *key,
+			  unsigned int keylen)
+{
+	return crypto_speck64_setkey(crypto_tfm_ctx(tfm), key, keylen);
+}
 
 /* Algorithm definitions */
 
diff --git a/include/crypto/speck.h b/include/crypto/speck.h
new file mode 100644
index 000000000000..73cfc952d405
--- /dev/null
+++ b/include/crypto/speck.h
@@ -0,0 +1,62 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Common values for the Speck algorithm
+ */
+
+#ifndef _CRYPTO_SPECK_H
+#define _CRYPTO_SPECK_H
+
+#include <linux/types.h>
+
+/* Speck128 */
+
+#define SPECK128_BLOCK_SIZE	16
+
+#define SPECK128_128_KEY_SIZE	16
+#define SPECK128_128_NROUNDS	32
+
+#define SPECK128_192_KEY_SIZE	24
+#define SPECK128_192_NROUNDS	33
+
+#define SPECK128_256_KEY_SIZE	32
+#define SPECK128_256_NROUNDS	34
+
+struct speck128_tfm_ctx {
+	u64 round_keys[SPECK128_256_NROUNDS];
+	int nrounds;
+};
+
+void crypto_speck128_encrypt(const struct speck128_tfm_ctx *ctx,
+			     u8 *out, const u8 *in);
+
+void crypto_speck128_decrypt(const struct speck128_tfm_ctx *ctx,
+			     u8 *out, const u8 *in);
+
+int crypto_speck128_setkey(struct speck128_tfm_ctx *ctx, const u8 *key,
+			   unsigned int keysize);
+
+/* Speck64 */
+
+#define SPECK64_BLOCK_SIZE	8
+
+#define SPECK64_96_KEY_SIZE	12
+#define SPECK64_96_NROUNDS	26
+
+#define SPECK64_128_KEY_SIZE	16
+#define SPECK64_128_NROUNDS	27
+
+struct speck64_tfm_ctx {
+	u32 round_keys[SPECK64_128_NROUNDS];
+	int nrounds;
+};
+
+void crypto_speck64_encrypt(const struct speck64_tfm_ctx *ctx,
+			    u8 *out, const u8 *in);
+
+void crypto_speck64_decrypt(const struct speck64_tfm_ctx *ctx,
+			    u8 *out, const u8 *in);
+
+int crypto_speck64_setkey(struct speck64_tfm_ctx *ctx, const u8 *key,
+			  unsigned int keysize);
+
+#endif /* _CRYPTO_SPECK_H */
-- 
2.16.1.291.g4437f3f132-goog

