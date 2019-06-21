Return-Path: <SRS0=1lvV=UU=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-2-ard.biesheuvel@linaro.org> <20190620010417.GA722@sol.localdomain>
 <20190620011325.phmxmeqnv2o3wqtr@gondor.apana.org.au> <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
 <20190620125339.gqup5623sw4xrsmi@gondor.apana.org.au> <CAKv+Gu_z3oMB-XBHRrNWpXNbSmb4CFC8VNn8s+8bOd-JjiakqQ@mail.gmail.com>
 <20190620134045.fncibzc7eyufd5sj@gondor.apana.org.au> <CAKv+Gu8OFbDJGoYw_DHresF5HJDSamtw1YtZ13gpOVJCYV+22Q@mail.gmail.com>
 <20190621010657.foscl7aaxlx7tfuy@gondor.apana.org.au>
In-Reply-To: <20190621010657.foscl7aaxlx7tfuy@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 21 Jun 2019 07:39:21 +0200
Message-ID: <CAKv+Gu9DuYvMA7yOTT3p75hvNHY_LOaDBE_oCdxB=SRFZ7U-kA@mail.gmail.com>
Subject: Re: [PATCH v3 1/6] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 21 Jun 2019 at 03:07, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Thu, Jun 20, 2019 at 03:53:45PM +0200, Ard Biesheuvel wrote:
> >
> > We'd need at least 512 and 4k for dm-crypt, but I don't think the
> > sector size is limited at all tbh
>
> In that case my preference would be to encode this into the key
> and hardware that encounters unsupported sector sizes can use a
> fallback.
>

OTOH, it also depends on what makes sense to implement in practice.

Gilad, I suppose sector size 512 is an obvious win, since the OS
always fetches at least 8 consective ones at a time. Do you see a
benefit for other sector sizes as well?
