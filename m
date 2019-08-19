Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from helcar.hmeau.com ([216.24.177.18]:57882 "EHLO fornost.hmeau.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728734AbfHSXfv (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 19 Aug 2019 19:35:51 -0400
Date: Tue, 20 Aug 2019 09:35:38 +1000
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v12 1/4] crypto: essiv - create wrapper template for
 ESSIV generation
Message-ID: <20190819233538.GB9089@gondor.apana.org.au>
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
 <20190815192858.28125-2-ard.biesheuvel@linaro.org>
 <20190819063218.GA31821@gondor.apana.org.au>
 <CAKv+Gu9Zcaq5gygGtgmf5f4L6U6sBDd0CVAzrBydjiLDenyrag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu9Zcaq5gygGtgmf5f4L6U6sBDd0CVAzrBydjiLDenyrag@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 19, 2019 at 05:14:25PM +0300, Ard Biesheuvel wrote:
>
> OK, but it should be the cra_driver_name not the cra_name. Otherwise,
> allocating essiv(cbc(aes),sha256-generic) may end up using a different
> implementation of sha256, which would be bad.

I agree.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
