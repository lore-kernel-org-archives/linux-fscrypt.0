Return-Path: <SRS0=w7HQ=SL=insidesecure.com=pvanleeuwen@kernel.org>
From: Pascal Van Leeuwen <pvanleeuwen@insidesecure.com>
Subject: RE: [PATCH 0/17] Add zinc using existing algorithm implementations
Date: Tue, 9 Apr 2019 16:14:10 +0000
Message-ID: 
 <AM6PR09MB352310B03190FD2454DA259FD22D0@AM6PR09MB3523.eurprd09.prod.outlook.com>
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
 <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
 <CAHk-=wg2LJ5qQ0B2y+_6Ue62SBP4h9MLxLvn89bfcP7Cp2ac6A@mail.gmail.com>
 <AM5PR0901MB1155FD05113D6DC79A6274CED25E0@AM5PR0901MB1155.eurprd09.prod.outlook.com>
 <20190326094603.nyfi2dsnt6a6u57f@08efd375aeba>
In-Reply-To: <20190326094603.nyfi2dsnt6a6u57f@08efd375aeba>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
To: Riku Voipio <riku.voipio@iki.fi>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller  <davem@davemloft.net>,  Jason A. Donenfeld  <Jason@zx2c4.com>, Eric Biggers" <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "linux-fscrypt@vger.kernel.org" <linux-fscrypt@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>


> The firmware files for eip197(?) crypto accelerator are secrets we are
> not
> allowed download anywhere from.
>
Riku,

The driver update I'm working on will fix that issue for you ;-)
I'm planning to upstream my changes but I still need to find the right
approach for doing so.

Regards,
Pascal
