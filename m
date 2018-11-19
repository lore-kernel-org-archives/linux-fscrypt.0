Return-Path: <SRS0=NMRA=N6=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com> <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au> <CAHmME9oXAnD0sbO2cKeTtotCMohX2Hu6P=uzA_6u0EWECU9Bpg@mail.gmail.com>
 <20181119225414.GB258711@gmail.com>
In-Reply-To: <20181119225414.GB258711@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 20 Nov 2018 00:15:17 +0100
Message-ID: <CAHmME9okRjuYUiL0D=6ZmtMX6rvxU+0xvy2tva+LetjU9itx8Q@mail.gmail.com>
Subject: Re: [RFC PATCH] zinc chacha20 generic implementation using crypto API code
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On Mon, Nov 19, 2018 at 11:54 PM Eric Biggers <ebiggers@kernel.org> wrote:
> Will v9 include a documentation file for Zinc in Documentation/crypto/?
> That's been suggested several times.

I had started writing that there, but then thought that the requested
information could go in the commit message instead. But I'm guessing
you're asking again now because you poked into the repo and didn't
find the Documentation/, so presumably you still want it. I can
reorganize the presentation of that to be more suitable for
Documentation/, and I'll have that for v9.

> I'd still prefer to see the conversion patches included.  Skipping them would be
> kicking the can down the road and avoiding issues that will need to be addressed
> anyway.  Like you, I don't want a "half-baked concoction that will be maybe
> possibly be replaced 'later'" :-)

Okay, fair enough. Will do.

> Either way though, it would make things much easier if you at least named the
> files, structures, constants, etc. "ChaCha" rather than "ChaCha20" from the
> start where appropriate.  For an example, see the commit "crypto: chacha -
> prepare for supporting non-20-round variants" on my "adiantum-zinc" branch:
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/commit/?h=adiantum-zinc&id=754af8d7d39f31238114426e39786c84d7cc0f98
> Then the actual introduction of the 12-round variant is much less noisy.

That's a good idea. I'll do it like that. I'll likely order it as what
we have now (renamed to omit the 20), and then put the 12 stuff on top
of that, so it's easier to see what's changed in the process. I
noticed in that branch, you didn't port the assembly to support fewer
rounds. Shall I follow suite, and then expect patches from you later
doing that? Or were you expecting me to also port the architecture
implementations to chacha12 as well?

Regards,
Jason
