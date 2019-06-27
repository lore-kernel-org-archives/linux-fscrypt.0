Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35830 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725770AbfF0Qjl (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 27 Jun 2019 12:39:41 -0400
Date: Thu, 27 Jun 2019 09:39:38 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v5 2/7] fs: crypto: invoke crypto API for ESSIV handling
Message-ID: <20190627163938.GD686@sol.localdomain>
References: <20190626204047.32131-1-ard.biesheuvel@linaro.org>
 <20190626204047.32131-3-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626204047.32131-3-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 26, 2019 at 10:40:42PM +0200, Ard Biesheuvel wrote:
> diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> index dcd91a3fbe49..82c7eb86ca00 100644
> --- a/fs/crypto/keyinfo.c
> +++ b/fs/crypto/keyinfo.c
> @@ -19,8 +19,6 @@
>  #include <crypto/skcipher.h>
>  #include "fscrypt_private.h"

Can you remove the includes that become unused as a result of this patch?

#include <crypto/aes.h>
#include <crypto/sha.h>

> @@ -495,7 +412,6 @@ static void put_crypt_info(struct fscrypt_info *ci)
>  		put_master_key(ci->ci_master_key);
>  	} else {
>  		crypto_free_skcipher(ci->ci_ctfm);
> -		crypto_free_cipher(ci->ci_essiv_tfm);
>  	}
>  	kmem_cache_free(fscrypt_info_cachep, ci);

Nit: should remove the curly braces here.

- Eric
