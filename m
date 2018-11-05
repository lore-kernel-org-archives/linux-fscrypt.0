Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54600 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729098AbeKFItO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Nov 2018 03:49:14 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v3 13/15] crypto: arm/nhpoly1305 - add NEON-accelerated NHPoly1305
Date: Mon,  5 Nov 2018 15:25:24 -0800
Message-Id: <20181105232526.173947-14-ebiggers@kernel.org>
In-Reply-To: <20181105232526.173947-1-ebiggers@kernel.org>
References: <20181105232526.173947-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add an ARM NEON implementation of NHPoly1305, an ε-almost-∆-universal
hash function used in the Adiantum encryption mode.  For now, only the
NH portion is actually NEON-accelerated; the Poly1305 part is less
performance-critical so is just implemented in C.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/arm/crypto/Kconfig                |   5 ++
 arch/arm/crypto/Makefile               |   2 +
 arch/arm/crypto/nh-neon-core.S         | 116 +++++++++++++++++++++++++
 arch/arm/crypto/nhpoly1305-neon-glue.c |  77 ++++++++++++++++
 4 files changed, 200 insertions(+)
 create mode 100644 arch/arm/crypto/nh-neon-core.S
 create mode 100644 arch/arm/crypto/nhpoly1305-neon-glue.c

diff --git a/arch/arm/crypto/Kconfig b/arch/arm/crypto/Kconfig
index cc932d9bba56..458562a34aab 100644
--- a/arch/arm/crypto/Kconfig
+++ b/arch/arm/crypto/Kconfig
@@ -122,4 +122,9 @@ config CRYPTO_CHACHA20_NEON
 	select CRYPTO_BLKCIPHER
 	select CRYPTO_CHACHA20
 
+config CRYPTO_NHPOLY1305_NEON
+	tristate "NEON accelerated NHPoly1305 hash function (for Adiantum)"
+	depends on KERNEL_MODE_NEON
+	select CRYPTO_NHPOLY1305
+
 endif
diff --git a/arch/arm/crypto/Makefile b/arch/arm/crypto/Makefile
index 005482ff9504..b65d6bfab8e6 100644
--- a/arch/arm/crypto/Makefile
+++ b/arch/arm/crypto/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_CRYPTO_SHA1_ARM_NEON) += sha1-arm-neon.o
 obj-$(CONFIG_CRYPTO_SHA256_ARM) += sha256-arm.o
 obj-$(CONFIG_CRYPTO_SHA512_ARM) += sha512-arm.o
 obj-$(CONFIG_CRYPTO_CHACHA20_NEON) += chacha-neon.o
+obj-$(CONFIG_CRYPTO_NHPOLY1305_NEON) += nhpoly1305-neon.o
 
 ce-obj-$(CONFIG_CRYPTO_AES_ARM_CE) += aes-arm-ce.o
 ce-obj-$(CONFIG_CRYPTO_SHA1_ARM_CE) += sha1-arm-ce.o
@@ -53,6 +54,7 @@ ghash-arm-ce-y	:= ghash-ce-core.o ghash-ce-glue.o
 crct10dif-arm-ce-y	:= crct10dif-ce-core.o crct10dif-ce-glue.o
 crc32-arm-ce-y:= crc32-ce-core.o crc32-ce-glue.o
 chacha-neon-y := chacha-neon-core.o chacha-neon-glue.o
+nhpoly1305-neon-y := nh-neon-core.o nhpoly1305-neon-glue.o
 
 ifdef REGENERATE_ARM_CRYPTO
 quiet_cmd_perl = PERL    $@
