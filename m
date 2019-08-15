Return-Path: <dm-devel-bounces@redhat.com>
MIME-Version: 1.0
References: <20190814163746.3525-1-ard.biesheuvel@linaro.org>
	<20190814163746.3525-2-ard.biesheuvel@linaro.org>
	<20190815023734.GB23782@gondor.apana.org.au>
In-Reply-To: <20190815023734.GB23782@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 15 Aug 2019 07:59:34 +0300
Message-ID: <CAKv+Gu_maif=kZk-HRMx7pP=ths1vuTgcu4kFpzz0tCkO2+DFA@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH v11 1/4] crypto: essiv - create wrapper
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

On Thu, 15 Aug 2019 at 05:37, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Wed, Aug 14, 2019 at 07:37:43PM +0300, Ard Biesheuvel wrote:
> >
> > +     /* Block cipher, e.g., "aes" */
> > +     crypto_set_spawn(&ictx->essiv_cipher_spawn, inst);
> > +     err = crypto_grab_spawn(&ictx->essiv_cipher_spawn, essiv_cipher_name,
> > +                             CRYPTO_ALG_TYPE_CIPHER, CRYPTO_ALG_TYPE_MASK);
> > +     if (err)
> > +             goto out_drop_skcipher;
> > +     essiv_cipher_alg = ictx->essiv_cipher_spawn.alg;
> > +
> > +     /* Synchronous hash, e.g., "sha256" */
> > +     _hash_alg = crypto_alg_mod_lookup(shash_name,
> > +                                       CRYPTO_ALG_TYPE_SHASH,
> > +                                       CRYPTO_ALG_TYPE_MASK);
> > +     if (IS_ERR(_hash_alg)) {
> > +             err = PTR_ERR(_hash_alg);
> > +             goto out_drop_essiv_cipher;
> > +     }
> > +     hash_alg = __crypto_shash_alg(_hash_alg);
> > +     err = crypto_init_shash_spawn(&ictx->hash_spawn, hash_alg, inst);
> > +     if (err)
> > +             goto out_put_hash;
>
> I wouldn't use spawns for these two algorithms.  The point of
> spawns is mainly to serve as a notification channel so we can
> tear down the top-level instance when a better underlying spawn
> implementation is added to the system.
>
> For these two algorithms, we don't really care about their performance
> to do such a tear-down since they only operate on small pieces of
> data.
>
> Therefore just keep things simple and allocate them in the tfm
> init function.
>

So how do I ensure that the cipher and shash are actually loaded at
create() time, and that they are still loaded at TFM init time?

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
