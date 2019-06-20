Return-Path: <SRS0=Fopc=UT=gondor.apana.org.au=herbert@kernel.org>
Date: Thu, 20 Jun 2019 20:52:14 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 1/6] crypto: essiv - create wrapper template for ESSIV
 generation
Message-ID: <20190620125214.njibb7fauz3ezhz6@gondor.apana.org.au>
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-2-ard.biesheuvel@linaro.org>
 <20190620010417.GA722@sol.localdomain>
 <20190620011325.phmxmeqnv2o3wqtr@gondor.apana.org.au>
 <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Eric Biggers <ebiggers@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 20, 2019 at 09:30:41AM +0200, Ard Biesheuvel wrote:
>
> Is this the right approach? Or are there better ways to convey this
> information when instantiating the template?
> Also, it seems to me that the dm-crypt and fscrypt layers would
> require major surgery in order to take advantage of this.

My preference would be to encode the sector size into the key.
Hardware that can only support some sector sizes can use fallbacks
as usual.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
