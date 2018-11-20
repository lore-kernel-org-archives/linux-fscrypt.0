Return-Path: <SRS0=+oNo=N7=gondor.apana.org.au=herbert@kernel.org>
Date: Tue, 20 Nov 2018 22:18:50 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through
 zinc
Message-ID: <20181120141850.zjmfwcari5kykk6y@gondor.apana.org.au>
References: <20181105232526.173947-1-ebiggers@kernel.org>
 <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
 <CAKv+Gu-SHS2tF665dfqSgmH5EF5vGVtef=3_4WgCE=+8+Jw7Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu-SHS2tF665dfqSgmH5EF5vGVtef=3_4WgCE=+8+Jw7Rw@mail.gmail.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard:

On Tue, Nov 20, 2018 at 11:32:05AM +0100, Ard Biesheuvel wrote:
>
> > 1. The crypto API algorithms remain individually accessible, this
> > is crucial as these algorithm names are exported to user-space so
> > changing the names to foo-zinc is not going to work.
> 
> Are you saying user space may use names like "ctr-aes-neon" directly
> rather than "ctr(aes)" for any implementation of the mode?

Yes.  In fact it's used for FIPS certification testing.

> If so, that is highly unfortunate, since it means we'd be breaking
> user space by wrapping a crypto library function with its own arch
> specific specializations into a generic crypto API wrapper.

You can never break things by introducing new algorithms.  The
problem is only when you remove existing ones.

> Note that I think that using AF_ALG to access software crypto routines
> (as opposed to accelerators) is rather pointless to begin with, but if
> it permits that today than we're stuck with it.

Sure, nobody sane should be doing it.  But when it comes to
government certification... :)

> > 2. The arch-specific algorithm code lives in their own module rather
> > than in a monolithic module.
> 
> This is one of the remaining issues I have with Zinc. However, modulo
> the above concerns, I think it does make sense to have a separate
> function API for synchronous software routines below the current
> crypto API. What I don't want is a separate Zinc kingdom with a
> different name, different maintainers and going through a different
> tree, and with its own approach to test vectors, arch specific code,
> etc etc

Even without the issue of replacing chacha20-generic with
chacha20-zinc which breaks point 1 above, we simply don't want
or need to go through zinc's run-time implementation choice for
the crypto API algorithms.  They've already paid for the indirect
function call so why make them go through yet another run-time
branch?

If the optics of having the code in crypto is the issue, we could
move the actual algorithm code into a third location, perhaps
arch/x86/crypto/lib or arch/x86/lib/crypto.  Then both zinc and
the crypto API can sit on top of that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
