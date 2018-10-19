Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Fri, 19 Oct 2018 11:28:05 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 04/12] crypto: chacha - add XChaCha12 support
Message-ID: <20181019182804.GA246441@gmail.com>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <20181015175424.97147-5-ebiggers@kernel.org>
 <CAKv+Gu_wVmnEND3MGTG7bqqynbBqyzmE_gTmqZfrT551_n9Hmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_wVmnEND3MGTG7bqqynbBqyzmE_gTmqZfrT551_n9Hmw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Greg Kaiser <gkaiser@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Samuel Neves <samuel.c.p.neves@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On Fri, Oct 19, 2018 at 10:34:41PM +0800, Ard Biesheuvel wrote:
> > diff --git a/include/crypto/chacha.h b/include/crypto/chacha.h
> > index ae79e9983c72f..3d261f5cd156d 100644
> > --- a/include/crypto/chacha.h
> > +++ b/include/crypto/chacha.h
> > @@ -5,6 +5,11 @@
> >   * XChaCha extends ChaCha's nonce to 192 bits, while provably retaining ChaCha's
> >   * security.  Here they share the same key size, tfm context, and setkey
> >   * function; only their IV size and encrypt/decrypt function differ.
> > + *
> > + * The ChaCha paper specifies 20, 12, and 8-round variants.  In general, it is
> > + * recommended to use the 20-round variant ChaCha20.  However, the other
> > + * variants can be needed in some performance-sensitive scenarios.  The generic
> > + * ChaCha code currently allows only the 20 and 12-round variants.
> >   */
> >
> >  #ifndef _CRYPTO_CHACHA_H
> > @@ -39,6 +44,8 @@ void crypto_chacha_init(u32 *state, struct chacha_ctx *ctx, u8 *iv);
> >
> >  int crypto_chacha20_setkey(struct crypto_skcipher *tfm, const u8 *key,
> >                            unsigned int keysize);
> > +int crypto_chacha12_setkey(struct crypto_skcipher *tfm, const u8 *key,
> > +                          unsigned int keysize);
> >
> >  int crypto_chacha_crypt(struct skcipher_request *req);
> >  int crypto_xchacha_crypt(struct skcipher_request *req);
> > diff --git a/lib/chacha.c b/lib/chacha.c
> > index 0a2c2e5b7b84d..c4d69a83fcd2d 100644
> > --- a/lib/chacha.c
> > +++ b/lib/chacha.c
> > @@ -21,7 +21,7 @@ static void chacha_permute(u32 *x, int nrounds)
> >         int i;
> >
> >         /* whitelist the allowed round counts */
> > -       BUG_ON(nrounds != 20);
> > +       BUG_ON(nrounds != 20 && nrounds != 12);
> >
> 
> I didn't spot this until this patch, but BUG_ON() may bring down the
> kernel, and so it should really only be used as a last resort. (i.e.,
> if this is called from non-process context things may explode rather
> painfully)
> 
> I didn't look at the entire file [which is a bit cumbersome while
> reviewing incremental changes like this] and so I don't really have
> another suggestion right now, but please try to come up with something
> better if you can.
> 

I'll change it to WARN_ON_ONCE(), I guess.  I do still want it to be very noisy
if something fishy is going on with the round count.

- Eric
