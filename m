Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33912 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725890AbfF2EXa (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 29 Jun 2019 00:23:30 -0400
Date: Fri, 28 Jun 2019 21:23:27 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v6 1/7] crypto: essiv - create wrapper template for ESSIV
 generation
Message-ID: <20190629042327.GB886@sol.localdomain>
References: <20190628152112.914-1-ard.biesheuvel@linaro.org>
 <20190628152112.914-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628152112.914-2-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jun 28, 2019 at 05:21:06PM +0200, Ard Biesheuvel wrote:
> Implement a template that wraps a (skcipher,cipher,shash) or
> (aead,cipher,shash) tuple so that we can consolidate the ESSIV handling
> in fscrypt and dm-crypt and move it into the crypto API. This will result
> in better test coverage, and will allow future changes to make the bare
> cipher interface internal to the crypto subsystem, in order to increase
> robustness of the API against misuse.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  crypto/Kconfig  |   4 +
>  crypto/Makefile |   1 +
>  crypto/essiv.c  | 640 ++++++++++++++++++++
>  3 files changed, 645 insertions(+)
> 
> diff --git a/crypto/Kconfig b/crypto/Kconfig
> index 3d056e7da65f..1aa47087c1a2 100644
> --- a/crypto/Kconfig
> +++ b/crypto/Kconfig
> @@ -1917,6 +1917,10 @@ config CRYPTO_STATS
>  config CRYPTO_HASH_INFO
>  	bool
>  
> +config CRYPTO_ESSIV
> +	tristate
> +	select CRYPTO_AUTHENC
> +

One more request: can you make this symbol explicitly selectable, with prompt
string and help text?

As discussed earlier, to reduce bloat I don't really want FS_ENCRYPTION to
select this.  So the user will need a way to select CRYPTO_ESSIV if they need
it.

- Eric
