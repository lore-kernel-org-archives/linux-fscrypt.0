Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54462 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725796AbeKFItL (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Nov 2018 03:49:11 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH v3 00/15] crypto: Adiantum support
Date: Mon,  5 Nov 2018 15:25:11 -0800
Message-Id: <20181105232526.173947-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

We've been working to find a way to bring storage encryption to
entry-level Android devices like the inexpensive "Android Go" devices
sold in developing countries, and some smartwatches.  Unfortunately,
often these devices still ship with no encryption, since for cost
reasons they have to use older CPUs like ARM Cortex-A7; and these CPUs
lack the ARMv8 Cryptography Extensions, making AES-XTS much too slow.

We're trying to change this, since we believe encryption is for
everyone, not just those who can afford it.  And while it's unknown how
long CPUs without AES support will be around, there will likely always
be a "low end"; and in any case it's immensely valuable to provide a
software-optimized cipher that doesn't depend on hardware support.
Lack of hardware support should not be an excuse for no encryption.

But after an extensive search (e.g. see [1]) we were unable to find an
existing cipher that simultaneously meets the very strict performance
requirements on ARM processors, is secure (including having sufficient
security parameters as well as sufficient cryptanalysis of any
primitive(s) used), is suitable for practical use in dm-crypt and
fscrypt, *and* avoids any particularly controversial primitive.

Therefore, we (well, Paul Crowley did the real work) designed a new
encryption mode, Adiantum.  In essence, Adiantum makes it secure to use
the ChaCha stream cipher for disk encryption.  Adiantum is specified by
our paper here: https://eprint.iacr.org/2018/720.pdf ("Adiantum:
length-preserving encryption for entry-level processors").  Reference
code and test vectors are here: https://github.com/google/adiantum.
Most of the high-level concepts of Adiantum are not new; similar
existing modes include XCB, HCTR, and HCH.  Adiantum and these modes are
true wide-block modes (tweakable super-pseudorandom permutations), so
they actually provide a stronger notion of security than XTS.

Adiantum is an improved version of our previous algorithm, HPolyC [2].
Like HPolyC, Adiantum uses XChaCha12, two passes of an
ε-almost-∆-universal (εA∆U) hash function, and one AES-256 encryption of
a single 16-byte block.  On ARM Cortex-A7, on 4096-byte messages
Adiantum is about 4x faster than AES-256-XTS (about 5x for decryption),
and about 30% faster than Speck128/256-XTS.

Adiantum is a construction, not a primitive.  Its security is reducible
to that of XChaCha12 and AES-256, subject to a security bound; the proof
is in Section 5 of our paper.  Therefore, one need not "trust" Adiantum;
they only need trust XChaCha12 and AES-256.  Note that of these two
primitives, AES-256 currently has the lower security margin.

Adiantum is ~20% faster than HPolyC, with no loss of security; in fact,
Adiantum's security bound is slightly better than HPolyC's.  It does
this by choosing a faster εA∆U hash function: it still uses Poly1305's
εA∆U hash function, but now a hash function from the "NH" family of hash
functions is used to "compress" the message by 32x first.  NH is εAU (as
shown in the UMAC paper[3]) but is over twice as fast as Poly1305.  Key
agility is reduced, but that's acceptable for disk encryption.

NH is also very simple, and it's easy to implement in SIMD assembly,
e.g. in ARM NEON.  Now, to get good performance only a SIMD
implementation of NH is required, not Poly1305.  Therefore, Adiantum can
be easier to port to new platforms than HPolyC, despite Adiantum's
slightly increased complexity.  For now this patchset only includes an
ARM32 NEON implementation of NH, but as a proof of concept I've also
written SSE2, AVX2, and ARM64 NEON implementations of NH; see
https://github.com/google/adiantum/tree/master/benchmark/src.

This patchset adds Adiantum to Linux's crypto API, focusing on generic
and ARM32 implementations.  Patches 1-9 add support for XChaCha20 and
XChaCha12.  Patches 10-13 add NHPoly1305 support, needed for Adiantum
hashing.  Patch 14 adds Adiantum support as a skcipher template.

Patch 15 adds Adiantum support to fscrypt ("file-based encryption").
In fscrypt, Adiantum is used for filenames encryption as well as
contents encryption; since Adiantum is a SPRP, it fixes the information
leak when filenames share a common prefix.  We also take advantage of
Adiantum's support for long tweaks to include the per-inode nonce
directly in the tweak, which allows providing an option to skip the
per-file key derivation, providing even greater performance benefits.

This patchset applies to v4.20-rc1.  It can also be found in git at
branch "adiantum-v3" of:
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git

As before, the XChaCha and Poly1305 changes conflict with the new "Zinc"
crypto library.  But I don't know when Zinc will be merged, so for now
I've continued to base this patchset on upstream.  An experimental
version of this patchset based on Zinc can be found at branch
"adiantum-zinc" of the git repository above.

