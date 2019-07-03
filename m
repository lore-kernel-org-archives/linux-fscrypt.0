Return-Path: <SRS0=FBtJ=VA=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190702164815.6341-1-ard.biesheuvel@linaro.org>
 <20190702164815.6341-3-ard.biesheuvel@linaro.org> <20190702215517.GA69157@gmail.com>
 <CAKv+Gu9qPPBpm7aocHCsid6yyL7HyX9Dk2M72A5W9OeHG58MZw@mail.gmail.com>
In-Reply-To: <CAKv+Gu9qPPBpm7aocHCsid6yyL7HyX9Dk2M72A5W9OeHG58MZw@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 3 Jul 2019 20:23:31 +0200
Message-ID: <CAKv+Gu9gcbYrU3EjCuYudoT-vrAp3Q2y7ExpcqgHBLQFPXQsWw@mail.gmail.com>
Subject: Re: [PATCH v7 2/7] fs: crypto: invoke crypto API for ESSIV handling
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, 3 Jul 2019 at 00:06, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> On Tue, 2 Jul 2019 at 23:55, Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > Hi Ard,
> >
> > On Tue, Jul 02, 2019 at 06:48:10PM +0200, Ard Biesheuvel wrote:
> > > Instead of open coding the calculations for ESSIV handling, use a
> > > ESSIV skcipher which does all of this under the hood.
> > >
> > > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > ---
> > >  fs/crypto/Kconfig           |  1 +
> > >  fs/crypto/crypto.c          |  5 --
> > >  fs/crypto/fscrypt_private.h |  9 --
> > >  fs/crypto/keyinfo.c         | 95 +-------------------
> > >  4 files changed, 5 insertions(+), 105 deletions(-)
> > >
> > > diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> > > index 24ed99e2eca0..b0292da8613c 100644
> > > --- a/fs/crypto/Kconfig
> > > +++ b/fs/crypto/Kconfig
> > > @@ -5,6 +5,7 @@ config FS_ENCRYPTION
> > >       select CRYPTO_AES
> > >       select CRYPTO_CBC
> > >       select CRYPTO_ECB
> > > +     select CRYPTO_ESSIV
> > >       select CRYPTO_XTS
> > >       select CRYPTO_CTS
> > >       select CRYPTO_SHA256
> > > diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
> > > index 335a362ee446..c53ce262a06c 100644
> > > --- a/fs/crypto/crypto.c
> > > +++ b/fs/crypto/crypto.c
> > > @@ -136,9 +136,6 @@ void fscrypt_generate_iv(union fscrypt_iv *iv, u64 lblk_num,
> > >
> > >       if (ci->ci_flags & FS_POLICY_FLAG_DIRECT_KEY)
> > >               memcpy(iv->nonce, ci->ci_nonce, FS_KEY_DERIVATION_NONCE_SIZE);
> > > -
> > > -     if (ci->ci_essiv_tfm != NULL)
> > > -             crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv->raw, iv->raw);
> > >  }
> > >
> > >  int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
> > > @@ -492,8 +489,6 @@ static void __exit fscrypt_exit(void)
> > >               destroy_workqueue(fscrypt_read_workqueue);
> > >       kmem_cache_destroy(fscrypt_ctx_cachep);
> > >       kmem_cache_destroy(fscrypt_info_cachep);
> > > -
> > > -     fscrypt_essiv_cleanup();
> > >  }
> > >  module_exit(fscrypt_exit);
> > >
> > > diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> > > index 7da276159593..59d0cba9cfb9 100644
> > > --- a/fs/crypto/fscrypt_private.h
> > > +++ b/fs/crypto/fscrypt_private.h
> > > @@ -61,12 +61,6 @@ struct fscrypt_info {
> > >       /* The actual crypto transform used for encryption and decryption */
> > >       struct crypto_skcipher *ci_ctfm;
> > >
> > > -     /*
> > > -      * Cipher for ESSIV IV generation.  Only set for CBC contents
> > > -      * encryption, otherwise is NULL.
> > > -      */
> > > -     struct crypto_cipher *ci_essiv_tfm;
> > > -
> > >       /*
> > >        * Encryption mode used for this inode.  It corresponds to either
> > >        * ci_data_mode or ci_filename_mode, depending on the inode type.
> > > @@ -166,9 +160,6 @@ struct fscrypt_mode {
> > >       int keysize;
> > >       int ivsize;
> > >       bool logged_impl_name;
> > > -     bool needs_essiv;
> > >  };
> > >
> > > -extern void __exit fscrypt_essiv_cleanup(void);
> > > -
> > >  #endif /* _FSCRYPT_PRIVATE_H */
> > > diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
> > > index dcd91a3fbe49..f39667d4316a 100644
> > > --- a/fs/crypto/keyinfo.c
> > > +++ b/fs/crypto/keyinfo.c
> > > @@ -13,14 +13,10 @@
> > >  #include <linux/hashtable.h>
> > >  #include <linux/scatterlist.h>
> > >  #include <linux/ratelimit.h>
> > > -#include <crypto/aes.h>
> > >  #include <crypto/algapi.h>
> > > -#include <crypto/sha.h>
> > >  #include <crypto/skcipher.h>
> > >  #include "fscrypt_private.h"
> > >
> > > -static struct crypto_shash *essiv_hash_tfm;
> > > -
> > >  /* Table of keys referenced by FS_POLICY_FLAG_DIRECT_KEY policies */
> > >  static DEFINE_HASHTABLE(fscrypt_master_keys, 6); /* 6 bits = 64 buckets */
> > >  static DEFINE_SPINLOCK(fscrypt_master_keys_lock);
> > > @@ -144,10 +140,9 @@ static struct fscrypt_mode available_modes[] = {
> > >       },
> > >       [FS_ENCRYPTION_MODE_AES_128_CBC] = {
> > >               .friendly_name = "AES-128-CBC",
> > > -             .cipher_str = "cbc(aes)",
> > > +             .cipher_str = "essiv(cbc(aes),aes,sha256)",
> > >               .keysize = 16,
> > > -             .ivsize = 16,
> > > -             .needs_essiv = true,
> > > +             .ivsize = 8,
> >
> > As I said before, this needs to be kept as .ivsize = 16.
> >
> > This bug actually causes the generic/549 test to fail.
> >
>
> Ugh, yes, I intended to fix that. Apologies for the sloppiness, I have
> been trying to wrap this up in time for my holidays, but the end
> result is quite the opposite :-)
>
> > Otherwise this patch looks good.  FYI: to avoid conflicts with planned fscrypt
> > work I'd prefer to take this patch through the fscrypt.git tree after the ESSIV
> > template is merged, rather than have Herbert take it through cryptodev.  (Unless
> > he's going to apply this whole series for v5.3, in which case I'm fine with him
> > taking the fscrypt patch too, though it seems too late for that.)
> >
>
> I agree that the fscrypt and dm-crypt changes should not be merged for v5.3
>
> I know that Herbert typically prefers not to take any new code without
> any of its users, but perhaps we can make an exception in this case,
> and merge patches #1, #5, #6 and #7 now (which is mostly risk free
> since no code uses essiv yet, and patch #5 is a straight-forward
> refactor) and take the fscrypt and dm-crypt patches through their
> respective trees for the next cycle.

Actually, #7 no longer applies cleanly to cryptodev, so I am going to
respin in any case, and finally fix the ivsize change.
