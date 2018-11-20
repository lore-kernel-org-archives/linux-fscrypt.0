Return-Path: <SRS0=+oNo=N7=gondor.apana.org.au=herbert@kernel.org>
Subject: [v2 PATCH 4/4] zinc: ChaCha20 x86_64 implementation
References: <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
Message-Id: <E1gOz9U-000678-EL@gondobar>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Nov 2018 14:04:48 +0800
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Jason A. Donenfeld <Jason@zx2c4.com>

This ports SSSE3, AVX-2, AVX-512F, and AVX-512VL implementations for
ChaCha20. The AVX-512F implementation is disabled on Skylake, due to
throttling, and the VL ymm implementation is used instead. These come
from Andy Polyakov's implementation, with the following modifications
from Samuel Neves:

  - Some cosmetic changes, like renaming labels to .Lname, constants,
    and other Linux conventions.

  - CPU feature checking is done in C by the glue code, so that has been
    removed from the assembly.

  - Eliminate translating certain instructions, such as pshufb, palignr,
    vprotd, etc, to .byte directives. This is meant for compatibility
    with ancient toolchains, but presumably it is unnecessary here,
    since the build system already does checks on what GNU as can
    assemble.

  - When aligning the stack, the original code was saving %rsp to %r9.
    To keep objtool happy, we use instead the DRAP idiom to save %rsp
    to %r10:

      leaq    8(%rsp),%r10
      ... code here ...
      leaq    -8(%r10),%rsp

  - The original code assumes the stack comes aligned to 16 bytes. This
    is not necessarily the case, and to avoid crashes,
    `andq $-alignment, %rsp` was added in the prolog of a few functions.

  - The original hardcodes returns as .byte 0xf3,0xc3, aka "rep ret".
    We replace this by "ret". "rep ret" was meant to help with AMD K8
    chips, cf. http://repzret.org/p/repzret. It makes no sense to
    continue to use this kludge for code that won't even run on ancient
    AMD chips.

Cycle counts on a Core i7 6700HQ using the AVX-2 codepath, comparing
this implementation ("new") to the implementation in the current crypto
api ("old"):

size	old	new
----	----	----
0	62	52
16	414	376
32	410	400
48	414	422
64	362	356
80	714	666
96	714	700
112	712	718
128	692	646
144	1042	674
160	1042	694
176	1042	726
192	1018	650
208	1366	686
224	1366	696
240	1366	722
256	640	656
272	988	1246
288	988	1276
304	992	1296
320	972	1222
336	1318	1256
352	1318	1276
368	1316	1294
384	1294	1218
400	1642	1258
416	1642	1282
432	1642	1302
448	1628	1224
464	1970	1258
480	1970	1280
496	1970	1300
512	656	676
528	1010	1290
544	1010	1306
560	1010	1332
576	986	1254
592	1340	1284
608	1334	1310
624	1340	1334
640	1314	1254
656	1664	1282
672	1674	1306
688	1662	1336
704	1638	1250
720	1992	1292
736	1994	1308
752	1988	1334
768	1252	1254
784	1596	1290
800	1596	1314
816	1596	1330
832	1576	1256
848	1922	1286
864	1922	1314
880	1926	1338
896	1898	1258
912	2248	1288
928	2248	1320
944	2248	1338
960	2226	1268
976	2574	1288
992	2576	1312
1008	2574	1340

Cycle counts on a Xeon Gold 5120 using the AVX-512 codepath:

size	old	new
----	----	----
0	64	54
16	386	372
32	388	396
48	388	420
64	366	350
80	708	666
96	708	692
112	706	736
128	692	648
144	1036	682
160	1036	708
176	1036	730
192	1016	658
208	1360	684
224	1362	708
240	1360	732
256	644	500
272	990	526
288	988	556
304	988	576
320	972	500
336	1314	532
352	1316	558
368	1318	578
384	1308	506
400	1644	532
416	1644	556
432	1644	594
448	1624	508
464	1970	534
480	1970	556
496	1968	582
512	660	624
528	1016	682
544	1016	702
560	1018	728
576	998	654
592	1344	680
608	1344	708
624	1344	730
640	1326	654
656	1670	686
672	1670	708
688	1670	732
704	1652	658
720	1998	682
736	1998	710
752	1996	734
768	1256	662
784	1606	688
800	1606	714
816	1606	736
832	1584	660
848	1948	688
864	1950	714
880	1948	736
896	1912	688
912	2258	718
928	2258	744
944	2256	768
960	2238	692
976	2584	718
992	2584	744
1008	2584	770

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Signed-off-by: Samuel Neves <sneves@dei.uc.pt>
Co-developed-by: Samuel Neves <sneves@dei.uc.pt>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: x86@kernel.org
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kernel-hardening@lists.openwall.com
Cc: linux-crypto@vger.kernel.org
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/x86/crypto/Makefile                 |    3 
 arch/x86/crypto/chacha20-avx2-x86_64.S   | 1026 ------------
 arch/x86/crypto/chacha20-ssse3-x86_64.S  |  761 --------
 arch/x86/crypto/chacha20-zinc-x86_64.S   | 2632 +++++++++++++++++++++++++++++++
 arch/x86/crypto/chacha20_glue.c          |  119 -
 include/crypto/chacha20.h                |    4 
 lib/zinc/chacha20/chacha20-x86_64-glue.c |    3 
 7 files changed, 2692 insertions(+), 1856 deletions(-)

diff --git a/arch/x86/crypto/Makefile b/arch/x86/crypto/Makefile
index a4b0007a54e1..e054aff91005 100644
--- a/arch/x86/crypto/Makefile
+++ b/arch/x86/crypto/Makefile
@@ -74,7 +74,7 @@ camellia-x86_64-y := camellia-x86_64-asm_64.o camellia_glue.o
 blowfish-x86_64-y := blowfish-x86_64-asm_64.o blowfish_glue.o
 twofish-x86_64-y := twofish-x86_64-asm_64.o twofish_glue.o
 twofish-x86_64-3way-y := twofish-x86_64-asm_64-3way.o twofish_glue_3way.o
-chacha20-x86_64-y := chacha20-ssse3-x86_64.o chacha20_glue.o
+chacha20-x86_64-y := chacha20-zinc-x86_64.o chacha20_glue.o
 serpent-sse2-x86_64-y := serpent-sse2-x86_64-asm_64.o serpent_sse2_glue.o
 
 aegis128-aesni-y := aegis128-aesni-asm.o aegis128-aesni-glue.o
@@ -97,7 +97,6 @@ endif
 
 ifeq ($(avx2_supported),yes)
 	camellia-aesni-avx2-y := camellia-aesni-avx2-asm_64.o camellia_aesni_avx2_glue.o
-	chacha20-x86_64-y += chacha20-avx2-x86_64.o
 	serpent-avx2-y := serpent-avx2-asm_64.o serpent_avx2_glue.o
 
 	morus1280-avx2-y := morus1280-avx2-asm.o morus1280-avx2-glue.o
