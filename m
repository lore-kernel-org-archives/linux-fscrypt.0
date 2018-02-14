Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:40595 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162189AbeBNSoO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Feb 2018 13:44:14 -0500
Received: by mail-it0-f51.google.com with SMTP id v186so10909406itc.5
        for <linux-fscrypt@vger.kernel.org>; Wed, 14 Feb 2018 10:44:14 -0800 (PST)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v3 1/5] crypto: add support for the Speck block cipher
Date: Wed, 14 Feb 2018 10:42:19 -0800
Message-Id: <20180214184223.254359-2-ebiggers@google.com>
In-Reply-To: <20180214184223.254359-1-ebiggers@google.com>
References: <20180214184223.254359-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Add a generic implementation of Speck, including the Speck128 and
Speck64 variants.  Speck is a lightweight block cipher that can be much
faster than AES on processors that don't have AES instructions.

We are planning to offer Speck-XTS (probably Speck128/256-XTS) as an
option for dm-crypt and fscrypt on Android, for low-end mobile devices
with older CPUs such as ARMv7 which don't have the Cryptography
Extensions.  Currently, such devices are unencrypted because AES is not
fast enough, even when the NEON bit-sliced implementation of AES is
used.  Other AES alternatives such as Twofish, Threefish, Camellia,
CAST6, and Serpent aren't fast enough either; it seems that only a
modern ARX cipher can provide sufficient performance on these devices.

