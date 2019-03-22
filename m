Return-Path: <SRS0=kiei=RZ=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au> <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
In-Reply-To: <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 22 Mar 2019 02:10:15 -0600
Message-ID: <CAHmME9rWpTzxTCjG3ynyNwgxndW3DP5+r9NmLX2AMfp1s9vB-g@mail.gmail.com>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Content-Type: text/plain; charset="UTF-8"
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 22, 2019 at 1:56 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> that implement it, the reluctance of Jason to work with the community
> to fix the issues that he identified in the crypto API means that
> WireGuard will not be able to use these, and is restricted to
> synchronous software implementations.

There's no reluctance to work with the community. I'm pretty deeply
committed to this, as evidenced by the multitudes of patch
submissions, discussions, and popping around from conference to
conference discussing with folks face to face.

> - The way WireGuard uses crypto in the kernel is essentially a
> layering violation - while we already have an asynchronous API that
> implements ChaCha20Poly1305 in a way that WireGuard /could/ benefit
> from, and while we even have support already for async accelerators
> Saying accelerators will not
> matter is a bit like saying there are no American soldiers in Iraq.
> (Note that adding async interfaces to Zinc is not the right way to
> deal with this IMO)

Geopolitics aside, as explained over and over, the point of Zinc is to
just get down simple software function calls, for instances where
async accelerators aren't available. I consider smushing it all
together to be the "layering violation".

> - I don't think Zinc changes should go through Greg's tree and have
> separate maintainers

As I've mentioned before, I'm fine with merges going whichever route
is best for merges. If Herbert thinks it'd be useful to send things in
that direction and would reduce clashes and such, then that's fine
with me.

>  in fact, I am a bit concerned about the fact
> that, after the last Zinc/WG submission in October, Jason has not
> really interacted

Such as... https://www.youtube.com/watch?v=CejbCQ5wS7Q ? November is
after October.

Anyway, I thought it good advice to not post v9 too swiftly after
plumbers, letting things calm a bit and focusing on other improvements
in Zinc in the meanwhile. I've certainly been around.

Looks like Herbert posting this might erupt another contentious thread
of bikeshedding and argument, what a bummer.
