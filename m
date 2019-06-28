Return-Path: <SRS0=I/L0=U3=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190628152112.914-1-ard.biesheuvel@linaro.org>
 <20190628152112.914-3-ard.biesheuvel@linaro.org> <20190628180037.GC103946@gmail.com>
In-Reply-To: <20190628180037.GC103946@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 28 Jun 2019 20:09:54 +0200
Message-ID: <CAKv+Gu9=6uWSy2V4=7CVU6oqVUA0GFrjXHp48aiZ6sd_YQH-Uw@mail.gmail.com>
Subject: Re: [PATCH v6 2/7] fs: crypto: invoke crypto API for ESSIV handling
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 28 Jun 2019 at 20:00, Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Fri, Jun 28, 2019 at 05:21:07PM +0200, Ard Biesheuvel wrote:
> > diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> > index dcd91a3fbe49..f39667d4316a 100644
> > --- a/fs/crypto/keyinfo.c
> > +++ b/fs/crypto/keyinfo.c
> > @@ -13,14 +13,10 @@
> >  #include <linux/hashtable.h>
> >  #include <linux/scatterlist.h>
> >  #include <linux/ratelimit.h>
> > -#include <crypto/aes.h>
> >  #include <crypto/algapi.h>
> > -#include <crypto/sha.h>
> >  #include <crypto/skcipher.h>
> >  #include "fscrypt_private.h"
> >
> > -static struct crypto_shash *essiv_hash_tfm;
> > -
> >  /* Table of keys referenced by FS_POLICY_FLAG_DIRECT_KEY policies */
> >  static DEFINE_HASHTABLE(fscrypt_master_keys, 6); /* 6 bits = 64 buckets */
> >  static DEFINE_SPINLOCK(fscrypt_master_keys_lock);
> > @@ -144,10 +140,9 @@ static struct fscrypt_mode available_modes[] = {
> >       },
> >       [FS_ENCRYPTION_MODE_AES_128_CBC] = {
> >               .friendly_name = "AES-128-CBC",
> > -             .cipher_str = "cbc(aes)",
> > +             .cipher_str = "essiv(cbc(aes),aes,sha256)",
> >               .keysize = 16,
> > -             .ivsize = 16,
> > -             .needs_essiv = true,
> > +             .ivsize = 8,
> >       },
>
> Now that the essiv template takes the same size IV, the .ivsize here needs to be
> left as 16.
>

indeed. Thanks for spotting that.
