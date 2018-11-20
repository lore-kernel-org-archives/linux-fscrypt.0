Return-Path: <SRS0=+oNo=N7=gondor.apana.org.au=herbert@kernel.org>
Subject: [v2 PATCH 3/4] zinc: Add x86 accelerated ChaCha20
References: <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
Message-Id: <E1gOz9T-00066y-BK@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Nov 2018 14:04:47 +0800
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch exposes the crypto API x86 chacha20 implementation through
zinc.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/zinc/Kconfig                         |    1 
 lib/zinc/chacha20/chacha20-x86_64-glue.c |   55 +++++++++++++++++++++++++++++++
 lib/zinc/chacha20/chacha20.c             |    4 ++
 3 files changed, 60 insertions(+)

diff --git a/lib/zinc/Kconfig b/lib/zinc/Kconfig
index 1fffd0a1a74c..010547fa6c9d 100644
--- a/lib/zinc/Kconfig
+++ b/lib/zinc/Kconfig
@@ -1,6 +1,7 @@
 config ZINC_CHACHA20
 	tristate
 	select CRYPTO_CHACHA20
+	select CRYPTO_CHACHA20_X86_64 if ZINC_ARCH_X86_64
 
 config ZINC_SELFTEST
 	bool "Zinc cryptography library self-tests"
diff --git a/lib/zinc/chacha20/chacha20-x86_64-glue.c b/lib/zinc/chacha20/chacha20-x86_64-glue.c
new file mode 100644
index 000000000000..07f72729a64e
--- /dev/null
+++ b/lib/zinc/chacha20/chacha20-x86_64-glue.c
@@ -0,0 +1,55 @@
+// SPDX-License-Identifier: GPL-2.0 OR MIT
+/*
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#include <asm/fpu/api.h>
+#include <asm/cpufeature.h>
+#include <asm/processor.h>
+#include <asm/intel-family.h>
+#include <crypto/chacha20.h>
+
+static bool chacha20_use_ssse3 __ro_after_init;
+static bool *const chacha20_nobs[] __initconst = {
+	&chacha20_use_ssse3 };
+
+static void __init chacha20_fpu_init(void)
+{
+	chacha20_use_ssse3 = boot_cpu_has(X86_FEATURE_SSSE3);
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
+	if (!IS_ENABLED(CONFIG_AS_SSSE3) || !chacha20_use_ssse3 ||
+	    len <= CHACHA20_BLOCK_SIZE || !simd_use(simd_context))
+		return false;
+
+	for (;;) {
+		const size_t bytes = min_t(size_t, len, PAGE_SIZE);
+
+		crypto_chacha20_dosimd(ctx->state, dst, src, bytes);
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
index 132850d19e39..480d304cd917 100644
--- a/lib/zinc/chacha20/chacha20.c
+++ b/lib/zinc/chacha20/chacha20.c
@@ -17,6 +17,9 @@
 #include <crypto/algapi.h> // For crypto_xor_cpy.
 #include <crypto/chacha20.h>
 
+#if defined(CONFIG_ZINC_ARCH_X86_64)
+#include "chacha20-x86_64-glue.c"
+#else
 static bool *const chacha20_nobs[] __initconst = { };
 static void __init chacha20_fpu_init(void)
 {
@@ -34,6 +37,7 @@ static inline bool hchacha20_arch(u32 derived_key[CHACHA20_KEY_WORDS],
 {
 	return false;
 }
+#endif
 
 void chacha20(struct chacha20_ctx *ctx, u8 *dst, const u8 *src, u32 len,
 	      simd_context_t *simd_context)
