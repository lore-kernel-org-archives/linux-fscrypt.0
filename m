Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55436 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932641AbeBLXz7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 12 Feb 2018 18:55:59 -0500
Received: by mail-it0-f66.google.com with SMTP id b66so8950929itd.5
        for <linux-fscrypt@vger.kernel.org>; Mon, 12 Feb 2018 15:55:59 -0800 (PST)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v2 0/5] crypto: Speck support
Date: Mon, 12 Feb 2018 15:52:04 -0800
Message-Id: <20180212235209.117393-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

This series adds Speck support to the crypto API, including the Speck128
and Speck64 variants.  Speck is a lightweight block cipher that can be
much faster than AES on processors that don't have AES instructions.

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

Thus, patch 1 adds a generic implementation of Speck, and the following
patches add a 32-bit ARM NEON implementation of Speck-XTS.  The
NEON-accelerated implementation is much faster than the generic
implementation and therefore is the implementation that would primarily
be used in practice on the devices we are targeting.

There is no AArch64 implementation added, since such CPUs are likely to
have the Cryptography Extensions, allowing the use of AES.

Changed since v1:

  - Use the word order recommended by the Speck authors.  All test
    vectors were updated.

Eric Biggers (5):
  crypto: add support for the Speck block cipher
  crypto: speck - export common helpers
  crypto: arm/speck - add NEON-accelerated implementation of Speck-XTS
  crypto: speck - add test vectors for Speck128-XTS
  crypto: speck - add test vectors for Speck64-XTS

 arch/arm/crypto/Kconfig           |    6 +
 arch/arm/crypto/Makefile          |    2 +
 arch/arm/crypto/speck-neon-core.S |  432 +++++++++++
 arch/arm/crypto/speck-neon-glue.c |  290 ++++++++
 crypto/Kconfig                    |   14 +
 crypto/Makefile                   |    1 +
 crypto/speck.c                    |  307 ++++++++
 crypto/testmgr.c                  |   36 +
 crypto/testmgr.h                  | 1486 +++++++++++++++++++++++++++++++++++++
 include/crypto/speck.h            |   62 ++
 10 files changed, 2636 insertions(+)
 create mode 100644 arch/arm/crypto/speck-neon-core.S
 create mode 100644 arch/arm/crypto/speck-neon-glue.c
 create mode 100644 crypto/speck.c
 create mode 100644 include/crypto/speck.h

-- 
2.16.0.rc1.238.g530d649a79-goog

