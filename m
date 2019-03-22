Return-Path: <SRS0=kiei=RZ=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
In-Reply-To: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 22 Mar 2019 00:41:34 -0600
Message-ID: <CAHmME9qSNp+T3NcL0a7xCZGn9pronRquyu=MYDN4cjd2ELFB7w@mail.gmail.com>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hey Herbert,

On Fri, Mar 22, 2019 at 12:34 AM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> This should allow the wireguard code itself to proceed.  At the
> same time we can also move forward with replacing the existing
> implementations of chacha20 and/or poly1305 where appropriate.

I'll have a long flight tomorrow to review this, but also, I should
have v9 of the patchset submitted soon, which will address a lot of
the good issues people brought up several months ago for v8. So please
sit tight while I prepare that.

Jason
