Return-Path: <SRS0=z2KQ=R5=linaro.org=riku.voipio@kernel.org>
Date: Tue, 26 Mar 2019 09:46:03 +0000
From: Riku Voipio <riku.voipio@iki.fi>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Message-ID: <20190326094603.nyfi2dsnt6a6u57f@08efd375aeba>
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
 <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
 <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
 <AM5PR0901MB1155FD05113D6DC79A6274CED25E0@AM5PR0901MB1155.eurprd09.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM5PR0901MB1155FD05113D6DC79A6274CED25E0@AM5PR0901MB1155.eurprd09.prod.outlook.com>
To: Pascal Van Leeuwen <pvanleeuwen@insidesecure.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 25, 2019 at 09:10:08AM +0000, Pascal Van Leeuwen wrote:
> As someone who has been working on crypto acceleration hardware for the better
> part of the past 20 years, I feel compelled to respond to this, in defence of
> the crypto API (which we're really happy with ...).

Thanks for joining in.

> We have done plenty of measurements, on both power and performance, to prove
> you wrong there. Typically our HW needs *at least* a full order of a magnitude
> less power to do the actual work. The CPU load for handing the interrupts etc.
> tends to be around 20%. So assuming the CPU goes to sleep for the other 80%
> of the time,  the combined solution would need about 1/3rd of the power of a
> CPU only solution. It's one of our biggest selling points.

I actually have the kind of (relatively) low-power system with your crypto
accelerator IP. But it doesn't matter how great performance or energy saving
I would get from using crypto offloading. I will continue to use CPU only
solution for the foreseeable future.

Because of one tiny problem:

The firmware files for eip197(?) crypto accelerator are secrets we are not
allowed download anywhere from.

> Pascal van Leeuwen,
> Silicon IP Architect @ Inside Secure

Riku
