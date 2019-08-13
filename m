Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f68.google.com ([209.85.221.68]:36625 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725781AbfHMFSK (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 13 Aug 2019 01:18:10 -0400
Received: by mail-wr1-f68.google.com with SMTP id r3so12787805wrt.3
        for <linux-fscrypt@vger.kernel.org>; Mon, 12 Aug 2019 22:18:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190812145324.27090-1-ard.biesheuvel@linaro.org>
 <20190812145324.27090-2-ard.biesheuvel@linaro.org> <20190812193849.GA131059@gmail.com>
In-Reply-To: <20190812193849.GA131059@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 13 Aug 2019 08:17:56 +0300
Message-ID: <CAKv+Gu-Nk0tMST32d3cwuiwGmZmXgKRDd2h9BuW-iPeoqSN5tA@mail.gmail.com>
Subject: Re: [PATCH v10 1/7] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 12 Aug 2019 at 22:38, Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Mon, Aug 12, 2019 at 05:53:18PM +0300, Ard Biesheuvel wrote:
> > +     switch (type) {
> > +     case CRYPTO_ALG_TYPE_BLKCIPHER:
> > +             skcipher_inst = kzalloc(sizeof(*skcipher_inst) +
> > +                                     sizeof(*ictx), GFP_KERNEL);
> > +             if (!skcipher_inst)
> > +                     return -ENOMEM;
> > +             inst = skcipher_crypto_instance(skcipher_inst);
> > +             base = &skcipher_inst->alg.base;
> > +             ictx = crypto_instance_ctx(inst);
> > +
> > +             /* Block cipher, e.g. "cbc(aes)" */
> > +             crypto_set_skcipher_spawn(&ictx->u.skcipher_spawn, inst);
> > +             err = crypto_grab_skcipher(&ictx->u.skcipher_spawn,
> > +                                        inner_cipher_name, 0,
> > +                                        crypto_requires_sync(algt->type,
> > +                                                             algt->mask));
> > +             if (err)
> > +                     goto out_free_inst;
>
> This should say "Symmetric cipher", not "Block cipher".
>
> > +
> > +     if (!parse_cipher_name(essiv_cipher_name, block_base->cra_name)) {
> > +             pr_warn("Failed to parse ESSIV cipher name from skcipher cra_name\n");
> > +             goto out_drop_skcipher;
> > +     }
>
> This is missing:
>
>                 err = -EINVAL;
>
> > +     if (type == CRYPTO_ALG_TYPE_BLKCIPHER) {
> > +             skcipher_inst->alg.setkey       = essiv_skcipher_setkey;
> > +             skcipher_inst->alg.encrypt      = essiv_skcipher_encrypt;
> > +             skcipher_inst->alg.decrypt      = essiv_skcipher_decrypt;
> > +             skcipher_inst->alg.init         = essiv_skcipher_init_tfm;
> > +             skcipher_inst->alg.exit         = essiv_skcipher_exit_tfm;
> > +
> > +             skcipher_inst->alg.min_keysize  = crypto_skcipher_alg_min_keysize(skcipher_alg);
> > +             skcipher_inst->alg.max_keysize  = crypto_skcipher_alg_max_keysize(skcipher_alg);
> > +             skcipher_inst->alg.ivsize       = crypto_skcipher_alg_ivsize(skcipher_alg);
> > +             skcipher_inst->alg.chunksize    = crypto_skcipher_alg_chunksize(skcipher_alg);
> > +             skcipher_inst->alg.walksize     = crypto_skcipher_alg_walksize(skcipher_alg);
> > +
> > +             skcipher_inst->free             = essiv_skcipher_free_instance;
> > +
> > +             err = skcipher_register_instance(tmpl, skcipher_inst);
> > +     } else {
> > +             aead_inst->alg.setkey           = essiv_aead_setkey;
> > +             aead_inst->alg.setauthsize      = essiv_aead_setauthsize;
> > +             aead_inst->alg.encrypt          = essiv_aead_encrypt;
> > +             aead_inst->alg.decrypt          = essiv_aead_decrypt;
> > +             aead_inst->alg.init             = essiv_aead_init_tfm;
> > +             aead_inst->alg.exit             = essiv_aead_exit_tfm;
> > +
> > +             aead_inst->alg.ivsize           = crypto_aead_alg_ivsize(aead_alg);
> > +             aead_inst->alg.maxauthsize      = crypto_aead_alg_maxauthsize(aead_alg);
> > +             aead_inst->alg.chunksize        = crypto_aead_alg_chunksize(aead_alg);
> > +
> > +             aead_inst->free                 = essiv_aead_free_instance;
> > +
> > +             err = aead_register_instance(tmpl, aead_inst);
> > +     }
>
> 'ivsize' is already in a variable, so could use
>
>                 skcipher_inst->alg.ivsize       = ivsize;
>
>         and
>                 aead_inst->alg.ivsize           = ivsize;
>

Thanks Eric. These will all be fixed in the next respin.
