Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Subject: [PATCH 3/17] zinc: introduce minimal cryptography library
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
Message-Id: <E1h7DgR-0001H9-UN@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Mar 2019 14:29:39 +0800
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Jason A. Donenfeld <Jason@zx2c4.com>

Zinc stands for "Zinc Is Neat Crypto" or "Zinc as IN Crypto". It's also
short, easy to type, and plays nicely with the recent trend of naming
crypto libraries after elements. The guiding principle is "don't overdo
it". It's less of a library and more of a directory tree for organizing
well-curated direct implementations of cryptography primitives.

Zinc is a new cryptography API that is much more minimal and lower-level
than the current one. It intends to complement it and provide a basis
upon which the current crypto API might build, as the provider of
software implementations of cryptographic primitives. It is motivated by
three primary observations in crypto API design:

  * Highly composable "cipher modes" and related abstractions from the
    90s did not turn out to be as terrific an idea as hoped, leading to
    a host of API misuse problems.

  * Most programmers are afraid of crypto code, and so prefer to
    integrate it into libraries in a highly abstracted manner, so as to
    shield themselves from implementation details. Cryptographers, on
    the other hand, prefer simple direct implementations, which they're
    able to verify for high assurance and optimize in accordance with
    their expertise.

  * Overly abstracted and flexible cryptography APIs lead to a host of
    dangerous problems and performance issues. The kernel is in the
    business usually not of coming up with new uses of crypto, but
    rather implementing various constructions, which means it essentially
    needs a library of primitives, not a highly abstracted enterprise-ready
    pluggable system, with a few particular exceptions.

This last observation has seen itself play out several times over and
over again within the kernel:

  * The perennial move of actual primitives away from crypto/ and into
    lib/, so that users can actually call these functions directly with
    no overhead and without lots of allocations, function pointers,
    string specifier parsing, and general clunkiness. For example:
    sha256, chacha20, siphash, sha1, and so forth live in lib/ rather
    than in crypto/. Zinc intends to stop the cluttering of lib/ and
    introduce these direct primitives into their proper place, lib/zinc/.

  * An abundance of misuse bugs with the present crypto API that have
    been very unpleasant to clean up.

  * A hesitance to even use cryptography, because of the overhead and
    headaches involved in accessing the routines.

Zinc goes in a rather different direction. Rather than providing a
thoroughly designed and abstracted API, Zinc gives you simple functions,
which implement some primitive, or some particular and specific
construction of primitives. It is not dynamic in the least, though one
could imagine implementing a complex dynamic dispatch mechanism (such as
the current crypto API) on top of these basic functions. After all,
dynamic dispatch is usually needed for applications with cipher agility,
such as IPsec, dm-crypt, AF_ALG, and so forth, and the existing crypto
API will continue to play that role. However, Zinc will provide a non-
haphazard way of directly utilizing crypto routines in applications
that do have neither the need nor desire for abstraction and dynamic
dispatch.

It also organizes the implementations in a simple, straight-forward,
and direct manner, making it enjoyable and intuitive to work on.
Rather than moving optimized assembly implementations into arch/, it
keeps them all together in lib/zinc/, making it simple and obvious to
compare and contrast what's happening. This is, notably, exactly what
the lib/raid6/ tree does, and that seems to work out rather well. It's
also the pattern of most successful crypto libraries. The architecture-
specific glue-code is made a part of each translation unit, rather than
being in a separate one, so that generic and architecture-optimized code
are combined at compile-time, and incompatibility branches compiled out by
the optimizer.

All implementations have been extensively tested and fuzzed, and are
selected for their quality, trustworthiness, and performance. Wherever
possible and performant, formally verified implementations are used,
such as those from HACL* [1] and Fiat-Crypto [2]. The routines also take
special care to zero out secrets using memzero_explicit (and future work
is planned to have gcc do this more reliably and performantly with
compiler plugins). The performance of the selected implementations is
state-of-the-art and unrivaled on a broad array of hardware, though of
course we will continue to fine tune these to the hardware demands
needed by kernel contributors. Each implementation also comes with
extensive self-tests and crafted test vectors, pulled from various
places such as Wycheproof [9].

Regularity of function signatures is important, so that users can easily
"guess" the name of the function they want. Though, individual
primitives are oftentimes not trivially interchangeable, having been
designed for different things and requiring different parameters and
semantics, and so the function signatures they provide will directly
reflect the realities of the primitives' usages, rather than hiding it
behind (inevitably leaky) abstractions. Also, in contrast to the current
crypto API, Zinc functions can work on stack buffers, and can be called
with different keys, without requiring allocations or locking.

SIMD is used automatically when available, though some routines may
benefit from either having their SIMD disabled for particular
invocations, or to have the SIMD initialization calls amortized over
several invocations of the function, and so Zinc utilizes function
signatures enabling that in conjunction with the recently introduced
simd_context_t.

More generally, Zinc provides function signatures that allow just what
is required by the various callers. This isn't to say that users of the
functions will be permitted to pollute the function semantics with weird
particular needs, but we are trying very hard not to overdo it, and that
means looking carefully at what's actually necessary, and doing just that,
and not much more than that. Remember: practicality and cleanliness rather
than over-zealous infrastructure.

