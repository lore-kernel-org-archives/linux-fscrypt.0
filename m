Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190704183017.31570-2-ard.biesheuvel@linaro.org>
	<20190726043117.GA654@gondor.apana.org.au>
	<CAKv+Gu_Pir7uU4h6GQfh2my2Fu-j2AGPLWNZKzc9_iG6n4xJNA@mail.gmail.com>
	<20190802035515.GA15758@gondor.apana.org.au>
In-Reply-To: <20190802035515.GA15758@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 3 Aug 2019 10:36:44 +0300
Message-ID: <CAKv+Gu_a-tpc4+b4aopGZxHizkOgnqkFMCTzeF0uFo5iXXf24Q@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v8 1/7] crypto: essiv - create wrapper
	template for ESSIV generation
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 2 Aug 2019 at 06:55, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Fri, Jul 26, 2019 at 12:00:20PM +0300, Ard Biesheuvel wrote:
> >
> > For Y and Z, it is not straightforward either: since the crypto API
> > permits the use of driver names in addition to the plain CRA names,
> > we'd have to infer from the first parameter which cipher is being
> > used.
>
> We don't really permit that.  It might work but it is certainly not
> guaranteed to work.  The only thing we guarantee is that the
> algorithm name and the canonical driver name will work.  For example,
> with gcm you can either say gcm(aes) or gcm_base(drv_name1, drv_name2).
>
> Anything else is not supported.
>

Understood. But that is not the problem.

The problem is that we want to instantiate a cipher based on the
cipher algorithm that is encapsulated by the skcipher, and how that is
encoded in the name is not straightforward.

To use your GCM analogy: gcm_base(ctr-ppc-spe, ghash-generic) is a
supported aead identifier, but  there is nothing in the name that
identifies the skcipher as one that encapsulates AES.

> So I would envisage something similar for essiv where essiv just has
> U, X and Y (as you said that U and X are independent) while you can
> then have an essiv_base that spells everything out in detail.
>

That might be a useful enhancement by itself, but it does not fix the
issue above. The only way to instantiate the same cipher as the one
encapsulated by "cbc-ppc-spe" is to instantiate the latter, parse the
cipher name and pass it to crypto_alloc_cipher()

> Also, do we allow anything other than HMAC for X? If not then that
> should be encoded either into the name by dropping the hmac in the
> algorithm name and adding it through the driver name, or by checking
> for it in the template creation function.
>
> What I'd like to achieve is a state where we support only what is
> currently supported and no more.
>

Yeah, that makes sense. But we have h/w drivers that instantiate
authenc(X,Y) in its entirety, and passing those driver names is
something that is supported today, so we can't just remove that.

> > > Because this is legacy stuff, I don't want it to support any more
> > > than what is currently being supported by dm-crypt.
> > >
> > > Similary for the skcipher case, given
> > >
> > >         essiv(cbc(X),Y,Z)
> > >
> > > is it ever possible for X != Y? If not then we should just make the
> > > algorithm name essiv(X,Z).
> > >
> >
> > Same problem. We'd need to instantiate the skcipher and parse the cra_name.
> >
> > Perhaps we should introduce a crypto API call that infers the cra_name
> > from a cra_driver_name?
>
> You don't need to do that.  Just copy whatever gcm does in its
> creation function when you invoke it as gcm_base.
>
> Thanks,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
