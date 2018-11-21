Return-Path: <SRS0=NNaM=OA=gondor.apana.org.au=herbert@kernel.org>
Date: Wed, 21 Nov 2018 15:55:02 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through
 zinc
Message-ID: <20181121075502.zch53qoc66lh6z22@gondor.apana.org.au>
References: <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
 <CAKv+Gu-SHS2tF665dfqSgmH5EF5vGVtef=3_4WgCE=+8+Jw7Rw@mail.gmail.com>
 <20181120141850.zjmfwcari5kykk6y@gondor.apana.org.au>
 <CAHmME9oPGkvEmqvfbav-AOf_P=Z4zWYxvqD3a3QhuOSh_OWd_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9oPGkvEmqvfbav-AOf_P=Z4zWYxvqD3a3QhuOSh_OWd_A@mail.gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Nov 20, 2018 at 05:24:41PM +0100, Jason A. Donenfeld wrote:
> On Tue, Nov 20, 2018 at 3:19 PM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > Yes.  In fact it's used for FIPS certification testing.
> > Sure, nobody sane should be doing it.  But when it comes to
> > government certification... :)
> 
> The kernel does not aim toward any FIPS certification, and we're not
> going to start bloating our designs to fulfill this. It's never been a
> goal. Maybe ask Ted to add a FIPS mode to random.c and see what
> happens... When you start arguing "because FIPS!" as your
> justification, you really hit a head scratcher.

FIPS is not the issue.  The issue is that we need to keep the
existing user-space ABI.  We can't break that.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
