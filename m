Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 9/17] zinc: Add x86 accelerated poly1305
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgZ-0001IW-E8@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:47 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch exposes the crypto API x86 poly1305 implementation through
zinc.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/zinc/Kconfig                         |    1 
 lib/zinc/poly1305/poly1305-x86_64-glue.c |   68 +++++++++++++++++++++++++++++++
 lib/zinc/poly1305/poly1305.c             |    4 +
 3 files changed, 73 insertions(+)

diff --git a/lib/zinc/Kconfig b/lib/zinc/Kconfig
index 70d45b3288d2..34fa49beb37f 100644
--- a/lib/zinc/Kconfig
+++ b/lib/zinc/Kconfig
@@ -8,6 +8,7 @@ config ZINC_CHACHA20
 config ZINC_POLY1305
 	tristate
 	select CRYPTO_POLY1305
+	select CRYPTO_POLY1305_X86_64 if ZINC_ARCH_X86_64
 
 config ZINC_SELFTEST
 	bool "Zinc cryptography library self-tests"
diff --git a/lib/zinc/poly1305/poly1305-x86_64-glue.c b/lib/zinc/poly1305/poly1305-x86_64-glue.c
new file mode 100644
index 000000000000..9e6dbd40911d
--- /dev/null
+++ b/lib/zinc/poly1305/poly1305-x86_64-glue.c
@@ -0,0 +1,68 @@
+// SPDX-License-Identifier: GPL-2.0 OR MIT
+/*
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#include <asm/cpufeature.h>
+#include <asm/processor.h>
+#include <asm/intel-family.h>
+
+static bool poly1305_use_sse2 __ro_after_init;
+static bool *const poly1305_nobs[] __initconst = {
+	&poly1305_use_sse2 };
+
+static void __init poly1305_fpu_init(void)
+{
+	poly1305_use_sse2 = boot_cpu_has(X86_FEATURE_XMM2);
+}
+
+struct poly1305_arch_internal {
+	struct poly1305_internal base;
+	struct poly1305_simd_xtra x;
+};
+
+static inline bool poly1305_init_arch(void *ctx,
+				      const u8 key[POLY1305_KEY_SIZE])
+{
+	struct poly1305_arch_internal *state = ctx;
+
+	poly1305_simd_init(&state->x);
+	poly1305_core_setkey(&state->base.r, key);
+	return true;
+}
+
+static inline bool poly1305_blocks_arch(void *ctx, const u8 *inp,
+					size_t len, const u32 padbit,
+					simd_context_t *simd_context)
+{
+	struct poly1305_arch_internal *state = ctx;
+
+	/* SIMD disables preemption, so relax after processing each page. */
+	BUILD_BUG_ON(PAGE_SIZE < POLY1305_BLOCK_SIZE ||
+		     PAGE_SIZE % POLY1305_BLOCK_SIZE);
+
+	if (!poly1305_use_sse2 || !simd_use(simd_context) || padbit)
+		return false;
+
+	for (;;) {
+		const size_t bytes = min_t(size_t, len, PAGE_SIZE);
+
+		poly1305_simd_blocks(&state->base.h, &state->base.r,
+				     &state->x, inp, bytes);
+
+		len -= bytes;
+		if (!len)
+			break;
+		inp += bytes;
+		simd_relax(simd_context);
+	}
+
+	return true;
+}
+
+static inline bool poly1305_emit_arch(void *ctx, u8 mac[POLY1305_MAC_SIZE],
+				      const u32 nonce[4],
+				      simd_context_t *simd_context)
+{
+	return false;
+}
diff --git a/lib/zinc/poly1305/poly1305.c b/lib/zinc/poly1305/poly1305.c
index 1546f5ac6d1c..c6a88136abb7 100644
--- a/lib/zinc/poly1305/poly1305.c
+++ b/lib/zinc/poly1305/poly1305.c
@@ -22,6 +22,9 @@ struct poly1305_internal {
 	struct poly1305_state h;
 };
 
+#if defined(CONFIG_ZINC_ARCH_X86_64)
+#include "poly1305-x86_64-glue.c"
+#else
 static inline bool poly1305_init_arch(void *ctx,
 				      const u8 key[POLY1305_KEY_SIZE])
 {
@@ -43,6 +46,7 @@ static bool *const poly1305_nobs[] __initconst = { };
 static void __init poly1305_fpu_init(void)
 {
 }
+#endif
 
 static void poly1305_init_generic(void *ctx, const u8 key[16])
 {
