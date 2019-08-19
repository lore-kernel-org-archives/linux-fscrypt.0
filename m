Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from helcar.hmeau.com ([216.24.177.18]:57698 "EHLO fornost.hmeau.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725308AbfHSGcb (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 19 Aug 2019 02:32:31 -0400
Date: Mon, 19 Aug 2019 16:32:18 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v12 1/4] crypto: essiv - create wrapper template for
 ESSIV generation
Message-ID: <20190819063218.GA31821@gondor.apana.org.au>
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
 <20190815192858.28125-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815192858.28125-2-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Aug 15, 2019 at 10:28:55PM +0300, Ard Biesheuvel wrote:
>
> +	/* Synchronous hash, e.g., "sha256" */
> +	ictx->hash = crypto_alloc_shash(shash_name, 0, 0);
> +	if (IS_ERR(ictx->hash)) {
> +		err = PTR_ERR(ictx->hash);
> +		goto out_drop_skcipher;
> +	}

Holding a reference to this algorithm for the life-time of the
instance is not nice.  How about just doing a lookup as you were
doing before with crypto_alg_mod_lookup and getting the cra_name
from that?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
