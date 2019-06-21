Return-Path: <SRS0=EIxF=UU=gmail.com=gmazyland@kernel.org>
Subject: Re: [PATCH v3 1/6] crypto: essiv - create wrapper template for ESSIV
 generation
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-2-ard.biesheuvel@linaro.org>
 <20190620010417.GA722@sol.localdomain>
 <20190620011325.phmxmeqnv2o3wqtr@gondor.apana.org.au>
 <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
 <20190620125339.gqup5623sw4xrsmi@gondor.apana.org.au>
 <CAKv+Gu_z3oMB-XBHRrNWpXNbSmb4CFC8VNn8s+8bOd-JjiakqQ@mail.gmail.com>
 <20190620134045.fncibzc7eyufd5sj@gondor.apana.org.au>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <8d522740-1c3c-5102-86b8-fb5428a6cb3e@gmail.com>
Date: Fri, 21 Jun 2019 08:44:24 +0200
MIME-Version: 1.0
In-Reply-To: <20190620134045.fncibzc7eyufd5sj@gondor.apana.org.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-crypto@vger.kernel.org, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 20/06/2019 15:40, Herbert Xu wrote:
> On Thu, Jun 20, 2019 at 03:02:04PM +0200, Ard Biesheuvel wrote:
>>
>> It also depend on how realistic it is that we will need to support
>> arbitrary sector sizes in the future. I mean, if we decide today that
>> essiv() uses an implicit sector size of 4k, we can always add
>> essiv64k() later, rather than adding lots of complexity now that we
>> are never going to use. Note that ESSIV is already more or less
>> deprecated, so there is really no point in inventing these weird and
>> wonderful things if we want people to move to XTS and plain IV
>> generation instead.
> 
> Well whatever we do for ESSIV should also extend to other IV
> generators in dm-crypt so that potentially we can have a single
> interface for dm-crypt multi-sector processing in future (IOW
> you don't have special code for ESSIV vs. other algos).
> 
> That is why we should get the ESSIV interface right as it could
> serve as an example for future implementations.
> 
> What do the dm-crypt people think? Are you ever going to need
> processing in units other than 4K?

For the "technical" limit, dm-crypt supports 512, 1024, 2048 and 4096-byte encryption
sector size (power of two) since commit 8f0009a225171cc1b76a6b443de5137b26e1374b.

As the commit says, the 4k limit is because of page limit where whole IO must fit
(4k is minimal page size).
I do not want to introduce devices that are created on some architecture
and cannot be opened elsewhere with a smaller page size.
But maybe some reason appears, or there is some trick we did not tried...

(I guess fs has the same limits?)

Milan