Zinc provides also an opening for the best implementers in academia to
contribute their time and effort to the kernel, by being sufficiently
simple and inviting. In discussing this commit with some of the best and
brightest over the last few years, there are many who are eager to
devote rare talent and energy to this effort.

Following the merging of this, I expect for the primitives that
currently exist in lib/ to work their way into lib/zinc/, after intense
scrutiny of each implementation, potentially replacing them with either
formally-verified implementations, or better studied and faster
state-of-the-art implementations.

Also following the merging of this, I expect for the old crypto API
implementations to be ported over to use Zinc for their software-based
implementations.

As Zinc is simply library code, its config options are un-menued, with
the exception of CONFIG_ZINC_SELFTEST and CONFIG_ZINC_DEBUG, which enables
various selftests and debugging conditions.

[1] https://github.com/project-everest/hacl-star
[2] https://github.com/mit-plv/fiat-crypto
[3] https://cr.yp.to/ecdh.html
[4] https://cr.yp.to/chacha.html
[5] https://cr.yp.to/snuffle/xsalsa-20081128.pdf
[6] https://cr.yp.to/mac.html
[7] https://blake2.net/
[8] https://tools.ietf.org/html/rfc8439
[9] https://github.com/google/wycheproof

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Samuel Neves <sneves@dei.uc.pt>
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kernel-hardening@lists.openwall.com
Cc: linux-crypto@vger.kernel.org
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 MAINTAINERS       |    8 ++++++++
 lib/Kconfig       |    2 ++
 lib/Makefile      |    2 ++
 lib/zinc/Kconfig  |   41 +++++++++++++++++++++++++++++++++++++++++
 lib/zinc/Makefile |    3 +++
 5 files changed, 56 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index e17ebf70b548..0cd22cc5b0e5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -17210,6 +17210,14 @@ Q:	https://patchwork.linuxtv.org/project/linux-media/list/
 S:	Maintained
 F:	drivers/media/dvb-frontends/zd1301_demod*
 
+ZINC CRYPTOGRAPHY LIBRARY
+M:	Jason A. Donenfeld <Jason@zx2c4.com>
+M:	Samuel Neves <sneves@dei.uc.pt>
+S:	Maintained
+F:	lib/zinc/
+F:	include/zinc/
+L:	linux-crypto@vger.kernel.org
+
 ZPOOL COMPRESSED PAGE STORAGE API
 M:	Dan Streetman <ddstreet@ieee.org>
 L:	linux-mm@kvack.org
diff --git a/lib/Kconfig b/lib/Kconfig
index a9e56539bd11..00670e26435a 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -496,6 +496,8 @@ config GLOB_SELFTEST
 	  module load) by a small amount, so you're welcome to play with
 	  it, but you probably don't need it.
 
+source "lib/zinc/Kconfig"
+
 #
 # Netlink attribute parsing support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index 3b08673e8881..a2b86844b1e0 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -223,6 +223,8 @@ obj-$(CONFIG_PERCPU_TEST) += percpu_test.o
 
 obj-$(CONFIG_ASN1) += asn1_decoder.o
 
+obj-y += zinc/
+
 obj-$(CONFIG_FONT_SUPPORT) += fonts/
 
 obj-$(CONFIG_PRIME_NUMBERS) += prime_numbers.o
diff --git a/lib/zinc/Kconfig b/lib/zinc/Kconfig
new file mode 100644
index 000000000000..90e066ea93a0
--- /dev/null
+++ b/lib/zinc/Kconfig
@@ -0,0 +1,41 @@
+config ZINC_SELFTEST
+	bool "Zinc cryptography library self-tests"
+	help
+	  This builds a series of self-tests for the Zinc crypto library, which
+	  help diagnose any cryptographic algorithm implementation issues that
+	  might be at the root cause of potential bugs. It also adds various
+	  traps for incorrect usage.
+
+	  Unless you are optimizing for machines without much disk space or for
+	  very slow machines, it is probably a good idea to say Y here, so that
+	  any potential cryptographic bugs translate into easy bug reports
+	  rather than long-lasting security issues.
+
+config ZINC_DEBUG
+	bool "Zinc cryptography library debugging"
+	help
+	  This turns on a series of additional checks and debugging options
+	  that are useful for developers but probably will not provide much
+	  benefit to end users.
+
+	  Most people should say N here.
+
+config ZINC_ARCH_ARM
+	def_bool y
+	depends on ARM
+
+config ZINC_ARCH_ARM64
+	def_bool y
+	depends on ARM64
+
+config ZINC_ARCH_X86_64
+	def_bool y
+	depends on X86_64 && !UML
+
+config ZINC_ARCH_MIPS
+	def_bool y
+	depends on MIPS && CPU_MIPS32_R2 && !64BIT
+
+config ZINC_ARCH_MIPS64
+	def_bool y
+	depends on MIPS && 64BIT
diff --git a/lib/zinc/Makefile b/lib/zinc/Makefile
new file mode 100644
index 000000000000..a61c80d676cb
--- /dev/null
+++ b/lib/zinc/Makefile
@@ -0,0 +1,3 @@
+ccflags-y := -O2
+ccflags-y += -D'pr_fmt(fmt)="zinc: " fmt'
+ccflags-$(CONFIG_ZINC_DEBUG) += -DDEBUG
