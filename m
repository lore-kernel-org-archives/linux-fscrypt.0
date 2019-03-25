Return-Path: <SRS0=4IBS=R4=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
 <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com> <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
In-Reply-To: <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 25 Mar 2019 11:43:38 +0100
Message-ID: <CAKv+Gu_NoKi3hhxw+S59Yu_c0R6fZh8+KW1XnyFWg74MxEixGA@mail.gmail.com>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Content-Type: text/plain; charset="UTF-8"
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 22 Mar 2019 at 18:48, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Fri, Mar 22, 2019 at 12:56 AM Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
> >
> > - The way WireGuard uses crypto in the kernel is essentially a
> > layering violation
>
> What? No.
>
> That's just wrong.
>
> It's only a layering violation if you accept and buy into the crypto/ model.
>
> And Jason obviously doesn't.
>
> And honestly, I'm 1000% with Jason on this. The crypto/ model is hard
> to use, inefficient, and completely pointless when you know what your
> cipher or hash algorithm is, and your CPU just does it well directly.
>

Well, it is true that the the dynamic dispatch is annoying and we need
to fix that. And I have not given up hope that someone like Jason,
with his level of understanding of crypto, and an enticing use case
such as WireGuard, will choose to work with the linux-crypto community
to improve it rather than build something from scratch on the side.

But that is orthogonal to the sync vs async debate.

> > we even have support already for async accelerators that implement it,
>
> Afaik, none of the async accelerator code has ever been worth anything
> on real hardware and on any sane and real loads. The cost of going
> outside the CPU is *so* expensive that you'll always lose, unless the
> algorithm has been explicitly designed to be insanely hard on a
> regular CPU.
>
> (Corollary: "insanely hard on a regular CPU" is also easy to do by
> making the CPU be weak and bad. Which is not a case we should optimize
> for).
>
> The whole "external accelerator" model is odd. It was wrong. It only
> makes sense if the accelerator does *everything* (ie it's the network
> card), and then you wouldn't use the wireguard thing on the CPU at
> all, you'd have all those things on the accelerator (ie a "network
> card that does WG").
>
> One of the (best or worst, depending on your hangups) arguments for
> external accelerators has been "but I trust the external hardware with
> the key, but not my own code", aka the TPM or Disney argument.  I
> don't think that's at all relevant to the discussion either.
>
> The whole model of async accelerators is completely bogus. The only
> crypto or hash accelerator that is worth it are the ones integrated on
> the CPU cores, which have the direct access to caches.
>
> And if the accelerator is some tightly coupled thing that has direct
> access to your caches, and doesn't need interrupt overhead or address
> translation etc (at which point it can be worth using) then you might
> as well just consider it an odd version of the above. You'd want to
> poll for the result anyway, because not polling is too expensive.
>
> Just a single interrupt would completely undo all the advantages you
> got from using specialized hardware - both power and performance.
>
> And that kind of model would work just fine with zinc.
>
> So an accelerator ends up being useful in two cases:
>
>  - it's entirely external and part of the network card, so that
> there's no extra data transfer overhead
>
>  - it's tightly coupled enough (either CPU instructions or some on-die
> cache coherent engine) that you can and will just use it synchronously
> anyway.
>
> In the first case, you wouldn't run wireguard on the CPU anyway - you
> have a network card that just implements the VPN.
>
> And in the second case, the zinc model is the right one.
>
> So no. I don't believe "layering violation" is the issue here at all.
>

If the consensus is that no accelerator is likely to ever exist that
outperforms CPU crypto by any measure (latency, throughput, power
efficiency), then I don't have any objections to bolting this straight
onto a synchronous interface. My concern is that we will end up with
Zinc patches 12 months from now that implement async interfaces to
support some particular piece of hardware, while other hardware is
only supported by the crypto/ API, even though the algorithm they
implement is the same.

> The only main issue as far as I'm concerned is how to deal with the
> fact that we have duplicate code and effort.
>
>                       Linus
