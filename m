Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v5 0/7] crypto: switch to crypto API for ESSIV generation
Date: Wed, 26 Jun 2019 22:40:40 +0200
Message-Id: <20190626204047.32131-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-crypto-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

This series creates an ESSIV template that produces a skcipher or AEAD
transform based on a tuple of the form '<skcipher>,<cipher>,<shash>'
(or '<aead>,<cipher>,<shash>' for the AEAD case). It exposes the
encapsulated sync or async skcipher/aead by passing through all operations,
while using the cipher/shash pair to transform the input IV into an ESSIV
output IV.

This matches what both users of ESSIV in the kernel do, and so it is proposed
as a replacement for those, in patches #2 and #4.

This code has been tested using the fscrypt test suggested by Eric
(generic/549), as well as the mode-test script suggested by Milan for
the dm-crypt case. I also tested the aead case in a virtual machine,
but it definitely needs some wider testing from the dm-crypt experts.

The consensus appears to be that it would be useful if the crypto API
encapsulates the handling of multiple subsequent blocks that are
encrypted using a 64-bit LE counter as IV, and makes it the duty of
the algo to increment the counter between blocks. However, this is
equally suitable for non-ESSIV transforms (or even more so), and so
this is left as a future enhancement to  be applied on top.

Changes since v4:
- make the ESSIV template IV size equal the IV size of the encapsulated
  cipher - defining it as 8 bytes was needlessly restrictive, and also
  complicated the code for no reason
- add a missing kfree() spotted by Smatch
- add additional algo length name checks when constructing the essiv()
  cipher name
- reinstate the 'essiv' IV generation implementation in dm-crypt, but
  make its generation function identical to plain64le (and drop the other
  methods)
- fix a bug in the arm64 CE/NEON code
- simplify the arm64 code by reusing more of the existing CBC implementation
  (patch #6 is new to this series and was added for this reason)

Changes since v3:
- address various review comments from Eric on patch #1
- use Kconfig's 'imply' instead of 'select' to permit CRYPTO_ESSIV to be
  enabled as a module or disabled entirely even if fscrypt is compiled in (#2)
- fix an issue in the AEAD encrypt path caused by the IV being clobbered by
  the inner skcipher before the hmac was being calculated

Changes since v2:
- fixed a couple of bugs that snuck in after I'd done the bulk of my
  testing
- some cosmetic tweaks to the ESSIV template skcipher setkey function
  to align it with the aead one
- add a test case for essiv(cbc(aes),aes,sha256)
- add an accelerated implementation for arm64 that combines the IV
  derivation and the actual en/decryption in a single asm routine

Scroll down for tcrypt speed test result comparing the essiv template
with the asm implementation. Bare cbc(aes) tests included for reference
as well. Taken on a 2GHz Cortex-A57 (AMD Seattle)

Code can be found here
https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/log/?h=essiv-v5

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@google.com>
Cc: dm-devel@redhat.com
Cc: linux-fscrypt@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Milan Broz <gmazyland@gmail.com>

Ard Biesheuvel (7):
  crypto: essiv - create wrapper template for ESSIV generation
  fs: crypto: invoke crypto API for ESSIV handling
  md: dm-crypt: infer ESSIV block cipher from cipher string directly
  md: dm-crypt: switch to ESSIV crypto API template
  crypto: essiv - add test vector for essiv(cbc(aes),aes,sha256)
  crypto: arm64/aes-cts-cbc - factor out CBC en/decryption of a walk
  crypto: arm64/aes - implement accelerated ESSIV/CBC mode

 arch/arm64/crypto/aes-glue.c  | 205 +++++--
 arch/arm64/crypto/aes-modes.S |  29 +-
 crypto/Kconfig                |   4 +
 crypto/Makefile               |   1 +
 crypto/essiv.c                | 636 ++++++++++++++++++++
 crypto/tcrypt.c               |   9 +
 crypto/testmgr.c              |   6 +
 crypto/testmgr.h              | 213 +++++++
 drivers/md/Kconfig            |   1 +
 drivers/md/dm-crypt.c         | 229 ++-----
 fs/crypto/Kconfig             |   1 +
 fs/crypto/crypto.c            |   5 -
 fs/crypto/fscrypt_private.h   |   9 -
 fs/crypto/keyinfo.c           |  88 +--
 14 files changed, 1111 insertions(+), 325 deletions(-)
 create mode 100644 crypto/essiv.c

-- 
2.20.1
