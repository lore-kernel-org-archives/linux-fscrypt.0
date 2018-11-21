Return-Path: <SRS0=NNaM=OA=gondor.apana.org.au=herbert@kernel.org>
Date: Wed, 21 Nov 2018 14:01:03 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through
 zinc
Message-ID: <20181121060103.4s2byjn2fh2mglno@gondor.apana.org.au>
References: <20181105232526.173947-1-ebiggers@kernel.org>
 <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
 <CAHmME9qOFA2hEe-8hb3CxEPsLbwNm8oev4SO5WBDhA+pxqadGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9qOFA2hEe-8hb3CxEPsLbwNm8oev4SO5WBDhA+pxqadGA@mail.gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Nov 20, 2018 at 05:18:24PM +0100, Jason A. Donenfeld wrote:
>
> N'ack. As I mentioned in the last email, this really isn't okay, and
> mostly defeats the purpose of Zinc in the first place, adding
> complexity in a discombobulated half-baked way. Your proposal seems to
> be the worst of all worlds. Having talked to lots of people about the
> design of Zinc at this point to very positive reception, I'm going to
> move forward with submitting v9, once I rebase with the required
> changes for Eric's latest merge.

Do you have any actual technical reasons for rejecting this apart
from your apparent hatred of the existing crypto API?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