Again, for more details please read our paper:

    Adiantum: length-preserving encryption for entry-level processors
    (https://eprint.iacr.org/2018/720.pdf)

References:
  [1] https://www.spinics.net/lists/linux-crypto/msg33000.html
  [2] https://patchwork.kernel.org/cover/10558059/
  [3] https://fastcrypto.org/umac/umac_proc.pdf

Changed since v2:
  - Simplify the generic NH implementation.
  - Add patches to reduce atomic walks and disabling preemption.
  - Split Poly1305 changes into two patches.
  - Add tcrypt test mode for Adiantum.
  - Make NEON 'chacha_permute' a function rather than a macro.
  - Use .base.* style when declaring algorithms.
  - Replace BUG_ON() in chacha_permute() with WARN_ON_ONCE().
  - Set Adiantum instance {min,max}_keysize correctly in all cases.
  - Make the Adiantum template take the nhpoly1305 driver name as
    optional third argument (useful for testing).

  Thanks to Ard Biesheuvel for reviewing the patches.

Changed since v1:
  - Replace HPolyC with Adiantum (uses a faster hash function).
  - Drop ARM accelerated Poly1305.
  - Add fscrypt patch.

Eric Biggers (15):
  crypto: chacha20-generic - add HChaCha20 library function
  crypto: chacha20-generic - don't unnecessarily use atomic walk
  crypto: chacha20-generic - add XChaCha20 support
  crypto: chacha20-generic - refactor to allow varying number of rounds
  crypto: chacha - add XChaCha12 support
  crypto: arm/chacha20 - limit the preemption-disabled section
  crypto: arm/chacha20 - add XChaCha20 support
  crypto: arm/chacha20 - refactor to allow varying number of rounds
  crypto: arm/chacha - add XChaCha12 support
  crypto: poly1305 - use structures for key and accumulator
  crypto: poly1305 - add Poly1305 core API
  crypto: nhpoly1305 - add NHPoly1305 support
  crypto: arm/nhpoly1305 - add NEON-accelerated NHPoly1305
  crypto: adiantum - add Adiantum support
  fscrypt: add Adiantum support

 Documentation/filesystems/fscrypt.rst         |  187 +-
 arch/arm/crypto/Kconfig                       |    7 +-
 arch/arm/crypto/Makefile                      |    6 +-
 ...hacha20-neon-core.S => chacha-neon-core.S} |   98 +-
 arch/arm/crypto/chacha-neon-glue.c            |  201 ++
 arch/arm/crypto/chacha20-neon-glue.c          |  127 -
 arch/arm/crypto/nh-neon-core.S                |  116 +
 arch/arm/crypto/nhpoly1305-neon-glue.c        |   77 +
 arch/arm64/crypto/chacha20-neon-glue.c        |   40 +-
 arch/x86/crypto/chacha20_glue.c               |   52 +-
 arch/x86/crypto/poly1305_glue.c               |   20 +-
 crypto/Kconfig                                |   46 +-
 crypto/Makefile                               |    4 +-
 crypto/adiantum.c                             |  658 ++++
 crypto/chacha20_generic.c                     |  137 -
 crypto/chacha20poly1305.c                     |   10 +-
 crypto/chacha_generic.c                       |  217 ++
 crypto/nhpoly1305.c                           |  254 ++
 crypto/poly1305_generic.c                     |  174 +-
 crypto/tcrypt.c                               |   12 +
 crypto/testmgr.c                              |   30 +
 crypto/testmgr.h                              | 2856 ++++++++++++++++-
 drivers/char/random.c                         |   51 +-
 fs/crypto/crypto.c                            |   35 +-
 fs/crypto/fname.c                             |   22 +-
 fs/crypto/fscrypt_private.h                   |   66 +-
 fs/crypto/keyinfo.c                           |  322 +-
 fs/crypto/policy.c                            |    5 +-
 include/crypto/chacha.h                       |   53 +
 include/crypto/chacha20.h                     |   27 -
 include/crypto/nhpoly1305.h                   |   74 +
 include/crypto/poly1305.h                     |   28 +-
 include/uapi/linux/fs.h                       |    4 +-
 lib/Makefile                                  |    2 +-
 lib/{chacha20.c => chacha.c}                  |   59 +-
 35 files changed, 5380 insertions(+), 697 deletions(-)
 rename arch/arm/crypto/{chacha20-neon-core.S => chacha-neon-core.S} (90%)
 create mode 100644 arch/arm/crypto/chacha-neon-glue.c
 delete mode 100644 arch/arm/crypto/chacha20-neon-glue.c
 create mode 100644 arch/arm/crypto/nh-neon-core.S
 create mode 100644 arch/arm/crypto/nhpoly1305-neon-glue.c
 create mode 100644 crypto/adiantum.c
 delete mode 100644 crypto/chacha20_generic.c
 create mode 100644 crypto/chacha_generic.c
 create mode 100644 crypto/nhpoly1305.c
 create mode 100644 include/crypto/chacha.h
 delete mode 100644 include/crypto/chacha20.h
 create mode 100644 include/crypto/nhpoly1305.h
 rename lib/{chacha20.c => chacha.c} (58%)

-- 
2.19.1.930.g4563a0d9d0-goog
