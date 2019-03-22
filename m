Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 6/17] zinc: Add arm accelerated chacha20
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgV-0001Hv-7y@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:43 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch exposes the crypto API arm neon chacha20 implementation
through zinc.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/zinc/Kconfig                      |    2 +
 lib/zinc/chacha20/chacha20-arm-glue.c |   68 ++++++++++++++++++++++++++++++++++
 lib/zinc/chacha20/chacha20.c          |    2 +
 3 files changed, 72 insertions(+)

diff --git a/lib/zinc/Kconfig b/lib/zinc/Kconfig
index 010547fa6c9d..2d1750c50919 100644
--- a/lib/zinc/Kconfig
+++ b/lib/zinc/Kconfig
@@ -2,6 +2,8 @@ config ZINC_CHACHA20
 	tristate
 	select CRYPTO_CHACHA20
 	select CRYPTO_CHACHA20_X86_64 if ZINC_ARCH_X86_64
+	select CRYPTO_CHACHA20_NEON if ZINC_ARCH_ARM
+	select CRYPTO_CHACHA20_NEON if ZINC_ARCH_ARM64
 
 config ZINC_SELFTEST
 	bool "Zinc cryptography library self-tests"
diff --git a/lib/zinc/chacha20/chacha20-arm-glue.c b/lib/zinc/chacha20/chacha20-arm-glue.c
new file mode 100644
index 000000000000..2b6c88cf516b
--- /dev/null
+++ b/lib/zinc/chacha20/chacha20-arm-glue.c
@@ -0,0 +1,68 @@
+// SPDX-License-Identifier: GPL-2.0 OR MIT
+/*
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#include <asm/hwcap.h>
+#include <asm/neon.h>
+#if defined(CONFIG_ZINC_ARCH_ARM)
+#include <asm/system_info.h>
+#include <asm/cputype.h>
+#endif
+#include <crypto/chacha.h>
+
+static bool chacha20_use_neon __ro_after_init;
+static bool *const chacha20_nobs[] __initconst = { &chacha20_use_neon };
+static void __init chacha20_fpu_init(void)
+{
+#if defined(CONFIG_ZINC_ARCH_ARM64)
+	chacha20_use_neon = elf_hwcap & HWCAP_ASIMD;
+#elif defined(CONFIG_ZINC_ARCH_ARM)
+	switch (read_cpuid_part()) {
+	case ARM_CPU_PART_CORTEX_A7:
+	case ARM_CPU_PART_CORTEX_A5:
+		/* The Cortex-A7 and Cortex-A5 do not perform well with the NEON
+		 * implementation but do incredibly with the scalar one and use
+		 * less power.
+		 */
+		break;
+	default:
+		chacha20_use_neon = elf_hwcap & HWCAP_NEON;
+	}
+#endif
+}
+
+static inline bool chacha20_arch(struct chacha20_ctx *ctx, u8 *dst,
+				 const u8 *src, size_t len,
+				 simd_context_t *simd_context)
+{
+	/* SIMD disables preemption, so relax after processing each page. */
+	BUILD_BUG_ON(PAGE_SIZE < CHACHA20_BLOCK_SIZE ||
+		     PAGE_SIZE % CHACHA20_BLOCK_SIZE);
+
+	if (!IS_ENABLED(CONFIG_KERNEL_MODE_NEON) || !chacha20_use_neon ||
+	    len < CHACHA20_BLOCK_SIZE * 3 || !simd_use(simd_context)) {
+
+	for (;;) {
+		const size_t bytes = min_t(size_t, len, PAGE_SIZE);
+
+		crypto_chacha_neon(ctx->state, dst, src, bytes, 20);
+
+		len -= bytes;
+		if (!len)
+			break;
+		dst += bytes;
+		src += bytes;
+		simd_relax(simd_context);
+	}
+
+	return true;
+}
+
+static inline bool hchacha20_arch(u32 derived_key[CHACHA20_KEY_WORDS],
+				  const u8 nonce[HCHACHA20_NONCE_SIZE],
+				  const u8 key[HCHACHA20_KEY_SIZE],
+				  simd_context_t *simd_context)
+{
+	return false;
+}
diff --git a/lib/zinc/chacha20/chacha20.c b/lib/zinc/chacha20/chacha20.c
index c84fe504623f..314525f86757 100644
--- a/lib/zinc/chacha20/chacha20.c
+++ b/lib/zinc/chacha20/chacha20.c
@@ -19,6 +19,8 @@
 
 #if defined(CONFIG_ZINC_ARCH_X86_64)
 #include "chacha20-x86_64-glue.c"
+#elif defined(CONFIG_ZINC_ARCH_ARM) || defined(CONFIG_ZINC_ARCH_ARM64)
+#include "chacha20-arm-glue.c"
 #else
 static bool *const chacha20_nobs[] __initconst = { };
 static void __init chacha20_fpu_init(void)
