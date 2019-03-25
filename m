Return-Path: <SRS0=AXoB=R4=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
 <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
 <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com> <CAKv+Gu_NoKi3hhxw+S59Yu_c0R6fZh8+KW1XnyFWg74MxEixGA@mail.gmail.com>
In-Reply-To: <CAKv+Gu_NoKi3hhxw+S59Yu_c0R6fZh8+KW1XnyFWg74MxEixGA@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 25 Mar 2019 11:45:21 +0100
Message-ID: <CAHmME9o4YsfLcQnChSSn7p-dr9Y9q6Ky84rVdKdPD_1=4Qtx_A@mail.gmail.com>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Content-Type: text/plain; charset="UTF-8"
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 25, 2019 at 11:43 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> onto a synchronous interface. My concern is that we will end up with
> Zinc patches 12 months from now that implement async interfaces to
> support some particular piece of hardware, while other hardware is
> only supported by the crypto/ API, even though the algorithm they
> implement is the same.

Allow me to allay that concern: Zinc is for simple synchronous
software functions.
