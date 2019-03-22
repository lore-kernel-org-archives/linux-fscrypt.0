Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 1/17] asm: simd context helper API
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgP-0001Gp-MP@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:37 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Jason A. Donenfeld <Jason@zx2c4.com>

Sometimes it's useful to amortize calls to XSAVE/XRSTOR and the related
FPU/SIMD functions over a number of calls, because FPU restoration is
quite expensive. This adds a simple header for carrying out this pattern:

    simd_context_t simd_context;

    simd_get(&simd_context);
    while ((item = get_item_from_queue()) != NULL) {
        encrypt_item(item, &simd_context);
        simd_relax(&simd_context);
    }
    simd_put(&simd_context);

The relaxation step ensures that we don't trample over preemption, and
the get/put API should be a familiar paradigm in the kernel.

On the other end, code that actually wants to use SIMD instructions can
accept this as a parameter and check it via:

   void encrypt_item(struct item *item, simd_context_t *simd_context)
   {
       if (item->len > LARGE_FOR_SIMD && simd_use(simd_context))
           wild_simd_code(item);
       else
           boring_scalar_code(item);
   }

The actual XSAVE happens during simd_use (and only on the first time),
so that if the context is never actually used, no performance penalty is
hit.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Samuel Neves <sneves@dei.uc.pt>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: linux-arch@vger.kernel.org
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/alpha/include/asm/Kbuild      |    1 
 arch/arc/include/asm/Kbuild        |    1 
 arch/arm/include/asm/Kbuild        |    1 
 arch/arm/include/asm/simd.h        |   63 +++++++++++++++++++++++++++++++++++++
 arch/arm64/include/asm/simd.h      |   51 ++++++++++++++++++++++++++---
 arch/c6x/include/asm/Kbuild        |    1 
 arch/h8300/include/asm/Kbuild      |    1 
 arch/hexagon/include/asm/Kbuild    |    1 
 arch/ia64/include/asm/Kbuild       |    1 
 arch/m68k/include/asm/Kbuild       |    1 
 arch/microblaze/include/asm/Kbuild |    1 
 arch/mips/include/asm/Kbuild       |    1 
 arch/nds32/include/asm/Kbuild      |    1 
 arch/nios2/include/asm/Kbuild      |    1 
 arch/openrisc/include/asm/Kbuild   |    1 
 arch/parisc/include/asm/Kbuild     |    1 
 arch/powerpc/include/asm/Kbuild    |    1 
 arch/riscv/include/asm/Kbuild      |    1 
 arch/s390/include/asm/Kbuild       |    1 
 arch/sh/include/asm/Kbuild         |    1 
 arch/sparc/include/asm/Kbuild      |    1 
 arch/um/include/asm/Kbuild         |    1 
 arch/unicore32/include/asm/Kbuild  |    1 
 arch/x86/include/asm/simd.h        |   44 +++++++++++++++++++++++++
 arch/xtensa/include/asm/Kbuild     |    1 
 include/asm-generic/simd.h         |   20 +++++++++++
 include/linux/simd.h               |   32 ++++++++++++++++++
 27 files changed, 224 insertions(+), 8 deletions(-)

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index dc0ab28baca1..b385c2036290 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += sections.h
 generic-y += trace_clock.h
 generic-y += current.h
 generic-y += kprobes.h
+generic-y += simd.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index b41f8881ecc8..3028a2246ab4 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += msi.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
+generic-y += simd.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += user.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index a8a4eb7f6dae..27ce7c7a795a 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -16,7 +16,6 @@ generic-y += rwsem.h
 generic-y += seccomp.h
 generic-y += segment.h
 generic-y += serial.h
-generic-y += simd.h
 generic-y += sizes.h
 generic-y += trace_clock.h
 
