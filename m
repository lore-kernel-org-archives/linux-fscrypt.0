Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54512 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725308AbfFZEdA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 26 Jun 2019 00:33:00 -0400
Date: Tue, 25 Jun 2019 21:32:58 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3 6/6] crypto: arm64/aes - implement accelerated
 ESSIV/CBC mode
Message-ID: <20190626043258.GA23471@sol.localdomain>
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-7-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619162921.12509-7-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 19, 2019 at 06:29:21PM +0200, Ard Biesheuvel wrote:
> Add an accelerated version of the 'essiv(cbc(aes),aes,sha256)'
> skcipher, which is used by fscrypt, and in some cases, by dm-crypt.
> This avoids a separate call into the AES cipher for every invocation.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This patch causes a self-tests failure:

[   26.787681] alg: skcipher: essiv-cbc-aes-sha256-neon encryption test failed (wrong result) on test vector 1, cfg="two even aligned splits"

- Eric