diff --git a/arch/x86/crypto/chacha20-avx2-x86_64.S b/arch/x86/crypto/chacha20-avx2-x86_64.S
deleted file mode 100644
index b6ab082be657..000000000000
--- a/arch/x86/crypto/chacha20-avx2-x86_64.S
+++ /dev/null
@@ -1,1026 +0,0 @@
-/*
- * ChaCha20 256-bit cipher algorithm, RFC7539, x64 AVX2 functions
- *
- * Copyright (C) 2015 Martin Willi
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/linkage.h>
-
-.section	.rodata.cst32.ROT8, "aM", @progbits, 32
-.align 32
-ROT8:	.octa 0x0e0d0c0f0a09080b0605040702010003
-	.octa 0x0e0d0c0f0a09080b0605040702010003
-
-.section	.rodata.cst32.ROT16, "aM", @progbits, 32
-.align 32
-ROT16:	.octa 0x0d0c0f0e09080b0a0504070601000302
-	.octa 0x0d0c0f0e09080b0a0504070601000302
-
-.section	.rodata.cst32.CTRINC, "aM", @progbits, 32
-.align 32
-CTRINC:	.octa 0x00000003000000020000000100000000
-	.octa 0x00000007000000060000000500000004
-
-.section	.rodata.cst32.CTR2BL, "aM", @progbits, 32
-.align 32
-CTR2BL:	.octa 0x00000000000000000000000000000000
-	.octa 0x00000000000000000000000000000001
-
-.section	.rodata.cst32.CTR4BL, "aM", @progbits, 32
-.align 32
-CTR4BL:	.octa 0x00000000000000000000000000000002
-	.octa 0x00000000000000000000000000000003
-
-.text
-
-ENTRY(chacha20_2block_xor_avx2)
-	# %rdi: Input state matrix, s
-	# %rsi: up to 2 data blocks output, o
-	# %rdx: up to 2 data blocks input, i
-	# %rcx: input/output length in bytes
-
-	# This function encrypts two ChaCha20 blocks by loading the state
-	# matrix twice across four AVX registers. It performs matrix operations
-	# on four words in each matrix in parallel, but requires shuffling to
-	# rearrange the words after each round.
-
-	vzeroupper
-
-	# x0..3[0-2] = s0..3
-	vbroadcasti128	0x00(%rdi),%ymm0
-	vbroadcasti128	0x10(%rdi),%ymm1
-	vbroadcasti128	0x20(%rdi),%ymm2
-	vbroadcasti128	0x30(%rdi),%ymm3
-
-	vpaddd		CTR2BL(%rip),%ymm3,%ymm3
-
-	vmovdqa		%ymm0,%ymm8
-	vmovdqa		%ymm1,%ymm9
-	vmovdqa		%ymm2,%ymm10
-	vmovdqa		%ymm3,%ymm11
-
-	vmovdqa		ROT8(%rip),%ymm4
-	vmovdqa		ROT16(%rip),%ymm5
-
-	mov		%rcx,%rax
-	mov		$10,%ecx
-
-.Ldoubleround:
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm5,%ymm3,%ymm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm6
-	vpslld		$12,%ymm6,%ymm6
-	vpsrld		$20,%ymm1,%ymm1
-	vpor		%ymm6,%ymm1,%ymm1
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm4,%ymm3,%ymm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm7
-	vpslld		$7,%ymm7,%ymm7
-	vpsrld		$25,%ymm1,%ymm1
-	vpor		%ymm7,%ymm1,%ymm1
-
-	# x1 = shuffle32(x1, MASK(0, 3, 2, 1))
-	vpshufd		$0x39,%ymm1,%ymm1
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	vpshufd		$0x4e,%ymm2,%ymm2
-	# x3 = shuffle32(x3, MASK(2, 1, 0, 3))
-	vpshufd		$0x93,%ymm3,%ymm3
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm5,%ymm3,%ymm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm6
-	vpslld		$12,%ymm6,%ymm6
-	vpsrld		$20,%ymm1,%ymm1
-	vpor		%ymm6,%ymm1,%ymm1
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm4,%ymm3,%ymm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm7
-	vpslld		$7,%ymm7,%ymm7
-	vpsrld		$25,%ymm1,%ymm1
-	vpor		%ymm7,%ymm1,%ymm1
-
-	# x1 = shuffle32(x1, MASK(2, 1, 0, 3))
-	vpshufd		$0x93,%ymm1,%ymm1
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	vpshufd		$0x4e,%ymm2,%ymm2
-	# x3 = shuffle32(x3, MASK(0, 3, 2, 1))
-	vpshufd		$0x39,%ymm3,%ymm3
-
-	dec		%ecx
-	jnz		.Ldoubleround
-
-	# o0 = i0 ^ (x0 + s0)
-	vpaddd		%ymm8,%ymm0,%ymm7
-	cmp		$0x10,%rax
-	jl		.Lxorpart2
-	vpxor		0x00(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x00(%rsi)
-	vextracti128	$1,%ymm7,%xmm0
-	# o1 = i1 ^ (x1 + s1)
-	vpaddd		%ymm9,%ymm1,%ymm7
-	cmp		$0x20,%rax
-	jl		.Lxorpart2
-	vpxor		0x10(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x10(%rsi)
-	vextracti128	$1,%ymm7,%xmm1
-	# o2 = i2 ^ (x2 + s2)
-	vpaddd		%ymm10,%ymm2,%ymm7
-	cmp		$0x30,%rax
-	jl		.Lxorpart2
-	vpxor		0x20(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x20(%rsi)
-	vextracti128	$1,%ymm7,%xmm2
-	# o3 = i3 ^ (x3 + s3)
-	vpaddd		%ymm11,%ymm3,%ymm7
-	cmp		$0x40,%rax
-	jl		.Lxorpart2
-	vpxor		0x30(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x30(%rsi)
-	vextracti128	$1,%ymm7,%xmm3
-
-	# xor and write second block
-	vmovdqa		%xmm0,%xmm7
-	cmp		$0x50,%rax
-	jl		.Lxorpart2
-	vpxor		0x40(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x40(%rsi)
-
-	vmovdqa		%xmm1,%xmm7
-	cmp		$0x60,%rax
-	jl		.Lxorpart2
-	vpxor		0x50(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x50(%rsi)
-
-	vmovdqa		%xmm2,%xmm7
-	cmp		$0x70,%rax
-	jl		.Lxorpart2
-	vpxor		0x60(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x60(%rsi)
-
-	vmovdqa		%xmm3,%xmm7
-	cmp		$0x80,%rax
-	jl		.Lxorpart2
-	vpxor		0x70(%rdx),%xmm7,%xmm6
-	vmovdqu		%xmm6,0x70(%rsi)
-
-.Ldone2:
-	vzeroupper
-	ret
-
-.Lxorpart2:
-	# xor remaining bytes from partial register into output
-	mov		%rax,%r9
-	and		$0x0f,%r9
-	jz		.Ldone2
-	and		$~0x0f,%rax
-
-	mov		%rsi,%r11
-
-	lea		8(%rsp),%r10
-	sub		$0x10,%rsp
-	and		$~31,%rsp
-
-	lea		(%rdx,%rax),%rsi
-	mov		%rsp,%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	vpxor		0x00(%rsp),%xmm7,%xmm7
-	vmovdqa		%xmm7,0x00(%rsp)
-
-	mov		%rsp,%rsi
-	lea		(%r11,%rax),%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	lea		-8(%r10),%rsp
-	jmp		.Ldone2
-
-ENDPROC(chacha20_2block_xor_avx2)
-
-ENTRY(chacha20_4block_xor_avx2)
-	# %rdi: Input state matrix, s
-	# %rsi: up to 4 data blocks output, o
-	# %rdx: up to 4 data blocks input, i
-	# %rcx: input/output length in bytes
-
-	# This function encrypts four ChaCha20 block by loading the state
-	# matrix four times across eight AVX registers. It performs matrix
-	# operations on four words in two matrices in parallel, sequentially
-	# to the operations on the four words of the other two matrices. The
-	# required word shuffling has a rather high latency, we can do the
-	# arithmetic on two matrix-pairs without much slowdown.
-
-	vzeroupper
-
-	# x0..3[0-4] = s0..3
-	vbroadcasti128	0x00(%rdi),%ymm0
-	vbroadcasti128	0x10(%rdi),%ymm1
-	vbroadcasti128	0x20(%rdi),%ymm2
-	vbroadcasti128	0x30(%rdi),%ymm3
-
-	vmovdqa		%ymm0,%ymm4
-	vmovdqa		%ymm1,%ymm5
-	vmovdqa		%ymm2,%ymm6
-	vmovdqa		%ymm3,%ymm7
-
-	vpaddd		CTR2BL(%rip),%ymm3,%ymm3
-	vpaddd		CTR4BL(%rip),%ymm7,%ymm7
-
-	vmovdqa		%ymm0,%ymm11
-	vmovdqa		%ymm1,%ymm12
-	vmovdqa		%ymm2,%ymm13
-	vmovdqa		%ymm3,%ymm14
-	vmovdqa		%ymm7,%ymm15
-
-	vmovdqa		ROT8(%rip),%ymm8
-	vmovdqa		ROT16(%rip),%ymm9
-
-	mov		%rcx,%rax
-	mov		$10,%ecx
-
-.Ldoubleround4:
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm9,%ymm3,%ymm3
-
-	vpaddd		%ymm5,%ymm4,%ymm4
-	vpxor		%ymm4,%ymm7,%ymm7
-	vpshufb		%ymm9,%ymm7,%ymm7
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm10
-	vpslld		$12,%ymm10,%ymm10
-	vpsrld		$20,%ymm1,%ymm1
-	vpor		%ymm10,%ymm1,%ymm1
-
-	vpaddd		%ymm7,%ymm6,%ymm6
-	vpxor		%ymm6,%ymm5,%ymm5
-	vmovdqa		%ymm5,%ymm10
-	vpslld		$12,%ymm10,%ymm10
-	vpsrld		$20,%ymm5,%ymm5
-	vpor		%ymm10,%ymm5,%ymm5
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm8,%ymm3,%ymm3
-
-	vpaddd		%ymm5,%ymm4,%ymm4
-	vpxor		%ymm4,%ymm7,%ymm7
-	vpshufb		%ymm8,%ymm7,%ymm7
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm10
-	vpslld		$7,%ymm10,%ymm10
-	vpsrld		$25,%ymm1,%ymm1
-	vpor		%ymm10,%ymm1,%ymm1
-
-	vpaddd		%ymm7,%ymm6,%ymm6
-	vpxor		%ymm6,%ymm5,%ymm5
-	vmovdqa		%ymm5,%ymm10
-	vpslld		$7,%ymm10,%ymm10
-	vpsrld		$25,%ymm5,%ymm5
-	vpor		%ymm10,%ymm5,%ymm5
-
-	# x1 = shuffle32(x1, MASK(0, 3, 2, 1))
-	vpshufd		$0x39,%ymm1,%ymm1
-	vpshufd		$0x39,%ymm5,%ymm5
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	vpshufd		$0x4e,%ymm2,%ymm2
-	vpshufd		$0x4e,%ymm6,%ymm6
-	# x3 = shuffle32(x3, MASK(2, 1, 0, 3))
-	vpshufd		$0x93,%ymm3,%ymm3
-	vpshufd		$0x93,%ymm7,%ymm7
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm9,%ymm3,%ymm3
-
-	vpaddd		%ymm5,%ymm4,%ymm4
-	vpxor		%ymm4,%ymm7,%ymm7
-	vpshufb		%ymm9,%ymm7,%ymm7
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm10
-	vpslld		$12,%ymm10,%ymm10
-	vpsrld		$20,%ymm1,%ymm1
-	vpor		%ymm10,%ymm1,%ymm1
-
-	vpaddd		%ymm7,%ymm6,%ymm6
-	vpxor		%ymm6,%ymm5,%ymm5
-	vmovdqa		%ymm5,%ymm10
-	vpslld		$12,%ymm10,%ymm10
-	vpsrld		$20,%ymm5,%ymm5
-	vpor		%ymm10,%ymm5,%ymm5
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	vpaddd		%ymm1,%ymm0,%ymm0
-	vpxor		%ymm0,%ymm3,%ymm3
-	vpshufb		%ymm8,%ymm3,%ymm3
-
-	vpaddd		%ymm5,%ymm4,%ymm4
-	vpxor		%ymm4,%ymm7,%ymm7
-	vpshufb		%ymm8,%ymm7,%ymm7
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	vpaddd		%ymm3,%ymm2,%ymm2
-	vpxor		%ymm2,%ymm1,%ymm1
-	vmovdqa		%ymm1,%ymm10
-	vpslld		$7,%ymm10,%ymm10
-	vpsrld		$25,%ymm1,%ymm1
-	vpor		%ymm10,%ymm1,%ymm1
-
-	vpaddd		%ymm7,%ymm6,%ymm6
-	vpxor		%ymm6,%ymm5,%ymm5
-	vmovdqa		%ymm5,%ymm10
-	vpslld		$7,%ymm10,%ymm10
-	vpsrld		$25,%ymm5,%ymm5
-	vpor		%ymm10,%ymm5,%ymm5
-
-	# x1 = shuffle32(x1, MASK(2, 1, 0, 3))
-	vpshufd		$0x93,%ymm1,%ymm1
-	vpshufd		$0x93,%ymm5,%ymm5
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	vpshufd		$0x4e,%ymm2,%ymm2
-	vpshufd		$0x4e,%ymm6,%ymm6
-	# x3 = shuffle32(x3, MASK(0, 3, 2, 1))
-	vpshufd		$0x39,%ymm3,%ymm3
-	vpshufd		$0x39,%ymm7,%ymm7
-
-	dec		%ecx
-	jnz		.Ldoubleround4
-
-	# o0 = i0 ^ (x0 + s0), first block
-	vpaddd		%ymm11,%ymm0,%ymm10
-	cmp		$0x10,%rax
-	jl		.Lxorpart4
-	vpxor		0x00(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x00(%rsi)
-	vextracti128	$1,%ymm10,%xmm0
-	# o1 = i1 ^ (x1 + s1), first block
-	vpaddd		%ymm12,%ymm1,%ymm10
-	cmp		$0x20,%rax
-	jl		.Lxorpart4
-	vpxor		0x10(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x10(%rsi)
-	vextracti128	$1,%ymm10,%xmm1
-	# o2 = i2 ^ (x2 + s2), first block
-	vpaddd		%ymm13,%ymm2,%ymm10
-	cmp		$0x30,%rax
-	jl		.Lxorpart4
-	vpxor		0x20(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x20(%rsi)
-	vextracti128	$1,%ymm10,%xmm2
-	# o3 = i3 ^ (x3 + s3), first block
-	vpaddd		%ymm14,%ymm3,%ymm10
-	cmp		$0x40,%rax
-	jl		.Lxorpart4
-	vpxor		0x30(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x30(%rsi)
-	vextracti128	$1,%ymm10,%xmm3
-
-	# xor and write second block
-	vmovdqa		%xmm0,%xmm10
-	cmp		$0x50,%rax
-	jl		.Lxorpart4
-	vpxor		0x40(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x40(%rsi)
-
-	vmovdqa		%xmm1,%xmm10
-	cmp		$0x60,%rax
-	jl		.Lxorpart4
-	vpxor		0x50(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x50(%rsi)
-
-	vmovdqa		%xmm2,%xmm10
-	cmp		$0x70,%rax
-	jl		.Lxorpart4
-	vpxor		0x60(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x60(%rsi)
-
-	vmovdqa		%xmm3,%xmm10
-	cmp		$0x80,%rax
-	jl		.Lxorpart4
-	vpxor		0x70(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x70(%rsi)
-
-	# o0 = i0 ^ (x0 + s0), third block
-	vpaddd		%ymm11,%ymm4,%ymm10
-	cmp		$0x90,%rax
-	jl		.Lxorpart4
-	vpxor		0x80(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x80(%rsi)
-	vextracti128	$1,%ymm10,%xmm4
-	# o1 = i1 ^ (x1 + s1), third block
-	vpaddd		%ymm12,%ymm5,%ymm10
-	cmp		$0xa0,%rax
-	jl		.Lxorpart4
-	vpxor		0x90(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0x90(%rsi)
-	vextracti128	$1,%ymm10,%xmm5
-	# o2 = i2 ^ (x2 + s2), third block
-	vpaddd		%ymm13,%ymm6,%ymm10
-	cmp		$0xb0,%rax
-	jl		.Lxorpart4
-	vpxor		0xa0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xa0(%rsi)
-	vextracti128	$1,%ymm10,%xmm6
-	# o3 = i3 ^ (x3 + s3), third block
-	vpaddd		%ymm15,%ymm7,%ymm10
-	cmp		$0xc0,%rax
-	jl		.Lxorpart4
-	vpxor		0xb0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xb0(%rsi)
-	vextracti128	$1,%ymm10,%xmm7
-
-	# xor and write fourth block
-	vmovdqa		%xmm4,%xmm10
-	cmp		$0xd0,%rax
-	jl		.Lxorpart4
-	vpxor		0xc0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xc0(%rsi)
-
-	vmovdqa		%xmm5,%xmm10
-	cmp		$0xe0,%rax
-	jl		.Lxorpart4
-	vpxor		0xd0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xd0(%rsi)
-
-	vmovdqa		%xmm6,%xmm10
-	cmp		$0xf0,%rax
-	jl		.Lxorpart4
-	vpxor		0xe0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xe0(%rsi)
-
-	vmovdqa		%xmm7,%xmm10
-	cmp		$0x100,%rax
-	jl		.Lxorpart4
-	vpxor		0xf0(%rdx),%xmm10,%xmm9
-	vmovdqu		%xmm9,0xf0(%rsi)
-
-.Ldone4:
-	vzeroupper
-	ret
-
-.Lxorpart4:
-	# xor remaining bytes from partial register into output
-	mov		%rax,%r9
-	and		$0x0f,%r9
-	jz		.Ldone4
-	and		$~0x0f,%rax
-
-	mov		%rsi,%r11
-
-	lea		8(%rsp),%r10
-	sub		$0x10,%rsp
-	and		$~31,%rsp
-
-	lea		(%rdx,%rax),%rsi
-	mov		%rsp,%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	vpxor		0x00(%rsp),%xmm10,%xmm10
-	vmovdqa		%xmm10,0x00(%rsp)
-
-	mov		%rsp,%rsi
-	lea		(%r11,%rax),%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	lea		-8(%r10),%rsp
-	jmp		.Ldone4
-
-ENDPROC(chacha20_4block_xor_avx2)
-
-ENTRY(chacha20_8block_xor_avx2)
-	# %rdi: Input state matrix, s
-	# %rsi: up to 8 data blocks output, o
-	# %rdx: up to 8 data blocks input, i
-	# %rcx: input/output length in bytes
-
-	# This function encrypts eight consecutive ChaCha20 blocks by loading
-	# the state matrix in AVX registers eight times. As we need some
-	# scratch registers, we save the first four registers on the stack. The
-	# algorithm performs each operation on the corresponding word of each
-	# state matrix, hence requires no word shuffling. For final XORing step
-	# we transpose the matrix by interleaving 32-, 64- and then 128-bit
-	# words, which allows us to do XOR in AVX registers. 8/16-bit word
-	# rotation is done with the slightly better performing byte shuffling,
-	# 7/12-bit word rotation uses traditional shift+OR.
-
-	vzeroupper
-	# 4 * 32 byte stack, 32-byte aligned
-	lea		8(%rsp),%r10
-	and		$~31, %rsp
-	sub		$0x80, %rsp
-	mov		%rcx,%rax
-
-	# x0..15[0-7] = s[0..15]
-	vpbroadcastd	0x00(%rdi),%ymm0
-	vpbroadcastd	0x04(%rdi),%ymm1
-	vpbroadcastd	0x08(%rdi),%ymm2
-	vpbroadcastd	0x0c(%rdi),%ymm3
-	vpbroadcastd	0x10(%rdi),%ymm4
-	vpbroadcastd	0x14(%rdi),%ymm5
-	vpbroadcastd	0x18(%rdi),%ymm6
-	vpbroadcastd	0x1c(%rdi),%ymm7
-	vpbroadcastd	0x20(%rdi),%ymm8
-	vpbroadcastd	0x24(%rdi),%ymm9
-	vpbroadcastd	0x28(%rdi),%ymm10
-	vpbroadcastd	0x2c(%rdi),%ymm11
-	vpbroadcastd	0x30(%rdi),%ymm12
-	vpbroadcastd	0x34(%rdi),%ymm13
-	vpbroadcastd	0x38(%rdi),%ymm14
-	vpbroadcastd	0x3c(%rdi),%ymm15
-	# x0..3 on stack
-	vmovdqa		%ymm0,0x00(%rsp)
-	vmovdqa		%ymm1,0x20(%rsp)
-	vmovdqa		%ymm2,0x40(%rsp)
-	vmovdqa		%ymm3,0x60(%rsp)
-
-	vmovdqa		CTRINC(%rip),%ymm1
-	vmovdqa		ROT8(%rip),%ymm2
-	vmovdqa		ROT16(%rip),%ymm3
-
-	# x12 += counter values 0-3
-	vpaddd		%ymm1,%ymm12,%ymm12
-
-	mov		$10,%ecx
-
-.Ldoubleround8:
-	# x0 += x4, x12 = rotl32(x12 ^ x0, 16)
-	vpaddd		0x00(%rsp),%ymm4,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-	vpxor		%ymm0,%ymm12,%ymm12
-	vpshufb		%ymm3,%ymm12,%ymm12
-	# x1 += x5, x13 = rotl32(x13 ^ x1, 16)
-	vpaddd		0x20(%rsp),%ymm5,%ymm0
-	vmovdqa		%ymm0,0x20(%rsp)
-	vpxor		%ymm0,%ymm13,%ymm13
-	vpshufb		%ymm3,%ymm13,%ymm13
-	# x2 += x6, x14 = rotl32(x14 ^ x2, 16)
-	vpaddd		0x40(%rsp),%ymm6,%ymm0
-	vmovdqa		%ymm0,0x40(%rsp)
-	vpxor		%ymm0,%ymm14,%ymm14
-	vpshufb		%ymm3,%ymm14,%ymm14
-	# x3 += x7, x15 = rotl32(x15 ^ x3, 16)
-	vpaddd		0x60(%rsp),%ymm7,%ymm0
-	vmovdqa		%ymm0,0x60(%rsp)
-	vpxor		%ymm0,%ymm15,%ymm15
-	vpshufb		%ymm3,%ymm15,%ymm15
-
-	# x8 += x12, x4 = rotl32(x4 ^ x8, 12)
-	vpaddd		%ymm12,%ymm8,%ymm8
-	vpxor		%ymm8,%ymm4,%ymm4
-	vpslld		$12,%ymm4,%ymm0
-	vpsrld		$20,%ymm4,%ymm4
-	vpor		%ymm0,%ymm4,%ymm4
-	# x9 += x13, x5 = rotl32(x5 ^ x9, 12)
-	vpaddd		%ymm13,%ymm9,%ymm9
-	vpxor		%ymm9,%ymm5,%ymm5
-	vpslld		$12,%ymm5,%ymm0
-	vpsrld		$20,%ymm5,%ymm5
-	vpor		%ymm0,%ymm5,%ymm5
-	# x10 += x14, x6 = rotl32(x6 ^ x10, 12)
-	vpaddd		%ymm14,%ymm10,%ymm10
-	vpxor		%ymm10,%ymm6,%ymm6
-	vpslld		$12,%ymm6,%ymm0
-	vpsrld		$20,%ymm6,%ymm6
-	vpor		%ymm0,%ymm6,%ymm6
-	# x11 += x15, x7 = rotl32(x7 ^ x11, 12)
-	vpaddd		%ymm15,%ymm11,%ymm11
-	vpxor		%ymm11,%ymm7,%ymm7
-	vpslld		$12,%ymm7,%ymm0
-	vpsrld		$20,%ymm7,%ymm7
-	vpor		%ymm0,%ymm7,%ymm7
-
-	# x0 += x4, x12 = rotl32(x12 ^ x0, 8)
-	vpaddd		0x00(%rsp),%ymm4,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-	vpxor		%ymm0,%ymm12,%ymm12
-	vpshufb		%ymm2,%ymm12,%ymm12
-	# x1 += x5, x13 = rotl32(x13 ^ x1, 8)
-	vpaddd		0x20(%rsp),%ymm5,%ymm0
-	vmovdqa		%ymm0,0x20(%rsp)
-	vpxor		%ymm0,%ymm13,%ymm13
-	vpshufb		%ymm2,%ymm13,%ymm13
-	# x2 += x6, x14 = rotl32(x14 ^ x2, 8)
-	vpaddd		0x40(%rsp),%ymm6,%ymm0
-	vmovdqa		%ymm0,0x40(%rsp)
-	vpxor		%ymm0,%ymm14,%ymm14
-	vpshufb		%ymm2,%ymm14,%ymm14
-	# x3 += x7, x15 = rotl32(x15 ^ x3, 8)
-	vpaddd		0x60(%rsp),%ymm7,%ymm0
-	vmovdqa		%ymm0,0x60(%rsp)
-	vpxor		%ymm0,%ymm15,%ymm15
-	vpshufb		%ymm2,%ymm15,%ymm15
-
-	# x8 += x12, x4 = rotl32(x4 ^ x8, 7)
-	vpaddd		%ymm12,%ymm8,%ymm8
-	vpxor		%ymm8,%ymm4,%ymm4
-	vpslld		$7,%ymm4,%ymm0
-	vpsrld		$25,%ymm4,%ymm4
-	vpor		%ymm0,%ymm4,%ymm4
-	# x9 += x13, x5 = rotl32(x5 ^ x9, 7)
-	vpaddd		%ymm13,%ymm9,%ymm9
-	vpxor		%ymm9,%ymm5,%ymm5
-	vpslld		$7,%ymm5,%ymm0
-	vpsrld		$25,%ymm5,%ymm5
-	vpor		%ymm0,%ymm5,%ymm5
-	# x10 += x14, x6 = rotl32(x6 ^ x10, 7)
-	vpaddd		%ymm14,%ymm10,%ymm10
-	vpxor		%ymm10,%ymm6,%ymm6
-	vpslld		$7,%ymm6,%ymm0
-	vpsrld		$25,%ymm6,%ymm6
-	vpor		%ymm0,%ymm6,%ymm6
-	# x11 += x15, x7 = rotl32(x7 ^ x11, 7)
-	vpaddd		%ymm15,%ymm11,%ymm11
-	vpxor		%ymm11,%ymm7,%ymm7
-	vpslld		$7,%ymm7,%ymm0
-	vpsrld		$25,%ymm7,%ymm7
-	vpor		%ymm0,%ymm7,%ymm7
-
-	# x0 += x5, x15 = rotl32(x15 ^ x0, 16)
-	vpaddd		0x00(%rsp),%ymm5,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-	vpxor		%ymm0,%ymm15,%ymm15
-	vpshufb		%ymm3,%ymm15,%ymm15
-	# x1 += x6, x12 = rotl32(x12 ^ x1, 16)%ymm0
-	vpaddd		0x20(%rsp),%ymm6,%ymm0
-	vmovdqa		%ymm0,0x20(%rsp)
-	vpxor		%ymm0,%ymm12,%ymm12
-	vpshufb		%ymm3,%ymm12,%ymm12
-	# x2 += x7, x13 = rotl32(x13 ^ x2, 16)
-	vpaddd		0x40(%rsp),%ymm7,%ymm0
-	vmovdqa		%ymm0,0x40(%rsp)
-	vpxor		%ymm0,%ymm13,%ymm13
-	vpshufb		%ymm3,%ymm13,%ymm13
-	# x3 += x4, x14 = rotl32(x14 ^ x3, 16)
-	vpaddd		0x60(%rsp),%ymm4,%ymm0
-	vmovdqa		%ymm0,0x60(%rsp)
-	vpxor		%ymm0,%ymm14,%ymm14
-	vpshufb		%ymm3,%ymm14,%ymm14
-
-	# x10 += x15, x5 = rotl32(x5 ^ x10, 12)
-	vpaddd		%ymm15,%ymm10,%ymm10
-	vpxor		%ymm10,%ymm5,%ymm5
-	vpslld		$12,%ymm5,%ymm0
-	vpsrld		$20,%ymm5,%ymm5
-	vpor		%ymm0,%ymm5,%ymm5
-	# x11 += x12, x6 = rotl32(x6 ^ x11, 12)
-	vpaddd		%ymm12,%ymm11,%ymm11
-	vpxor		%ymm11,%ymm6,%ymm6
-	vpslld		$12,%ymm6,%ymm0
-	vpsrld		$20,%ymm6,%ymm6
-	vpor		%ymm0,%ymm6,%ymm6
-	# x8 += x13, x7 = rotl32(x7 ^ x8, 12)
-	vpaddd		%ymm13,%ymm8,%ymm8
-	vpxor		%ymm8,%ymm7,%ymm7
-	vpslld		$12,%ymm7,%ymm0
-	vpsrld		$20,%ymm7,%ymm7
-	vpor		%ymm0,%ymm7,%ymm7
-	# x9 += x14, x4 = rotl32(x4 ^ x9, 12)
-	vpaddd		%ymm14,%ymm9,%ymm9
-	vpxor		%ymm9,%ymm4,%ymm4
-	vpslld		$12,%ymm4,%ymm0
-	vpsrld		$20,%ymm4,%ymm4
-	vpor		%ymm0,%ymm4,%ymm4
-
-	# x0 += x5, x15 = rotl32(x15 ^ x0, 8)
-	vpaddd		0x00(%rsp),%ymm5,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-	vpxor		%ymm0,%ymm15,%ymm15
-	vpshufb		%ymm2,%ymm15,%ymm15
-	# x1 += x6, x12 = rotl32(x12 ^ x1, 8)
-	vpaddd		0x20(%rsp),%ymm6,%ymm0
-	vmovdqa		%ymm0,0x20(%rsp)
-	vpxor		%ymm0,%ymm12,%ymm12
-	vpshufb		%ymm2,%ymm12,%ymm12
-	# x2 += x7, x13 = rotl32(x13 ^ x2, 8)
-	vpaddd		0x40(%rsp),%ymm7,%ymm0
-	vmovdqa		%ymm0,0x40(%rsp)
-	vpxor		%ymm0,%ymm13,%ymm13
-	vpshufb		%ymm2,%ymm13,%ymm13
-	# x3 += x4, x14 = rotl32(x14 ^ x3, 8)
-	vpaddd		0x60(%rsp),%ymm4,%ymm0
-	vmovdqa		%ymm0,0x60(%rsp)
-	vpxor		%ymm0,%ymm14,%ymm14
-	vpshufb		%ymm2,%ymm14,%ymm14
-
-	# x10 += x15, x5 = rotl32(x5 ^ x10, 7)
-	vpaddd		%ymm15,%ymm10,%ymm10
-	vpxor		%ymm10,%ymm5,%ymm5
-	vpslld		$7,%ymm5,%ymm0
-	vpsrld		$25,%ymm5,%ymm5
-	vpor		%ymm0,%ymm5,%ymm5
-	# x11 += x12, x6 = rotl32(x6 ^ x11, 7)
-	vpaddd		%ymm12,%ymm11,%ymm11
-	vpxor		%ymm11,%ymm6,%ymm6
-	vpslld		$7,%ymm6,%ymm0
-	vpsrld		$25,%ymm6,%ymm6
-	vpor		%ymm0,%ymm6,%ymm6
-	# x8 += x13, x7 = rotl32(x7 ^ x8, 7)
-	vpaddd		%ymm13,%ymm8,%ymm8
-	vpxor		%ymm8,%ymm7,%ymm7
-	vpslld		$7,%ymm7,%ymm0
-	vpsrld		$25,%ymm7,%ymm7
-	vpor		%ymm0,%ymm7,%ymm7
-	# x9 += x14, x4 = rotl32(x4 ^ x9, 7)
-	vpaddd		%ymm14,%ymm9,%ymm9
-	vpxor		%ymm9,%ymm4,%ymm4
-	vpslld		$7,%ymm4,%ymm0
-	vpsrld		$25,%ymm4,%ymm4
-	vpor		%ymm0,%ymm4,%ymm4
-
-	dec		%ecx
-	jnz		.Ldoubleround8
-
-	# x0..15[0-3] += s[0..15]
-	vpbroadcastd	0x00(%rdi),%ymm0
-	vpaddd		0x00(%rsp),%ymm0,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-	vpbroadcastd	0x04(%rdi),%ymm0
-	vpaddd		0x20(%rsp),%ymm0,%ymm0
-	vmovdqa		%ymm0,0x20(%rsp)
-	vpbroadcastd	0x08(%rdi),%ymm0
-	vpaddd		0x40(%rsp),%ymm0,%ymm0
-	vmovdqa		%ymm0,0x40(%rsp)
-	vpbroadcastd	0x0c(%rdi),%ymm0
-	vpaddd		0x60(%rsp),%ymm0,%ymm0
-	vmovdqa		%ymm0,0x60(%rsp)
-	vpbroadcastd	0x10(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm4,%ymm4
-	vpbroadcastd	0x14(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm5,%ymm5
-	vpbroadcastd	0x18(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm6,%ymm6
-	vpbroadcastd	0x1c(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm7,%ymm7
-	vpbroadcastd	0x20(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm8,%ymm8
-	vpbroadcastd	0x24(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm9,%ymm9
-	vpbroadcastd	0x28(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm10,%ymm10
-	vpbroadcastd	0x2c(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm11,%ymm11
-	vpbroadcastd	0x30(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm12,%ymm12
-	vpbroadcastd	0x34(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm13,%ymm13
-	vpbroadcastd	0x38(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm14,%ymm14
-	vpbroadcastd	0x3c(%rdi),%ymm0
-	vpaddd		%ymm0,%ymm15,%ymm15
-
-	# x12 += counter values 0-3
-	vpaddd		%ymm1,%ymm12,%ymm12
-
-	# interleave 32-bit words in state n, n+1
-	vmovdqa		0x00(%rsp),%ymm0
-	vmovdqa		0x20(%rsp),%ymm1
-	vpunpckldq	%ymm1,%ymm0,%ymm2
-	vpunpckhdq	%ymm1,%ymm0,%ymm1
-	vmovdqa		%ymm2,0x00(%rsp)
-	vmovdqa		%ymm1,0x20(%rsp)
-	vmovdqa		0x40(%rsp),%ymm0
-	vmovdqa		0x60(%rsp),%ymm1
-	vpunpckldq	%ymm1,%ymm0,%ymm2
-	vpunpckhdq	%ymm1,%ymm0,%ymm1
-	vmovdqa		%ymm2,0x40(%rsp)
-	vmovdqa		%ymm1,0x60(%rsp)
-	vmovdqa		%ymm4,%ymm0
-	vpunpckldq	%ymm5,%ymm0,%ymm4
-	vpunpckhdq	%ymm5,%ymm0,%ymm5
-	vmovdqa		%ymm6,%ymm0
-	vpunpckldq	%ymm7,%ymm0,%ymm6
-	vpunpckhdq	%ymm7,%ymm0,%ymm7
-	vmovdqa		%ymm8,%ymm0
-	vpunpckldq	%ymm9,%ymm0,%ymm8
-	vpunpckhdq	%ymm9,%ymm0,%ymm9
-	vmovdqa		%ymm10,%ymm0
-	vpunpckldq	%ymm11,%ymm0,%ymm10
-	vpunpckhdq	%ymm11,%ymm0,%ymm11
-	vmovdqa		%ymm12,%ymm0
-	vpunpckldq	%ymm13,%ymm0,%ymm12
-	vpunpckhdq	%ymm13,%ymm0,%ymm13
-	vmovdqa		%ymm14,%ymm0
-	vpunpckldq	%ymm15,%ymm0,%ymm14
-	vpunpckhdq	%ymm15,%ymm0,%ymm15
-
-	# interleave 64-bit words in state n, n+2
-	vmovdqa		0x00(%rsp),%ymm0
-	vmovdqa		0x40(%rsp),%ymm2
-	vpunpcklqdq	%ymm2,%ymm0,%ymm1
-	vpunpckhqdq	%ymm2,%ymm0,%ymm2
-	vmovdqa		%ymm1,0x00(%rsp)
-	vmovdqa		%ymm2,0x40(%rsp)
-	vmovdqa		0x20(%rsp),%ymm0
-	vmovdqa		0x60(%rsp),%ymm2
-	vpunpcklqdq	%ymm2,%ymm0,%ymm1
-	vpunpckhqdq	%ymm2,%ymm0,%ymm2
-	vmovdqa		%ymm1,0x20(%rsp)
-	vmovdqa		%ymm2,0x60(%rsp)
-	vmovdqa		%ymm4,%ymm0
-	vpunpcklqdq	%ymm6,%ymm0,%ymm4
-	vpunpckhqdq	%ymm6,%ymm0,%ymm6
-	vmovdqa		%ymm5,%ymm0
-	vpunpcklqdq	%ymm7,%ymm0,%ymm5
-	vpunpckhqdq	%ymm7,%ymm0,%ymm7
-	vmovdqa		%ymm8,%ymm0
-	vpunpcklqdq	%ymm10,%ymm0,%ymm8
-	vpunpckhqdq	%ymm10,%ymm0,%ymm10
-	vmovdqa		%ymm9,%ymm0
-	vpunpcklqdq	%ymm11,%ymm0,%ymm9
-	vpunpckhqdq	%ymm11,%ymm0,%ymm11
-	vmovdqa		%ymm12,%ymm0
-	vpunpcklqdq	%ymm14,%ymm0,%ymm12
-	vpunpckhqdq	%ymm14,%ymm0,%ymm14
-	vmovdqa		%ymm13,%ymm0
-	vpunpcklqdq	%ymm15,%ymm0,%ymm13
-	vpunpckhqdq	%ymm15,%ymm0,%ymm15
-
-	# interleave 128-bit words in state n, n+4
-	# xor/write first four blocks
-	vmovdqa		0x00(%rsp),%ymm1
-	vperm2i128	$0x20,%ymm4,%ymm1,%ymm0
-	cmp		$0x0020,%rax
-	jl		.Lxorpart8
-	vpxor		0x0000(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0000(%rsi)
-	vperm2i128	$0x31,%ymm4,%ymm1,%ymm4
-
-	vperm2i128	$0x20,%ymm12,%ymm8,%ymm0
-	cmp		$0x0040,%rax
-	jl		.Lxorpart8
-	vpxor		0x0020(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0020(%rsi)
-	vperm2i128	$0x31,%ymm12,%ymm8,%ymm12
-
-	vmovdqa		0x40(%rsp),%ymm1
-	vperm2i128	$0x20,%ymm6,%ymm1,%ymm0
-	cmp		$0x0060,%rax
-	jl		.Lxorpart8
-	vpxor		0x0040(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0040(%rsi)
-	vperm2i128	$0x31,%ymm6,%ymm1,%ymm6
-
-	vperm2i128	$0x20,%ymm14,%ymm10,%ymm0
-	cmp		$0x0080,%rax
-	jl		.Lxorpart8
-	vpxor		0x0060(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0060(%rsi)
-	vperm2i128	$0x31,%ymm14,%ymm10,%ymm14
-
-	vmovdqa		0x20(%rsp),%ymm1
-	vperm2i128	$0x20,%ymm5,%ymm1,%ymm0
-	cmp		$0x00a0,%rax
-	jl		.Lxorpart8
-	vpxor		0x0080(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0080(%rsi)
-	vperm2i128	$0x31,%ymm5,%ymm1,%ymm5
-
-	vperm2i128	$0x20,%ymm13,%ymm9,%ymm0
-	cmp		$0x00c0,%rax
-	jl		.Lxorpart8
-	vpxor		0x00a0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x00a0(%rsi)
-	vperm2i128	$0x31,%ymm13,%ymm9,%ymm13
-
-	vmovdqa		0x60(%rsp),%ymm1
-	vperm2i128	$0x20,%ymm7,%ymm1,%ymm0
-	cmp		$0x00e0,%rax
-	jl		.Lxorpart8
-	vpxor		0x00c0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x00c0(%rsi)
-	vperm2i128	$0x31,%ymm7,%ymm1,%ymm7
-
-	vperm2i128	$0x20,%ymm15,%ymm11,%ymm0
-	cmp		$0x0100,%rax
-	jl		.Lxorpart8
-	vpxor		0x00e0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x00e0(%rsi)
-	vperm2i128	$0x31,%ymm15,%ymm11,%ymm15
-
-	# xor remaining blocks, write to output
-	vmovdqa		%ymm4,%ymm0
-	cmp		$0x0120,%rax
-	jl		.Lxorpart8
-	vpxor		0x0100(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0100(%rsi)
-
-	vmovdqa		%ymm12,%ymm0
-	cmp		$0x0140,%rax
-	jl		.Lxorpart8
-	vpxor		0x0120(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0120(%rsi)
-
-	vmovdqa		%ymm6,%ymm0
-	cmp		$0x0160,%rax
-	jl		.Lxorpart8
-	vpxor		0x0140(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0140(%rsi)
-
-	vmovdqa		%ymm14,%ymm0
-	cmp		$0x0180,%rax
-	jl		.Lxorpart8
-	vpxor		0x0160(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0160(%rsi)
-
-	vmovdqa		%ymm5,%ymm0
-	cmp		$0x01a0,%rax
-	jl		.Lxorpart8
-	vpxor		0x0180(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x0180(%rsi)
-
-	vmovdqa		%ymm13,%ymm0
-	cmp		$0x01c0,%rax
-	jl		.Lxorpart8
-	vpxor		0x01a0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x01a0(%rsi)
-
-	vmovdqa		%ymm7,%ymm0
-	cmp		$0x01e0,%rax
-	jl		.Lxorpart8
-	vpxor		0x01c0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x01c0(%rsi)
-
-	vmovdqa		%ymm15,%ymm0
-	cmp		$0x0200,%rax
-	jl		.Lxorpart8
-	vpxor		0x01e0(%rdx),%ymm0,%ymm0
-	vmovdqu		%ymm0,0x01e0(%rsi)
-
-.Ldone8:
-	vzeroupper
-	lea		-8(%r10),%rsp
-	ret
-
-.Lxorpart8:
-	# xor remaining bytes from partial register into output
-	mov		%rax,%r9
-	and		$0x1f,%r9
-	jz		.Ldone8
-	and		$~0x1f,%rax
-
-	mov		%rsi,%r11
-
-	lea		(%rdx,%rax),%rsi
-	mov		%rsp,%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	vpxor		0x00(%rsp),%ymm0,%ymm0
-	vmovdqa		%ymm0,0x00(%rsp)
-
-	mov		%rsp,%rsi
-	lea		(%r11,%rax),%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	jmp		.Ldone8
-
-ENDPROC(chacha20_8block_xor_avx2)
diff --git a/arch/x86/crypto/chacha20-ssse3-x86_64.S b/arch/x86/crypto/chacha20-ssse3-x86_64.S
deleted file mode 100644
index d8ac75bb448f..000000000000
--- a/arch/x86/crypto/chacha20-ssse3-x86_64.S
+++ /dev/null
@@ -1,761 +0,0 @@
-/*
- * ChaCha20 256-bit cipher algorithm, RFC7539, x64 SSSE3 functions
- *
- * Copyright (C) 2015 Martin Willi
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/linkage.h>
-
-.section	.rodata.cst16.ROT8, "aM", @progbits, 16
-.align 16
-ROT8:	.octa 0x0e0d0c0f0a09080b0605040702010003
-.section	.rodata.cst16.ROT16, "aM", @progbits, 16
-.align 16
-ROT16:	.octa 0x0d0c0f0e09080b0a0504070601000302
-.section	.rodata.cst16.CTRINC, "aM", @progbits, 16
-.align 16
-CTRINC:	.octa 0x00000003000000020000000100000000
-
-.text
-
-ENTRY(chacha20_block_xor_ssse3)
-	# %rdi: Input state matrix, s
-	# %rsi: up to 1 data block output, o
-	# %rdx: up to 1 data block input, i
-	# %rcx: input/output length in bytes
-
-	# This function encrypts one ChaCha20 block by loading the state matrix
-	# in four SSE registers. It performs matrix operation on four words in
-	# parallel, but requires shuffling to rearrange the words after each
-	# round. 8/16-bit word rotation is done with the slightly better
-	# performing SSSE3 byte shuffling, 7/12-bit word rotation uses
-	# traditional shift+OR.
-
-	# x0..3 = s0..3
-	movdqa		0x00(%rdi),%xmm0
-	movdqa		0x10(%rdi),%xmm1
-	movdqa		0x20(%rdi),%xmm2
-	movdqa		0x30(%rdi),%xmm3
-	movdqa		%xmm0,%xmm8
-	movdqa		%xmm1,%xmm9
-	movdqa		%xmm2,%xmm10
-	movdqa		%xmm3,%xmm11
-
-	movdqa		ROT8(%rip),%xmm4
-	movdqa		ROT16(%rip),%xmm5
-
-	mov		%rcx,%rax
-	mov		$10,%ecx
-
-.Ldoubleround:
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	paddd		%xmm1,%xmm0
-	pxor		%xmm0,%xmm3
-	pshufb		%xmm5,%xmm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	paddd		%xmm3,%xmm2
-	pxor		%xmm2,%xmm1
-	movdqa		%xmm1,%xmm6
-	pslld		$12,%xmm6
-	psrld		$20,%xmm1
-	por		%xmm6,%xmm1
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	paddd		%xmm1,%xmm0
-	pxor		%xmm0,%xmm3
-	pshufb		%xmm4,%xmm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	paddd		%xmm3,%xmm2
-	pxor		%xmm2,%xmm1
-	movdqa		%xmm1,%xmm7
-	pslld		$7,%xmm7
-	psrld		$25,%xmm1
-	por		%xmm7,%xmm1
-
-	# x1 = shuffle32(x1, MASK(0, 3, 2, 1))
-	pshufd		$0x39,%xmm1,%xmm1
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	pshufd		$0x4e,%xmm2,%xmm2
-	# x3 = shuffle32(x3, MASK(2, 1, 0, 3))
-	pshufd		$0x93,%xmm3,%xmm3
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 16)
-	paddd		%xmm1,%xmm0
-	pxor		%xmm0,%xmm3
-	pshufb		%xmm5,%xmm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 12)
-	paddd		%xmm3,%xmm2
-	pxor		%xmm2,%xmm1
-	movdqa		%xmm1,%xmm6
-	pslld		$12,%xmm6
-	psrld		$20,%xmm1
-	por		%xmm6,%xmm1
-
-	# x0 += x1, x3 = rotl32(x3 ^ x0, 8)
-	paddd		%xmm1,%xmm0
-	pxor		%xmm0,%xmm3
-	pshufb		%xmm4,%xmm3
-
-	# x2 += x3, x1 = rotl32(x1 ^ x2, 7)
-	paddd		%xmm3,%xmm2
-	pxor		%xmm2,%xmm1
-	movdqa		%xmm1,%xmm7
-	pslld		$7,%xmm7
-	psrld		$25,%xmm1
-	por		%xmm7,%xmm1
-
-	# x1 = shuffle32(x1, MASK(2, 1, 0, 3))
-	pshufd		$0x93,%xmm1,%xmm1
-	# x2 = shuffle32(x2, MASK(1, 0, 3, 2))
-	pshufd		$0x4e,%xmm2,%xmm2
-	# x3 = shuffle32(x3, MASK(0, 3, 2, 1))
-	pshufd		$0x39,%xmm3,%xmm3
-
-	dec		%ecx
-	jnz		.Ldoubleround
-
-	# o0 = i0 ^ (x0 + s0)
-	paddd		%xmm8,%xmm0
-	cmp		$0x10,%rax
-	jl		.Lxorpart
-	movdqu		0x00(%rdx),%xmm4
-	pxor		%xmm4,%xmm0
-	movdqu		%xmm0,0x00(%rsi)
-	# o1 = i1 ^ (x1 + s1)
-	paddd		%xmm9,%xmm1
-	movdqa		%xmm1,%xmm0
-	cmp		$0x20,%rax
-	jl		.Lxorpart
-	movdqu		0x10(%rdx),%xmm0
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x10(%rsi)
-	# o2 = i2 ^ (x2 + s2)
-	paddd		%xmm10,%xmm2
-	movdqa		%xmm2,%xmm0
-	cmp		$0x30,%rax
-	jl		.Lxorpart
-	movdqu		0x20(%rdx),%xmm0
-	pxor		%xmm2,%xmm0
-	movdqu		%xmm0,0x20(%rsi)
-	# o3 = i3 ^ (x3 + s3)
-	paddd		%xmm11,%xmm3
-	movdqa		%xmm3,%xmm0
-	cmp		$0x40,%rax
-	jl		.Lxorpart
-	movdqu		0x30(%rdx),%xmm0
-	pxor		%xmm3,%xmm0
-	movdqu		%xmm0,0x30(%rsi)
-
-.Ldone:
-	ret
-
-.Lxorpart:
-	# xor remaining bytes from partial register into output
-	mov		%rax,%r9
-	and		$0x0f,%r9
-	jz		.Ldone
-	and		$~0x0f,%rax
-
-	mov		%rsi,%r11
-
-	lea		8(%rsp),%r10
-	sub		$0x10,%rsp
-	and		$~31,%rsp
-
-	lea		(%rdx,%rax),%rsi
-	mov		%rsp,%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	pxor		0x00(%rsp),%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-
-	mov		%rsp,%rsi
-	lea		(%r11,%rax),%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	lea		-8(%r10),%rsp
-	jmp		.Ldone
-
-ENDPROC(chacha20_block_xor_ssse3)
-
-ENTRY(chacha20_4block_xor_ssse3)
-	# %rdi: Input state matrix, s
-	# %rsi: up to 4 data blocks output, o
-	# %rdx: up to 4 data blocks input, i
-	# %rcx: input/output length in bytes
-
-	# This function encrypts four consecutive ChaCha20 blocks by loading the
-	# the state matrix in SSE registers four times. As we need some scratch
-	# registers, we save the first four registers on the stack. The
-	# algorithm performs each operation on the corresponding word of each
-	# state matrix, hence requires no word shuffling. For final XORing step
-	# we transpose the matrix by interleaving 32- and then 64-bit words,
-	# which allows us to do XOR in SSE registers. 8/16-bit word rotation is
-	# done with the slightly better performing SSSE3 byte shuffling,
-	# 7/12-bit word rotation uses traditional shift+OR.
-
-	lea		8(%rsp),%r10
-	sub		$0x80,%rsp
-	and		$~63,%rsp
-	mov		%rcx,%rax
-
-	# x0..15[0-3] = s0..3[0..3]
-	movq		0x00(%rdi),%xmm1
-	pshufd		$0x00,%xmm1,%xmm0
-	pshufd		$0x55,%xmm1,%xmm1
-	movq		0x08(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	movq		0x10(%rdi),%xmm5
-	pshufd		$0x00,%xmm5,%xmm4
-	pshufd		$0x55,%xmm5,%xmm5
-	movq		0x18(%rdi),%xmm7
-	pshufd		$0x00,%xmm7,%xmm6
-	pshufd		$0x55,%xmm7,%xmm7
-	movq		0x20(%rdi),%xmm9
-	pshufd		$0x00,%xmm9,%xmm8
-	pshufd		$0x55,%xmm9,%xmm9
-	movq		0x28(%rdi),%xmm11
-	pshufd		$0x00,%xmm11,%xmm10
-	pshufd		$0x55,%xmm11,%xmm11
-	movq		0x30(%rdi),%xmm13
-	pshufd		$0x00,%xmm13,%xmm12
-	pshufd		$0x55,%xmm13,%xmm13
-	movq		0x38(%rdi),%xmm15
-	pshufd		$0x00,%xmm15,%xmm14
-	pshufd		$0x55,%xmm15,%xmm15
-	# x0..3 on stack
-	movdqa		%xmm0,0x00(%rsp)
-	movdqa		%xmm1,0x10(%rsp)
-	movdqa		%xmm2,0x20(%rsp)
-	movdqa		%xmm3,0x30(%rsp)
-
-	movdqa		CTRINC(%rip),%xmm1
-	movdqa		ROT8(%rip),%xmm2
-	movdqa		ROT16(%rip),%xmm3
-
-	# x12 += counter values 0-3
-	paddd		%xmm1,%xmm12
-
-	mov		$10,%ecx
-
-.Ldoubleround4:
-	# x0 += x4, x12 = rotl32(x12 ^ x0, 16)
-	movdqa		0x00(%rsp),%xmm0
-	paddd		%xmm4,%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-	pxor		%xmm0,%xmm12
-	pshufb		%xmm3,%xmm12
-	# x1 += x5, x13 = rotl32(x13 ^ x1, 16)
-	movdqa		0x10(%rsp),%xmm0
-	paddd		%xmm5,%xmm0
-	movdqa		%xmm0,0x10(%rsp)
-	pxor		%xmm0,%xmm13
-	pshufb		%xmm3,%xmm13
-	# x2 += x6, x14 = rotl32(x14 ^ x2, 16)
-	movdqa		0x20(%rsp),%xmm0
-	paddd		%xmm6,%xmm0
-	movdqa		%xmm0,0x20(%rsp)
-	pxor		%xmm0,%xmm14
-	pshufb		%xmm3,%xmm14
-	# x3 += x7, x15 = rotl32(x15 ^ x3, 16)
-	movdqa		0x30(%rsp),%xmm0
-	paddd		%xmm7,%xmm0
-	movdqa		%xmm0,0x30(%rsp)
-	pxor		%xmm0,%xmm15
-	pshufb		%xmm3,%xmm15
-
-	# x8 += x12, x4 = rotl32(x4 ^ x8, 12)
-	paddd		%xmm12,%xmm8
-	pxor		%xmm8,%xmm4
-	movdqa		%xmm4,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm4
-	por		%xmm0,%xmm4
-	# x9 += x13, x5 = rotl32(x5 ^ x9, 12)
-	paddd		%xmm13,%xmm9
-	pxor		%xmm9,%xmm5
-	movdqa		%xmm5,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm5
-	por		%xmm0,%xmm5
-	# x10 += x14, x6 = rotl32(x6 ^ x10, 12)
-	paddd		%xmm14,%xmm10
-	pxor		%xmm10,%xmm6
-	movdqa		%xmm6,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm6
-	por		%xmm0,%xmm6
-	# x11 += x15, x7 = rotl32(x7 ^ x11, 12)
-	paddd		%xmm15,%xmm11
-	pxor		%xmm11,%xmm7
-	movdqa		%xmm7,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm7
-	por		%xmm0,%xmm7
-
-	# x0 += x4, x12 = rotl32(x12 ^ x0, 8)
-	movdqa		0x00(%rsp),%xmm0
-	paddd		%xmm4,%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-	pxor		%xmm0,%xmm12
-	pshufb		%xmm2,%xmm12
-	# x1 += x5, x13 = rotl32(x13 ^ x1, 8)
-	movdqa		0x10(%rsp),%xmm0
-	paddd		%xmm5,%xmm0
-	movdqa		%xmm0,0x10(%rsp)
-	pxor		%xmm0,%xmm13
-	pshufb		%xmm2,%xmm13
-	# x2 += x6, x14 = rotl32(x14 ^ x2, 8)
-	movdqa		0x20(%rsp),%xmm0
-	paddd		%xmm6,%xmm0
-	movdqa		%xmm0,0x20(%rsp)
-	pxor		%xmm0,%xmm14
-	pshufb		%xmm2,%xmm14
-	# x3 += x7, x15 = rotl32(x15 ^ x3, 8)
-	movdqa		0x30(%rsp),%xmm0
-	paddd		%xmm7,%xmm0
-	movdqa		%xmm0,0x30(%rsp)
-	pxor		%xmm0,%xmm15
-	pshufb		%xmm2,%xmm15
-
-	# x8 += x12, x4 = rotl32(x4 ^ x8, 7)
-	paddd		%xmm12,%xmm8
-	pxor		%xmm8,%xmm4
-	movdqa		%xmm4,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm4
-	por		%xmm0,%xmm4
-	# x9 += x13, x5 = rotl32(x5 ^ x9, 7)
-	paddd		%xmm13,%xmm9
-	pxor		%xmm9,%xmm5
-	movdqa		%xmm5,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm5
-	por		%xmm0,%xmm5
-	# x10 += x14, x6 = rotl32(x6 ^ x10, 7)
-	paddd		%xmm14,%xmm10
-	pxor		%xmm10,%xmm6
-	movdqa		%xmm6,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm6
-	por		%xmm0,%xmm6
-	# x11 += x15, x7 = rotl32(x7 ^ x11, 7)
-	paddd		%xmm15,%xmm11
-	pxor		%xmm11,%xmm7
-	movdqa		%xmm7,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm7
-	por		%xmm0,%xmm7
-
-	# x0 += x5, x15 = rotl32(x15 ^ x0, 16)
-	movdqa		0x00(%rsp),%xmm0
-	paddd		%xmm5,%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-	pxor		%xmm0,%xmm15
-	pshufb		%xmm3,%xmm15
-	# x1 += x6, x12 = rotl32(x12 ^ x1, 16)
-	movdqa		0x10(%rsp),%xmm0
-	paddd		%xmm6,%xmm0
-	movdqa		%xmm0,0x10(%rsp)
-	pxor		%xmm0,%xmm12
-	pshufb		%xmm3,%xmm12
-	# x2 += x7, x13 = rotl32(x13 ^ x2, 16)
-	movdqa		0x20(%rsp),%xmm0
-	paddd		%xmm7,%xmm0
-	movdqa		%xmm0,0x20(%rsp)
-	pxor		%xmm0,%xmm13
-	pshufb		%xmm3,%xmm13
-	# x3 += x4, x14 = rotl32(x14 ^ x3, 16)
-	movdqa		0x30(%rsp),%xmm0
-	paddd		%xmm4,%xmm0
-	movdqa		%xmm0,0x30(%rsp)
-	pxor		%xmm0,%xmm14
-	pshufb		%xmm3,%xmm14
-
-	# x10 += x15, x5 = rotl32(x5 ^ x10, 12)
-	paddd		%xmm15,%xmm10
-	pxor		%xmm10,%xmm5
-	movdqa		%xmm5,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm5
-	por		%xmm0,%xmm5
-	# x11 += x12, x6 = rotl32(x6 ^ x11, 12)
-	paddd		%xmm12,%xmm11
-	pxor		%xmm11,%xmm6
-	movdqa		%xmm6,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm6
-	por		%xmm0,%xmm6
-	# x8 += x13, x7 = rotl32(x7 ^ x8, 12)
-	paddd		%xmm13,%xmm8
-	pxor		%xmm8,%xmm7
-	movdqa		%xmm7,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm7
-	por		%xmm0,%xmm7
-	# x9 += x14, x4 = rotl32(x4 ^ x9, 12)
-	paddd		%xmm14,%xmm9
-	pxor		%xmm9,%xmm4
-	movdqa		%xmm4,%xmm0
-	pslld		$12,%xmm0
-	psrld		$20,%xmm4
-	por		%xmm0,%xmm4
-
-	# x0 += x5, x15 = rotl32(x15 ^ x0, 8)
-	movdqa		0x00(%rsp),%xmm0
-	paddd		%xmm5,%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-	pxor		%xmm0,%xmm15
-	pshufb		%xmm2,%xmm15
-	# x1 += x6, x12 = rotl32(x12 ^ x1, 8)
-	movdqa		0x10(%rsp),%xmm0
-	paddd		%xmm6,%xmm0
-	movdqa		%xmm0,0x10(%rsp)
-	pxor		%xmm0,%xmm12
-	pshufb		%xmm2,%xmm12
-	# x2 += x7, x13 = rotl32(x13 ^ x2, 8)
-	movdqa		0x20(%rsp),%xmm0
-	paddd		%xmm7,%xmm0
-	movdqa		%xmm0,0x20(%rsp)
-	pxor		%xmm0,%xmm13
-	pshufb		%xmm2,%xmm13
-	# x3 += x4, x14 = rotl32(x14 ^ x3, 8)
-	movdqa		0x30(%rsp),%xmm0
-	paddd		%xmm4,%xmm0
-	movdqa		%xmm0,0x30(%rsp)
-	pxor		%xmm0,%xmm14
-	pshufb		%xmm2,%xmm14
-
-	# x10 += x15, x5 = rotl32(x5 ^ x10, 7)
-	paddd		%xmm15,%xmm10
-	pxor		%xmm10,%xmm5
-	movdqa		%xmm5,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm5
-	por		%xmm0,%xmm5
-	# x11 += x12, x6 = rotl32(x6 ^ x11, 7)
-	paddd		%xmm12,%xmm11
-	pxor		%xmm11,%xmm6
-	movdqa		%xmm6,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm6
-	por		%xmm0,%xmm6
-	# x8 += x13, x7 = rotl32(x7 ^ x8, 7)
-	paddd		%xmm13,%xmm8
-	pxor		%xmm8,%xmm7
-	movdqa		%xmm7,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm7
-	por		%xmm0,%xmm7
-	# x9 += x14, x4 = rotl32(x4 ^ x9, 7)
-	paddd		%xmm14,%xmm9
-	pxor		%xmm9,%xmm4
-	movdqa		%xmm4,%xmm0
-	pslld		$7,%xmm0
-	psrld		$25,%xmm4
-	por		%xmm0,%xmm4
-
-	dec		%ecx
-	jnz		.Ldoubleround4
-
-	# x0[0-3] += s0[0]
-	# x1[0-3] += s0[1]
-	movq		0x00(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		0x00(%rsp),%xmm2
-	movdqa		%xmm2,0x00(%rsp)
-	paddd		0x10(%rsp),%xmm3
-	movdqa		%xmm3,0x10(%rsp)
-	# x2[0-3] += s0[2]
-	# x3[0-3] += s0[3]
-	movq		0x08(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		0x20(%rsp),%xmm2
-	movdqa		%xmm2,0x20(%rsp)
-	paddd		0x30(%rsp),%xmm3
-	movdqa		%xmm3,0x30(%rsp)
-
-	# x4[0-3] += s1[0]
-	# x5[0-3] += s1[1]
-	movq		0x10(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm4
-	paddd		%xmm3,%xmm5
-	# x6[0-3] += s1[2]
-	# x7[0-3] += s1[3]
-	movq		0x18(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm6
-	paddd		%xmm3,%xmm7
-
-	# x8[0-3] += s2[0]
-	# x9[0-3] += s2[1]
-	movq		0x20(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm8
-	paddd		%xmm3,%xmm9
-	# x10[0-3] += s2[2]
-	# x11[0-3] += s2[3]
-	movq		0x28(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm10
-	paddd		%xmm3,%xmm11
-
-	# x12[0-3] += s3[0]
-	# x13[0-3] += s3[1]
-	movq		0x30(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm12
-	paddd		%xmm3,%xmm13
-	# x14[0-3] += s3[2]
-	# x15[0-3] += s3[3]
-	movq		0x38(%rdi),%xmm3
-	pshufd		$0x00,%xmm3,%xmm2
-	pshufd		$0x55,%xmm3,%xmm3
-	paddd		%xmm2,%xmm14
-	paddd		%xmm3,%xmm15
-
-	# x12 += counter values 0-3
-	paddd		%xmm1,%xmm12
-
-	# interleave 32-bit words in state n, n+1
-	movdqa		0x00(%rsp),%xmm0
-	movdqa		0x10(%rsp),%xmm1
-	movdqa		%xmm0,%xmm2
-	punpckldq	%xmm1,%xmm2
-	punpckhdq	%xmm1,%xmm0
-	movdqa		%xmm2,0x00(%rsp)
-	movdqa		%xmm0,0x10(%rsp)
-	movdqa		0x20(%rsp),%xmm0
-	movdqa		0x30(%rsp),%xmm1
-	movdqa		%xmm0,%xmm2
-	punpckldq	%xmm1,%xmm2
-	punpckhdq	%xmm1,%xmm0
-	movdqa		%xmm2,0x20(%rsp)
-	movdqa		%xmm0,0x30(%rsp)
-	movdqa		%xmm4,%xmm0
-	punpckldq	%xmm5,%xmm4
-	punpckhdq	%xmm5,%xmm0
-	movdqa		%xmm0,%xmm5
-	movdqa		%xmm6,%xmm0
-	punpckldq	%xmm7,%xmm6
-	punpckhdq	%xmm7,%xmm0
-	movdqa		%xmm0,%xmm7
-	movdqa		%xmm8,%xmm0
-	punpckldq	%xmm9,%xmm8
-	punpckhdq	%xmm9,%xmm0
-	movdqa		%xmm0,%xmm9
-	movdqa		%xmm10,%xmm0
-	punpckldq	%xmm11,%xmm10
-	punpckhdq	%xmm11,%xmm0
-	movdqa		%xmm0,%xmm11
-	movdqa		%xmm12,%xmm0
-	punpckldq	%xmm13,%xmm12
-	punpckhdq	%xmm13,%xmm0
-	movdqa		%xmm0,%xmm13
-	movdqa		%xmm14,%xmm0
-	punpckldq	%xmm15,%xmm14
-	punpckhdq	%xmm15,%xmm0
-	movdqa		%xmm0,%xmm15
-
-	# interleave 64-bit words in state n, n+2
-	movdqa		0x00(%rsp),%xmm0
-	movdqa		0x20(%rsp),%xmm1
-	movdqa		%xmm0,%xmm2
-	punpcklqdq	%xmm1,%xmm2
-	punpckhqdq	%xmm1,%xmm0
-	movdqa		%xmm2,0x00(%rsp)
-	movdqa		%xmm0,0x20(%rsp)
-	movdqa		0x10(%rsp),%xmm0
-	movdqa		0x30(%rsp),%xmm1
-	movdqa		%xmm0,%xmm2
-	punpcklqdq	%xmm1,%xmm2
-	punpckhqdq	%xmm1,%xmm0
-	movdqa		%xmm2,0x10(%rsp)
-	movdqa		%xmm0,0x30(%rsp)
-	movdqa		%xmm4,%xmm0
-	punpcklqdq	%xmm6,%xmm4
-	punpckhqdq	%xmm6,%xmm0
-	movdqa		%xmm0,%xmm6
-	movdqa		%xmm5,%xmm0
-	punpcklqdq	%xmm7,%xmm5
-	punpckhqdq	%xmm7,%xmm0
-	movdqa		%xmm0,%xmm7
-	movdqa		%xmm8,%xmm0
-	punpcklqdq	%xmm10,%xmm8
-	punpckhqdq	%xmm10,%xmm0
-	movdqa		%xmm0,%xmm10
-	movdqa		%xmm9,%xmm0
-	punpcklqdq	%xmm11,%xmm9
-	punpckhqdq	%xmm11,%xmm0
-	movdqa		%xmm0,%xmm11
-	movdqa		%xmm12,%xmm0
-	punpcklqdq	%xmm14,%xmm12
-	punpckhqdq	%xmm14,%xmm0
-	movdqa		%xmm0,%xmm14
-	movdqa		%xmm13,%xmm0
-	punpcklqdq	%xmm15,%xmm13
-	punpckhqdq	%xmm15,%xmm0
-	movdqa		%xmm0,%xmm15
-
-	# xor with corresponding input, write to output
-	movdqa		0x00(%rsp),%xmm0
-	cmp		$0x10,%rax
-	jl		.Lxorpart4
-	movdqu		0x00(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x00(%rsi)
-
-	movdqu		%xmm4,%xmm0
-	cmp		$0x20,%rax
-	jl		.Lxorpart4
-	movdqu		0x10(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x10(%rsi)
-
-	movdqu		%xmm8,%xmm0
-	cmp		$0x30,%rax
-	jl		.Lxorpart4
-	movdqu		0x20(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x20(%rsi)
-
-	movdqu		%xmm12,%xmm0
-	cmp		$0x40,%rax
-	jl		.Lxorpart4
-	movdqu		0x30(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x30(%rsi)
-
-	movdqa		0x20(%rsp),%xmm0
-	cmp		$0x50,%rax
-	jl		.Lxorpart4
-	movdqu		0x40(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x40(%rsi)
-
-	movdqu		%xmm6,%xmm0
-	cmp		$0x60,%rax
-	jl		.Lxorpart4
-	movdqu		0x50(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x50(%rsi)
-
-	movdqu		%xmm10,%xmm0
-	cmp		$0x70,%rax
-	jl		.Lxorpart4
-	movdqu		0x60(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x60(%rsi)
-
-	movdqu		%xmm14,%xmm0
-	cmp		$0x80,%rax
-	jl		.Lxorpart4
-	movdqu		0x70(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x70(%rsi)
-
-	movdqa		0x10(%rsp),%xmm0
-	cmp		$0x90,%rax
-	jl		.Lxorpart4
-	movdqu		0x80(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x80(%rsi)
-
-	movdqu		%xmm5,%xmm0
-	cmp		$0xa0,%rax
-	jl		.Lxorpart4
-	movdqu		0x90(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0x90(%rsi)
-
-	movdqu		%xmm9,%xmm0
-	cmp		$0xb0,%rax
-	jl		.Lxorpart4
-	movdqu		0xa0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xa0(%rsi)
-
-	movdqu		%xmm13,%xmm0
-	cmp		$0xc0,%rax
-	jl		.Lxorpart4
-	movdqu		0xb0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xb0(%rsi)
-
-	movdqa		0x30(%rsp),%xmm0
-	cmp		$0xd0,%rax
-	jl		.Lxorpart4
-	movdqu		0xc0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xc0(%rsi)
-
-	movdqu		%xmm7,%xmm0
-	cmp		$0xe0,%rax
-	jl		.Lxorpart4
-	movdqu		0xd0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xd0(%rsi)
-
-	movdqu		%xmm11,%xmm0
-	cmp		$0xf0,%rax
-	jl		.Lxorpart4
-	movdqu		0xe0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xe0(%rsi)
-
-	movdqu		%xmm15,%xmm0
-	cmp		$0x100,%rax
-	jl		.Lxorpart4
-	movdqu		0xf0(%rdx),%xmm1
-	pxor		%xmm1,%xmm0
-	movdqu		%xmm0,0xf0(%rsi)
-
-.Ldone4:
-	lea		-8(%r10),%rsp
-	ret
-
-.Lxorpart4:
-	# xor remaining bytes from partial register into output
-	mov		%rax,%r9
-	and		$0x0f,%r9
-	jz		.Ldone4
-	and		$~0x0f,%rax
-
-	mov		%rsi,%r11
-
-	lea		(%rdx,%rax),%rsi
-	mov		%rsp,%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	pxor		0x00(%rsp),%xmm0
-	movdqa		%xmm0,0x00(%rsp)
-
-	mov		%rsp,%rsi
-	lea		(%r11,%rax),%rdi
-	mov		%r9,%rcx
-	rep movsb
-
-	jmp		.Ldone4
-
-ENDPROC(chacha20_4block_xor_ssse3)
diff --git a/arch/x86/crypto/chacha20-zinc-x86_64.S b/arch/x86/crypto/chacha20-zinc-x86_64.S
new file mode 100644
index 000000000000..3d10c7f21642
--- /dev/null
+++ b/arch/x86/crypto/chacha20-zinc-x86_64.S
@@ -0,0 +1,2632 @@
+/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
+/*
+ * Copyright (C) 2017 Samuel Neves <sneves@dei.uc.pt>. All Rights Reserved.
+ * Copyright (C) 2015-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
+ * Copyright (C) 2006-2017 CRYPTOGAMS by <appro@openssl.org>. All Rights Reserved.
+ *
+ * This is based in part on Andy Polyakov's implementation from CRYPTOGAMS.
+ */
+
+#include <linux/linkage.h>
+
+.section .rodata.cst16.Lzero, "aM", @progbits, 16
+.align	16
+.Lzero:
+.long	0,0,0,0
+.section .rodata.cst16.Lone, "aM", @progbits, 16
+.align	16
+.Lone:
+.long	1,0,0,0
+.section .rodata.cst16.Linc, "aM", @progbits, 16
+.align	16
+.Linc:
+.long	0,1,2,3
+.section .rodata.cst16.Lfour, "aM", @progbits, 16
+.align	16
+.Lfour:
+.long	4,4,4,4
+.section .rodata.cst32.Lincy, "aM", @progbits, 32
+.align	32
+.Lincy:
+.long	0,2,4,6,1,3,5,7
+.section .rodata.cst32.Leight, "aM", @progbits, 32
+.align	32
+.Leight:
+.long	8,8,8,8,8,8,8,8
+.section .rodata.cst16.Lrot16, "aM", @progbits, 16
+.align	16
+.Lrot16:
+.byte	0x2,0x3,0x0,0x1, 0x6,0x7,0x4,0x5, 0xa,0xb,0x8,0x9, 0xe,0xf,0xc,0xd
+.section .rodata.cst16.Lrot24, "aM", @progbits, 16
+.align	16
+.Lrot24:
+.byte	0x3,0x0,0x1,0x2, 0x7,0x4,0x5,0x6, 0xb,0x8,0x9,0xa, 0xf,0xc,0xd,0xe
+.section .rodata.cst16.Lsigma, "aM", @progbits, 16
+.align	16
+.Lsigma:
+.byte	101,120,112,97,110,100,32,51,50,45,98,121,116,101,32,107,0
+.section .rodata.cst64.Lzeroz, "aM", @progbits, 64
+.align	64
+.Lzeroz:
+.long	0,0,0,0, 1,0,0,0, 2,0,0,0, 3,0,0,0
+.section .rodata.cst64.Lfourz, "aM", @progbits, 64
+.align	64
+.Lfourz:
+.long	4,0,0,0, 4,0,0,0, 4,0,0,0, 4,0,0,0
+.section .rodata.cst64.Lincz, "aM", @progbits, 64
+.align	64
+.Lincz:
+.long	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
+.section .rodata.cst64.Lsixteen, "aM", @progbits, 64
+.align	64
+.Lsixteen:
+.long	16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
+.section .rodata.cst32.Ltwoy, "aM", @progbits, 32
+.align	64
+.Ltwoy:
+.long	2,0,0,0, 2,0,0,0
+
+.text
+
+#ifdef CONFIG_AS_SSSE3
+.align	32
+ENTRY(hchacha20_ssse3)
+	movdqa	.Lsigma(%rip),%xmm0
+	movdqu	(%rdx),%xmm1
+	movdqu	16(%rdx),%xmm2
+	movdqu	(%rsi),%xmm3
+	movdqa	.Lrot16(%rip),%xmm6
+	movdqa	.Lrot24(%rip),%xmm7
+	movq	$10,%r8
+	.align	32
+.Loop_hssse3:
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm6,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$20,%xmm1
+	pslld	$12,%xmm4
+	por	%xmm4,%xmm1
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm7,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$25,%xmm1
+	pslld	$7,%xmm4
+	por	%xmm4,%xmm1
+	pshufd	$78,%xmm2,%xmm2
+	pshufd	$57,%xmm1,%xmm1
+	pshufd	$147,%xmm3,%xmm3
+	nop
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm6,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$20,%xmm1
+	pslld	$12,%xmm4
+	por	%xmm4,%xmm1
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm7,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$25,%xmm1
+	pslld	$7,%xmm4
+	por	%xmm4,%xmm1
+	pshufd	$78,%xmm2,%xmm2
+	pshufd	$147,%xmm1,%xmm1
+	pshufd	$57,%xmm3,%xmm3
+	decq	%r8
+	jnz	.Loop_hssse3
+	movdqu	%xmm0,0(%rdi)
+	movdqu	%xmm3,16(%rdi)
+	ret
+ENDPROC(hchacha20_ssse3)
+
+.align	32
+ENTRY(chacha20_ssse3)
+.Lchacha20_ssse3:
+	cmpq	$0,%rdx
+	je	.Lssse3_epilogue
+	leaq	8(%rsp),%r10
+
+	cmpq	$128,%rdx
+	ja	.Lchacha20_4x
+
+.Ldo_sse3_after_all:
+	subq	$64+8,%rsp
+	andq	$-32,%rsp
+	movdqa	.Lsigma(%rip),%xmm0
+	movdqu	(%rcx),%xmm1
+	movdqu	16(%rcx),%xmm2
+	movdqu	(%r8),%xmm3
+	movdqa	.Lrot16(%rip),%xmm6
+	movdqa	.Lrot24(%rip),%xmm7
+
+	movdqa	%xmm0,0(%rsp)
+	movdqa	%xmm1,16(%rsp)
+	movdqa	%xmm2,32(%rsp)
+	movdqa	%xmm3,48(%rsp)
+	movq	$10,%r8
+	jmp	.Loop_ssse3
+
+.align	32
+.Loop_outer_ssse3:
+	movdqa	.Lone(%rip),%xmm3
+	movdqa	0(%rsp),%xmm0
+	movdqa	16(%rsp),%xmm1
+	movdqa	32(%rsp),%xmm2
+	paddd	48(%rsp),%xmm3
+	movq	$10,%r8
+	movdqa	%xmm3,48(%rsp)
+	jmp	.Loop_ssse3
+
+.align	32
+.Loop_ssse3:
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm6,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$20,%xmm1
+	pslld	$12,%xmm4
+	por	%xmm4,%xmm1
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm7,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$25,%xmm1
+	pslld	$7,%xmm4
+	por	%xmm4,%xmm1
+	pshufd	$78,%xmm2,%xmm2
+	pshufd	$57,%xmm1,%xmm1
+	pshufd	$147,%xmm3,%xmm3
+	nop
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm6,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$20,%xmm1
+	pslld	$12,%xmm4
+	por	%xmm4,%xmm1
+	paddd	%xmm1,%xmm0
+	pxor	%xmm0,%xmm3
+	pshufb	%xmm7,%xmm3
+	paddd	%xmm3,%xmm2
+	pxor	%xmm2,%xmm1
+	movdqa	%xmm1,%xmm4
+	psrld	$25,%xmm1
+	pslld	$7,%xmm4
+	por	%xmm4,%xmm1
+	pshufd	$78,%xmm2,%xmm2
+	pshufd	$147,%xmm1,%xmm1
+	pshufd	$57,%xmm3,%xmm3
+	decq	%r8
+	jnz	.Loop_ssse3
+	paddd	0(%rsp),%xmm0
+	paddd	16(%rsp),%xmm1
+	paddd	32(%rsp),%xmm2
+	paddd	48(%rsp),%xmm3
+
+	cmpq	$64,%rdx
+	jb	.Ltail_ssse3
+
+	movdqu	0(%rsi),%xmm4
+	movdqu	16(%rsi),%xmm5
+	pxor	%xmm4,%xmm0
+	movdqu	32(%rsi),%xmm4
+	pxor	%xmm5,%xmm1
+	movdqu	48(%rsi),%xmm5
+	leaq	64(%rsi),%rsi
+	pxor	%xmm4,%xmm2
+	pxor	%xmm5,%xmm3
+
+	movdqu	%xmm0,0(%rdi)
+	movdqu	%xmm1,16(%rdi)
+	movdqu	%xmm2,32(%rdi)
+	movdqu	%xmm3,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	subq	$64,%rdx
+	jnz	.Loop_outer_ssse3
+
+	jmp	.Ldone_ssse3
+
+.align	16
+.Ltail_ssse3:
+	movdqa	%xmm0,0(%rsp)
+	movdqa	%xmm1,16(%rsp)
+	movdqa	%xmm2,32(%rsp)
+	movdqa	%xmm3,48(%rsp)
+	xorq	%r8,%r8
+
+.Loop_tail_ssse3:
+	movzbl	(%rsi,%r8,1),%eax
+	movzbl	(%rsp,%r8,1),%ecx
+	leaq	1(%r8),%r8
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r8,1)
+	decq	%rdx
+	jnz	.Loop_tail_ssse3
+
+.Ldone_ssse3:
+	leaq	-8(%r10),%rsp
+
+.Lssse3_epilogue:
+	ret
+
+.align	32
+.Lchacha20_4x:
+	leaq	8(%rsp),%r10
+
+.Lproceed4x:
+	subq	$0x140+8,%rsp
+	andq	$-32,%rsp
+	movdqa	.Lsigma(%rip),%xmm11
+	movdqu	(%rcx),%xmm15
+	movdqu	16(%rcx),%xmm7
+	movdqu	(%r8),%xmm3
+	leaq	256(%rsp),%rcx
+	leaq	.Lrot16(%rip),%r9
+	leaq	.Lrot24(%rip),%r11
+
+	pshufd	$0x00,%xmm11,%xmm8
+	pshufd	$0x55,%xmm11,%xmm9
+	movdqa	%xmm8,64(%rsp)
+	pshufd	$0xaa,%xmm11,%xmm10
+	movdqa	%xmm9,80(%rsp)
+	pshufd	$0xff,%xmm11,%xmm11
+	movdqa	%xmm10,96(%rsp)
+	movdqa	%xmm11,112(%rsp)
+
+	pshufd	$0x00,%xmm15,%xmm12
+	pshufd	$0x55,%xmm15,%xmm13
+	movdqa	%xmm12,128-256(%rcx)
+	pshufd	$0xaa,%xmm15,%xmm14
+	movdqa	%xmm13,144-256(%rcx)
+	pshufd	$0xff,%xmm15,%xmm15
+	movdqa	%xmm14,160-256(%rcx)
+	movdqa	%xmm15,176-256(%rcx)
+
+	pshufd	$0x00,%xmm7,%xmm4
+	pshufd	$0x55,%xmm7,%xmm5
+	movdqa	%xmm4,192-256(%rcx)
+	pshufd	$0xaa,%xmm7,%xmm6
+	movdqa	%xmm5,208-256(%rcx)
+	pshufd	$0xff,%xmm7,%xmm7
+	movdqa	%xmm6,224-256(%rcx)
+	movdqa	%xmm7,240-256(%rcx)
+
+	pshufd	$0x00,%xmm3,%xmm0
+	pshufd	$0x55,%xmm3,%xmm1
+	paddd	.Linc(%rip),%xmm0
+	pshufd	$0xaa,%xmm3,%xmm2
+	movdqa	%xmm1,272-256(%rcx)
+	pshufd	$0xff,%xmm3,%xmm3
+	movdqa	%xmm2,288-256(%rcx)
+	movdqa	%xmm3,304-256(%rcx)
+
+	jmp	.Loop_enter4x
+
+.align	32
+.Loop_outer4x:
+	movdqa	64(%rsp),%xmm8
+	movdqa	80(%rsp),%xmm9
+	movdqa	96(%rsp),%xmm10
+	movdqa	112(%rsp),%xmm11
+	movdqa	128-256(%rcx),%xmm12
+	movdqa	144-256(%rcx),%xmm13
+	movdqa	160-256(%rcx),%xmm14
+	movdqa	176-256(%rcx),%xmm15
+	movdqa	192-256(%rcx),%xmm4
+	movdqa	208-256(%rcx),%xmm5
+	movdqa	224-256(%rcx),%xmm6
+	movdqa	240-256(%rcx),%xmm7
+	movdqa	256-256(%rcx),%xmm0
+	movdqa	272-256(%rcx),%xmm1
+	movdqa	288-256(%rcx),%xmm2
+	movdqa	304-256(%rcx),%xmm3
+	paddd	.Lfour(%rip),%xmm0
+
+.Loop_enter4x:
+	movdqa	%xmm6,32(%rsp)
+	movdqa	%xmm7,48(%rsp)
+	movdqa	(%r9),%xmm7
+	movl	$10,%eax
+	movdqa	%xmm0,256-256(%rcx)
+	jmp	.Loop4x
+
+.align	32
+.Loop4x:
+	paddd	%xmm12,%xmm8
+	paddd	%xmm13,%xmm9
+	pxor	%xmm8,%xmm0
+	pxor	%xmm9,%xmm1
+	pshufb	%xmm7,%xmm0
+	pshufb	%xmm7,%xmm1
+	paddd	%xmm0,%xmm4
+	paddd	%xmm1,%xmm5
+	pxor	%xmm4,%xmm12
+	pxor	%xmm5,%xmm13
+	movdqa	%xmm12,%xmm6
+	pslld	$12,%xmm12
+	psrld	$20,%xmm6
+	movdqa	%xmm13,%xmm7
+	pslld	$12,%xmm13
+	por	%xmm6,%xmm12
+	psrld	$20,%xmm7
+	movdqa	(%r11),%xmm6
+	por	%xmm7,%xmm13
+	paddd	%xmm12,%xmm8
+	paddd	%xmm13,%xmm9
+	pxor	%xmm8,%xmm0
+	pxor	%xmm9,%xmm1
+	pshufb	%xmm6,%xmm0
+	pshufb	%xmm6,%xmm1
+	paddd	%xmm0,%xmm4
+	paddd	%xmm1,%xmm5
+	pxor	%xmm4,%xmm12
+	pxor	%xmm5,%xmm13
+	movdqa	%xmm12,%xmm7
+	pslld	$7,%xmm12
+	psrld	$25,%xmm7
+	movdqa	%xmm13,%xmm6
+	pslld	$7,%xmm13
+	por	%xmm7,%xmm12
+	psrld	$25,%xmm6
+	movdqa	(%r9),%xmm7
+	por	%xmm6,%xmm13
+	movdqa	%xmm4,0(%rsp)
+	movdqa	%xmm5,16(%rsp)
+	movdqa	32(%rsp),%xmm4
+	movdqa	48(%rsp),%xmm5
+	paddd	%xmm14,%xmm10
+	paddd	%xmm15,%xmm11
+	pxor	%xmm10,%xmm2
+	pxor	%xmm11,%xmm3
+	pshufb	%xmm7,%xmm2
+	pshufb	%xmm7,%xmm3
+	paddd	%xmm2,%xmm4
+	paddd	%xmm3,%xmm5
+	pxor	%xmm4,%xmm14
+	pxor	%xmm5,%xmm15
+	movdqa	%xmm14,%xmm6
+	pslld	$12,%xmm14
+	psrld	$20,%xmm6
+	movdqa	%xmm15,%xmm7
+	pslld	$12,%xmm15
+	por	%xmm6,%xmm14
+	psrld	$20,%xmm7
+	movdqa	(%r11),%xmm6
+	por	%xmm7,%xmm15
+	paddd	%xmm14,%xmm10
+	paddd	%xmm15,%xmm11
+	pxor	%xmm10,%xmm2
+	pxor	%xmm11,%xmm3
+	pshufb	%xmm6,%xmm2
+	pshufb	%xmm6,%xmm3
+	paddd	%xmm2,%xmm4
+	paddd	%xmm3,%xmm5
+	pxor	%xmm4,%xmm14
+	pxor	%xmm5,%xmm15
+	movdqa	%xmm14,%xmm7
+	pslld	$7,%xmm14
+	psrld	$25,%xmm7
+	movdqa	%xmm15,%xmm6
+	pslld	$7,%xmm15
+	por	%xmm7,%xmm14
+	psrld	$25,%xmm6
+	movdqa	(%r9),%xmm7
+	por	%xmm6,%xmm15
+	paddd	%xmm13,%xmm8
+	paddd	%xmm14,%xmm9
+	pxor	%xmm8,%xmm3
+	pxor	%xmm9,%xmm0
+	pshufb	%xmm7,%xmm3
+	pshufb	%xmm7,%xmm0
+	paddd	%xmm3,%xmm4
+	paddd	%xmm0,%xmm5
+	pxor	%xmm4,%xmm13
+	pxor	%xmm5,%xmm14
+	movdqa	%xmm13,%xmm6
+	pslld	$12,%xmm13
+	psrld	$20,%xmm6
+	movdqa	%xmm14,%xmm7
+	pslld	$12,%xmm14
+	por	%xmm6,%xmm13
+	psrld	$20,%xmm7
+	movdqa	(%r11),%xmm6
+	por	%xmm7,%xmm14
+	paddd	%xmm13,%xmm8
+	paddd	%xmm14,%xmm9
+	pxor	%xmm8,%xmm3
+	pxor	%xmm9,%xmm0
+	pshufb	%xmm6,%xmm3
+	pshufb	%xmm6,%xmm0
+	paddd	%xmm3,%xmm4
+	paddd	%xmm0,%xmm5
+	pxor	%xmm4,%xmm13
+	pxor	%xmm5,%xmm14
+	movdqa	%xmm13,%xmm7
+	pslld	$7,%xmm13
+	psrld	$25,%xmm7
+	movdqa	%xmm14,%xmm6
+	pslld	$7,%xmm14
+	por	%xmm7,%xmm13
+	psrld	$25,%xmm6
+	movdqa	(%r9),%xmm7
+	por	%xmm6,%xmm14
+	movdqa	%xmm4,32(%rsp)
+	movdqa	%xmm5,48(%rsp)
+	movdqa	0(%rsp),%xmm4
+	movdqa	16(%rsp),%xmm5
+	paddd	%xmm15,%xmm10
+	paddd	%xmm12,%xmm11
+	pxor	%xmm10,%xmm1
+	pxor	%xmm11,%xmm2
+	pshufb	%xmm7,%xmm1
+	pshufb	%xmm7,%xmm2
+	paddd	%xmm1,%xmm4
+	paddd	%xmm2,%xmm5
+	pxor	%xmm4,%xmm15
+	pxor	%xmm5,%xmm12
+	movdqa	%xmm15,%xmm6
+	pslld	$12,%xmm15
+	psrld	$20,%xmm6
+	movdqa	%xmm12,%xmm7
+	pslld	$12,%xmm12
+	por	%xmm6,%xmm15
+	psrld	$20,%xmm7
+	movdqa	(%r11),%xmm6
+	por	%xmm7,%xmm12
+	paddd	%xmm15,%xmm10
+	paddd	%xmm12,%xmm11
+	pxor	%xmm10,%xmm1
+	pxor	%xmm11,%xmm2
+	pshufb	%xmm6,%xmm1
+	pshufb	%xmm6,%xmm2
+	paddd	%xmm1,%xmm4
+	paddd	%xmm2,%xmm5
+	pxor	%xmm4,%xmm15
+	pxor	%xmm5,%xmm12
+	movdqa	%xmm15,%xmm7
+	pslld	$7,%xmm15
+	psrld	$25,%xmm7
+	movdqa	%xmm12,%xmm6
+	pslld	$7,%xmm12
+	por	%xmm7,%xmm15
+	psrld	$25,%xmm6
+	movdqa	(%r9),%xmm7
+	por	%xmm6,%xmm12
+	decl	%eax
+	jnz	.Loop4x
+
+	paddd	64(%rsp),%xmm8
+	paddd	80(%rsp),%xmm9
+	paddd	96(%rsp),%xmm10
+	paddd	112(%rsp),%xmm11
+
+	movdqa	%xmm8,%xmm6
+	punpckldq	%xmm9,%xmm8
+	movdqa	%xmm10,%xmm7
+	punpckldq	%xmm11,%xmm10
+	punpckhdq	%xmm9,%xmm6
+	punpckhdq	%xmm11,%xmm7
+	movdqa	%xmm8,%xmm9
+	punpcklqdq	%xmm10,%xmm8
+	movdqa	%xmm6,%xmm11
+	punpcklqdq	%xmm7,%xmm6
+	punpckhqdq	%xmm10,%xmm9
+	punpckhqdq	%xmm7,%xmm11
+	paddd	128-256(%rcx),%xmm12
+	paddd	144-256(%rcx),%xmm13
+	paddd	160-256(%rcx),%xmm14
+	paddd	176-256(%rcx),%xmm15
+
+	movdqa	%xmm8,0(%rsp)
+	movdqa	%xmm9,16(%rsp)
+	movdqa	32(%rsp),%xmm8
+	movdqa	48(%rsp),%xmm9
+
+	movdqa	%xmm12,%xmm10
+	punpckldq	%xmm13,%xmm12
+	movdqa	%xmm14,%xmm7
+	punpckldq	%xmm15,%xmm14
+	punpckhdq	%xmm13,%xmm10
+	punpckhdq	%xmm15,%xmm7
+	movdqa	%xmm12,%xmm13
+	punpcklqdq	%xmm14,%xmm12
+	movdqa	%xmm10,%xmm15
+	punpcklqdq	%xmm7,%xmm10
+	punpckhqdq	%xmm14,%xmm13
+	punpckhqdq	%xmm7,%xmm15
+	paddd	192-256(%rcx),%xmm4
+	paddd	208-256(%rcx),%xmm5
+	paddd	224-256(%rcx),%xmm8
+	paddd	240-256(%rcx),%xmm9
+
+	movdqa	%xmm6,32(%rsp)
+	movdqa	%xmm11,48(%rsp)
+
+	movdqa	%xmm4,%xmm14
+	punpckldq	%xmm5,%xmm4
+	movdqa	%xmm8,%xmm7
+	punpckldq	%xmm9,%xmm8
+	punpckhdq	%xmm5,%xmm14
+	punpckhdq	%xmm9,%xmm7
+	movdqa	%xmm4,%xmm5
+	punpcklqdq	%xmm8,%xmm4
+	movdqa	%xmm14,%xmm9
+	punpcklqdq	%xmm7,%xmm14
+	punpckhqdq	%xmm8,%xmm5
+	punpckhqdq	%xmm7,%xmm9
+	paddd	256-256(%rcx),%xmm0
+	paddd	272-256(%rcx),%xmm1
+	paddd	288-256(%rcx),%xmm2
+	paddd	304-256(%rcx),%xmm3
+
+	movdqa	%xmm0,%xmm8
+	punpckldq	%xmm1,%xmm0
+	movdqa	%xmm2,%xmm7
+	punpckldq	%xmm3,%xmm2
+	punpckhdq	%xmm1,%xmm8
+	punpckhdq	%xmm3,%xmm7
+	movdqa	%xmm0,%xmm1
+	punpcklqdq	%xmm2,%xmm0
+	movdqa	%xmm8,%xmm3
+	punpcklqdq	%xmm7,%xmm8
+	punpckhqdq	%xmm2,%xmm1
+	punpckhqdq	%xmm7,%xmm3
+	cmpq	$256,%rdx
+	jb	.Ltail4x
+
+	movdqu	0(%rsi),%xmm6
+	movdqu	16(%rsi),%xmm11
+	movdqu	32(%rsi),%xmm2
+	movdqu	48(%rsi),%xmm7
+	pxor	0(%rsp),%xmm6
+	pxor	%xmm12,%xmm11
+	pxor	%xmm4,%xmm2
+	pxor	%xmm0,%xmm7
+
+	movdqu	%xmm6,0(%rdi)
+	movdqu	64(%rsi),%xmm6
+	movdqu	%xmm11,16(%rdi)
+	movdqu	80(%rsi),%xmm11
+	movdqu	%xmm2,32(%rdi)
+	movdqu	96(%rsi),%xmm2
+	movdqu	%xmm7,48(%rdi)
+	movdqu	112(%rsi),%xmm7
+	leaq	128(%rsi),%rsi
+	pxor	16(%rsp),%xmm6
+	pxor	%xmm13,%xmm11
+	pxor	%xmm5,%xmm2
+	pxor	%xmm1,%xmm7
+
+	movdqu	%xmm6,64(%rdi)
+	movdqu	0(%rsi),%xmm6
+	movdqu	%xmm11,80(%rdi)
+	movdqu	16(%rsi),%xmm11
+	movdqu	%xmm2,96(%rdi)
+	movdqu	32(%rsi),%xmm2
+	movdqu	%xmm7,112(%rdi)
+	leaq	128(%rdi),%rdi
+	movdqu	48(%rsi),%xmm7
+	pxor	32(%rsp),%xmm6
+	pxor	%xmm10,%xmm11
+	pxor	%xmm14,%xmm2
+	pxor	%xmm8,%xmm7
+
+	movdqu	%xmm6,0(%rdi)
+	movdqu	64(%rsi),%xmm6
+	movdqu	%xmm11,16(%rdi)
+	movdqu	80(%rsi),%xmm11
+	movdqu	%xmm2,32(%rdi)
+	movdqu	96(%rsi),%xmm2
+	movdqu	%xmm7,48(%rdi)
+	movdqu	112(%rsi),%xmm7
+	leaq	128(%rsi),%rsi
+	pxor	48(%rsp),%xmm6
+	pxor	%xmm15,%xmm11
+	pxor	%xmm9,%xmm2
+	pxor	%xmm3,%xmm7
+	movdqu	%xmm6,64(%rdi)
+	movdqu	%xmm11,80(%rdi)
+	movdqu	%xmm2,96(%rdi)
+	movdqu	%xmm7,112(%rdi)
+	leaq	128(%rdi),%rdi
+
+	subq	$256,%rdx
+	jnz	.Loop_outer4x
+
+	jmp	.Ldone4x
+
+.Ltail4x:
+	cmpq	$192,%rdx
+	jae	.L192_or_more4x
+	cmpq	$128,%rdx
+	jae	.L128_or_more4x
+	cmpq	$64,%rdx
+	jae	.L64_or_more4x
+
+
+	xorq	%r9,%r9
+
+	movdqa	%xmm12,16(%rsp)
+	movdqa	%xmm4,32(%rsp)
+	movdqa	%xmm0,48(%rsp)
+	jmp	.Loop_tail4x
+
+.align	32
+.L64_or_more4x:
+	movdqu	0(%rsi),%xmm6
+	movdqu	16(%rsi),%xmm11
+	movdqu	32(%rsi),%xmm2
+	movdqu	48(%rsi),%xmm7
+	pxor	0(%rsp),%xmm6
+	pxor	%xmm12,%xmm11
+	pxor	%xmm4,%xmm2
+	pxor	%xmm0,%xmm7
+	movdqu	%xmm6,0(%rdi)
+	movdqu	%xmm11,16(%rdi)
+	movdqu	%xmm2,32(%rdi)
+	movdqu	%xmm7,48(%rdi)
+	je	.Ldone4x
+
+	movdqa	16(%rsp),%xmm6
+	leaq	64(%rsi),%rsi
+	xorq	%r9,%r9
+	movdqa	%xmm6,0(%rsp)
+	movdqa	%xmm13,16(%rsp)
+	leaq	64(%rdi),%rdi
+	movdqa	%xmm5,32(%rsp)
+	subq	$64,%rdx
+	movdqa	%xmm1,48(%rsp)
+	jmp	.Loop_tail4x
+
+.align	32
+.L128_or_more4x:
+	movdqu	0(%rsi),%xmm6
+	movdqu	16(%rsi),%xmm11
+	movdqu	32(%rsi),%xmm2
+	movdqu	48(%rsi),%xmm7
+	pxor	0(%rsp),%xmm6
+	pxor	%xmm12,%xmm11
+	pxor	%xmm4,%xmm2
+	pxor	%xmm0,%xmm7
+
+	movdqu	%xmm6,0(%rdi)
+	movdqu	64(%rsi),%xmm6
+	movdqu	%xmm11,16(%rdi)
+	movdqu	80(%rsi),%xmm11
+	movdqu	%xmm2,32(%rdi)
+	movdqu	96(%rsi),%xmm2
+	movdqu	%xmm7,48(%rdi)
+	movdqu	112(%rsi),%xmm7
+	pxor	16(%rsp),%xmm6
+	pxor	%xmm13,%xmm11
+	pxor	%xmm5,%xmm2
+	pxor	%xmm1,%xmm7
+	movdqu	%xmm6,64(%rdi)
+	movdqu	%xmm11,80(%rdi)
+	movdqu	%xmm2,96(%rdi)
+	movdqu	%xmm7,112(%rdi)
+	je	.Ldone4x
+
+	movdqa	32(%rsp),%xmm6
+	leaq	128(%rsi),%rsi
+	xorq	%r9,%r9
+	movdqa	%xmm6,0(%rsp)
+	movdqa	%xmm10,16(%rsp)
+	leaq	128(%rdi),%rdi
+	movdqa	%xmm14,32(%rsp)
+	subq	$128,%rdx
+	movdqa	%xmm8,48(%rsp)
+	jmp	.Loop_tail4x
+
+.align	32
+.L192_or_more4x:
+	movdqu	0(%rsi),%xmm6
+	movdqu	16(%rsi),%xmm11
+	movdqu	32(%rsi),%xmm2
+	movdqu	48(%rsi),%xmm7
+	pxor	0(%rsp),%xmm6
+	pxor	%xmm12,%xmm11
+	pxor	%xmm4,%xmm2
+	pxor	%xmm0,%xmm7
+
+	movdqu	%xmm6,0(%rdi)
+	movdqu	64(%rsi),%xmm6
+	movdqu	%xmm11,16(%rdi)
+	movdqu	80(%rsi),%xmm11
+	movdqu	%xmm2,32(%rdi)
+	movdqu	96(%rsi),%xmm2
+	movdqu	%xmm7,48(%rdi)
+	movdqu	112(%rsi),%xmm7
+	leaq	128(%rsi),%rsi
+	pxor	16(%rsp),%xmm6
+	pxor	%xmm13,%xmm11
+	pxor	%xmm5,%xmm2
+	pxor	%xmm1,%xmm7
+
+	movdqu	%xmm6,64(%rdi)
+	movdqu	0(%rsi),%xmm6
+	movdqu	%xmm11,80(%rdi)
+	movdqu	16(%rsi),%xmm11
+	movdqu	%xmm2,96(%rdi)
+	movdqu	32(%rsi),%xmm2
+	movdqu	%xmm7,112(%rdi)
+	leaq	128(%rdi),%rdi
+	movdqu	48(%rsi),%xmm7
+	pxor	32(%rsp),%xmm6
+	pxor	%xmm10,%xmm11
+	pxor	%xmm14,%xmm2
+	pxor	%xmm8,%xmm7
+	movdqu	%xmm6,0(%rdi)
+	movdqu	%xmm11,16(%rdi)
+	movdqu	%xmm2,32(%rdi)
+	movdqu	%xmm7,48(%rdi)
+	je	.Ldone4x
+
+	movdqa	48(%rsp),%xmm6
+	leaq	64(%rsi),%rsi
+	xorq	%r9,%r9
+	movdqa	%xmm6,0(%rsp)
+	movdqa	%xmm15,16(%rsp)
+	leaq	64(%rdi),%rdi
+	movdqa	%xmm9,32(%rsp)
+	subq	$192,%rdx
+	movdqa	%xmm3,48(%rsp)
+
+.Loop_tail4x:
+	movzbl	(%rsi,%r9,1),%eax
+	movzbl	(%rsp,%r9,1),%ecx
+	leaq	1(%r9),%r9
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r9,1)
+	decq	%rdx
+	jnz	.Loop_tail4x
+
+.Ldone4x:
+	leaq	-8(%r10),%rsp
+
+.L4x_epilogue:
+	ret
+ENDPROC(chacha20_ssse3)
+#endif /* CONFIG_AS_SSSE3 */
+
+#ifdef CONFIG_AS_AVX2
+.align	32
+ENTRY(chacha20_avx2)
+.Lchacha20_avx2:
+	cmpq	$0,%rdx
+	je	.L8x_epilogue
+	leaq	8(%rsp),%r10
+
+	subq	$0x280+8,%rsp
+	andq	$-32,%rsp
+	vzeroupper
+
+	vbroadcasti128	.Lsigma(%rip),%ymm11
+	vbroadcasti128	(%rcx),%ymm3
+	vbroadcasti128	16(%rcx),%ymm15
+	vbroadcasti128	(%r8),%ymm7
+	leaq	256(%rsp),%rcx
+	leaq	512(%rsp),%rax
+	leaq	.Lrot16(%rip),%r9
+	leaq	.Lrot24(%rip),%r11
+
+	vpshufd	$0x00,%ymm11,%ymm8
+	vpshufd	$0x55,%ymm11,%ymm9
+	vmovdqa	%ymm8,128-256(%rcx)
+	vpshufd	$0xaa,%ymm11,%ymm10
+	vmovdqa	%ymm9,160-256(%rcx)
+	vpshufd	$0xff,%ymm11,%ymm11
+	vmovdqa	%ymm10,192-256(%rcx)
+	vmovdqa	%ymm11,224-256(%rcx)
+
+	vpshufd	$0x00,%ymm3,%ymm0
+	vpshufd	$0x55,%ymm3,%ymm1
+	vmovdqa	%ymm0,256-256(%rcx)
+	vpshufd	$0xaa,%ymm3,%ymm2
+	vmovdqa	%ymm1,288-256(%rcx)
+	vpshufd	$0xff,%ymm3,%ymm3
+	vmovdqa	%ymm2,320-256(%rcx)
+	vmovdqa	%ymm3,352-256(%rcx)
+
+	vpshufd	$0x00,%ymm15,%ymm12
+	vpshufd	$0x55,%ymm15,%ymm13
+	vmovdqa	%ymm12,384-512(%rax)
+	vpshufd	$0xaa,%ymm15,%ymm14
+	vmovdqa	%ymm13,416-512(%rax)
+	vpshufd	$0xff,%ymm15,%ymm15
+	vmovdqa	%ymm14,448-512(%rax)
+	vmovdqa	%ymm15,480-512(%rax)
+
+	vpshufd	$0x00,%ymm7,%ymm4
+	vpshufd	$0x55,%ymm7,%ymm5
+	vpaddd	.Lincy(%rip),%ymm4,%ymm4
+	vpshufd	$0xaa,%ymm7,%ymm6
+	vmovdqa	%ymm5,544-512(%rax)
+	vpshufd	$0xff,%ymm7,%ymm7
+	vmovdqa	%ymm6,576-512(%rax)
+	vmovdqa	%ymm7,608-512(%rax)
+
+	jmp	.Loop_enter8x
+
+.align	32
+.Loop_outer8x:
+	vmovdqa	128-256(%rcx),%ymm8
+	vmovdqa	160-256(%rcx),%ymm9
+	vmovdqa	192-256(%rcx),%ymm10
+	vmovdqa	224-256(%rcx),%ymm11
+	vmovdqa	256-256(%rcx),%ymm0
+	vmovdqa	288-256(%rcx),%ymm1
+	vmovdqa	320-256(%rcx),%ymm2
+	vmovdqa	352-256(%rcx),%ymm3
+	vmovdqa	384-512(%rax),%ymm12
+	vmovdqa	416-512(%rax),%ymm13
+	vmovdqa	448-512(%rax),%ymm14
+	vmovdqa	480-512(%rax),%ymm15
+	vmovdqa	512-512(%rax),%ymm4
+	vmovdqa	544-512(%rax),%ymm5
+	vmovdqa	576-512(%rax),%ymm6
+	vmovdqa	608-512(%rax),%ymm7
+	vpaddd	.Leight(%rip),%ymm4,%ymm4
+
+.Loop_enter8x:
+	vmovdqa	%ymm14,64(%rsp)
+	vmovdqa	%ymm15,96(%rsp)
+	vbroadcasti128	(%r9),%ymm15
+	vmovdqa	%ymm4,512-512(%rax)
+	movl	$10,%eax
+	jmp	.Loop8x
+
+.align	32
+.Loop8x:
+	vpaddd	%ymm0,%ymm8,%ymm8
+	vpxor	%ymm4,%ymm8,%ymm4
+	vpshufb	%ymm15,%ymm4,%ymm4
+	vpaddd	%ymm1,%ymm9,%ymm9
+	vpxor	%ymm5,%ymm9,%ymm5
+	vpshufb	%ymm15,%ymm5,%ymm5
+	vpaddd	%ymm4,%ymm12,%ymm12
+	vpxor	%ymm0,%ymm12,%ymm0
+	vpslld	$12,%ymm0,%ymm14
+	vpsrld	$20,%ymm0,%ymm0
+	vpor	%ymm0,%ymm14,%ymm0
+	vbroadcasti128	(%r11),%ymm14
+	vpaddd	%ymm5,%ymm13,%ymm13
+	vpxor	%ymm1,%ymm13,%ymm1
+	vpslld	$12,%ymm1,%ymm15
+	vpsrld	$20,%ymm1,%ymm1
+	vpor	%ymm1,%ymm15,%ymm1
+	vpaddd	%ymm0,%ymm8,%ymm8
+	vpxor	%ymm4,%ymm8,%ymm4
+	vpshufb	%ymm14,%ymm4,%ymm4
+	vpaddd	%ymm1,%ymm9,%ymm9
+	vpxor	%ymm5,%ymm9,%ymm5
+	vpshufb	%ymm14,%ymm5,%ymm5
+	vpaddd	%ymm4,%ymm12,%ymm12
+	vpxor	%ymm0,%ymm12,%ymm0
+	vpslld	$7,%ymm0,%ymm15
+	vpsrld	$25,%ymm0,%ymm0
+	vpor	%ymm0,%ymm15,%ymm0
+	vbroadcasti128	(%r9),%ymm15
+	vpaddd	%ymm5,%ymm13,%ymm13
+	vpxor	%ymm1,%ymm13,%ymm1
+	vpslld	$7,%ymm1,%ymm14
+	vpsrld	$25,%ymm1,%ymm1
+	vpor	%ymm1,%ymm14,%ymm1
+	vmovdqa	%ymm12,0(%rsp)
+	vmovdqa	%ymm13,32(%rsp)
+	vmovdqa	64(%rsp),%ymm12
+	vmovdqa	96(%rsp),%ymm13
+	vpaddd	%ymm2,%ymm10,%ymm10
+	vpxor	%ymm6,%ymm10,%ymm6
+	vpshufb	%ymm15,%ymm6,%ymm6
+	vpaddd	%ymm3,%ymm11,%ymm11
+	vpxor	%ymm7,%ymm11,%ymm7
+	vpshufb	%ymm15,%ymm7,%ymm7
+	vpaddd	%ymm6,%ymm12,%ymm12
+	vpxor	%ymm2,%ymm12,%ymm2
+	vpslld	$12,%ymm2,%ymm14
+	vpsrld	$20,%ymm2,%ymm2
+	vpor	%ymm2,%ymm14,%ymm2
+	vbroadcasti128	(%r11),%ymm14
+	vpaddd	%ymm7,%ymm13,%ymm13
+	vpxor	%ymm3,%ymm13,%ymm3
+	vpslld	$12,%ymm3,%ymm15
+	vpsrld	$20,%ymm3,%ymm3
+	vpor	%ymm3,%ymm15,%ymm3
+	vpaddd	%ymm2,%ymm10,%ymm10
+	vpxor	%ymm6,%ymm10,%ymm6
+	vpshufb	%ymm14,%ymm6,%ymm6
+	vpaddd	%ymm3,%ymm11,%ymm11
+	vpxor	%ymm7,%ymm11,%ymm7
+	vpshufb	%ymm14,%ymm7,%ymm7
+	vpaddd	%ymm6,%ymm12,%ymm12
+	vpxor	%ymm2,%ymm12,%ymm2
+	vpslld	$7,%ymm2,%ymm15
+	vpsrld	$25,%ymm2,%ymm2
+	vpor	%ymm2,%ymm15,%ymm2
+	vbroadcasti128	(%r9),%ymm15
+	vpaddd	%ymm7,%ymm13,%ymm13
+	vpxor	%ymm3,%ymm13,%ymm3
+	vpslld	$7,%ymm3,%ymm14
+	vpsrld	$25,%ymm3,%ymm3
+	vpor	%ymm3,%ymm14,%ymm3
+	vpaddd	%ymm1,%ymm8,%ymm8
+	vpxor	%ymm7,%ymm8,%ymm7
+	vpshufb	%ymm15,%ymm7,%ymm7
+	vpaddd	%ymm2,%ymm9,%ymm9
+	vpxor	%ymm4,%ymm9,%ymm4
+	vpshufb	%ymm15,%ymm4,%ymm4
+	vpaddd	%ymm7,%ymm12,%ymm12
+	vpxor	%ymm1,%ymm12,%ymm1
+	vpslld	$12,%ymm1,%ymm14
+	vpsrld	$20,%ymm1,%ymm1
+	vpor	%ymm1,%ymm14,%ymm1
+	vbroadcasti128	(%r11),%ymm14
+	vpaddd	%ymm4,%ymm13,%ymm13
+	vpxor	%ymm2,%ymm13,%ymm2
+	vpslld	$12,%ymm2,%ymm15
+	vpsrld	$20,%ymm2,%ymm2
+	vpor	%ymm2,%ymm15,%ymm2
+	vpaddd	%ymm1,%ymm8,%ymm8
+	vpxor	%ymm7,%ymm8,%ymm7
+	vpshufb	%ymm14,%ymm7,%ymm7
+	vpaddd	%ymm2,%ymm9,%ymm9
+	vpxor	%ymm4,%ymm9,%ymm4
+	vpshufb	%ymm14,%ymm4,%ymm4
+	vpaddd	%ymm7,%ymm12,%ymm12
+	vpxor	%ymm1,%ymm12,%ymm1
+	vpslld	$7,%ymm1,%ymm15
+	vpsrld	$25,%ymm1,%ymm1
+	vpor	%ymm1,%ymm15,%ymm1
+	vbroadcasti128	(%r9),%ymm15
+	vpaddd	%ymm4,%ymm13,%ymm13
+	vpxor	%ymm2,%ymm13,%ymm2
+	vpslld	$7,%ymm2,%ymm14
+	vpsrld	$25,%ymm2,%ymm2
+	vpor	%ymm2,%ymm14,%ymm2
+	vmovdqa	%ymm12,64(%rsp)
+	vmovdqa	%ymm13,96(%rsp)
+	vmovdqa	0(%rsp),%ymm12
+	vmovdqa	32(%rsp),%ymm13
+	vpaddd	%ymm3,%ymm10,%ymm10
+	vpxor	%ymm5,%ymm10,%ymm5
+	vpshufb	%ymm15,%ymm5,%ymm5
+	vpaddd	%ymm0,%ymm11,%ymm11
+	vpxor	%ymm6,%ymm11,%ymm6
+	vpshufb	%ymm15,%ymm6,%ymm6
+	vpaddd	%ymm5,%ymm12,%ymm12
+	vpxor	%ymm3,%ymm12,%ymm3
+	vpslld	$12,%ymm3,%ymm14
+	vpsrld	$20,%ymm3,%ymm3
+	vpor	%ymm3,%ymm14,%ymm3
+	vbroadcasti128	(%r11),%ymm14
+	vpaddd	%ymm6,%ymm13,%ymm13
+	vpxor	%ymm0,%ymm13,%ymm0
+	vpslld	$12,%ymm0,%ymm15
+	vpsrld	$20,%ymm0,%ymm0
+	vpor	%ymm0,%ymm15,%ymm0
+	vpaddd	%ymm3,%ymm10,%ymm10
+	vpxor	%ymm5,%ymm10,%ymm5
+	vpshufb	%ymm14,%ymm5,%ymm5
+	vpaddd	%ymm0,%ymm11,%ymm11
+	vpxor	%ymm6,%ymm11,%ymm6
+	vpshufb	%ymm14,%ymm6,%ymm6
+	vpaddd	%ymm5,%ymm12,%ymm12
+	vpxor	%ymm3,%ymm12,%ymm3
+	vpslld	$7,%ymm3,%ymm15
+	vpsrld	$25,%ymm3,%ymm3
+	vpor	%ymm3,%ymm15,%ymm3
+	vbroadcasti128	(%r9),%ymm15
+	vpaddd	%ymm6,%ymm13,%ymm13
+	vpxor	%ymm0,%ymm13,%ymm0
+	vpslld	$7,%ymm0,%ymm14
+	vpsrld	$25,%ymm0,%ymm0
+	vpor	%ymm0,%ymm14,%ymm0
+	decl	%eax
+	jnz	.Loop8x
+
+	leaq	512(%rsp),%rax
+	vpaddd	128-256(%rcx),%ymm8,%ymm8
+	vpaddd	160-256(%rcx),%ymm9,%ymm9
+	vpaddd	192-256(%rcx),%ymm10,%ymm10
+	vpaddd	224-256(%rcx),%ymm11,%ymm11
+
+	vpunpckldq	%ymm9,%ymm8,%ymm14
+	vpunpckldq	%ymm11,%ymm10,%ymm15
+	vpunpckhdq	%ymm9,%ymm8,%ymm8
+	vpunpckhdq	%ymm11,%ymm10,%ymm10
+	vpunpcklqdq	%ymm15,%ymm14,%ymm9
+	vpunpckhqdq	%ymm15,%ymm14,%ymm14
+	vpunpcklqdq	%ymm10,%ymm8,%ymm11
+	vpunpckhqdq	%ymm10,%ymm8,%ymm8
+	vpaddd	256-256(%rcx),%ymm0,%ymm0
+	vpaddd	288-256(%rcx),%ymm1,%ymm1
+	vpaddd	320-256(%rcx),%ymm2,%ymm2
+	vpaddd	352-256(%rcx),%ymm3,%ymm3
+
+	vpunpckldq	%ymm1,%ymm0,%ymm10
+	vpunpckldq	%ymm3,%ymm2,%ymm15
+	vpunpckhdq	%ymm1,%ymm0,%ymm0
+	vpunpckhdq	%ymm3,%ymm2,%ymm2
+	vpunpcklqdq	%ymm15,%ymm10,%ymm1
+	vpunpckhqdq	%ymm15,%ymm10,%ymm10
+	vpunpcklqdq	%ymm2,%ymm0,%ymm3
+	vpunpckhqdq	%ymm2,%ymm0,%ymm0
+	vperm2i128	$0x20,%ymm1,%ymm9,%ymm15
+	vperm2i128	$0x31,%ymm1,%ymm9,%ymm1
+	vperm2i128	$0x20,%ymm10,%ymm14,%ymm9
+	vperm2i128	$0x31,%ymm10,%ymm14,%ymm10
+	vperm2i128	$0x20,%ymm3,%ymm11,%ymm14
+	vperm2i128	$0x31,%ymm3,%ymm11,%ymm3
+	vperm2i128	$0x20,%ymm0,%ymm8,%ymm11
+	vperm2i128	$0x31,%ymm0,%ymm8,%ymm0
+	vmovdqa	%ymm15,0(%rsp)
+	vmovdqa	%ymm9,32(%rsp)
+	vmovdqa	64(%rsp),%ymm15
+	vmovdqa	96(%rsp),%ymm9
+
+	vpaddd	384-512(%rax),%ymm12,%ymm12
+	vpaddd	416-512(%rax),%ymm13,%ymm13
+	vpaddd	448-512(%rax),%ymm15,%ymm15
+	vpaddd	480-512(%rax),%ymm9,%ymm9
+
+	vpunpckldq	%ymm13,%ymm12,%ymm2
+	vpunpckldq	%ymm9,%ymm15,%ymm8
+	vpunpckhdq	%ymm13,%ymm12,%ymm12
+	vpunpckhdq	%ymm9,%ymm15,%ymm15
+	vpunpcklqdq	%ymm8,%ymm2,%ymm13
+	vpunpckhqdq	%ymm8,%ymm2,%ymm2
+	vpunpcklqdq	%ymm15,%ymm12,%ymm9
+	vpunpckhqdq	%ymm15,%ymm12,%ymm12
+	vpaddd	512-512(%rax),%ymm4,%ymm4
+	vpaddd	544-512(%rax),%ymm5,%ymm5
+	vpaddd	576-512(%rax),%ymm6,%ymm6
+	vpaddd	608-512(%rax),%ymm7,%ymm7
+
+	vpunpckldq	%ymm5,%ymm4,%ymm15
+	vpunpckldq	%ymm7,%ymm6,%ymm8
+	vpunpckhdq	%ymm5,%ymm4,%ymm4
+	vpunpckhdq	%ymm7,%ymm6,%ymm6
+	vpunpcklqdq	%ymm8,%ymm15,%ymm5
+	vpunpckhqdq	%ymm8,%ymm15,%ymm15
+	vpunpcklqdq	%ymm6,%ymm4,%ymm7
+	vpunpckhqdq	%ymm6,%ymm4,%ymm4
+	vperm2i128	$0x20,%ymm5,%ymm13,%ymm8
+	vperm2i128	$0x31,%ymm5,%ymm13,%ymm5
+	vperm2i128	$0x20,%ymm15,%ymm2,%ymm13
+	vperm2i128	$0x31,%ymm15,%ymm2,%ymm15
+	vperm2i128	$0x20,%ymm7,%ymm9,%ymm2
+	vperm2i128	$0x31,%ymm7,%ymm9,%ymm7
+	vperm2i128	$0x20,%ymm4,%ymm12,%ymm9
+	vperm2i128	$0x31,%ymm4,%ymm12,%ymm4
+	vmovdqa	0(%rsp),%ymm6
+	vmovdqa	32(%rsp),%ymm12
+
+	cmpq	$512,%rdx
+	jb	.Ltail8x
+
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	leaq	128(%rsi),%rsi
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	leaq	128(%rdi),%rdi
+
+	vpxor	0(%rsi),%ymm12,%ymm12
+	vpxor	32(%rsi),%ymm13,%ymm13
+	vpxor	64(%rsi),%ymm10,%ymm10
+	vpxor	96(%rsi),%ymm15,%ymm15
+	leaq	128(%rsi),%rsi
+	vmovdqu	%ymm12,0(%rdi)
+	vmovdqu	%ymm13,32(%rdi)
+	vmovdqu	%ymm10,64(%rdi)
+	vmovdqu	%ymm15,96(%rdi)
+	leaq	128(%rdi),%rdi
+
+	vpxor	0(%rsi),%ymm14,%ymm14
+	vpxor	32(%rsi),%ymm2,%ymm2
+	vpxor	64(%rsi),%ymm3,%ymm3
+	vpxor	96(%rsi),%ymm7,%ymm7
+	leaq	128(%rsi),%rsi
+	vmovdqu	%ymm14,0(%rdi)
+	vmovdqu	%ymm2,32(%rdi)
+	vmovdqu	%ymm3,64(%rdi)
+	vmovdqu	%ymm7,96(%rdi)
+	leaq	128(%rdi),%rdi
+
+	vpxor	0(%rsi),%ymm11,%ymm11
+	vpxor	32(%rsi),%ymm9,%ymm9
+	vpxor	64(%rsi),%ymm0,%ymm0
+	vpxor	96(%rsi),%ymm4,%ymm4
+	leaq	128(%rsi),%rsi
+	vmovdqu	%ymm11,0(%rdi)
+	vmovdqu	%ymm9,32(%rdi)
+	vmovdqu	%ymm0,64(%rdi)
+	vmovdqu	%ymm4,96(%rdi)
+	leaq	128(%rdi),%rdi
+
+	subq	$512,%rdx
+	jnz	.Loop_outer8x
+
+	jmp	.Ldone8x
+
+.Ltail8x:
+	cmpq	$448,%rdx
+	jae	.L448_or_more8x
+	cmpq	$384,%rdx
+	jae	.L384_or_more8x
+	cmpq	$320,%rdx
+	jae	.L320_or_more8x
+	cmpq	$256,%rdx
+	jae	.L256_or_more8x
+	cmpq	$192,%rdx
+	jae	.L192_or_more8x
+	cmpq	$128,%rdx
+	jae	.L128_or_more8x
+	cmpq	$64,%rdx
+	jae	.L64_or_more8x
+
+	xorq	%r9,%r9
+	vmovdqa	%ymm6,0(%rsp)
+	vmovdqa	%ymm8,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L64_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	je	.Ldone8x
+
+	leaq	64(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm1,0(%rsp)
+	leaq	64(%rdi),%rdi
+	subq	$64,%rdx
+	vmovdqa	%ymm5,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L128_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	je	.Ldone8x
+
+	leaq	128(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm12,0(%rsp)
+	leaq	128(%rdi),%rdi
+	subq	$128,%rdx
+	vmovdqa	%ymm13,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L192_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vpxor	128(%rsi),%ymm12,%ymm12
+	vpxor	160(%rsi),%ymm13,%ymm13
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	vmovdqu	%ymm12,128(%rdi)
+	vmovdqu	%ymm13,160(%rdi)
+	je	.Ldone8x
+
+	leaq	192(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm10,0(%rsp)
+	leaq	192(%rdi),%rdi
+	subq	$192,%rdx
+	vmovdqa	%ymm15,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L256_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vpxor	128(%rsi),%ymm12,%ymm12
+	vpxor	160(%rsi),%ymm13,%ymm13
+	vpxor	192(%rsi),%ymm10,%ymm10
+	vpxor	224(%rsi),%ymm15,%ymm15
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	vmovdqu	%ymm12,128(%rdi)
+	vmovdqu	%ymm13,160(%rdi)
+	vmovdqu	%ymm10,192(%rdi)
+	vmovdqu	%ymm15,224(%rdi)
+	je	.Ldone8x
+
+	leaq	256(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm14,0(%rsp)
+	leaq	256(%rdi),%rdi
+	subq	$256,%rdx
+	vmovdqa	%ymm2,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L320_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vpxor	128(%rsi),%ymm12,%ymm12
+	vpxor	160(%rsi),%ymm13,%ymm13
+	vpxor	192(%rsi),%ymm10,%ymm10
+	vpxor	224(%rsi),%ymm15,%ymm15
+	vpxor	256(%rsi),%ymm14,%ymm14
+	vpxor	288(%rsi),%ymm2,%ymm2
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	vmovdqu	%ymm12,128(%rdi)
+	vmovdqu	%ymm13,160(%rdi)
+	vmovdqu	%ymm10,192(%rdi)
+	vmovdqu	%ymm15,224(%rdi)
+	vmovdqu	%ymm14,256(%rdi)
+	vmovdqu	%ymm2,288(%rdi)
+	je	.Ldone8x
+
+	leaq	320(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm3,0(%rsp)
+	leaq	320(%rdi),%rdi
+	subq	$320,%rdx
+	vmovdqa	%ymm7,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L384_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vpxor	128(%rsi),%ymm12,%ymm12
+	vpxor	160(%rsi),%ymm13,%ymm13
+	vpxor	192(%rsi),%ymm10,%ymm10
+	vpxor	224(%rsi),%ymm15,%ymm15
+	vpxor	256(%rsi),%ymm14,%ymm14
+	vpxor	288(%rsi),%ymm2,%ymm2
+	vpxor	320(%rsi),%ymm3,%ymm3
+	vpxor	352(%rsi),%ymm7,%ymm7
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	vmovdqu	%ymm12,128(%rdi)
+	vmovdqu	%ymm13,160(%rdi)
+	vmovdqu	%ymm10,192(%rdi)
+	vmovdqu	%ymm15,224(%rdi)
+	vmovdqu	%ymm14,256(%rdi)
+	vmovdqu	%ymm2,288(%rdi)
+	vmovdqu	%ymm3,320(%rdi)
+	vmovdqu	%ymm7,352(%rdi)
+	je	.Ldone8x
+
+	leaq	384(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm11,0(%rsp)
+	leaq	384(%rdi),%rdi
+	subq	$384,%rdx
+	vmovdqa	%ymm9,32(%rsp)
+	jmp	.Loop_tail8x
+
+.align	32
+.L448_or_more8x:
+	vpxor	0(%rsi),%ymm6,%ymm6
+	vpxor	32(%rsi),%ymm8,%ymm8
+	vpxor	64(%rsi),%ymm1,%ymm1
+	vpxor	96(%rsi),%ymm5,%ymm5
+	vpxor	128(%rsi),%ymm12,%ymm12
+	vpxor	160(%rsi),%ymm13,%ymm13
+	vpxor	192(%rsi),%ymm10,%ymm10
+	vpxor	224(%rsi),%ymm15,%ymm15
+	vpxor	256(%rsi),%ymm14,%ymm14
+	vpxor	288(%rsi),%ymm2,%ymm2
+	vpxor	320(%rsi),%ymm3,%ymm3
+	vpxor	352(%rsi),%ymm7,%ymm7
+	vpxor	384(%rsi),%ymm11,%ymm11
+	vpxor	416(%rsi),%ymm9,%ymm9
+	vmovdqu	%ymm6,0(%rdi)
+	vmovdqu	%ymm8,32(%rdi)
+	vmovdqu	%ymm1,64(%rdi)
+	vmovdqu	%ymm5,96(%rdi)
+	vmovdqu	%ymm12,128(%rdi)
+	vmovdqu	%ymm13,160(%rdi)
+	vmovdqu	%ymm10,192(%rdi)
+	vmovdqu	%ymm15,224(%rdi)
+	vmovdqu	%ymm14,256(%rdi)
+	vmovdqu	%ymm2,288(%rdi)
+	vmovdqu	%ymm3,320(%rdi)
+	vmovdqu	%ymm7,352(%rdi)
+	vmovdqu	%ymm11,384(%rdi)
+	vmovdqu	%ymm9,416(%rdi)
+	je	.Ldone8x
+
+	leaq	448(%rsi),%rsi
+	xorq	%r9,%r9
+	vmovdqa	%ymm0,0(%rsp)
+	leaq	448(%rdi),%rdi
+	subq	$448,%rdx
+	vmovdqa	%ymm4,32(%rsp)
+
+.Loop_tail8x:
+	movzbl	(%rsi,%r9,1),%eax
+	movzbl	(%rsp,%r9,1),%ecx
+	leaq	1(%r9),%r9
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r9,1)
+	decq	%rdx
+	jnz	.Loop_tail8x
+
+.Ldone8x:
+	vzeroall
+	leaq	-8(%r10),%rsp
+
+.L8x_epilogue:
+	ret
+ENDPROC(chacha20_avx2)
+#endif /* CONFIG_AS_AVX2 */
+
+#ifdef CONFIG_AS_AVX512
+.align	32
+ENTRY(chacha20_avx512)
+.Lchacha20_avx512:
+	cmpq	$0,%rdx
+	je	.Lavx512_epilogue
+	leaq	8(%rsp),%r10
+
+	cmpq	$512,%rdx
+	ja	.Lchacha20_16x
+
+	subq	$64+8,%rsp
+	andq	$-64,%rsp
+	vbroadcasti32x4	.Lsigma(%rip),%zmm0
+	vbroadcasti32x4	(%rcx),%zmm1
+	vbroadcasti32x4	16(%rcx),%zmm2
+	vbroadcasti32x4	(%r8),%zmm3
+
+	vmovdqa32	%zmm0,%zmm16
+	vmovdqa32	%zmm1,%zmm17
+	vmovdqa32	%zmm2,%zmm18
+	vpaddd	.Lzeroz(%rip),%zmm3,%zmm3
+	vmovdqa32	.Lfourz(%rip),%zmm20
+	movq	$10,%r8
+	vmovdqa32	%zmm3,%zmm19
+	jmp	.Loop_avx512
+
+.align	16
+.Loop_outer_avx512:
+	vmovdqa32	%zmm16,%zmm0
+	vmovdqa32	%zmm17,%zmm1
+	vmovdqa32	%zmm18,%zmm2
+	vpaddd	%zmm20,%zmm19,%zmm3
+	movq	$10,%r8
+	vmovdqa32	%zmm3,%zmm19
+	jmp	.Loop_avx512
+
+.align	32
+.Loop_avx512:
+	vpaddd	%zmm1,%zmm0,%zmm0
+	vpxord	%zmm0,%zmm3,%zmm3
+	vprold	$16,%zmm3,%zmm3
+	vpaddd	%zmm3,%zmm2,%zmm2
+	vpxord	%zmm2,%zmm1,%zmm1
+	vprold	$12,%zmm1,%zmm1
+	vpaddd	%zmm1,%zmm0,%zmm0
+	vpxord	%zmm0,%zmm3,%zmm3
+	vprold	$8,%zmm3,%zmm3
+	vpaddd	%zmm3,%zmm2,%zmm2
+	vpxord	%zmm2,%zmm1,%zmm1
+	vprold	$7,%zmm1,%zmm1
+	vpshufd	$78,%zmm2,%zmm2
+	vpshufd	$57,%zmm1,%zmm1
+	vpshufd	$147,%zmm3,%zmm3
+	vpaddd	%zmm1,%zmm0,%zmm0
+	vpxord	%zmm0,%zmm3,%zmm3
+	vprold	$16,%zmm3,%zmm3
+	vpaddd	%zmm3,%zmm2,%zmm2
+	vpxord	%zmm2,%zmm1,%zmm1
+	vprold	$12,%zmm1,%zmm1
+	vpaddd	%zmm1,%zmm0,%zmm0
+	vpxord	%zmm0,%zmm3,%zmm3
+	vprold	$8,%zmm3,%zmm3
+	vpaddd	%zmm3,%zmm2,%zmm2
+	vpxord	%zmm2,%zmm1,%zmm1
+	vprold	$7,%zmm1,%zmm1
+	vpshufd	$78,%zmm2,%zmm2
+	vpshufd	$147,%zmm1,%zmm1
+	vpshufd	$57,%zmm3,%zmm3
+	decq	%r8
+	jnz	.Loop_avx512
+	vpaddd	%zmm16,%zmm0,%zmm0
+	vpaddd	%zmm17,%zmm1,%zmm1
+	vpaddd	%zmm18,%zmm2,%zmm2
+	vpaddd	%zmm19,%zmm3,%zmm3
+
+	subq	$64,%rdx
+	jb	.Ltail64_avx512
+
+	vpxor	0(%rsi),%xmm0,%xmm4
+	vpxor	16(%rsi),%xmm1,%xmm5
+	vpxor	32(%rsi),%xmm2,%xmm6
+	vpxor	48(%rsi),%xmm3,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	jz	.Ldone_avx512
+
+	vextracti32x4	$1,%zmm0,%xmm4
+	vextracti32x4	$1,%zmm1,%xmm5
+	vextracti32x4	$1,%zmm2,%xmm6
+	vextracti32x4	$1,%zmm3,%xmm7
+
+	subq	$64,%rdx
+	jb	.Ltail_avx512
+
+	vpxor	0(%rsi),%xmm4,%xmm4
+	vpxor	16(%rsi),%xmm5,%xmm5
+	vpxor	32(%rsi),%xmm6,%xmm6
+	vpxor	48(%rsi),%xmm7,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	jz	.Ldone_avx512
+
+	vextracti32x4	$2,%zmm0,%xmm4
+	vextracti32x4	$2,%zmm1,%xmm5
+	vextracti32x4	$2,%zmm2,%xmm6
+	vextracti32x4	$2,%zmm3,%xmm7
+
+	subq	$64,%rdx
+	jb	.Ltail_avx512
+
+	vpxor	0(%rsi),%xmm4,%xmm4
+	vpxor	16(%rsi),%xmm5,%xmm5
+	vpxor	32(%rsi),%xmm6,%xmm6
+	vpxor	48(%rsi),%xmm7,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	jz	.Ldone_avx512
+
+	vextracti32x4	$3,%zmm0,%xmm4
+	vextracti32x4	$3,%zmm1,%xmm5
+	vextracti32x4	$3,%zmm2,%xmm6
+	vextracti32x4	$3,%zmm3,%xmm7
+
+	subq	$64,%rdx
+	jb	.Ltail_avx512
+
+	vpxor	0(%rsi),%xmm4,%xmm4
+	vpxor	16(%rsi),%xmm5,%xmm5
+	vpxor	32(%rsi),%xmm6,%xmm6
+	vpxor	48(%rsi),%xmm7,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	jnz	.Loop_outer_avx512
+
+	jmp	.Ldone_avx512
+
+.align	16
+.Ltail64_avx512:
+	vmovdqa	%xmm0,0(%rsp)
+	vmovdqa	%xmm1,16(%rsp)
+	vmovdqa	%xmm2,32(%rsp)
+	vmovdqa	%xmm3,48(%rsp)
+	addq	$64,%rdx
+	jmp	.Loop_tail_avx512
+
+.align	16
+.Ltail_avx512:
+	vmovdqa	%xmm4,0(%rsp)
+	vmovdqa	%xmm5,16(%rsp)
+	vmovdqa	%xmm6,32(%rsp)
+	vmovdqa	%xmm7,48(%rsp)
+	addq	$64,%rdx
+
+.Loop_tail_avx512:
+	movzbl	(%rsi,%r8,1),%eax
+	movzbl	(%rsp,%r8,1),%ecx
+	leaq	1(%r8),%r8
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r8,1)
+	decq	%rdx
+	jnz	.Loop_tail_avx512
+
+	vmovdqa32	%zmm16,0(%rsp)
+
+.Ldone_avx512:
+	vzeroall
+	leaq	-8(%r10),%rsp
+
+.Lavx512_epilogue:
+	ret
+
+.align	32
+.Lchacha20_16x:
+	leaq	8(%rsp),%r10
+
+	subq	$64+8,%rsp
+	andq	$-64,%rsp
+	vzeroupper
+
+	leaq	.Lsigma(%rip),%r9
+	vbroadcasti32x4	(%r9),%zmm3
+	vbroadcasti32x4	(%rcx),%zmm7
+	vbroadcasti32x4	16(%rcx),%zmm11
+	vbroadcasti32x4	(%r8),%zmm15
+
+	vpshufd	$0x00,%zmm3,%zmm0
+	vpshufd	$0x55,%zmm3,%zmm1
+	vpshufd	$0xaa,%zmm3,%zmm2
+	vpshufd	$0xff,%zmm3,%zmm3
+	vmovdqa64	%zmm0,%zmm16
+	vmovdqa64	%zmm1,%zmm17
+	vmovdqa64	%zmm2,%zmm18
+	vmovdqa64	%zmm3,%zmm19
+
+	vpshufd	$0x00,%zmm7,%zmm4
+	vpshufd	$0x55,%zmm7,%zmm5
+	vpshufd	$0xaa,%zmm7,%zmm6
+	vpshufd	$0xff,%zmm7,%zmm7
+	vmovdqa64	%zmm4,%zmm20
+	vmovdqa64	%zmm5,%zmm21
+	vmovdqa64	%zmm6,%zmm22
+	vmovdqa64	%zmm7,%zmm23
+
+	vpshufd	$0x00,%zmm11,%zmm8
+	vpshufd	$0x55,%zmm11,%zmm9
+	vpshufd	$0xaa,%zmm11,%zmm10
+	vpshufd	$0xff,%zmm11,%zmm11
+	vmovdqa64	%zmm8,%zmm24
+	vmovdqa64	%zmm9,%zmm25
+	vmovdqa64	%zmm10,%zmm26
+	vmovdqa64	%zmm11,%zmm27
+
+	vpshufd	$0x00,%zmm15,%zmm12
+	vpshufd	$0x55,%zmm15,%zmm13
+	vpshufd	$0xaa,%zmm15,%zmm14
+	vpshufd	$0xff,%zmm15,%zmm15
+	vpaddd	.Lincz(%rip),%zmm12,%zmm12
+	vmovdqa64	%zmm12,%zmm28
+	vmovdqa64	%zmm13,%zmm29
+	vmovdqa64	%zmm14,%zmm30
+	vmovdqa64	%zmm15,%zmm31
+
+	movl	$10,%eax
+	jmp	.Loop16x
+
+.align	32
+.Loop_outer16x:
+	vpbroadcastd	0(%r9),%zmm0
+	vpbroadcastd	4(%r9),%zmm1
+	vpbroadcastd	8(%r9),%zmm2
+	vpbroadcastd	12(%r9),%zmm3
+	vpaddd	.Lsixteen(%rip),%zmm28,%zmm28
+	vmovdqa64	%zmm20,%zmm4
+	vmovdqa64	%zmm21,%zmm5
+	vmovdqa64	%zmm22,%zmm6
+	vmovdqa64	%zmm23,%zmm7
+	vmovdqa64	%zmm24,%zmm8
+	vmovdqa64	%zmm25,%zmm9
+	vmovdqa64	%zmm26,%zmm10
+	vmovdqa64	%zmm27,%zmm11
+	vmovdqa64	%zmm28,%zmm12
+	vmovdqa64	%zmm29,%zmm13
+	vmovdqa64	%zmm30,%zmm14
+	vmovdqa64	%zmm31,%zmm15
+
+	vmovdqa64	%zmm0,%zmm16
+	vmovdqa64	%zmm1,%zmm17
+	vmovdqa64	%zmm2,%zmm18
+	vmovdqa64	%zmm3,%zmm19
+
+	movl	$10,%eax
+	jmp	.Loop16x
+
+.align	32
+.Loop16x:
+	vpaddd	%zmm4,%zmm0,%zmm0
+	vpaddd	%zmm5,%zmm1,%zmm1
+	vpaddd	%zmm6,%zmm2,%zmm2
+	vpaddd	%zmm7,%zmm3,%zmm3
+	vpxord	%zmm0,%zmm12,%zmm12
+	vpxord	%zmm1,%zmm13,%zmm13
+	vpxord	%zmm2,%zmm14,%zmm14
+	vpxord	%zmm3,%zmm15,%zmm15
+	vprold	$16,%zmm12,%zmm12
+	vprold	$16,%zmm13,%zmm13
+	vprold	$16,%zmm14,%zmm14
+	vprold	$16,%zmm15,%zmm15
+	vpaddd	%zmm12,%zmm8,%zmm8
+	vpaddd	%zmm13,%zmm9,%zmm9
+	vpaddd	%zmm14,%zmm10,%zmm10
+	vpaddd	%zmm15,%zmm11,%zmm11
+	vpxord	%zmm8,%zmm4,%zmm4
+	vpxord	%zmm9,%zmm5,%zmm5
+	vpxord	%zmm10,%zmm6,%zmm6
+	vpxord	%zmm11,%zmm7,%zmm7
+	vprold	$12,%zmm4,%zmm4
+	vprold	$12,%zmm5,%zmm5
+	vprold	$12,%zmm6,%zmm6
+	vprold	$12,%zmm7,%zmm7
+	vpaddd	%zmm4,%zmm0,%zmm0
+	vpaddd	%zmm5,%zmm1,%zmm1
+	vpaddd	%zmm6,%zmm2,%zmm2
+	vpaddd	%zmm7,%zmm3,%zmm3
+	vpxord	%zmm0,%zmm12,%zmm12
+	vpxord	%zmm1,%zmm13,%zmm13
+	vpxord	%zmm2,%zmm14,%zmm14
+	vpxord	%zmm3,%zmm15,%zmm15
+	vprold	$8,%zmm12,%zmm12
+	vprold	$8,%zmm13,%zmm13
+	vprold	$8,%zmm14,%zmm14
+	vprold	$8,%zmm15,%zmm15
+	vpaddd	%zmm12,%zmm8,%zmm8
+	vpaddd	%zmm13,%zmm9,%zmm9
+	vpaddd	%zmm14,%zmm10,%zmm10
+	vpaddd	%zmm15,%zmm11,%zmm11
+	vpxord	%zmm8,%zmm4,%zmm4
+	vpxord	%zmm9,%zmm5,%zmm5
+	vpxord	%zmm10,%zmm6,%zmm6
+	vpxord	%zmm11,%zmm7,%zmm7
+	vprold	$7,%zmm4,%zmm4
+	vprold	$7,%zmm5,%zmm5
+	vprold	$7,%zmm6,%zmm6
+	vprold	$7,%zmm7,%zmm7
+	vpaddd	%zmm5,%zmm0,%zmm0
+	vpaddd	%zmm6,%zmm1,%zmm1
+	vpaddd	%zmm7,%zmm2,%zmm2
+	vpaddd	%zmm4,%zmm3,%zmm3
+	vpxord	%zmm0,%zmm15,%zmm15
+	vpxord	%zmm1,%zmm12,%zmm12
+	vpxord	%zmm2,%zmm13,%zmm13
+	vpxord	%zmm3,%zmm14,%zmm14
+	vprold	$16,%zmm15,%zmm15
+	vprold	$16,%zmm12,%zmm12
+	vprold	$16,%zmm13,%zmm13
+	vprold	$16,%zmm14,%zmm14
+	vpaddd	%zmm15,%zmm10,%zmm10
+	vpaddd	%zmm12,%zmm11,%zmm11
+	vpaddd	%zmm13,%zmm8,%zmm8
+	vpaddd	%zmm14,%zmm9,%zmm9
+	vpxord	%zmm10,%zmm5,%zmm5
+	vpxord	%zmm11,%zmm6,%zmm6
+	vpxord	%zmm8,%zmm7,%zmm7
+	vpxord	%zmm9,%zmm4,%zmm4
+	vprold	$12,%zmm5,%zmm5
+	vprold	$12,%zmm6,%zmm6
+	vprold	$12,%zmm7,%zmm7
+	vprold	$12,%zmm4,%zmm4
+	vpaddd	%zmm5,%zmm0,%zmm0
+	vpaddd	%zmm6,%zmm1,%zmm1
+	vpaddd	%zmm7,%zmm2,%zmm2
+	vpaddd	%zmm4,%zmm3,%zmm3
+	vpxord	%zmm0,%zmm15,%zmm15
+	vpxord	%zmm1,%zmm12,%zmm12
+	vpxord	%zmm2,%zmm13,%zmm13
+	vpxord	%zmm3,%zmm14,%zmm14
+	vprold	$8,%zmm15,%zmm15
+	vprold	$8,%zmm12,%zmm12
+	vprold	$8,%zmm13,%zmm13
+	vprold	$8,%zmm14,%zmm14
+	vpaddd	%zmm15,%zmm10,%zmm10
+	vpaddd	%zmm12,%zmm11,%zmm11
+	vpaddd	%zmm13,%zmm8,%zmm8
+	vpaddd	%zmm14,%zmm9,%zmm9
+	vpxord	%zmm10,%zmm5,%zmm5
+	vpxord	%zmm11,%zmm6,%zmm6
+	vpxord	%zmm8,%zmm7,%zmm7
+	vpxord	%zmm9,%zmm4,%zmm4
+	vprold	$7,%zmm5,%zmm5
+	vprold	$7,%zmm6,%zmm6
+	vprold	$7,%zmm7,%zmm7
+	vprold	$7,%zmm4,%zmm4
+	decl	%eax
+	jnz	.Loop16x
+
+	vpaddd	%zmm16,%zmm0,%zmm0
+	vpaddd	%zmm17,%zmm1,%zmm1
+	vpaddd	%zmm18,%zmm2,%zmm2
+	vpaddd	%zmm19,%zmm3,%zmm3
+
+	vpunpckldq	%zmm1,%zmm0,%zmm18
+	vpunpckldq	%zmm3,%zmm2,%zmm19
+	vpunpckhdq	%zmm1,%zmm0,%zmm0
+	vpunpckhdq	%zmm3,%zmm2,%zmm2
+	vpunpcklqdq	%zmm19,%zmm18,%zmm1
+	vpunpckhqdq	%zmm19,%zmm18,%zmm18
+	vpunpcklqdq	%zmm2,%zmm0,%zmm3
+	vpunpckhqdq	%zmm2,%zmm0,%zmm0
+	vpaddd	%zmm20,%zmm4,%zmm4
+	vpaddd	%zmm21,%zmm5,%zmm5
+	vpaddd	%zmm22,%zmm6,%zmm6
+	vpaddd	%zmm23,%zmm7,%zmm7
+
+	vpunpckldq	%zmm5,%zmm4,%zmm2
+	vpunpckldq	%zmm7,%zmm6,%zmm19
+	vpunpckhdq	%zmm5,%zmm4,%zmm4
+	vpunpckhdq	%zmm7,%zmm6,%zmm6
+	vpunpcklqdq	%zmm19,%zmm2,%zmm5
+	vpunpckhqdq	%zmm19,%zmm2,%zmm2
+	vpunpcklqdq	%zmm6,%zmm4,%zmm7
+	vpunpckhqdq	%zmm6,%zmm4,%zmm4
+	vshufi32x4	$0x44,%zmm5,%zmm1,%zmm19
+	vshufi32x4	$0xee,%zmm5,%zmm1,%zmm5
+	vshufi32x4	$0x44,%zmm2,%zmm18,%zmm1
+	vshufi32x4	$0xee,%zmm2,%zmm18,%zmm2
+	vshufi32x4	$0x44,%zmm7,%zmm3,%zmm18
+	vshufi32x4	$0xee,%zmm7,%zmm3,%zmm7
+	vshufi32x4	$0x44,%zmm4,%zmm0,%zmm3
+	vshufi32x4	$0xee,%zmm4,%zmm0,%zmm4
+	vpaddd	%zmm24,%zmm8,%zmm8
+	vpaddd	%zmm25,%zmm9,%zmm9
+	vpaddd	%zmm26,%zmm10,%zmm10
+	vpaddd	%zmm27,%zmm11,%zmm11
+
+	vpunpckldq	%zmm9,%zmm8,%zmm6
+	vpunpckldq	%zmm11,%zmm10,%zmm0
+	vpunpckhdq	%zmm9,%zmm8,%zmm8
+	vpunpckhdq	%zmm11,%zmm10,%zmm10
+	vpunpcklqdq	%zmm0,%zmm6,%zmm9
+	vpunpckhqdq	%zmm0,%zmm6,%zmm6
+	vpunpcklqdq	%zmm10,%zmm8,%zmm11
+	vpunpckhqdq	%zmm10,%zmm8,%zmm8
+	vpaddd	%zmm28,%zmm12,%zmm12
+	vpaddd	%zmm29,%zmm13,%zmm13
+	vpaddd	%zmm30,%zmm14,%zmm14
+	vpaddd	%zmm31,%zmm15,%zmm15
+
+	vpunpckldq	%zmm13,%zmm12,%zmm10
+	vpunpckldq	%zmm15,%zmm14,%zmm0
+	vpunpckhdq	%zmm13,%zmm12,%zmm12
+	vpunpckhdq	%zmm15,%zmm14,%zmm14
+	vpunpcklqdq	%zmm0,%zmm10,%zmm13
+	vpunpckhqdq	%zmm0,%zmm10,%zmm10
+	vpunpcklqdq	%zmm14,%zmm12,%zmm15
+	vpunpckhqdq	%zmm14,%zmm12,%zmm12
+	vshufi32x4	$0x44,%zmm13,%zmm9,%zmm0
+	vshufi32x4	$0xee,%zmm13,%zmm9,%zmm13
+	vshufi32x4	$0x44,%zmm10,%zmm6,%zmm9
+	vshufi32x4	$0xee,%zmm10,%zmm6,%zmm10
+	vshufi32x4	$0x44,%zmm15,%zmm11,%zmm6
+	vshufi32x4	$0xee,%zmm15,%zmm11,%zmm15
+	vshufi32x4	$0x44,%zmm12,%zmm8,%zmm11
+	vshufi32x4	$0xee,%zmm12,%zmm8,%zmm12
+	vshufi32x4	$0x88,%zmm0,%zmm19,%zmm16
+	vshufi32x4	$0xdd,%zmm0,%zmm19,%zmm19
+	vshufi32x4	$0x88,%zmm13,%zmm5,%zmm0
+	vshufi32x4	$0xdd,%zmm13,%zmm5,%zmm13
+	vshufi32x4	$0x88,%zmm9,%zmm1,%zmm17
+	vshufi32x4	$0xdd,%zmm9,%zmm1,%zmm1
+	vshufi32x4	$0x88,%zmm10,%zmm2,%zmm9
+	vshufi32x4	$0xdd,%zmm10,%zmm2,%zmm10
+	vshufi32x4	$0x88,%zmm6,%zmm18,%zmm14
+	vshufi32x4	$0xdd,%zmm6,%zmm18,%zmm18
+	vshufi32x4	$0x88,%zmm15,%zmm7,%zmm6
+	vshufi32x4	$0xdd,%zmm15,%zmm7,%zmm15
+	vshufi32x4	$0x88,%zmm11,%zmm3,%zmm8
+	vshufi32x4	$0xdd,%zmm11,%zmm3,%zmm3
+	vshufi32x4	$0x88,%zmm12,%zmm4,%zmm11
+	vshufi32x4	$0xdd,%zmm12,%zmm4,%zmm12
+	cmpq	$1024,%rdx
+	jb	.Ltail16x
+
+	vpxord	0(%rsi),%zmm16,%zmm16
+	vpxord	64(%rsi),%zmm17,%zmm17
+	vpxord	128(%rsi),%zmm14,%zmm14
+	vpxord	192(%rsi),%zmm8,%zmm8
+	vmovdqu32	%zmm16,0(%rdi)
+	vmovdqu32	%zmm17,64(%rdi)
+	vmovdqu32	%zmm14,128(%rdi)
+	vmovdqu32	%zmm8,192(%rdi)
+
+	vpxord	256(%rsi),%zmm19,%zmm19
+	vpxord	320(%rsi),%zmm1,%zmm1
+	vpxord	384(%rsi),%zmm18,%zmm18
+	vpxord	448(%rsi),%zmm3,%zmm3
+	vmovdqu32	%zmm19,256(%rdi)
+	vmovdqu32	%zmm1,320(%rdi)
+	vmovdqu32	%zmm18,384(%rdi)
+	vmovdqu32	%zmm3,448(%rdi)
+
+	vpxord	512(%rsi),%zmm0,%zmm0
+	vpxord	576(%rsi),%zmm9,%zmm9
+	vpxord	640(%rsi),%zmm6,%zmm6
+	vpxord	704(%rsi),%zmm11,%zmm11
+	vmovdqu32	%zmm0,512(%rdi)
+	vmovdqu32	%zmm9,576(%rdi)
+	vmovdqu32	%zmm6,640(%rdi)
+	vmovdqu32	%zmm11,704(%rdi)
+
+	vpxord	768(%rsi),%zmm13,%zmm13
+	vpxord	832(%rsi),%zmm10,%zmm10
+	vpxord	896(%rsi),%zmm15,%zmm15
+	vpxord	960(%rsi),%zmm12,%zmm12
+	leaq	1024(%rsi),%rsi
+	vmovdqu32	%zmm13,768(%rdi)
+	vmovdqu32	%zmm10,832(%rdi)
+	vmovdqu32	%zmm15,896(%rdi)
+	vmovdqu32	%zmm12,960(%rdi)
+	leaq	1024(%rdi),%rdi
+
+	subq	$1024,%rdx
+	jnz	.Loop_outer16x
+
+	jmp	.Ldone16x
+
+.align	32
+.Ltail16x:
+	xorq	%r9,%r9
+	subq	%rsi,%rdi
+	cmpq	$64,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm16,%zmm16
+	vmovdqu32	%zmm16,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm17,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$128,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm17,%zmm17
+	vmovdqu32	%zmm17,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm14,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$192,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm14,%zmm14
+	vmovdqu32	%zmm14,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm8,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$256,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm8,%zmm8
+	vmovdqu32	%zmm8,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm19,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$320,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm19,%zmm19
+	vmovdqu32	%zmm19,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm1,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$384,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm1,%zmm1
+	vmovdqu32	%zmm1,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm18,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$448,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm18,%zmm18
+	vmovdqu32	%zmm18,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm3,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$512,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm3,%zmm3
+	vmovdqu32	%zmm3,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm0,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$576,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm0,%zmm0
+	vmovdqu32	%zmm0,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm9,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$640,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm9,%zmm9
+	vmovdqu32	%zmm9,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm6,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$704,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm6,%zmm6
+	vmovdqu32	%zmm6,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm11,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$768,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm11,%zmm11
+	vmovdqu32	%zmm11,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm13,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$832,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm13,%zmm13
+	vmovdqu32	%zmm13,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm10,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$896,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm10,%zmm10
+	vmovdqu32	%zmm10,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm15,%zmm16
+	leaq	64(%rsi),%rsi
+
+	cmpq	$960,%rdx
+	jb	.Less_than_64_16x
+	vpxord	(%rsi),%zmm15,%zmm15
+	vmovdqu32	%zmm15,(%rdi,%rsi,1)
+	je	.Ldone16x
+	vmovdqa32	%zmm12,%zmm16
+	leaq	64(%rsi),%rsi
+
+.Less_than_64_16x:
+	vmovdqa32	%zmm16,0(%rsp)
+	leaq	(%rdi,%rsi,1),%rdi
+	andq	$63,%rdx
+
+.Loop_tail16x:
+	movzbl	(%rsi,%r9,1),%eax
+	movzbl	(%rsp,%r9,1),%ecx
+	leaq	1(%r9),%r9
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r9,1)
+	decq	%rdx
+	jnz	.Loop_tail16x
+
+	vpxord	%zmm16,%zmm16,%zmm16
+	vmovdqa32	%zmm16,0(%rsp)
+
+.Ldone16x:
+	vzeroall
+	leaq	-8(%r10),%rsp
+
+.L16x_epilogue:
+	ret
+ENDPROC(chacha20_avx512)
+
+.align	32
+ENTRY(chacha20_avx512vl)
+	cmpq	$0,%rdx
+	je	.Lavx512vl_epilogue
+
+	leaq	8(%rsp),%r10
+
+	cmpq	$128,%rdx
+	ja	.Lchacha20_8xvl
+
+	subq	$64+8,%rsp
+	andq	$-64,%rsp
+	vbroadcasti128	.Lsigma(%rip),%ymm0
+	vbroadcasti128	(%rcx),%ymm1
+	vbroadcasti128	16(%rcx),%ymm2
+	vbroadcasti128	(%r8),%ymm3
+
+	vmovdqa32	%ymm0,%ymm16
+	vmovdqa32	%ymm1,%ymm17
+	vmovdqa32	%ymm2,%ymm18
+	vpaddd	.Lzeroz(%rip),%ymm3,%ymm3
+	vmovdqa32	.Ltwoy(%rip),%ymm20
+	movq	$10,%r8
+	vmovdqa32	%ymm3,%ymm19
+	jmp	.Loop_avx512vl
+
+.align	16
+.Loop_outer_avx512vl:
+	vmovdqa32	%ymm18,%ymm2
+	vpaddd	%ymm20,%ymm19,%ymm3
+	movq	$10,%r8
+	vmovdqa32	%ymm3,%ymm19
+	jmp	.Loop_avx512vl
+
+.align	32
+.Loop_avx512vl:
+	vpaddd	%ymm1,%ymm0,%ymm0
+	vpxor	%ymm0,%ymm3,%ymm3
+	vprold	$16,%ymm3,%ymm3
+	vpaddd	%ymm3,%ymm2,%ymm2
+	vpxor	%ymm2,%ymm1,%ymm1
+	vprold	$12,%ymm1,%ymm1
+	vpaddd	%ymm1,%ymm0,%ymm0
+	vpxor	%ymm0,%ymm3,%ymm3
+	vprold	$8,%ymm3,%ymm3
+	vpaddd	%ymm3,%ymm2,%ymm2
+	vpxor	%ymm2,%ymm1,%ymm1
+	vprold	$7,%ymm1,%ymm1
+	vpshufd	$78,%ymm2,%ymm2
+	vpshufd	$57,%ymm1,%ymm1
+	vpshufd	$147,%ymm3,%ymm3
+	vpaddd	%ymm1,%ymm0,%ymm0
+	vpxor	%ymm0,%ymm3,%ymm3
+	vprold	$16,%ymm3,%ymm3
+	vpaddd	%ymm3,%ymm2,%ymm2
+	vpxor	%ymm2,%ymm1,%ymm1
+	vprold	$12,%ymm1,%ymm1
+	vpaddd	%ymm1,%ymm0,%ymm0
+	vpxor	%ymm0,%ymm3,%ymm3
+	vprold	$8,%ymm3,%ymm3
+	vpaddd	%ymm3,%ymm2,%ymm2
+	vpxor	%ymm2,%ymm1,%ymm1
+	vprold	$7,%ymm1,%ymm1
+	vpshufd	$78,%ymm2,%ymm2
+	vpshufd	$147,%ymm1,%ymm1
+	vpshufd	$57,%ymm3,%ymm3
+	decq	%r8
+	jnz	.Loop_avx512vl
+	vpaddd	%ymm16,%ymm0,%ymm0
+	vpaddd	%ymm17,%ymm1,%ymm1
+	vpaddd	%ymm18,%ymm2,%ymm2
+	vpaddd	%ymm19,%ymm3,%ymm3
+
+	subq	$64,%rdx
+	jb	.Ltail64_avx512vl
+
+	vpxor	0(%rsi),%xmm0,%xmm4
+	vpxor	16(%rsi),%xmm1,%xmm5
+	vpxor	32(%rsi),%xmm2,%xmm6
+	vpxor	48(%rsi),%xmm3,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	jz	.Ldone_avx512vl
+
+	vextracti128	$1,%ymm0,%xmm4
+	vextracti128	$1,%ymm1,%xmm5
+	vextracti128	$1,%ymm2,%xmm6
+	vextracti128	$1,%ymm3,%xmm7
+
+	subq	$64,%rdx
+	jb	.Ltail_avx512vl
+
+	vpxor	0(%rsi),%xmm4,%xmm4
+	vpxor	16(%rsi),%xmm5,%xmm5
+	vpxor	32(%rsi),%xmm6,%xmm6
+	vpxor	48(%rsi),%xmm7,%xmm7
+	leaq	64(%rsi),%rsi
+
+	vmovdqu	%xmm4,0(%rdi)
+	vmovdqu	%xmm5,16(%rdi)
+	vmovdqu	%xmm6,32(%rdi)
+	vmovdqu	%xmm7,48(%rdi)
+	leaq	64(%rdi),%rdi
+
+	vmovdqa32	%ymm16,%ymm0
+	vmovdqa32	%ymm17,%ymm1
+	jnz	.Loop_outer_avx512vl
+
+	jmp	.Ldone_avx512vl
+
+.align	16
+.Ltail64_avx512vl:
+	vmovdqa	%xmm0,0(%rsp)
+	vmovdqa	%xmm1,16(%rsp)
+	vmovdqa	%xmm2,32(%rsp)
+	vmovdqa	%xmm3,48(%rsp)
+	addq	$64,%rdx
+	jmp	.Loop_tail_avx512vl
+
+.align	16
+.Ltail_avx512vl:
+	vmovdqa	%xmm4,0(%rsp)
+	vmovdqa	%xmm5,16(%rsp)
+	vmovdqa	%xmm6,32(%rsp)
+	vmovdqa	%xmm7,48(%rsp)
+	addq	$64,%rdx
+
+.Loop_tail_avx512vl:
+	movzbl	(%rsi,%r8,1),%eax
+	movzbl	(%rsp,%r8,1),%ecx
+	leaq	1(%r8),%r8
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r8,1)
+	decq	%rdx
+	jnz	.Loop_tail_avx512vl
+
+	vmovdqa32	%ymm16,0(%rsp)
+	vmovdqa32	%ymm16,32(%rsp)
+
+.Ldone_avx512vl:
+	vzeroall
+	leaq	-8(%r10),%rsp
+.Lavx512vl_epilogue:
+	ret
+
+.align	32
+.Lchacha20_8xvl:
+	leaq	8(%rsp),%r10
+	subq	$64+8,%rsp
+	andq	$-64,%rsp
+	vzeroupper
+
+	leaq	.Lsigma(%rip),%r9
+	vbroadcasti128	(%r9),%ymm3
+	vbroadcasti128	(%rcx),%ymm7
+	vbroadcasti128	16(%rcx),%ymm11
+	vbroadcasti128	(%r8),%ymm15
+
+	vpshufd	$0x00,%ymm3,%ymm0
+	vpshufd	$0x55,%ymm3,%ymm1
+	vpshufd	$0xaa,%ymm3,%ymm2
+	vpshufd	$0xff,%ymm3,%ymm3
+	vmovdqa64	%ymm0,%ymm16
+	vmovdqa64	%ymm1,%ymm17
+	vmovdqa64	%ymm2,%ymm18
+	vmovdqa64	%ymm3,%ymm19
+
+	vpshufd	$0x00,%ymm7,%ymm4
+	vpshufd	$0x55,%ymm7,%ymm5
+	vpshufd	$0xaa,%ymm7,%ymm6
+	vpshufd	$0xff,%ymm7,%ymm7
+	vmovdqa64	%ymm4,%ymm20
+	vmovdqa64	%ymm5,%ymm21
+	vmovdqa64	%ymm6,%ymm22
+	vmovdqa64	%ymm7,%ymm23
+
+	vpshufd	$0x00,%ymm11,%ymm8
+	vpshufd	$0x55,%ymm11,%ymm9
+	vpshufd	$0xaa,%ymm11,%ymm10
+	vpshufd	$0xff,%ymm11,%ymm11
+	vmovdqa64	%ymm8,%ymm24
+	vmovdqa64	%ymm9,%ymm25
+	vmovdqa64	%ymm10,%ymm26
+	vmovdqa64	%ymm11,%ymm27
+
+	vpshufd	$0x00,%ymm15,%ymm12
+	vpshufd	$0x55,%ymm15,%ymm13
+	vpshufd	$0xaa,%ymm15,%ymm14
+	vpshufd	$0xff,%ymm15,%ymm15
+	vpaddd	.Lincy(%rip),%ymm12,%ymm12
+	vmovdqa64	%ymm12,%ymm28
+	vmovdqa64	%ymm13,%ymm29
+	vmovdqa64	%ymm14,%ymm30
+	vmovdqa64	%ymm15,%ymm31
+
+	movl	$10,%eax
+	jmp	.Loop8xvl
+
+.align	32
+.Loop_outer8xvl:
+
+
+	vpbroadcastd	8(%r9),%ymm2
+	vpbroadcastd	12(%r9),%ymm3
+	vpaddd	.Leight(%rip),%ymm28,%ymm28
+	vmovdqa64	%ymm20,%ymm4
+	vmovdqa64	%ymm21,%ymm5
+	vmovdqa64	%ymm22,%ymm6
+	vmovdqa64	%ymm23,%ymm7
+	vmovdqa64	%ymm24,%ymm8
+	vmovdqa64	%ymm25,%ymm9
+	vmovdqa64	%ymm26,%ymm10
+	vmovdqa64	%ymm27,%ymm11
+	vmovdqa64	%ymm28,%ymm12
+	vmovdqa64	%ymm29,%ymm13
+	vmovdqa64	%ymm30,%ymm14
+	vmovdqa64	%ymm31,%ymm15
+
+	vmovdqa64	%ymm0,%ymm16
+	vmovdqa64	%ymm1,%ymm17
+	vmovdqa64	%ymm2,%ymm18
+	vmovdqa64	%ymm3,%ymm19
+
+	movl	$10,%eax
+	jmp	.Loop8xvl
+
+.align	32
+.Loop8xvl:
+	vpaddd	%ymm4,%ymm0,%ymm0
+	vpaddd	%ymm5,%ymm1,%ymm1
+	vpaddd	%ymm6,%ymm2,%ymm2
+	vpaddd	%ymm7,%ymm3,%ymm3
+	vpxor	%ymm0,%ymm12,%ymm12
+	vpxor	%ymm1,%ymm13,%ymm13
+	vpxor	%ymm2,%ymm14,%ymm14
+	vpxor	%ymm3,%ymm15,%ymm15
+	vprold	$16,%ymm12,%ymm12
+	vprold	$16,%ymm13,%ymm13
+	vprold	$16,%ymm14,%ymm14
+	vprold	$16,%ymm15,%ymm15
+	vpaddd	%ymm12,%ymm8,%ymm8
+	vpaddd	%ymm13,%ymm9,%ymm9
+	vpaddd	%ymm14,%ymm10,%ymm10
+	vpaddd	%ymm15,%ymm11,%ymm11
+	vpxor	%ymm8,%ymm4,%ymm4
+	vpxor	%ymm9,%ymm5,%ymm5
+	vpxor	%ymm10,%ymm6,%ymm6
+	vpxor	%ymm11,%ymm7,%ymm7
+	vprold	$12,%ymm4,%ymm4
+	vprold	$12,%ymm5,%ymm5
+	vprold	$12,%ymm6,%ymm6
+	vprold	$12,%ymm7,%ymm7
+	vpaddd	%ymm4,%ymm0,%ymm0
+	vpaddd	%ymm5,%ymm1,%ymm1
+	vpaddd	%ymm6,%ymm2,%ymm2
+	vpaddd	%ymm7,%ymm3,%ymm3
+	vpxor	%ymm0,%ymm12,%ymm12
+	vpxor	%ymm1,%ymm13,%ymm13
+	vpxor	%ymm2,%ymm14,%ymm14
+	vpxor	%ymm3,%ymm15,%ymm15
+	vprold	$8,%ymm12,%ymm12
+	vprold	$8,%ymm13,%ymm13
+	vprold	$8,%ymm14,%ymm14
+	vprold	$8,%ymm15,%ymm15
+	vpaddd	%ymm12,%ymm8,%ymm8
+	vpaddd	%ymm13,%ymm9,%ymm9
+	vpaddd	%ymm14,%ymm10,%ymm10
+	vpaddd	%ymm15,%ymm11,%ymm11
+	vpxor	%ymm8,%ymm4,%ymm4
+	vpxor	%ymm9,%ymm5,%ymm5
+	vpxor	%ymm10,%ymm6,%ymm6
+	vpxor	%ymm11,%ymm7,%ymm7
+	vprold	$7,%ymm4,%ymm4
+	vprold	$7,%ymm5,%ymm5
+	vprold	$7,%ymm6,%ymm6
+	vprold	$7,%ymm7,%ymm7
+	vpaddd	%ymm5,%ymm0,%ymm0
+	vpaddd	%ymm6,%ymm1,%ymm1
+	vpaddd	%ymm7,%ymm2,%ymm2
+	vpaddd	%ymm4,%ymm3,%ymm3
+	vpxor	%ymm0,%ymm15,%ymm15
+	vpxor	%ymm1,%ymm12,%ymm12
+	vpxor	%ymm2,%ymm13,%ymm13
+	vpxor	%ymm3,%ymm14,%ymm14
+	vprold	$16,%ymm15,%ymm15
+	vprold	$16,%ymm12,%ymm12
+	vprold	$16,%ymm13,%ymm13
+	vprold	$16,%ymm14,%ymm14
+	vpaddd	%ymm15,%ymm10,%ymm10
+	vpaddd	%ymm12,%ymm11,%ymm11
+	vpaddd	%ymm13,%ymm8,%ymm8
+	vpaddd	%ymm14,%ymm9,%ymm9
+	vpxor	%ymm10,%ymm5,%ymm5
+	vpxor	%ymm11,%ymm6,%ymm6
+	vpxor	%ymm8,%ymm7,%ymm7
+	vpxor	%ymm9,%ymm4,%ymm4
+	vprold	$12,%ymm5,%ymm5
+	vprold	$12,%ymm6,%ymm6
+	vprold	$12,%ymm7,%ymm7
+	vprold	$12,%ymm4,%ymm4
+	vpaddd	%ymm5,%ymm0,%ymm0
+	vpaddd	%ymm6,%ymm1,%ymm1
+	vpaddd	%ymm7,%ymm2,%ymm2
+	vpaddd	%ymm4,%ymm3,%ymm3
+	vpxor	%ymm0,%ymm15,%ymm15
+	vpxor	%ymm1,%ymm12,%ymm12
+	vpxor	%ymm2,%ymm13,%ymm13
+	vpxor	%ymm3,%ymm14,%ymm14
+	vprold	$8,%ymm15,%ymm15
+	vprold	$8,%ymm12,%ymm12
+	vprold	$8,%ymm13,%ymm13
+	vprold	$8,%ymm14,%ymm14
+	vpaddd	%ymm15,%ymm10,%ymm10
+	vpaddd	%ymm12,%ymm11,%ymm11
+	vpaddd	%ymm13,%ymm8,%ymm8
+	vpaddd	%ymm14,%ymm9,%ymm9
+	vpxor	%ymm10,%ymm5,%ymm5
+	vpxor	%ymm11,%ymm6,%ymm6
+	vpxor	%ymm8,%ymm7,%ymm7
+	vpxor	%ymm9,%ymm4,%ymm4
+	vprold	$7,%ymm5,%ymm5
+	vprold	$7,%ymm6,%ymm6
+	vprold	$7,%ymm7,%ymm7
+	vprold	$7,%ymm4,%ymm4
+	decl	%eax
+	jnz	.Loop8xvl
+
+	vpaddd	%ymm16,%ymm0,%ymm0
+	vpaddd	%ymm17,%ymm1,%ymm1
+	vpaddd	%ymm18,%ymm2,%ymm2
+	vpaddd	%ymm19,%ymm3,%ymm3
+
+	vpunpckldq	%ymm1,%ymm0,%ymm18
+	vpunpckldq	%ymm3,%ymm2,%ymm19
+	vpunpckhdq	%ymm1,%ymm0,%ymm0
+	vpunpckhdq	%ymm3,%ymm2,%ymm2
+	vpunpcklqdq	%ymm19,%ymm18,%ymm1
+	vpunpckhqdq	%ymm19,%ymm18,%ymm18
+	vpunpcklqdq	%ymm2,%ymm0,%ymm3
+	vpunpckhqdq	%ymm2,%ymm0,%ymm0
+	vpaddd	%ymm20,%ymm4,%ymm4
+	vpaddd	%ymm21,%ymm5,%ymm5
+	vpaddd	%ymm22,%ymm6,%ymm6
+	vpaddd	%ymm23,%ymm7,%ymm7
+
+	vpunpckldq	%ymm5,%ymm4,%ymm2
+	vpunpckldq	%ymm7,%ymm6,%ymm19
+	vpunpckhdq	%ymm5,%ymm4,%ymm4
+	vpunpckhdq	%ymm7,%ymm6,%ymm6
+	vpunpcklqdq	%ymm19,%ymm2,%ymm5
+	vpunpckhqdq	%ymm19,%ymm2,%ymm2
+	vpunpcklqdq	%ymm6,%ymm4,%ymm7
+	vpunpckhqdq	%ymm6,%ymm4,%ymm4
+	vshufi32x4	$0,%ymm5,%ymm1,%ymm19
+	vshufi32x4	$3,%ymm5,%ymm1,%ymm5
+	vshufi32x4	$0,%ymm2,%ymm18,%ymm1
+	vshufi32x4	$3,%ymm2,%ymm18,%ymm2
+	vshufi32x4	$0,%ymm7,%ymm3,%ymm18
+	vshufi32x4	$3,%ymm7,%ymm3,%ymm7
+	vshufi32x4	$0,%ymm4,%ymm0,%ymm3
+	vshufi32x4	$3,%ymm4,%ymm0,%ymm4
+	vpaddd	%ymm24,%ymm8,%ymm8
+	vpaddd	%ymm25,%ymm9,%ymm9
+	vpaddd	%ymm26,%ymm10,%ymm10
+	vpaddd	%ymm27,%ymm11,%ymm11
+
+	vpunpckldq	%ymm9,%ymm8,%ymm6
+	vpunpckldq	%ymm11,%ymm10,%ymm0
+	vpunpckhdq	%ymm9,%ymm8,%ymm8
+	vpunpckhdq	%ymm11,%ymm10,%ymm10
+	vpunpcklqdq	%ymm0,%ymm6,%ymm9
+	vpunpckhqdq	%ymm0,%ymm6,%ymm6
+	vpunpcklqdq	%ymm10,%ymm8,%ymm11
+	vpunpckhqdq	%ymm10,%ymm8,%ymm8
+	vpaddd	%ymm28,%ymm12,%ymm12
+	vpaddd	%ymm29,%ymm13,%ymm13
+	vpaddd	%ymm30,%ymm14,%ymm14
+	vpaddd	%ymm31,%ymm15,%ymm15
+
+	vpunpckldq	%ymm13,%ymm12,%ymm10
+	vpunpckldq	%ymm15,%ymm14,%ymm0
+	vpunpckhdq	%ymm13,%ymm12,%ymm12
+	vpunpckhdq	%ymm15,%ymm14,%ymm14
+	vpunpcklqdq	%ymm0,%ymm10,%ymm13
+	vpunpckhqdq	%ymm0,%ymm10,%ymm10
+	vpunpcklqdq	%ymm14,%ymm12,%ymm15
+	vpunpckhqdq	%ymm14,%ymm12,%ymm12
+	vperm2i128	$0x20,%ymm13,%ymm9,%ymm0
+	vperm2i128	$0x31,%ymm13,%ymm9,%ymm13
+	vperm2i128	$0x20,%ymm10,%ymm6,%ymm9
+	vperm2i128	$0x31,%ymm10,%ymm6,%ymm10
+	vperm2i128	$0x20,%ymm15,%ymm11,%ymm6
+	vperm2i128	$0x31,%ymm15,%ymm11,%ymm15
+	vperm2i128	$0x20,%ymm12,%ymm8,%ymm11
+	vperm2i128	$0x31,%ymm12,%ymm8,%ymm12
+	cmpq	$512,%rdx
+	jb	.Ltail8xvl
+
+	movl	$0x80,%eax
+	vpxord	0(%rsi),%ymm19,%ymm19
+	vpxor	32(%rsi),%ymm0,%ymm0
+	vpxor	64(%rsi),%ymm5,%ymm5
+	vpxor	96(%rsi),%ymm13,%ymm13
+	leaq	(%rsi,%rax,1),%rsi
+	vmovdqu32	%ymm19,0(%rdi)
+	vmovdqu	%ymm0,32(%rdi)
+	vmovdqu	%ymm5,64(%rdi)
+	vmovdqu	%ymm13,96(%rdi)
+	leaq	(%rdi,%rax,1),%rdi
+
+	vpxor	0(%rsi),%ymm1,%ymm1
+	vpxor	32(%rsi),%ymm9,%ymm9
+	vpxor	64(%rsi),%ymm2,%ymm2
+	vpxor	96(%rsi),%ymm10,%ymm10
+	leaq	(%rsi,%rax,1),%rsi
+	vmovdqu	%ymm1,0(%rdi)
+	vmovdqu	%ymm9,32(%rdi)
+	vmovdqu	%ymm2,64(%rdi)
+	vmovdqu	%ymm10,96(%rdi)
+	leaq	(%rdi,%rax,1),%rdi
+
+	vpxord	0(%rsi),%ymm18,%ymm18
+	vpxor	32(%rsi),%ymm6,%ymm6
+	vpxor	64(%rsi),%ymm7,%ymm7
+	vpxor	96(%rsi),%ymm15,%ymm15
+	leaq	(%rsi,%rax,1),%rsi
+	vmovdqu32	%ymm18,0(%rdi)
+	vmovdqu	%ymm6,32(%rdi)
+	vmovdqu	%ymm7,64(%rdi)
+	vmovdqu	%ymm15,96(%rdi)
+	leaq	(%rdi,%rax,1),%rdi
+
+	vpxor	0(%rsi),%ymm3,%ymm3
+	vpxor	32(%rsi),%ymm11,%ymm11
+	vpxor	64(%rsi),%ymm4,%ymm4
+	vpxor	96(%rsi),%ymm12,%ymm12
+	leaq	(%rsi,%rax,1),%rsi
+	vmovdqu	%ymm3,0(%rdi)
+	vmovdqu	%ymm11,32(%rdi)
+	vmovdqu	%ymm4,64(%rdi)
+	vmovdqu	%ymm12,96(%rdi)
+	leaq	(%rdi,%rax,1),%rdi
+
+	vpbroadcastd	0(%r9),%ymm0
+	vpbroadcastd	4(%r9),%ymm1
+
+	subq	$512,%rdx
+	jnz	.Loop_outer8xvl
+
+	jmp	.Ldone8xvl
+
+.align	32
+.Ltail8xvl:
+	vmovdqa64	%ymm19,%ymm8
+	xorq	%r9,%r9
+	subq	%rsi,%rdi
+	cmpq	$64,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm8,%ymm8
+	vpxor	32(%rsi),%ymm0,%ymm0
+	vmovdqu	%ymm8,0(%rdi,%rsi,1)
+	vmovdqu	%ymm0,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm5,%ymm8
+	vmovdqa	%ymm13,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$128,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm5,%ymm5
+	vpxor	32(%rsi),%ymm13,%ymm13
+	vmovdqu	%ymm5,0(%rdi,%rsi,1)
+	vmovdqu	%ymm13,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm1,%ymm8
+	vmovdqa	%ymm9,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$192,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm1,%ymm1
+	vpxor	32(%rsi),%ymm9,%ymm9
+	vmovdqu	%ymm1,0(%rdi,%rsi,1)
+	vmovdqu	%ymm9,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm2,%ymm8
+	vmovdqa	%ymm10,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$256,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm2,%ymm2
+	vpxor	32(%rsi),%ymm10,%ymm10
+	vmovdqu	%ymm2,0(%rdi,%rsi,1)
+	vmovdqu	%ymm10,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa32	%ymm18,%ymm8
+	vmovdqa	%ymm6,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$320,%rdx
+	jb	.Less_than_64_8xvl
+	vpxord	0(%rsi),%ymm18,%ymm18
+	vpxor	32(%rsi),%ymm6,%ymm6
+	vmovdqu32	%ymm18,0(%rdi,%rsi,1)
+	vmovdqu	%ymm6,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm7,%ymm8
+	vmovdqa	%ymm15,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$384,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm7,%ymm7
+	vpxor	32(%rsi),%ymm15,%ymm15
+	vmovdqu	%ymm7,0(%rdi,%rsi,1)
+	vmovdqu	%ymm15,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm3,%ymm8
+	vmovdqa	%ymm11,%ymm0
+	leaq	64(%rsi),%rsi
+
+	cmpq	$448,%rdx
+	jb	.Less_than_64_8xvl
+	vpxor	0(%rsi),%ymm3,%ymm3
+	vpxor	32(%rsi),%ymm11,%ymm11
+	vmovdqu	%ymm3,0(%rdi,%rsi,1)
+	vmovdqu	%ymm11,32(%rdi,%rsi,1)
+	je	.Ldone8xvl
+	vmovdqa	%ymm4,%ymm8
+	vmovdqa	%ymm12,%ymm0
+	leaq	64(%rsi),%rsi
+
+.Less_than_64_8xvl:
+	vmovdqa	%ymm8,0(%rsp)
+	vmovdqa	%ymm0,32(%rsp)
+	leaq	(%rdi,%rsi,1),%rdi
+	andq	$63,%rdx
+
+.Loop_tail8xvl:
+	movzbl	(%rsi,%r9,1),%eax
+	movzbl	(%rsp,%r9,1),%ecx
+	leaq	1(%r9),%r9
+	xorl	%ecx,%eax
+	movb	%al,-1(%rdi,%r9,1)
+	decq	%rdx
+	jnz	.Loop_tail8xvl
+
+	vpxor	%ymm8,%ymm8,%ymm8
+	vmovdqa	%ymm8,0(%rsp)
+	vmovdqa	%ymm8,32(%rsp)
+
+.Ldone8xvl:
+	vzeroall
+	leaq	-8(%r10),%rsp
+.L8xvl_epilogue:
+	ret
+ENDPROC(chacha20_avx512vl)
+
+#endif /* CONFIG_AS_AVX512 */
diff --git a/arch/x86/crypto/chacha20_glue.c b/arch/x86/crypto/chacha20_glue.c
index ba66e23cd752..c7027172ead0 100644
--- a/arch/x86/crypto/chacha20_glue.c
+++ b/arch/x86/crypto/chacha20_glue.c
@@ -16,74 +16,47 @@
 #include <linux/module.h>
 #include <asm/fpu/api.h>
 #include <asm/simd.h>
+#include <asm/intel-family.h>
 
 #define CHACHA20_STATE_ALIGN 16
 
-asmlinkage void chacha20_block_xor_ssse3(u32 *state, u8 *dst, const u8 *src,
-					 unsigned int len);
-asmlinkage void chacha20_4block_xor_ssse3(u32 *state, u8 *dst, const u8 *src,
-					  unsigned int len);
-#ifdef CONFIG_AS_AVX2
-asmlinkage void chacha20_2block_xor_avx2(u32 *state, u8 *dst, const u8 *src,
-					 unsigned int len);
-asmlinkage void chacha20_4block_xor_avx2(u32 *state, u8 *dst, const u8 *src,
-					 unsigned int len);
-asmlinkage void chacha20_8block_xor_avx2(u32 *state, u8 *dst, const u8 *src,
-					 unsigned int len);
-static bool chacha20_use_avx2;
-#endif
-
-static unsigned int chacha20_advance(unsigned int len, unsigned int maxblocks)
-{
-	len = min(len, maxblocks * CHACHA20_BLOCK_SIZE);
-	return round_up(len, CHACHA20_BLOCK_SIZE) / CHACHA20_BLOCK_SIZE;
-}
+bool crypto_chacha20_use_avx2;
+EXPORT_SYMBOL_GPL(crypto_chacha20_use_avx2);
+bool crypto_chacha20_use_avx512;
+EXPORT_SYMBOL_GPL(crypto_chacha20_use_avx512);
+bool crypto_chacha20_use_avx512vl;
+EXPORT_SYMBOL_GPL(crypto_chacha20_use_avx512vl);
+
+asmlinkage void hchacha20_ssse3(u32 *derived_key, const u8 *nonce,
+				const u8 *key);
+asmlinkage void chacha20_ssse3(u8 *out, const u8 *in, const size_t len,
+			       const u32 key[8], const u32 counter[4]);
+asmlinkage void chacha20_avx2(u8 *out, const u8 *in, const size_t len,
+			      const u32 key[8], const u32 counter[4]);
+asmlinkage void chacha20_avx512(u8 *out, const u8 *in, const size_t len,
+				const u32 key[8], const u32 counter[4]);
+asmlinkage void chacha20_avx512vl(u8 *out, const u8 *in, const size_t len,
+				  const u32 key[8], const u32 counter[4]);
 
 void crypto_chacha20_dosimd(u32 *state, u8 *dst, const u8 *src,
 			    unsigned int bytes)
 {
-#ifdef CONFIG_AS_AVX2
-	if (chacha20_use_avx2) {
-		while (bytes >= CHACHA20_BLOCK_SIZE * 8) {
-			chacha20_8block_xor_avx2(state, dst, src, bytes);
-			bytes -= CHACHA20_BLOCK_SIZE * 8;
-			src += CHACHA20_BLOCK_SIZE * 8;
-			dst += CHACHA20_BLOCK_SIZE * 8;
-			state[12] += 8;
-		}
-		if (bytes > CHACHA20_BLOCK_SIZE * 4) {
-			chacha20_8block_xor_avx2(state, dst, src, bytes);
-			state[12] += chacha20_advance(bytes, 8);
-			return;
-		}
-		if (bytes > CHACHA20_BLOCK_SIZE * 2) {
-			chacha20_4block_xor_avx2(state, dst, src, bytes);
-			state[12] += chacha20_advance(bytes, 4);
-			return;
-		}
-		if (bytes > CHACHA20_BLOCK_SIZE) {
-			chacha20_2block_xor_avx2(state, dst, src, bytes);
-			state[12] += chacha20_advance(bytes, 2);
-			return;
-		}
-	}
-#endif
-	while (bytes >= CHACHA20_BLOCK_SIZE * 4) {
-		chacha20_4block_xor_ssse3(state, dst, src, bytes);
-		bytes -= CHACHA20_BLOCK_SIZE * 4;
-		src += CHACHA20_BLOCK_SIZE * 4;
-		dst += CHACHA20_BLOCK_SIZE * 4;
-		state[12] += 4;
-	}
-	if (bytes > CHACHA20_BLOCK_SIZE) {
-		chacha20_4block_xor_ssse3(state, dst, src, bytes);
-		state[12] += chacha20_advance(bytes, 4);
-		return;
-	}
-	if (bytes) {
-		chacha20_block_xor_ssse3(state, dst, src, bytes);
-		state[12]++;
-	}
+	u32 *key = state + 4;
+	u32 *counter = key + 8;
+
+	if (IS_ENABLED(CONFIG_AS_AVX512) && crypto_chacha20_use_avx512 &&
+	    bytes >= CHACHA20_BLOCK_SIZE * 8)
+		chacha20_avx512(dst, src, bytes, key, counter);
+	else if (IS_ENABLED(CONFIG_AS_AVX512) &&
+		 crypto_chacha20_use_avx512vl &&
+		 bytes >= CHACHA20_BLOCK_SIZE * 4)
+		chacha20_avx512vl(dst, src, bytes, key, counter);
+	else if (IS_ENABLED(CONFIG_AS_AVX2) && crypto_chacha20_use_avx2 &&
+		 bytes >= CHACHA20_BLOCK_SIZE * 4)
+		chacha20_avx2(dst, src, bytes, key, counter);
+	else
+		chacha20_ssse3(dst, src, bytes, key, counter);
+	counter[0] += (bytes + 63) / 64;
 }
 EXPORT_SYMBOL_GPL(crypto_chacha20_dosimd);
 
@@ -146,11 +119,25 @@ static int __init chacha20_simd_mod_init(void)
 	if (!boot_cpu_has(X86_FEATURE_SSSE3))
 		return 0;
 
-#ifdef CONFIG_AS_AVX2
-	chacha20_use_avx2 = boot_cpu_has(X86_FEATURE_AVX) &&
-			    boot_cpu_has(X86_FEATURE_AVX2) &&
-			    cpu_has_xfeatures(XFEATURE_MASK_SSE | XFEATURE_MASK_YMM, NULL);
-#endif
+	crypto_chacha20_use_avx2 =
+		boot_cpu_has(X86_FEATURE_AVX) &&
+		boot_cpu_has(X86_FEATURE_AVX2) &&
+		cpu_has_xfeatures(XFEATURE_MASK_SSE | XFEATURE_MASK_YMM, NULL);
+	crypto_chacha20_use_avx512 =
+		boot_cpu_has(X86_FEATURE_AVX) &&
+		boot_cpu_has(X86_FEATURE_AVX2) &&
+		boot_cpu_has(X86_FEATURE_AVX512F) &&
+		cpu_has_xfeatures(XFEATURE_MASK_SSE | XFEATURE_MASK_YMM |
+				  XFEATURE_MASK_AVX512, NULL) &&
+		/* Skylake downclocks unacceptably much when using zmm. */
+		boot_cpu_data.x86_model != INTEL_FAM6_SKYLAKE_X;
+	crypto_chacha20_use_avx512vl =
+		boot_cpu_has(X86_FEATURE_AVX) &&
+		boot_cpu_has(X86_FEATURE_AVX2) &&
+		boot_cpu_has(X86_FEATURE_AVX512F) &&
+		boot_cpu_has(X86_FEATURE_AVX512VL) &&
+		cpu_has_xfeatures(XFEATURE_MASK_SSE | XFEATURE_MASK_YMM |
+				  XFEATURE_MASK_AVX512, NULL);
 	return crypto_register_skcipher(&alg);
 }
 
diff --git a/include/crypto/chacha20.h b/include/crypto/chacha20.h
index 0dd99c928123..8eeed26bcf93 100644
--- a/include/crypto/chacha20.h
+++ b/include/crypto/chacha20.h
@@ -19,6 +19,10 @@ struct crypto_chacha20_ctx {
 	u32 key[8];
 };
 
+extern bool crypto_chacha20_use_avx2;
+extern bool crypto_chacha20_use_avx512;
+extern bool crypto_chacha20_use_avx512vl;
+
 void chacha20_block(u32 *state, u8 *stream);
 void crypto_chacha20_generic(u32 *state, u8 *dst, const u8 *src,
 			     unsigned int bytes);
diff --git a/lib/zinc/chacha20/chacha20-x86_64-glue.c b/lib/zinc/chacha20/chacha20-x86_64-glue.c
index 07f72729a64e..0ffa534708b1 100644
--- a/lib/zinc/chacha20/chacha20-x86_64-glue.c
+++ b/lib/zinc/chacha20/chacha20-x86_64-glue.c
@@ -11,7 +11,8 @@
 
 static bool chacha20_use_ssse3 __ro_after_init;
 static bool *const chacha20_nobs[] __initconst = {
-	&chacha20_use_ssse3 };
+	&chacha20_use_ssse3, &crypto_chacha20_use_avx2,
+	&crypto_chacha20_use_avx512, &crypto_chacha20_use_avx512vl };
 
 static void __init chacha20_fpu_init(void)
 {
