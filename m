Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57228 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726315AbfF0QcY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 27 Jun 2019 12:32:24 -0400
Date: Thu, 27 Jun 2019 09:32:21 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v5 5/7] crypto: essiv - add test vector for
 essiv(cbc(aes),aes,sha256)
Message-ID: <20190627163221.GC686@sol.localdomain>
References: <20190626204047.32131-1-ard.biesheuvel@linaro.org>
 <20190626204047.32131-6-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626204047.32131-6-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 26, 2019 at 10:40:45PM +0200, Ard Biesheuvel wrote:
> Add a test vector for the ESSIV mode that is the most widely used,
> i.e., using cbc(aes) and sha256.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  crypto/tcrypt.c  |   9 +
>  crypto/testmgr.c |   6 +
>  crypto/testmgr.h | 213 ++++++++++++++++++++
>  3 files changed, 228 insertions(+)

Shouldn't there be an authenc test vector too?  Otherwise there will be no way
to test the AEAD support in essiv.c using the crypto self-tests.

- Eric
