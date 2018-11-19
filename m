Return-Path: <SRS0=NMRA=N6=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com> <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
In-Reply-To: <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 19 Nov 2018 07:13:07 +0100
Message-ID: <CAHmME9oXAnD0sbO2cKeTtotCMohX2Hu6P=uzA_6u0EWECU9Bpg@mail.gmail.com>
Subject: Re: [RFC PATCH] zinc chacha20 generic implementation using crypto API code
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Herbert,

On Mon, Nov 19, 2018 at 6:25 AM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> My proposal is to merge the zinc interface as is, but to invert
> how we place the algorithm implementations.  IOW the implementations
> should stay where they are now, with in the crypto API.  However,
> we will provide direct access to them for zinc without going through
> the crypto API.  IOW we'll just export the functions directly.

Sorry, but there isn't a chance I'll agree to this. The whole idea is
to have a clean place to focus on synchronous software
implementations, and not keep it tangled up with the asynchronous API.
If WireGuard and Zinc go in, it's going to be done right, not in a way
that introduces more problems and organizational complexity. Avoiding
the solution proposed here is kind of the point. And given that
cryptographic code is so security sensitive, I want to make sure this
is done right, as opposed to rushing it with some half-baked
concoction that will be maybe possibly be replaced "later". From
talking to folks at Plumbers, I believe most of the remaining issues
are taken care of by the upcoming v9, and that you're overstating the
status of discussions regarding that.

I think the remaining issue right now is how to order my series and
Eric's series. If Eric's goes in first, it means that I can either a)
spend some time developing Zinc further _now_ to support chacha12 and
keep the top two conversion patches, or b) just drop the top two
conversion patches and work that out carefully with Eric after. I
think (b) would be better, but I'm happy to do (a) if you disagree.
And as I mentioned in the last email, I'd prefer Eric's work to go in
after Zinc, but I don't think the reasoning for that is particularly
strong, so it seems fine to merge Eric's work first.

I'll post v9 pretty soon and you can see how things are shaping up.
Hopefully before then Eric/Ard/you can provide some feedback on
whether you'd prefer (a) or (b) above.

Regards,
Jason
