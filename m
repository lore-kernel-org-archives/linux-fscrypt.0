Return-Path: <SRS0=3Fs2=RZ=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
In-Reply-To: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 22 Mar 2019 08:56:39 +0100
Message-ID: <CAKv+Gu_mgyzqUCeb+wke--8Gn8YbjOb8jyrSgFr3-tcNP8ccEQ@mail.gmail.com>
Subject: Re: [PATCH 0/17] Add zinc using existing algorithm implementations
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 22 Mar 2019 at 07:28, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Hi:
>
> In the interest of moving forward with wireguard, this patch
> series adds the zinc interface as submitted in
>
> https://patchwork.kernel.org/project/linux-crypto/list/?series=32507&state=*
>
> with the change that existing implementations of chacha20 and
> poly1305 are used instead of the new ones.  The use of the existing
> chacha20/poly1305 implementations does not involve any use of the
> crypto API or indirect function calls.  Only direct function calls
> are made into the underlying implementation.
>
> This should allow the wireguard code itself to proceed.  At the
> same time we can also move forward with replacing the existing
> implementations of chacha20 and/or poly1305 where appropriate.
>

Hi Herbert,

Let me reiterate some of my concerns with Zinc, which aren't really
addressed by your patches afaict.

- The way WireGuard uses crypto in the kernel is essentially a
layering violation - while we already have an asynchronous API that
implements ChaCha20Poly1305 in a way that WireGuard /could/ benefit
from, and while we even have support already for async accelerators
that implement it, the reluctance of Jason to work with the community
to fix the issues that he identified in the crypto API means that
WireGuard will not be able to use these, and is restricted to
synchronous software implementations. Saying accelerators will not
matter is a bit like saying there are no American soldiers in Iraq.
(Note that adding async interfaces to Zinc is not the right way to
deal with this IMO)
- I think it is fine to have a 'blessed' set of software crypto in the
kernel that we standardize on for internal use cases but WireGuard is
not one of them. Having two separate s/w crypto stacks is a problem,
and I don't think it helps to have a cute name either.
- I don't think Zinc changes should go through Greg's tree and have
separate maintainers - in fact, I am a bit concerned about the fact
that, after the last Zinc/WG submission in October, Jason has not
really interacted with the linux-crypto community at all, while at lot
of work was being done (especially by Eric) to address issues that he
helped identify. So letting Jason (and Samuel, who has not chimed in
at all, IIRC) maintain something that is relevant to crypto in the
kernel, but without a community and without involvement of the
linux-crypto maintainer is not acceptable to me. (In general, people
tend to join a community before being volunteered to maintain its
codebase)

I am among the people who really want to see WireGuard merged. But the
whole Zinc thing is an unnecessary distraction from getting the
existing crypto API fixed in places where it fails to support
WireGuard's use case, and that is a loss for WireGuard users as well
as the linux-crypto community.

-- 
Ard.
