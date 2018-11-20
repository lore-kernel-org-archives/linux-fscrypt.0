Return-Path: <SRS0=+dPw=N7=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com> <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au> <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
 <CAKv+Gu-SHS2tF665dfqSgmH5EF5vGVtef=3_4WgCE=+8+Jw7Rw@mail.gmail.com> <20181120141850.zjmfwcari5kykk6y@gondor.apana.org.au>
In-Reply-To: <20181120141850.zjmfwcari5kykk6y@gondor.apana.org.au>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 20 Nov 2018 17:24:41 +0100
Message-ID: <CAHmME9oPGkvEmqvfbav-AOf_P=Z4zWYxvqD3a3QhuOSh_OWd_A@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through zinc
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Nov 20, 2018 at 3:19 PM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Yes.  In fact it's used for FIPS certification testing.
> Sure, nobody sane should be doing it.  But when it comes to
> government certification... :)

The kernel does not aim toward any FIPS certification, and we're not
going to start bloating our designs to fulfill this. It's never been a
goal. Maybe ask Ted to add a FIPS mode to random.c and see what
happens... When you start arguing "because FIPS!" as your
justification, you really hit a head scratcher.

> They've already paid for the indirect
> function call so why make them go through yet another run-time
> branch?

The indirect function call in the crypto API is the performance hit.
The branch in Zinc is not, as the predictor does the correct thing
every single time. I'm not able to distinguish between the two looking
at the performance measurements between it being there and the branch
being commented out.

Give me a few more days to finish v9's latest required changes for
chacha12, and then I'll submit a revision that I think should address
the remaining technical objections raised over the last several months
we've been discussing this.

Regards,
Jason