diff --git a/arch/arm/include/asm/simd.h b/arch/arm/include/asm/simd.h
new file mode 100644
index 000000000000..264ed84b41d8
--- /dev/null
+++ b/arch/arm/include/asm/simd.h
@@ -0,0 +1,63 @@
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#include <linux/simd.h>
+#ifndef _ASM_SIMD_H
+#define _ASM_SIMD_H
+
+#ifdef CONFIG_KERNEL_MODE_NEON
+#include <asm/neon.h>
+
+static __must_check inline bool may_use_simd(void)
+{
+	return !in_nmi() && !in_irq() && !in_serving_softirq();
+}
+
+static inline void simd_get(simd_context_t *ctx)
+{
+	*ctx = may_use_simd() ? HAVE_FULL_SIMD : HAVE_NO_SIMD;
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+	if (*ctx & HAVE_SIMD_IN_USE)
+		kernel_neon_end();
+	*ctx = HAVE_NO_SIMD;
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
+	if (!(*ctx & HAVE_FULL_SIMD))
+		return false;
+	if (*ctx & HAVE_SIMD_IN_USE)
+		return true;
+	kernel_neon_begin();
+	*ctx |= HAVE_SIMD_IN_USE;
+	return true;
+}
+
+#else
+
+static __must_check inline bool may_use_simd(void)
+{
+	return false;
+}
+
+static inline void simd_get(simd_context_t *ctx)
+{
+	*ctx = HAVE_NO_SIMD;
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
+	return false;
+}
+#endif
+
+#endif /* _ASM_SIMD_H */
diff --git a/arch/arm64/include/asm/simd.h b/arch/arm64/include/asm/simd.h
index 6495cc51246f..a45ff1600040 100644
--- a/arch/arm64/include/asm/simd.h
+++ b/arch/arm64/include/asm/simd.h
@@ -1,11 +1,10 @@
-/*
- * Copyright (C) 2017 Linaro Ltd. <ard.biesheuvel@linaro.org>
+/* SPDX-License-Identifier: GPL-2.0
  *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation.
+ * Copyright (C) 2017 Linaro Ltd. <ard.biesheuvel@linaro.org>
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
  */
 
+#include <linux/simd.h>
 #ifndef __ASM_SIMD_H
 #define __ASM_SIMD_H
 
@@ -16,6 +15,8 @@
 #include <linux/types.h>
 
 #ifdef CONFIG_KERNEL_MODE_NEON
+#include <asm/neon.h>
+#include <asm/simd.h>
 
 DECLARE_PER_CPU(bool, kernel_neon_busy);
 
@@ -40,9 +41,47 @@ static __must_check inline bool may_use_simd(void)
 		!this_cpu_read(kernel_neon_busy);
 }
 
+static inline void simd_get(simd_context_t *ctx)
+{
+	*ctx = may_use_simd() ? HAVE_FULL_SIMD : HAVE_NO_SIMD;
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+	if (*ctx & HAVE_SIMD_IN_USE)
+		kernel_neon_end();
+	*ctx = HAVE_NO_SIMD;
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
+	if (!(*ctx & HAVE_FULL_SIMD))
+		return false;
+	if (*ctx & HAVE_SIMD_IN_USE)
+		return true;
+	kernel_neon_begin();
+	*ctx |= HAVE_SIMD_IN_USE;
+	return true;
+}
+
 #else /* ! CONFIG_KERNEL_MODE_NEON */
 
