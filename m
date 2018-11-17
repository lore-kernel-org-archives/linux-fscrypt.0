Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:34136 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729957AbeKQKbx (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 17 Nov 2018 05:31:53 -0500
Date: Fri, 16 Nov 2018 16:17:19 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v3 10/15] crypto: poly1305 - use structures for key
 and accumulator
Message-ID: <20181117001718.GA175522@gmail.com>
References: <20181105232526.173947-1-ebiggers@kernel.org>
 <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com>
 <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Herbert,

On Fri, Nov 16, 2018 at 02:02:27PM +0800, Herbert Xu wrote:
> Hi Eric:
> 
> On Mon, Nov 12, 2018 at 10:58:17AM -0800, Eric Biggers wrote:
> >
> > I prefer separate types so that the type system enforces that a key is never
> > accidentally used as an accumulator, and vice versa.  Then the poly1305_core_*
> > functions will be harder to misuse, and the Poly1305 MAC implementations harder
> > to get wrong.
> > 
> > The key also has certain bits clear whereas the accumulator does not.  In the
> > future, the Poly1305 C implementation might use base 2^32 and take advantage of
> > this.  In that case, the two inputs to each multiplication won't be
> > interchangeable, so using the same type for both would be extra confusing.
> > 
> > Having a poly1305_val nested inside poly1305_key and poly1305_state would work,
> > but seemed excessive.
> 
> So it looks like there are no more unresolved issues with this
> patch series.  Please let me know when you want it to go in.
> 

I believe it's ready to go in.  I'll need to rebase it onto cryptodev, to
resolve some small conflicts with the recent ChaCha20-related changes.  Also
I'll probably omit the fscrypt patch (patch 15/15) so that that patch can be
taken through the fscrypt tree instead.

Do you prefer that this be merged before or after Zinc?  It seems it may still
be a while before the community is satisfied with Zinc (and Wireguard which is
in the same patchset), and I don't want this blocked unnecessarily...  So on my
part I'd prefer to just have this merged as-is.

Of course, it's always possible to change the xchacha12 and xchacha20
implementations later, whether that's to use "Zinc" or otherwise.  And
NHPoly1305 and Adiantum itself will be the same either way, except that the
Poly1305 helpers may change slightly.

What do you think?

Thanks!

- Eric
