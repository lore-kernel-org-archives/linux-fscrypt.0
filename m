Return-Path: <SRS0=q09O=M7=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181015175424.97147-1-ebiggers@kernel.org>
In-Reply-To: <20181015175424.97147-1-ebiggers@kernel.org>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 19 Oct 2018 17:58:35 +0200
Message-ID: <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello Eric,

> As before, some of these patches conflict with the new "Zinc" crypto
> library.  But I don't know when Zinc will be merged, so for now I've
> continued to base this patchset on the current 'cryptodev'.

I'd appreciate it if you waited to merge this until you can rebase it
on top of Zinc. In fact, if you already want to build it on top of
Zinc, I'm happy to work with you on that in a shared repo or similar.
We can also hash out the details of that in person in Vancouver in a
few weeks. I think pushing this in before will create undesirable
churn for both of us.

> Therefore, we (well, Paul Crowley did the real work) designed a new
> encryption mode, Adiantum.  In essence, Adiantum makes it secure to use
> the ChaCha stream cipher for disk encryption.  Adiantum is specified by
> our paper here: https://eprint.iacr.org/2018/720.pdf ("Adiantum:
> length-preserving encryption for entry-level processors").  Reference
> code and test vectors are here: https://github.com/google/adiantum.
> Most of the high-level concepts of Adiantum are not new; similar
> existing modes include XCB, HCTR, and HCH.  Adiantum and these modes are
> true wide-block modes (tweakable super-pseudorandom permutations), so
> they actually provide a stronger notion of security than XTS.

Great, I'm very happy to see you've created such a high performance alternative.

Before merging this into the kernel, do you want to wait until you've
received some public review from academia?

Jason
