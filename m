Return-Path: <SRS0=+oNo=N7=gondor.apana.org.au=herbert@kernel.org>
Date: Tue, 20 Nov 2018 11:06:35 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] zinc chacha20 generic implementation using crypto
 API code
Message-ID: <20181120030635.xfr543j5nngxfnxk@gondor.apana.org.au>
References: <20181105232526.173947-1-ebiggers@kernel.org>
 <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <CAHmME9oXAnD0sbO2cKeTtotCMohX2Hu6P=uzA_6u0EWECU9Bpg@mail.gmail.com>
 <20181119225414.GB258711@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119225414.GB258711@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Nov 19, 2018 at 02:54:15PM -0800, Eric Biggers wrote:
>
> > I think the remaining issue right now is how to order my series and
> > Eric's series. If Eric's goes in first, it means that I can either a)
> > spend some time developing Zinc further _now_ to support chacha12 and
> > keep the top two conversion patches, or b) just drop the top two
> > conversion patches and work that out carefully with Eric after. I
> > think (b) would be better, but I'm happy to do (a) if you disagree.
> > And as I mentioned in the last email, I'd prefer Eric's work to go in
> > after Zinc, but I don't think the reasoning for that is particularly
> > strong, so it seems fine to merge Eric's work first.
> > 
> > I'll post v9 pretty soon and you can see how things are shaping up.
> > Hopefully before then Eric/Ard/you can provide some feedback on
> > whether you'd prefer (a) or (b) above.
> > 
> 
> I'd still prefer to see the conversion patches included.  Skipping them would be
> kicking the can down the road and avoiding issues that will need to be addressed
> anyway.  Like you, I don't want a "half-baked concoction that will be maybe
> possibly be replaced 'later'" :-)

Are you guys talking about the conversion patches to eliminate the
two copies of chacha code that would otherwise exist in crypto as
well as in zinc?

If so I think that's not negotiable.  Having two copies of the same
code is just not acceptable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