diff --git a/arch/arm/crypto/nh-neon-core.S b/arch/arm/crypto/nh-neon-core.S
new file mode 100644
index 000000000000..434d80ab531c
--- /dev/null
+++ b/arch/arm/crypto/nh-neon-core.S
@@ -0,0 +1,116 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * NH - ε-almost-universal hash function, NEON accelerated version
+ *
+ * Copyright 2018 Google LLC
+ *
+ * Author: Eric Biggers <ebiggers@google.com>
+ */
+
+#include <linux/linkage.h>
+
+	.text
+	.fpu		neon
+
+	KEY		.req	r0
+	MESSAGE		.req	r1
+	MESSAGE_LEN	.req	r2
+	HASH		.req	r3
+
+	PASS0_SUMS	.req	q0
+	PASS0_SUM_A	.req	d0
+	PASS0_SUM_B	.req	d1
+	PASS1_SUMS	.req	q1
+	PASS1_SUM_A	.req	d2
+	PASS1_SUM_B	.req	d3
+	PASS2_SUMS	.req	q2
+	PASS2_SUM_A	.req	d4
+	PASS2_SUM_B	.req	d5
+	PASS3_SUMS	.req	q3
+	PASS3_SUM_A	.req	d6
+	PASS3_SUM_B	.req	d7
+	K0		.req	q4
+	K1		.req	q5
+	K2		.req	q6
+	K3		.req	q7
+	T0		.req	q8
+	T0_L		.req	d16
+	T0_H		.req	d17
+	T1		.req	q9
+	T1_L		.req	d18
+	T1_H		.req	d19
+	T2		.req	q10
+	T2_L		.req	d20
+	T2_H		.req	d21
+	T3		.req	q11
+	T3_L		.req	d22
+	T3_H		.req	d23
+
+.macro _nh_stride	k0, k1, k2, k3
+
+	// Load next message stride
+	vld1.8		{T3}, [MESSAGE]!
+
+	// Load next key stride
+	vld1.32		{\k3}, [KEY]!
+
+	// Add message words to key words
+	vadd.u32	T0, T3, \k0
+	vadd.u32	T1, T3, \k1
+	vadd.u32	T2, T3, \k2
+	vadd.u32	T3, T3, \k3
+
+	// Multiply 32x32 => 64 and accumulate
+	vmlal.u32	PASS0_SUMS, T0_L, T0_H
+	vmlal.u32	PASS1_SUMS, T1_L, T1_H
+	vmlal.u32	PASS2_SUMS, T2_L, T2_H
+	vmlal.u32	PASS3_SUMS, T3_L, T3_H
+.endm
+
+/*
+ * void nh_neon(const u32 *key, const u8 *message, size_t message_len,
+ *		u8 hash[NH_HASH_BYTES])
+ *
+ * It's guaranteed that message_len % 16 == 0.
+ */
+ENTRY(nh_neon)
+
+	vld1.32		{K0,K1}, [KEY]!
+	  vmov.u64	PASS0_SUMS, #0
+	  vmov.u64	PASS1_SUMS, #0
+	vld1.32		{K2}, [KEY]!
+	  vmov.u64	PASS2_SUMS, #0
+	  vmov.u64	PASS3_SUMS, #0
+
+	subs		MESSAGE_LEN, MESSAGE_LEN, #64
+	blt		.Lloop4_done
+.Lloop4:
+	_nh_stride	K0, K1, K2, K3
+	_nh_stride	K1, K2, K3, K0
+	_nh_stride	K2, K3, K0, K1
+	_nh_stride	K3, K0, K1, K2
+	subs		MESSAGE_LEN, MESSAGE_LEN, #64
+	bge		.Lloop4
+
+.Lloop4_done:
+	ands		MESSAGE_LEN, MESSAGE_LEN, #63
+	beq		.Ldone
+	_nh_stride	K0, K1, K2, K3
+
+	subs		MESSAGE_LEN, MESSAGE_LEN, #16
+	beq		.Ldone
+	_nh_stride	K1, K2, K3, K0
+
+	subs		MESSAGE_LEN, MESSAGE_LEN, #16
+	beq		.Ldone
+	_nh_stride	K2, K3, K0, K1
+
+.Ldone:
+	// Sum the accumulators for each pass, then store the sums to 'hash'
+	vadd.u64	T0_L, PASS0_SUM_A, PASS0_SUM_B
+	vadd.u64	T0_H, PASS1_SUM_A, PASS1_SUM_B
+	vadd.u64	T1_L, PASS2_SUM_A, PASS2_SUM_B
+	vadd.u64	T1_H, PASS3_SUM_A, PASS3_SUM_B
+	vst1.8		{T0-T1}, [HASH]
+	bx		lr
+ENDPROC(nh_neon)
diff --git a/arch/arm/crypto/nhpoly1305-neon-glue.c b/arch/arm/crypto/nhpoly1305-neon-glue.c
new file mode 100644
index 000000000000..49aae87cb2bc
--- /dev/null
+++ b/arch/arm/crypto/nhpoly1305-neon-glue.c
@@ -0,0 +1,77 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * NHPoly1305 - ε-almost-∆-universal hash function for Adiantum
+ * (NEON accelerated version)
+ *
+ * Copyright 2018 Google LLC
+ */
+
+#include <asm/neon.h>
+#include <asm/simd.h>
+#include <crypto/internal/hash.h>
+#include <crypto/nhpoly1305.h>
+#include <linux/module.h>
+
+asmlinkage void nh_neon(const u32 *key, const u8 *message, size_t message_len,
+			u8 hash[NH_HASH_BYTES]);
+
+/* wrapper to avoid indirect call to assembly, which doesn't work with CFI */
+static void _nh_neon(const u32 *key, const u8 *message, size_t message_len,
+		     __le64 hash[NH_NUM_PASSES])
+{
+	nh_neon(key, message, message_len, (u8 *)hash);
+}
+
+static int nhpoly1305_neon_update(struct shash_desc *desc,
+				  const u8 *src, unsigned int srclen)
+{
+	if (srclen < 64 || !may_use_simd())
+		return crypto_nhpoly1305_update(desc, src, srclen);
+
+	do {
+		unsigned int n = min_t(unsigned int, srclen, PAGE_SIZE);
+
+		kernel_neon_begin();
+		crypto_nhpoly1305_update_helper(desc, src, n, _nh_neon);
+		kernel_neon_end();
+		src += n;
+		srclen -= n;
+	} while (srclen);
+	return 0;
+}
+
+static struct shash_alg nhpoly1305_alg = {
+	.base.cra_name		= "nhpoly1305",
+	.base.cra_driver_name	= "nhpoly1305-neon",
+	.base.cra_priority	= 200,
+	.base.cra_ctxsize	= sizeof(struct nhpoly1305_key),
+	.base.cra_module	= THIS_MODULE,
+	.digestsize		= POLY1305_DIGEST_SIZE,
+	.init			= crypto_nhpoly1305_init,
+	.update			= nhpoly1305_neon_update,
+	.final			= crypto_nhpoly1305_final,
+	.setkey			= crypto_nhpoly1305_setkey,
+	.descsize		= sizeof(struct nhpoly1305_state),
+};
+
+static int __init nhpoly1305_mod_init(void)
+{
+	if (!(elf_hwcap & HWCAP_NEON))
+		return -ENODEV;
+
+	return crypto_register_shash(&nhpoly1305_alg);
+}
+
+static void __exit nhpoly1305_mod_exit(void)
+{
+	crypto_unregister_shash(&nhpoly1305_alg);
+}
+
+module_init(nhpoly1305_mod_init);
+module_exit(nhpoly1305_mod_exit);
+
+MODULE_DESCRIPTION("NHPoly1305 ε-almost-∆-universal hash function (NEON-accelerated)");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Eric Biggers <ebiggers@google.com>");
+MODULE_ALIAS_CRYPTO("nhpoly1305");
+MODULE_ALIAS_CRYPTO("nhpoly1305-neon");
-- 
2.19.1.930.g4563a0d9d0-goog
