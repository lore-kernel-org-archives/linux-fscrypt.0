Return-Path: <SRS0=+dPw=N7=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com> <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au> <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
In-Reply-To: <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 20 Nov 2018 17:18:24 +0100
Message-ID: <CAHmME9qOFA2hEe-8hb3CxEPsLbwNm8oev4SO5WBDhA+pxqadGA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through zinc
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Herbert,

On Tue, Nov 20, 2018 at 7:02 AM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Here is an updated version demonstrating how we could access the
> accelerated versions of chacha20.  It also includes a final patch
> to deposit the new zinc version of x86-64 chacha20 into
> arch/x86/crypto where it can be used by both the crypto API as well
> as zinc.

N'ack. As I mentioned in the last email, this really isn't okay, and
mostly defeats the purpose of Zinc in the first place, adding
complexity in a discombobulated half-baked way. Your proposal seems to
be the worst of all worlds. Having talked to lots of people about the
design of Zinc at this point to very positive reception, I'm going to
move forward with submitting v9, once I rebase with the required
changes for Eric's latest merge.

Jason