This is a replacement for our original proposal
(https://patchwork.kernel.org/patch/10101451/) which was to offer
ChaCha20 for these devices.  However, the use of a stream cipher for
disk/file encryption with no space to store nonces would have been much
more insecure than we thought initially, given that it would be used on
top of flash storage as well as potentially on top of F2FS, neither of
which is guaranteed to overwrite data in-place.

Speck has been somewhat controversial due to its origin.  Nevertheless,
it has a straightforward design (it's an ARX cipher), and it appears to
be the leading software-optimized lightweight block cipher currently,
with the most cryptanalysis.  It's also easy to implement without side
channels, unlike AES.  Moreover, we only intend Speck to be used when
the status quo is no encryption, due to AES not being fast enough.

We've also considered a novel length-preserving encryption mode based on
ChaCha20 and Poly1305.  While theoretically attractive, such a mode
would be a brand new crypto construction and would be more complicated
and difficult to implement efficiently in comparison to Speck-XTS.

There is confusion about the byte and word orders of Speck, since the
original paper doesn't specify them.  But we have implemented it using
the orders the authors recommended in a correspondence with them.  The
test vectors are taken from the original paper but were mapped to byte
arrays using the recommended byte and word orders.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 crypto/Kconfig   |  14 +++
 crypto/Makefile  |   1 +
 crypto/speck.c   | 299 +++++++++++++++++++++++++++++++++++++++++++++++
 crypto/testmgr.c |  18 +++
 crypto/testmgr.h | 128 ++++++++++++++++++++
 5 files changed, 460 insertions(+)
 create mode 100644 crypto/speck.c

diff --git a/crypto/Kconfig b/crypto/Kconfig
index b75264b09a46..558eff07b799 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -1508,6 +1508,20 @@ config CRYPTO_SERPENT_AVX2_X86_64
 	  See also:
 	  <http://www.cl.cam.ac.uk/~rja14/serpent.html>
 
+config CRYPTO_SPECK
+	tristate "Speck cipher algorithm"
+	select CRYPTO_ALGAPI
+	help
+	  Speck is a lightweight block cipher that is tuned for optimal
+	  performance in software (rather than hardware).
+
+	  Speck may not be as secure as AES, and should only be used on systems
+	  where AES is not fast enough.
+
+	  See also: <https://eprint.iacr.org/2013/404.pdf>
+
+	  If unsure, say N.
+
 config CRYPTO_TEA
 	tristate "TEA, XTEA and XETA cipher algorithms"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
index cdbc03b35510..ba6019471447 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -110,6 +110,7 @@ obj-$(CONFIG_CRYPTO_TEA) += tea.o
 obj-$(CONFIG_CRYPTO_KHAZAD) += khazad.o
 obj-$(CONFIG_CRYPTO_ANUBIS) += anubis.o
 obj-$(CONFIG_CRYPTO_SEED) += seed.o
+obj-$(CONFIG_CRYPTO_SPECK) += speck.o
 obj-$(CONFIG_CRYPTO_SALSA20) += salsa20_generic.o
 obj-$(CONFIG_CRYPTO_CHACHA20) += chacha20_generic.o
 obj-$(CONFIG_CRYPTO_POLY1305) += poly1305_generic.o
diff --git a/crypto/speck.c b/crypto/speck.c
new file mode 100644
index 000000000000..4e80ad76bcd7
--- /dev/null
+++ b/crypto/speck.c
@@ -0,0 +1,299 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * Speck: a lightweight block cipher
+ *
+ * Copyright (c) 2018 Google, Inc
+ *
+ * Speck has 10 variants, including 5 block sizes.  For now we only implement
+ * the variants Speck128/128, Speck128/192, Speck128/256, Speck64/96, and
+ * Speck64/128.   Speck${B}/${K} denotes the variant with a block size of B bits
+ * and a key size of K bits.  The Speck128 variants are believed to be the most
+ * secure variants, and they use the same block size and key sizes as AES.  The
+ * Speck64 variants are less secure, but on 32-bit processors are usually
+ * faster.  The remaining variants (Speck32, Speck48, and Speck96) are even less
+ * secure and/or not as well suited for implementation on either 32-bit or
+ * 64-bit processors, so are omitted.
+ *
+ * Reference: "The Simon and Speck Families of Lightweight Block Ciphers"
+ * https://eprint.iacr.org/2013/404.pdf
+ *
+ * In a correspondence, the Speck designers have also clarified that the words
+ * should be interpreted in little-endian format, and the words should be
+ * ordered such that the first word of each block is 'y' rather than 'x', and
+ * the first key word (rather than the last) becomes the first round key.
+ */
+
+#include <asm/unaligned.h>
+#include <linux/bitops.h>
+#include <linux/crypto.h>
+#include <linux/init.h>
+#include <linux/module.h>
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
+static __always_inline void speck128_round(u64 *x, u64 *y, u64 k)
+{
+	*x = ror64(*x, 8);
+	*x += *y;
+	*x ^= k;
+	*y = rol64(*y, 3);
+	*y ^= *x;
+}
+
+static __always_inline void speck128_unround(u64 *x, u64 *y, u64 k)
+{
+	*y ^= *x;
+	*y = ror64(*y, 3);
+	*x ^= k;
+	*x -= *y;
+	*x = rol64(*x, 8);
+}
+
+static void speck128_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	const struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u64 y = get_unaligned_le64(in);
+	u64 x = get_unaligned_le64(in + 8);
+	int i;
+
+	for (i = 0; i < ctx->nrounds; i++)
+		speck128_round(&x, &y, ctx->round_keys[i]);
+
+	put_unaligned_le64(y, out);
+	put_unaligned_le64(x, out + 8);
+}
+
+static void speck128_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	const struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u64 y = get_unaligned_le64(in);
+	u64 x = get_unaligned_le64(in + 8);
+	int i;
+
+	for (i = ctx->nrounds - 1; i >= 0; i--)
+		speck128_unround(&x, &y, ctx->round_keys[i]);
+
+	put_unaligned_le64(y, out);
+	put_unaligned_le64(x, out + 8);
+}
+
+static int speck128_setkey(struct crypto_tfm *tfm, const u8 *key,
+			   unsigned int keylen)
+{
+	struct speck128_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u64 l[3];
+	u64 k;
+	int i;
+
+	switch (keylen) {
+	case SPECK128_128_KEY_SIZE:
+		k = get_unaligned_le64(key);
+		l[0] = get_unaligned_le64(key + 8);
+		ctx->nrounds = SPECK128_128_NROUNDS;
+		for (i = 0; i < ctx->nrounds; i++) {
+			ctx->round_keys[i] = k;
+			speck128_round(&l[0], &k, i);
+		}
+		break;
+	case SPECK128_192_KEY_SIZE:
+		k = get_unaligned_le64(key);
+		l[0] = get_unaligned_le64(key + 8);
+		l[1] = get_unaligned_le64(key + 16);
+		ctx->nrounds = SPECK128_192_NROUNDS;
+		for (i = 0; i < ctx->nrounds; i++) {
+			ctx->round_keys[i] = k;
+			speck128_round(&l[i % 2], &k, i);
+		}
+		break;
+	case SPECK128_256_KEY_SIZE:
+		k = get_unaligned_le64(key);
+		l[0] = get_unaligned_le64(key + 8);
+		l[1] = get_unaligned_le64(key + 16);
+		l[2] = get_unaligned_le64(key + 24);
+		ctx->nrounds = SPECK128_256_NROUNDS;
+		for (i = 0; i < ctx->nrounds; i++) {
+			ctx->round_keys[i] = k;
+			speck128_round(&l[i % 3], &k, i);
+		}
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
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
+static __always_inline void speck64_round(u32 *x, u32 *y, u32 k)
+{
+	*x = ror32(*x, 8);
+	*x += *y;
+	*x ^= k;
+	*y = rol32(*y, 3);
+	*y ^= *x;
+}
+
+static __always_inline void speck64_unround(u32 *x, u32 *y, u32 k)
+{
+	*y ^= *x;
+	*y = ror32(*y, 3);
+	*x ^= k;
+	*x -= *y;
+	*x = rol32(*x, 8);
+}
+
+static void speck64_encrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	const struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u32 y = get_unaligned_le32(in);
+	u32 x = get_unaligned_le32(in + 4);
+	int i;
+
+	for (i = 0; i < ctx->nrounds; i++)
+		speck64_round(&x, &y, ctx->round_keys[i]);
+
+	put_unaligned_le32(y, out);
+	put_unaligned_le32(x, out + 4);
+}
+
+static void speck64_decrypt(struct crypto_tfm *tfm, u8 *out, const u8 *in)
+{
+	const struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u32 y = get_unaligned_le32(in);
+	u32 x = get_unaligned_le32(in + 4);
+	int i;
+
+	for (i = ctx->nrounds - 1; i >= 0; i--)
+		speck64_unround(&x, &y, ctx->round_keys[i]);
+
+	put_unaligned_le32(y, out);
+	put_unaligned_le32(x, out + 4);
+}
+
+static int speck64_setkey(struct crypto_tfm *tfm, const u8 *key,
+			  unsigned int keylen)
+{
+	struct speck64_tfm_ctx *ctx = crypto_tfm_ctx(tfm);
+	u32 l[3];
+	u32 k;
+	int i;
+
+	switch (keylen) {
+	case SPECK64_96_KEY_SIZE:
+		k = get_unaligned_le32(key);
+		l[0] = get_unaligned_le32(key + 4);
+		l[1] = get_unaligned_le32(key + 8);
+		ctx->nrounds = SPECK64_96_NROUNDS;
+		for (i = 0; i < ctx->nrounds; i++) {
+			ctx->round_keys[i] = k;
+			speck64_round(&l[i % 2], &k, i);
+		}
+		break;
+	case SPECK64_128_KEY_SIZE:
+		k = get_unaligned_le32(key);
+		l[0] = get_unaligned_le32(key + 4);
+		l[1] = get_unaligned_le32(key + 8);
+		l[2] = get_unaligned_le32(key + 12);
+		ctx->nrounds = SPECK64_128_NROUNDS;
+		for (i = 0; i < ctx->nrounds; i++) {
+			ctx->round_keys[i] = k;
+			speck64_round(&l[i % 3], &k, i);
+		}
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Algorithm definitions */
+
+static struct crypto_alg speck_algs[] = {
+	{
+		.cra_name		= "speck128",
+		.cra_driver_name	= "speck128-generic",
+		.cra_priority		= 100,
+		.cra_flags		= CRYPTO_ALG_TYPE_CIPHER,
+		.cra_blocksize		= SPECK128_BLOCK_SIZE,
+		.cra_ctxsize		= sizeof(struct speck128_tfm_ctx),
+		.cra_module		= THIS_MODULE,
+		.cra_u			= {
+			.cipher = {
+				.cia_min_keysize	= SPECK128_128_KEY_SIZE,
+				.cia_max_keysize	= SPECK128_256_KEY_SIZE,
+				.cia_setkey		= speck128_setkey,
+				.cia_encrypt		= speck128_encrypt,
+				.cia_decrypt		= speck128_decrypt
+			}
+		}
+	}, {
+		.cra_name		= "speck64",
+		.cra_driver_name	= "speck64-generic",
+		.cra_priority		= 100,
+		.cra_flags		= CRYPTO_ALG_TYPE_CIPHER,
+		.cra_blocksize		= SPECK64_BLOCK_SIZE,
+		.cra_ctxsize		= sizeof(struct speck64_tfm_ctx),
+		.cra_module		= THIS_MODULE,
+		.cra_u			= {
+			.cipher = {
+				.cia_min_keysize	= SPECK64_96_KEY_SIZE,
+				.cia_max_keysize	= SPECK64_128_KEY_SIZE,
+				.cia_setkey		= speck64_setkey,
+				.cia_encrypt		= speck64_encrypt,
+				.cia_decrypt		= speck64_decrypt
+			}
+		}
+	}
+};
+
+static int __init speck_module_init(void)
+{
+	return crypto_register_algs(speck_algs, ARRAY_SIZE(speck_algs));
+}
+
+static void __exit speck_module_exit(void)
+{
+	crypto_unregister_algs(speck_algs, ARRAY_SIZE(speck_algs));
+}
+
+module_init(speck_module_init);
+module_exit(speck_module_exit);
+
+MODULE_DESCRIPTION("Speck block cipher (generic)");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
+MODULE_ALIAS_CRYPTO("speck128");
+MODULE_ALIAS_CRYPTO("speck128-generic");
+MODULE_ALIAS_CRYPTO("speck64");
+MODULE_ALIAS_CRYPTO("speck64-generic");
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index d5e23a142a04..058ed5eb6620 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -3000,6 +3000,24 @@ static const struct alg_test_desc alg_test_descs[] = {
 				.dec = __VECS(serpent_dec_tv_template)
 			}
 		}
+	}, {
+		.alg = "ecb(speck128)",
+		.test = alg_test_skcipher,
+		.suite = {
+			.cipher = {
+				.enc = __VECS(speck128_enc_tv_template),
+				.dec = __VECS(speck128_dec_tv_template)
+			}
+		}
+	}, {
+		.alg = "ecb(speck64)",
+		.test = alg_test_skcipher,
+		.suite = {
+			.cipher = {
+				.enc = __VECS(speck64_enc_tv_template),
+				.dec = __VECS(speck64_dec_tv_template)
+			}
+		}
 	}, {
 		.alg = "ecb(tea)",
 		.test = alg_test_skcipher,
diff --git a/crypto/testmgr.h b/crypto/testmgr.h
index 6044f6906bd6..3818210f77cf 100644
--- a/crypto/testmgr.h
+++ b/crypto/testmgr.h
@@ -14323,6 +14323,134 @@ static const struct cipher_testvec serpent_xts_dec_tv_template[] = {
 	},
 };
 
+/*
+ * Speck test vectors taken from the original paper:
+ * "The Simon and Speck Families of Lightweight Block Ciphers"
+ * https://eprint.iacr.org/2013/404.pdf
+ *
+ * Note that the paper does not make byte and word order clear.  But it was
+ * confirmed with the authors that the intended orders are little endian byte
+ * order and (y, x) word order.  Equivalently, the printed test vectors, when
+ * looking at only the bytes (ignoring the whitespace that divides them into
+ * words), are backwards: the left-most byte is actually the one with the
+ * highest memory address, while the right-most byte is actually the one with
+ * the lowest memory address.
+ */
+
+static const struct cipher_testvec speck128_enc_tv_template[] = {
+	{ /* Speck128/128 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f",
+		.klen	= 16,
+		.input	= "\x20\x6d\x61\x64\x65\x20\x69\x74"
+			  "\x20\x65\x71\x75\x69\x76\x61\x6c",
+		.ilen	= 16,
+		.result	= "\x18\x0d\x57\x5c\xdf\xfe\x60\x78"
+			  "\x65\x32\x78\x79\x51\x98\x5d\xa6",
+		.rlen	= 16,
+	}, { /* Speck128/192 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
+			  "\x10\x11\x12\x13\x14\x15\x16\x17",
+		.klen	= 24,
+		.input	= "\x65\x6e\x74\x20\x74\x6f\x20\x43"
+			  "\x68\x69\x65\x66\x20\x48\x61\x72",
+		.ilen	= 16,
+		.result	= "\x86\x18\x3c\xe0\x5d\x18\xbc\xf9"
+			  "\x66\x55\x13\x13\x3a\xcf\xe4\x1b",
+		.rlen	= 16,
+	}, { /* Speck128/256 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
+			  "\x10\x11\x12\x13\x14\x15\x16\x17"
+			  "\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f",
+		.klen	= 32,
+		.input	= "\x70\x6f\x6f\x6e\x65\x72\x2e\x20"
+			  "\x49\x6e\x20\x74\x68\x6f\x73\x65",
+		.ilen	= 16,
+		.result	= "\x43\x8f\x18\x9c\x8d\xb4\xee\x4e"
+			  "\x3e\xf5\xc0\x05\x04\x01\x09\x41",
+		.rlen	= 16,
+	},
+};
+
+static const struct cipher_testvec speck128_dec_tv_template[] = {
+	{ /* Speck128/128 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f",
+		.klen	= 16,
+		.input	= "\x18\x0d\x57\x5c\xdf\xfe\x60\x78"
+			  "\x65\x32\x78\x79\x51\x98\x5d\xa6",
+		.ilen	= 16,
+		.result	= "\x20\x6d\x61\x64\x65\x20\x69\x74"
+			  "\x20\x65\x71\x75\x69\x76\x61\x6c",
+		.rlen	= 16,
+	}, { /* Speck128/192 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
+			  "\x10\x11\x12\x13\x14\x15\x16\x17",
+		.klen	= 24,
+		.input	= "\x86\x18\x3c\xe0\x5d\x18\xbc\xf9"
+			  "\x66\x55\x13\x13\x3a\xcf\xe4\x1b",
+		.ilen	= 16,
+		.result	= "\x65\x6e\x74\x20\x74\x6f\x20\x43"
+			  "\x68\x69\x65\x66\x20\x48\x61\x72",
+		.rlen	= 16,
+	}, { /* Speck128/256 */
+		.key	= "\x00\x01\x02\x03\x04\x05\x06\x07"
+			  "\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
+			  "\x10\x11\x12\x13\x14\x15\x16\x17"
+			  "\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f",
+		.klen	= 32,
+		.input	= "\x43\x8f\x18\x9c\x8d\xb4\xee\x4e"
+			  "\x3e\xf5\xc0\x05\x04\x01\x09\x41",
+		.ilen	= 16,
+		.result	= "\x70\x6f\x6f\x6e\x65\x72\x2e\x20"
+			  "\x49\x6e\x20\x74\x68\x6f\x73\x65",
+		.rlen	= 16,
+	},
+};
+
+static const struct cipher_testvec speck64_enc_tv_template[] = {
+	{ /* Speck64/96 */
+		.key	= "\x00\x01\x02\x03\x08\x09\x0a\x0b"
+			  "\x10\x11\x12\x13",
+		.klen	= 12,
+		.input	= "\x65\x61\x6e\x73\x20\x46\x61\x74",
+		.ilen	= 8,
+		.result	= "\x6c\x94\x75\x41\xec\x52\x79\x9f",
+		.rlen	= 8,
+	}, { /* Speck64/128 */
+		.key	= "\x00\x01\x02\x03\x08\x09\x0a\x0b"
+			  "\x10\x11\x12\x13\x18\x19\x1a\x1b",
+		.klen	= 16,
+		.input	= "\x2d\x43\x75\x74\x74\x65\x72\x3b",
+		.ilen	= 8,
+		.result	= "\x8b\x02\x4e\x45\x48\xa5\x6f\x8c",
+		.rlen	= 8,
+	},
+};
+
+static const struct cipher_testvec speck64_dec_tv_template[] = {
+	{ /* Speck64/96 */
+		.key	= "\x00\x01\x02\x03\x08\x09\x0a\x0b"
+			  "\x10\x11\x12\x13",
+		.klen	= 12,
+		.input	= "\x6c\x94\x75\x41\xec\x52\x79\x9f",
+		.ilen	= 8,
+		.result	= "\x65\x61\x6e\x73\x20\x46\x61\x74",
+		.rlen	= 8,
+	}, { /* Speck64/128 */
+		.key	= "\x00\x01\x02\x03\x08\x09\x0a\x0b"
+			  "\x10\x11\x12\x13\x18\x19\x1a\x1b",
+		.klen	= 16,
+		.input	= "\x8b\x02\x4e\x45\x48\xa5\x6f\x8c",
+		.ilen	= 8,
+		.result	= "\x2d\x43\x75\x74\x74\x65\x72\x3b",
+		.rlen	= 8,
+	},
+};
+
 /* Cast6 test vectors from RFC 2612 */
 static const struct cipher_testvec cast6_enc_tv_template[] = {
 	{
-- 
2.16.1.291.g4437f3f132-goog

