Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Thu, 20 Jun 2019 11:27:07 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3 1/6] crypto: essiv - create wrapper template for ESSIV
 generation
Message-ID: <20190620182706.GA246122@gmail.com>
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-2-ard.biesheuvel@linaro.org>
 <20190620010417.GA722@sol.localdomain>
 <20190620011325.phmxmeqnv2o3wqtr@gondor.apana.org.au>
 <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-OwzmoYR5uymSNghEVc9xbkkt5C8MxAYA48UE=yBgb5g@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jun 20, 2019 at 09:30:41AM +0200, Ard Biesheuvel wrote:
> On Thu, 20 Jun 2019 at 03:14, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >
> > On Wed, Jun 19, 2019 at 06:04:17PM -0700, Eric Biggers wrote:
> > >
> > > > +#define ESSIV_IV_SIZE              sizeof(u64)     // IV size of the outer algo
> > > > +#define MAX_INNER_IV_SIZE  16              // max IV size of inner algo
> > >
> > > Why does the outer algorithm declare a smaller IV size?  Shouldn't it just be
> > > the same as the inner algorithm's?
> >
> > In general we allow outer algorithms to have distinct IV sizes
> > compared to the inner algorithm.  For example, rfc4106 has a
> > different IV size compared to gcm.
> >
> > In this case, the outer IV size is the block number so that's
> > presumably why 64 bits is sufficient.  Do you forsee a case where
> > we need 128-bit block numbers?
> >
> 
> Indeed, the whole point of this template is that it turns a 64-bit
> sector number into a n-bit IV, where n equals the block size of the
> essiv cipher, and its min/max keysize covers the digest size of the
> shash.
> 
> I don't think it makes sense to generalize this further, and if I
> understand the feedback from Herbert and Gilad correctly, it would
> even be better to define the input IV as a LE 64-bit counter
> explicitly, so we can auto increment it between sectors.
> 

I was understanding ESSIV at a more abstract level, where you pass in some IV
(which may or may not contain a sector number of some particular length and
endianness) and it encrypts it.

I see that both fscrypt and dm-crypt use the convention of a __le64 sector
number though, so it's probably reasonable to define the IV to be that.  A brief
comment explaining this might be helpful, though.

- Eric