-static __must_check inline bool may_use_simd(void) {
+static __must_check inline bool may_use_simd(void)
+{
+	return false;
+}
+
+static inline void simd_get(simd_context_t *ctx)
+{
+	*ctx = HAVE_NO_SIMD;
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
 	return false;
 }
 
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index 63b4a1705182..b0aa9d783d2b 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -31,6 +31,7 @@ generic-y += preempt.h
 generic-y += segment.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += tlbflush.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/h8300/include/asm/Kbuild b/arch/h8300/include/asm/Kbuild
index 3e7c8ecf151e..a10bbf3c67e9 100644
--- a/arch/h8300/include/asm/Kbuild
+++ b/arch/h8300/include/asm/Kbuild
@@ -40,6 +40,7 @@ generic-y += scatterlist.h
 generic-y += sections.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += sizes.h
 generic-y += spinlock.h
 generic-y += timex.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index b25fd42aa0f4..843ae8d5c4d9 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -31,6 +31,7 @@ generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += sizes.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 43e21fe3499c..4f4a969c4611 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -5,6 +5,7 @@ generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += preempt.h
+generic-y += simd.h
 generic-y += trace_clock.h
 generic-y += vtime.h
 generic-y += word-at-a-time.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index 95f8f631c4df..d60a481e6f73 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += percpu.h
 generic-y += preempt.h
 generic-y += sections.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += spinlock.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 791cc8d54d0a..103ed3592214 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -27,6 +27,7 @@ generic-y += percpu.h
 generic-y += preempt.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += syscalls.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 87b86cdf126a..fb3345c870c6 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -20,6 +20,7 @@ generic-y += qrwlock.h
 generic-y += qspinlock.h
 generic-y += sections.h
 generic-y += segment.h
+generic-y += simd.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += user.h
diff --git a/arch/nds32/include/asm/Kbuild b/arch/nds32/include/asm/Kbuild
index 64ceff7ab99b..887923fdbb65 100644
--- a/arch/nds32/include/asm/Kbuild
+++ b/arch/nds32/include/asm/Kbuild
@@ -38,6 +38,7 @@ generic-y += preempt.h
 generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
+generic-y += simd.h
 generic-y += sizes.h
 generic-y += switch_to.h
 generic-y += timex.h
diff --git a/arch/nios2/include/asm/Kbuild b/arch/nios2/include/asm/Kbuild
index 8fde4fa2c34f..571a9d9ad107 100644
--- a/arch/nios2/include/asm/Kbuild
+++ b/arch/nios2/include/asm/Kbuild
@@ -33,6 +33,7 @@ generic-y += preempt.h
 generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
+generic-y += simd.h
 generic-y += spinlock.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 5a73e2956ac4..f0abc1c93be0 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -34,6 +34,7 @@ generic-y += qrwlock.h
 generic-y += sections.h
 generic-y += segment.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += switch_to.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 6f49e77d82a2..8aec86fd5393 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -19,6 +19,7 @@ generic-y += percpu.h
 generic-y += preempt.h
 generic-y += seccomp.h
 generic-y += segment.h
+generic-y += simd.h
 generic-y += trace_clock.h
 generic-y += user.h
 generic-y += vga.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index a0c132bedfae..5ac3dead6952 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -11,3 +11,4 @@ generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += vtime.h
 generic-y += msi.h
+generic-y += simd.h
diff --git a/arch/riscv/include/asm/Kbuild b/arch/riscv/include/asm/Kbuild
index cccd12cf27d4..525bd8707c7d 100644
--- a/arch/riscv/include/asm/Kbuild
+++ b/arch/riscv/include/asm/Kbuild
@@ -28,6 +28,7 @@ generic-y += scatterlist.h
 generic-y += sections.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 12d77cb11fe5..6bc0fdc57783 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -21,6 +21,7 @@ generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += rwsem.h
+generic-y += simd.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += word-at-a-time.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index a6ef3fee5f85..74b7bb3ba96a 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -18,6 +18,7 @@ generic-y += percpu.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += serial.h
+generic-y += simd.h
 generic-y += sizes.h
 generic-y += trace_clock.h
 generic-y += xor.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index b82f64e28f55..d053d5bad630 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -19,5 +19,6 @@ generic-y += msi.h
 generic-y += preempt.h
 generic-y += rwsem.h
 generic-y += serial.h
+generic-y += simd.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 00bcbe2326d9..a4dfffb2c22b 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -20,6 +20,7 @@ generic-y += param.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
+generic-y += simd.h
 generic-y += switch_to.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 1d1544b6ca74..c428158a3a19 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -29,6 +29,7 @@ generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
 generic-y += shmparam.h
+generic-y += simd.h
 generic-y += sizes.h
 generic-y += syscalls.h
 generic-y += topology.h
diff --git a/arch/x86/include/asm/simd.h b/arch/x86/include/asm/simd.h
index a341c878e977..4aad7f158dcb 100644
--- a/arch/x86/include/asm/simd.h
+++ b/arch/x86/include/asm/simd.h
@@ -1,4 +1,11 @@
-/* SPDX-License-Identifier: GPL-2.0 */
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#include <linux/simd.h>
+#ifndef _ASM_SIMD_H
+#define _ASM_SIMD_H
 
 #include <asm/fpu/api.h>
 
@@ -10,3 +17,38 @@ static __must_check inline bool may_use_simd(void)
 {
 	return irq_fpu_usable();
 }
+
+static inline void simd_get(simd_context_t *ctx)
+{
+#if !defined(CONFIG_UML)
+	*ctx = may_use_simd() ? HAVE_FULL_SIMD : HAVE_NO_SIMD;
+#else
+	*ctx = HAVE_NO_SIMD;
+#endif
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+#if !defined(CONFIG_UML)
+	if (*ctx & HAVE_SIMD_IN_USE)
+		kernel_fpu_end();
+#endif
+	*ctx = HAVE_NO_SIMD;
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
+#if !defined(CONFIG_UML)
+	if (!(*ctx & HAVE_FULL_SIMD))
+		return false;
+	if (*ctx & HAVE_SIMD_IN_USE)
+		return true;
+	kernel_fpu_begin();
+	*ctx |= HAVE_SIMD_IN_USE;
+	return true;
+#else
+	return false;
+#endif
+}
+
+#endif /* _ASM_SIMD_H */
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 42b6cb3d16f7..318cad148bea 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -26,6 +26,7 @@ generic-y += qrwlock.h
 generic-y += qspinlock.h
 generic-y += rwsem.h
 generic-y += sections.h
+generic-y += simd.h
 generic-y += socket.h
 generic-y += topology.h
 generic-y += trace_clock.h
diff --git a/include/asm-generic/simd.h b/include/asm-generic/simd.h
index d0343d58a74a..b3dd61ac010e 100644
--- a/include/asm-generic/simd.h
+++ b/include/asm-generic/simd.h
@@ -1,5 +1,9 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 
+#include <linux/simd.h>
+#ifndef _ASM_SIMD_H
+#define _ASM_SIMD_H
+
 #include <linux/hardirq.h>
 
 /*
@@ -13,3 +17,19 @@ static __must_check inline bool may_use_simd(void)
 {
 	return !in_interrupt();
 }
+
+static inline void simd_get(simd_context_t *ctx)
+{
+	*ctx = HAVE_NO_SIMD;
+}
+
+static inline void simd_put(simd_context_t *ctx)
+{
+}
+
+static __must_check inline bool simd_use(simd_context_t *ctx)
+{
+	return false;
+}
+
+#endif /* _ASM_SIMD_H */
diff --git a/include/linux/simd.h b/include/linux/simd.h
new file mode 100644
index 000000000000..4e0b8a9bdc14
--- /dev/null
+++ b/include/linux/simd.h
@@ -0,0 +1,32 @@
+/* SPDX-License-Identifier: GPL-2.0
+ *
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ */
+
+#ifndef _SIMD_H
+#define _SIMD_H
+
+typedef enum {
+	HAVE_NO_SIMD = 1 << 0,
+	HAVE_FULL_SIMD = 1 << 1,
+	HAVE_SIMD_IN_USE = 1 << 31
+} simd_context_t;
+
+#define DONT_USE_SIMD ((simd_context_t []){ HAVE_NO_SIMD })
+
+#include <linux/sched.h>
+#include <asm/simd.h>
+
+static inline bool simd_relax(simd_context_t *ctx)
+{
+#ifdef CONFIG_PREEMPT
+	if ((*ctx & HAVE_SIMD_IN_USE) && need_resched()) {
+		simd_put(ctx);
+		simd_get(ctx);
+		return true;
+	}
+#endif
+	return false;
+}
+
+#endif /* _SIMD_H */
