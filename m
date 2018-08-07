Return-Path: <SRS0=n9St=KW=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180806223300.113891-9-ebiggers@kernel.org>
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-9-ebiggers@kernel.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 7 Aug 2018 14:09:05 +0200
Message-ID: <CAKv+Gu_T+f=isb_dBF7icfTHApG+E8Y5njSQ=NmtyTHEN2VMgg@mail.gmail.com>
Subject: Re: [RFC PATCH 8/9] crypto: arm/poly1305 - add NEON accelerated
 Poly1305 implementation
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 7 August 2018 at 00:32, Eric Biggers <ebiggers@kernel.org> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> Add the Poly1305 code from OpenSSL, which was written by Andy Polyakov.
> I took the .S file from WireGuard, whose author has made the needed
> tweaks for Linux kernel integration and verified that Andy had given
> permission for GPLv2 distribution.  I didn't make any additional changes
> to the .S file.
>
> Note, for HPolyC I'd eventually like a Poly1305 implementation that
> allows precomputing powers of the key.  But for now this implementation
> just provides the existing semantics where the key and nonce are treated
> as a "one-time key" that must be provided for every message.
>
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Hi Eric,

In the past, I worked with Andy on several occasions to get my kernel
changes incorporated into the upstream OpenSSL version of the
'perlasm' .pl file.

This achieves a number of things:
- we get a readable version of the code in the kernel tree,
- our changes are reviewed upstream
- upgrading involves grabbing the latest .pl file rather than merging
generated code (which requires careful review)
- GPLv2 permission is made explicit, rather than something someone
claims to have reached agreement on,
- no legal ambiguity whether the output of the perl script is covered
by the license (which is what we incorporate here)

Note that the 'available under GPL depending on where you obtained the
code' in the CRYPTOGAMS license likely conflicts with the GPL itself,
but I am not a lawyer so I'd much prefer having the upstream copy
mention this explicitly.
