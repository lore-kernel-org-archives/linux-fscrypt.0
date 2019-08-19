Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f68.google.com ([209.85.221.68]:35275 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726736AbfHSOO2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 19 Aug 2019 10:14:28 -0400
Received: by mail-wr1-f68.google.com with SMTP id k2so8899694wrq.2
        for <linux-fscrypt@vger.kernel.org>; Mon, 19 Aug 2019 07:14:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
 <20190815192858.28125-2-ard.biesheuvel@linaro.org> <20190819063218.GA31821@gondor.apana.org.au>
In-Reply-To: <20190819063218.GA31821@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 19 Aug 2019 17:14:25 +0300
Message-ID: <CAKv+Gu9Zcaq5gygGtgmf5f4L6U6sBDd0CVAzrBydjiLDenyrag@mail.gmail.com>
Subject: Re: [PATCH v12 1/4] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 19 Aug 2019 at 09:32, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Thu, Aug 15, 2019 at 10:28:55PM +0300, Ard Biesheuvel wrote:
> >
> > +     /* Synchronous hash, e.g., "sha256" */
> > +     ictx->hash = crypto_alloc_shash(shash_name, 0, 0);
> > +     if (IS_ERR(ictx->hash)) {
> > +             err = PTR_ERR(ictx->hash);
> > +             goto out_drop_skcipher;
> > +     }
>
> Holding a reference to this algorithm for the life-time of the
> instance is not nice.  How about just doing a lookup as you were
> doing before with crypto_alg_mod_lookup and getting the cra_name
> from that?
>

OK, but it should be the cra_driver_name not the cra_name. Otherwise,
allocating essiv(cbc(aes),sha256-generic) may end up using a different
implementation of sha256, which would be bad.
