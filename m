Return-Path: <SRS0=8VlT=N7=thunk.org=tytso@kernel.org>
Date: Tue, 20 Nov 2018 13:51:54 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH v2 0/4] Exporting existing crypto API code through
 zinc
Message-ID: <20181120185154.GB6401@thunk.org>
References: <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
 <CAHmME9rtsCk8ZLt05xRKMGr4CVRnaUvCaVOS_WX3N22HOat4-A@mail.gmail.com>
 <20181119052451.qttzfgcm4hvbdc4u@gondor.apana.org.au>
 <20181120060217.t4nccaqpwnxkl4tx@gondor.apana.org.au>
 <CAKv+Gu-SHS2tF665dfqSgmH5EF5vGVtef=3_4WgCE=+8+Jw7Rw@mail.gmail.com>
 <20181120141850.zjmfwcari5kykk6y@gondor.apana.org.au>
 <CAHmME9oPGkvEmqvfbav-AOf_P=Z4zWYxvqD3a3QhuOSh_OWd_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHmME9oPGkvEmqvfbav-AOf_P=Z4zWYxvqD3a3QhuOSh_OWd_A@mail.gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Nov 20, 2018 at 05:24:41PM +0100, Jason A. Donenfeld wrote:
> On Tue, Nov 20, 2018 at 3:19 PM Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > Yes.  In fact it's used for FIPS certification testing.
> > Sure, nobody sane should be doing it.  But when it comes to
> > government certification... :)
> 
> The kernel does not aim toward any FIPS certification, and we're not
> going to start bloating our designs to fulfill this. It's never been a
> goal. Maybe ask Ted to add a FIPS mode to random.c and see what
> happens... When you start arguing "because FIPS!" as your
> justification, you really hit a head scratcher.

There are crazy people who go for FIPS certification for the kernel.
That's why crypto/drbg.c exists.  There is a crazy fips mode in
drivers/char/random.c which causes the kernel to panic with a 1 in
2**80 probability each time _extract_entropy is called.  It's not the
default, and I have no idea if any one uses it, or if it's like the
NIST OSI mandate, which forced everyone to buy an OSI networking stack
--- and then put it on the shelf and use TCP/IP instead.

Press release from March 2018:

https://www.redhat.com/en/about/press-releases/red-hat-completes-fips-140-2-re-certification-red-hat-enterprise-linux-7

    	     	       	   	     	 	- Ted
