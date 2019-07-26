Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f68.google.com ([209.85.221.68]:39835 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725842AbfGZJAe (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 26 Jul 2019 05:00:34 -0400
Received: by mail-wr1-f68.google.com with SMTP id x4so429537wrt.6
        for <linux-fscrypt@vger.kernel.org>; Fri, 26 Jul 2019 02:00:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190704183017.31570-2-ard.biesheuvel@linaro.org> <20190726043117.GA654@gondor.apana.org.au>
In-Reply-To: <20190726043117.GA654@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 26 Jul 2019 12:00:20 +0300
Message-ID: <CAKv+Gu_Pir7uU4h6GQfh2my2Fu-j2AGPLWNZKzc9_iG6n4xJNA@mail.gmail.com>
Subject: Re: [PATCH v8 1/7] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 26 Jul 2019 at 07:31, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> >
> > + * The typical use of this template is to instantiate the skcipher
> > + * 'essiv(cbc(aes),aes,sha256)', which is the only instantiation used by
> > + * fscrypt, and the most relevant one for dm-crypt. However, dm-crypt
> > + * also permits ESSIV to be used in combination with the authenc template,
> > + * e.g., 'essiv(authenc(hmac(sha256),cbc(aes)),aes,sha256)', in which case
> > + * we need to instantiate an aead that accepts the same special key format
> > + * as the authenc template, and deals with the way the encrypted IV is
> > + * embedded into the AAD area of the aead request. This means the AEAD
> > + * flavor produced by this template is tightly coupled to the way dm-crypt
> > + * happens to use it.
>
> IIRC only authenc is allowed in dm-crypt currently in conjunction
> with ESSIV.  Does it ever allow a different hash algorithm in
> authenc compared to the one used for ESSIV? IOW given
>
>         essiv(authenc(hmac(X),cbc(Y)),Z,U)
>
> is it currently possible for X != U or Y != Z? If not then let's
> just make the algorithm name be essiv(Y,X).
>

X and U are independent, since the dm-crypt userland API permits you
to specify both, and the only requirement is that the digest size of U
is a valid jey size for Z.

For Y and Z, it is not straightforward either: since the crypto API
permits the use of driver names in addition to the plain CRA names,
we'd have to infer from the first parameter which cipher is being
used.

E.g., this could be

authenc-hmac-sha1-cbc-aes-chcr
authenc-hmac-sha1-cbc-aes-iproc
authenc-hmac-sha1-cbc-aes-caam-qi
authenc-hmac-sha1-cbc-aes-ccree
safexcel-authenc-hmac-sha1-cbc-aes
authenc-hmac-sha1-cbc-aes-picoxcell
qat_aes_cbc_hmac_sha1
authenc-hmac-sha1-cbc-aes-talitos

but also

authenc(..., cbc-ppc-spe))
authenc(..., cbc-aes-s390))
authenc(..., cbc-aes-ppc4xx))
authenc(..., artpec6-cbc-aes))
authenc(..., cbc-aes-iproc))
authenc(..., cbc-aes-caam))
authenc(..., cbc-aes-caam-qi))
authenc(..., cbc-aes-caam-qi2))
authenc(..., cavium-cbc-aes))
authenc(..., n5_cbc(aes)))
authenc(..., cbc-aes-geode))
authenc(..., hisi_sec_aes_cbc))
authenc(..., safexcel-cbc-aes))
authenc(..., mv-cbc-aes))
authenc(..., cbc-aes-nx))
authenc(..., cbc-aes-padlock))
authenc(..., cbc-aes-picoxcell))
authenc(..., qat_aes_cbc))
authenc(..., cbc-aes-sun4i-ss))
authenc(..., cbc-aes-talitos))
authenc(..., cbc-des-talitos))
authenc(..., cbc-aes-ux500))
authenc(..., virtio_crypto_aes_cbc))
authenc(..., p8_aes_cbc))

where the first one does not even have the cipher in its name.

So the only way to deal with this is to instantiate the AEAD and then
parse the name.

Unfortunately, this means that patch #3 in this series is broken,
since it assumes that we can infer authenc'ness from the user
specified cipher string.

> Because this is legacy stuff, I don't want it to support any more
> than what is currently being supported by dm-crypt.
>
> Similary for the skcipher case, given
>
>         essiv(cbc(X),Y,Z)
>
> is it ever possible for X != Y? If not then we should just make the
> algorithm name essiv(X,Z).
>

Same problem. We'd need to instantiate the skcipher and parse the cra_name.

Perhaps we should introduce a crypto API call that infers the cra_name
from a cra_driver_name?
