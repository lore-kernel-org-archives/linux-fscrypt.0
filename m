Return-Path: <SRS0=X2oN=NB=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181015175424.97147-1-ebiggers@kernel.org> <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com> <20181021222341.GA742@sol.localdomain>
In-Reply-To: <20181021222341.GA742@sol.localdomain>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 22 Oct 2018 00:51:56 +0200
Message-ID: <CAHmME9oEQVTJ0xB+dpi8MKxohRfdogqnV+bN63EWTaoS5dE6Pw@mail.gmail.com>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hey Eric,

On Mon, Oct 22, 2018 at 12:23 AM Eric Biggers <ebiggers@kernel.org> wrote:
> I started a branch based on Zinc:

Nice to see. I'm heading to bed in a second, so I'll give this a
thorough read-through tomorrow, but some preliminary notes on your
comments:

> For Poly1305, for now I decided to just use the existing functions, passing 0
> for the 16-byte element is added at the end.  This causes some unnecessary
> overhead, but it's not very much.  It also results in a much larger size of
> 'struct nhpoly1305_state', but that doesn't matter too much anymore either [1].
> [1] Originally we were going to define Adiantum's hash function to be
>     Poly1305(message_length || tweak_length || tweak || NH(message)), which
>     would have made it desirable to export the Poly1305 state before NH, so that
>     it could be imported for the second hash step to avoid redundantly hashing
>     the message length and tweak.  But later we changed it to
>     Poly1305(message_length || tweak) + Poly1305(NH(message)).

Out of curiosity, why this change?

> For ChaCha, I haven't yet updated all the "Zinc" assembly to support 12 rounds.
> So far I've updated my ARM scalar implementation.  I still don't see how you
> expect people to maintain the files like chacha20-x86_64.S from which all
> comments, register aliases, etc. were removed in comparison to the original
> OpenSSL code.

For at least the ARM[64] and MIPS64 code, I think it will be feasible
to import the .pl eventually. There's an open PR from Andy importing
some of the necessary changes. For the x86_64, that might be a little
trickier, but I can take another stab at it.

> I don't see how dumping thousands of lines of undocumented,
> generated assembly code into the kernel fits with your goals of "Zinc's focus is
> on simplicity and clarity" and "inviting collaboration".

It's not totally "undocumented" and totally "dumped"; that's a bit
hyperbolic. But I can understand it's not as friendly as we'd like.
I'll try to improve that.

> Note that the
> OpenSSL-derived assembly files still have an unclear license as well.

Andy's been pretty clear about the CRYPTOGAMS aspect with me. But, as
you pointed out on lkml and in the private thread, it hasn't yet
migrated over to the CRYPTOGAMS repo. I don't think this is a cause
for immediate concern, because it seems pretty certain it will wind up
there soon enough.

> (I haven't yet gotten around to adding
> "zinc tests" for XChaCha12, though I did add "crypto tests".  Note that "crypto
> tests" are much easier to add, since all algorithms of the same type share a
> common test framework -- not the case for Zinc.)

Actually the advantage of not working with a winding abstraction layer
is that specific tests can test particular aspects of particular
primitives -- for example, by looking at different chunking patterns.
It also enables you to write tests for internal, non-exported
functions.

> nor is there a documentation file
> explaining things.

Sorry, my bad on delaying that one. I'll be sure the Documentation/
stuff is ready before posting another series.

> So please understand that until it's clear that Zinc is
> ready, I still have to have Adiantum ready to go without Zinc, just in case.

Makes sense. I do really appreciate you taking the time, though, to
try this out with Zinc as well. Thanks for that.

Regards,
Jason
