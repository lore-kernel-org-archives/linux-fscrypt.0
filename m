Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47076 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731678AbeKTJUM (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 20 Nov 2018 04:20:12 -0500
Date: Mon, 19 Nov 2018 14:54:15 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH] zinc chacha20 generic implementation using crypto
 API code
Message-ID: <20181119225414.GB258711@gmail.com>
References: <20181105232526.173947-1-ebiggers@kernel.org>
 <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <CAHmME9oXAnD0sbO2cKeTtotCMohX2Hu6P=uzA_6u0EWECU9Bpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9oXAnD0sbO2cKeTtotCMohX2Hu6P=uzA_6u0EWECU9Bpg@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Nov 19, 2018 at 07:13:07AM +0100, Jason A. Donenfeld wrote:
> Hi Herbert,
> 
> On Mon, Nov 19, 2018 at 6:25 AM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > My proposal is to merge the zinc interface as is, but to invert
> > how we place the algorithm implementations.  IOW the implementations
> > should stay where they are now, with in the crypto API.  However,
> > we will provide direct access to them for zinc without going through
> > the crypto API.  IOW we'll just export the functions directly.
> 
> Sorry, but there isn't a chance I'll agree to this. The whole idea is
> to have a clean place to focus on synchronous software
> implementations, and not keep it tangled up with the asynchronous API.
> If WireGuard and Zinc go in, it's going to be done right, not in a way
> that introduces more problems and organizational complexity. Avoiding
> the solution proposed here is kind of the point. And given that
> cryptographic code is so security sensitive, I want to make sure this
> is done right, as opposed to rushing it with some half-baked
> concoction that will be maybe possibly be replaced "later". From
> talking to folks at Plumbers, I believe most of the remaining issues
> are taken care of by the upcoming v9, and that you're overstating the
> status of discussions regarding that.

Will v9 include a documentation file for Zinc in Documentation/crypto/?
That's been suggested several times.

> 
> I think the remaining issue right now is how to order my series and
> Eric's series. If Eric's goes in first, it means that I can either a)
> spend some time developing Zinc further _now_ to support chacha12 and
> keep the top two conversion patches, or b) just drop the top two
> conversion patches and work that out carefully with Eric after. I
> think (b) would be better, but I'm happy to do (a) if you disagree.
> And as I mentioned in the last email, I'd prefer Eric's work to go in
> after Zinc, but I don't think the reasoning for that is particularly
> strong, so it seems fine to merge Eric's work first.
> 
> I'll post v9 pretty soon and you can see how things are shaping up.
> Hopefully before then Eric/Ard/you can provide some feedback on
> whether you'd prefer (a) or (b) above.
> 

I'd still prefer to see the conversion patches included.  Skipping them would be
kicking the can down the road and avoiding issues that will need to be addressed
anyway.  Like you, I don't want a "half-baked concoction that will be maybe
possibly be replaced 'later'" :-)

Either way though, it would make things much easier if you at least named the
files, structures, constants, etc. "ChaCha" rather than "ChaCha20" from the
start where appropriate.  For an example, see the commit "crypto: chacha -
prepare for supporting non-20-round variants" on my "adiantum-zinc" branch:
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/commit/?h=adiantum-zinc&id=754af8d7d39f31238114426e39786c84d7cc0f98
Then the actual introduction of the 12-round variant is much less noisy.

- Eric
