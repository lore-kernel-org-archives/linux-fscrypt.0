Return-Path: <SRS0=Lk93=UT=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-2-ard.biesheuvel@linaro.org> <20190620010417.GA722@sol.localdomain>
 <20190620011325.phmxmeqnv2o3wqtr@gondor.apana.org.au> <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
 <20190620125339.gqup5623sw4xrsmi@gondor.apana.org.au> <CAKv+Gu_z3oMB-XBHRrNWpXNbSmb4CFC8VNn8s+8bOd-JjiakqQ@mail.gmail.com>
 <20190620134045.fncibzc7eyufd5sj@gondor.apana.org.au>
In-Reply-To: <20190620134045.fncibzc7eyufd5sj@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 20 Jun 2019 15:53:45 +0200
Message-ID: <CAKv+Gu8OFbDJGoYw_DHresF5HJDSamtw1YtZ13gpOVJCYV+22Q@mail.gmail.com>
Subject: Re: [PATCH v3 1/6] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 20 Jun 2019 at 15:40, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Thu, Jun 20, 2019 at 03:02:04PM +0200, Ard Biesheuvel wrote:
> >
> > It also depend on how realistic it is that we will need to support
> > arbitrary sector sizes in the future. I mean, if we decide today that
> > essiv() uses an implicit sector size of 4k, we can always add
> > essiv64k() later, rather than adding lots of complexity now that we
> > are never going to use. Note that ESSIV is already more or less
> > deprecated, so there is really no point in inventing these weird and
> > wonderful things if we want people to move to XTS and plain IV
> > generation instead.
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
>

We'd need at least 512 and 4k for dm-crypt, but I don't think the
sector size is limited at all tbh
