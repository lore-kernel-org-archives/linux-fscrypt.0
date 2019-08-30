Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from helcar.hmeau.com ([216.24.177.18]:59506 "EHLO fornost.hmeau.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725648AbfH3E6h (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Aug 2019 00:58:37 -0400
Date: Fri, 30 Aug 2019 14:58:23 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v13 1/6] crypto: essiv - create wrapper template for
 ESSIV generation
Message-ID: <20190830045822.GA17901@gondor.apana.org.au>
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
 <20190819141738.1231-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819141738.1231-2-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 19, 2019 at 05:17:33PM +0300, Ard Biesheuvel wrote:
> Implement a template that wraps a (skcipher,shash) or (aead,shash) tuple
> so that we can consolidate the ESSIV handling in fscrypt and dm-crypt and
> move it into the crypto API. This will result in better test coverage, and
> will allow future changes to make the bare cipher interface internal to the
> crypto subsystem, in order to increase robustness of the API against misuse.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  crypto/Kconfig  |  28 +
>  crypto/Makefile |   1 +
>  crypto/essiv.c  | 663 ++++++++++++++++++++
>  3 files changed, 692 insertions(+)

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
