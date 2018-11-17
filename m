Return-Path: <SRS0=3xn4=N4=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20181105232526.173947-1-ebiggers@kernel.org> <20181105232526.173947-11-ebiggers@kernel.org>
 <CAKv+Gu-o0khD5=0EOkv2PiczMs5uZ=XP9V=G2ogBNMK8Kb93sw@mail.gmail.com>
 <20181112185816.GA8663@gmail.com> <20181116060227.hwu4igi6bp26ddpi@gondor.apana.org.au>
 <20181117001718.GA175522@gmail.com>
In-Reply-To: <20181117001718.GA175522@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Nov 2018 16:30:20 -0800
Message-ID: <CAKv+Gu9KU9pviBsmAJUoSdBDK6Sk-7TdM0avgFdz-0AaOwaD9Q@mail.gmail.com>
Subject: Re: [RFC PATCH v3 10/15] crypto: poly1305 - use structures for key
 and accumulator
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 16 Nov 2018 at 16:17, Eric Biggers <ebiggers@kernel.org> wrote:
>
> Hi Herbert,
>
> On Fri, Nov 16, 2018 at 02:02:27PM +0800, Herbert Xu wrote:
> > Hi Eric:
> >
> > On Mon, Nov 12, 2018 at 10:58:17AM -0800, Eric Biggers wrote:
> > >
> > > I prefer separate types so that the type system enforces that a key is never
> > > accidentally used as an accumulator, and vice versa.  Then the poly1305_core_*
> > > functions will be harder to misuse, and the Poly1305 MAC implementations harder
> > > to get wrong.
> > >
> > > The key also has certain bits clear whereas the accumulator does not.  In the
> > > future, the Poly1305 C implementation might use base 2^32 and take advantage of
> > > this.  In that case, the two inputs to each multiplication won't be
> > > interchangeable, so using the same type for both would be extra confusing.
> > >
> > > Having a poly1305_val nested inside poly1305_key and poly1305_state would work,
> > > but seemed excessive.
> >
> > So it looks like there are no more unresolved issues with this
> > patch series.  Please let me know when you want it to go in.
> >
>
> I believe it's ready to go in.  I'll need to rebase it onto cryptodev, to
> resolve some small conflicts with the recent ChaCha20-related changes.  Also
> I'll probably omit the fscrypt patch (patch 15/15) so that that patch can be
> taken through the fscrypt tree instead.
>
> Do you prefer that this be merged before or after Zinc?  It seems it may still
> be a while before the community is satisfied with Zinc (and Wireguard which is
> in the same patchset), and I don't want this blocked unnecessarily...  So on my
> part I'd prefer to just have this merged as-is.
>
> Of course, it's always possible to change the xchacha12 and xchacha20
> implementations later, whether that's to use "Zinc" or otherwise.  And
> NHPoly1305 and Adiantum itself will be the same either way, except that the
> Poly1305 helpers may change slightly.
>
> What do you think?
>

I think this is ready to go in. Most of Zinc itself will not be
blocked by this, only the changes to the crypto API ChaCha20
implementation will have to wait until the Zinc version gains support
for the reduced round variant, but that will not block WireGuard.
