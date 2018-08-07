Return-Path: <SRS0=dv93=KW=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180807011937.GA133621@gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806230437.21431-1-Jason@zx2c4.com>
 <20180807011937.GA133621@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 6 Aug 2018 22:38:23 -0400
Message-ID: <CAHmME9oTApV-zHD60QPryaoQf45ODpG25Da5FgB8c+LO162gWQ@mail.gmail.com>
Subject: Re: [PATCH] crypto: remove speck
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 8/6/18, Eric Biggers <ebiggers@kernel.org> wrote:
>
> For context, in your commit message can you include a link to my email
> mentioning Android's Speck decision
> (https://marc.info/?l=linux-crypto-vger&m=153359499015659)?

Sure.

>
> Also: "speck" => "Speck".

Ack.

>
> Also I think the fscrypt code points should be reserved so they don't
> get reused for something else:
>
> #define FS_ENCRYPTION_MODE_SPECK128_256_XTS    7	/* removed */
> #define FS_ENCRYPTION_MODE_SPECK128_256_CTS    8	/* removed */

I thought about this too, but it occurred to me it's highly improbable
these were ever used, and I thought it shinier not to leave scars. But
if you feel strongly about it, no problem, I'll fix that up and send
in a v2 shortly.

>
> For the record, I think the statements Paul and I have made evaluating
> Speck from a technical perspective remain substantially accurate.

It wasn't my intention to relitigate this, hence the rather short
commit message. You said your thing, Tomer said his, and now I'm just
trying to clear out the leftover soda cans.

> We've also designed and proposed
> an alternative solution for the ARMv7 disk encryption use case, HPolyC.

This sounds like a nice and interesting outcome of the whole thing.
I'll certainly be looking forward to reading analyses of HPolyC as
they come out.
