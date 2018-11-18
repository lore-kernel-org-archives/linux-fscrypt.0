Return-Path: <SRS0=wM/J=N5=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
In-Reply-To: <20181117001718.GA175522@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Sun, 18 Nov 2018 14:46:30 +0100
Message-ID: <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
Subject: Re: [RFC PATCH v3 10/15] crypto: poly1305 - use structures for key
 and accumulator
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On Sat, Nov 17, 2018 at 1:17 AM Eric Biggers <ebiggers@kernel.org> wrote:
> Do you prefer that this be merged before or after Zinc?  It seems it may still
> be a while before the community is satisfied with Zinc (and Wireguard which is
> in the same patchset), and I don't want this blocked unnecessarily...  So on my
> part I'd prefer to just have this merged as-is.

Personally I'd prefer this be merged after Zinc, since there's work to
be done on adjusting the 20->12 in chacha20. That's not really much of
a reason though. But maybe we can just sidestep the ordering concern
all together:

What I suspect we should do is make the initial Zinc merge _without_
those top two patches that replace the crypto api's implementations
with Zinc, and defer those until after the initial merges. Those
commits are already written -- so there's no chance it won't happen
due to laziness or something -- and I think the general merge will go
a bit more smoothly if we wait until after. (Somebody suggested we do
it this way at Plumbers, and was actually a bit surprised I had
already ported the crypto API stuff to Zinc.) This way, Adiantum and
Zinc aren't potentially co-dependent in their initial merges and we
can work on the details carefully with each other after both have
landed. I figure this might make things a little bit less stressful
for both of us. How would you feel about doing it that?

Jason
