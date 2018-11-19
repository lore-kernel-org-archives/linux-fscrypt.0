Return-Path: <SRS0=NMRA=N6=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181015175424.97147-1-ebiggers@kernel.org> <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com> <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
 <20181116215249.GA27149@gmail.com> <56883f08-26cb-ecef-5698-1c2948714773@gmail.com>
 <20181119192821.GA258711@gmail.com> <1e9ec59a-6a2c-3536-0722-c6d96d6714b2@gmail.com>
In-Reply-To: <1e9ec59a-6a2c-3536-0722-c6d96d6714b2@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 19 Nov 2018 21:30:05 +0100
Message-ID: <CAHmME9pU79WRKWd32ihp2aQgQ1D6Kh+jh2e2sETm8tqjNxgdvg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Content-Type: text/plain; charset="UTF-8"
To: Milan Broz <gmazyland@gmail.com>
Cc: Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Nov 19, 2018 at 9:05 PM Milan Broz <gmazyland@gmail.com> wrote:
> p.s.
> Reading the discussion about Zinc/Adiantum - I would perhaps prefer to merge
> Adiantum first (if it is ready).
> It is a new feature, I see it as useful cipher alternative for dm-crypt and it can be
> esily backported without Zinc to older kernels (I am testing it actually this way).

Seems reasonable to me.

Jason
