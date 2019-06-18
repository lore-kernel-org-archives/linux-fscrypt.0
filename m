Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f66.google.com ([209.85.221.66]:39088 "EHLO
        mail-wr1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729196AbfFRV2G (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 18 Jun 2019 17:28:06 -0400
Received: by mail-wr1-f66.google.com with SMTP id x4so1042120wrt.6
        for <linux-fscrypt@vger.kernel.org>; Tue, 18 Jun 2019 14:28:05 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 0/4]  crypto: switch to crypto API for ESSIV generation
Date: Tue, 18 Jun 2019 23:27:45 +0200
Message-Id: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
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

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@google.com>
Cc: dm-devel@redhat.com
Cc: linux-fscrypt@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Milan Broz <gmazyland@gmail.com>

Ard Biesheuvel (4):
  crypto: essiv - create wrapper template for ESSIV generation
  fs: crypto: invoke crypto API for ESSIV handling
  md: dm-crypt: infer ESSIV block cipher from cipher string directly
  md: dm-crypt: switch to ESSIV crypto API template

 crypto/Kconfig              |   4 +
 crypto/Makefile             |   1 +
 crypto/essiv.c              | 624 ++++++++++++++++++++
 drivers/md/Kconfig          |   1 +
 drivers/md/dm-crypt.c       | 237 ++------
 fs/crypto/Kconfig           |   1 +
 fs/crypto/crypto.c          |   5 -
 fs/crypto/fscrypt_private.h |   9 -
 fs/crypto/keyinfo.c         |  88 +--
 9 files changed, 675 insertions(+), 295 deletions(-)
 create mode 100644 crypto/essiv.c

-- 
2.17.1
