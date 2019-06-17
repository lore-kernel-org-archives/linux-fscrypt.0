Return-Path: <SRS0=VVWU=UQ=benyossef.com=gilad@kernel.org>
MIME-Version: 1.0
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org> <20190616204419.GE923@sol.localdomain>
In-Reply-To: <20190616204419.GE923@sol.localdomain>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Mon, 17 Jun 2019 11:51:52 +0300
Message-ID: <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Eric Biggers <ebiggers@kernel.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jun 16, 2019 at 11:44 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> [+Cc dm-devel and linux-fscrypt]
>
> On Fri, Jun 14, 2019 at 10:34:01AM +0200, Ard Biesheuvel wrote:
> > This series is presented as an RFC for a couple of reasons:
> > - it is only build tested
> > - it is unclear whether this is the right way to move away from the use=
 of
> >   bare ciphers in non-crypto code
> > - we haven't really discussed whether moving away from the use of bare =
ciphers
> >   in non-crypto code is a goal we agree on
> >
> > This series creates an ESSIV shash template that takes a (cipher,hash) =
tuple,
> > where the digest size of the hash must be a valid key length for the ci=
pher.
> > The setkey() operation takes the hash of the input key, and sets into t=
he
> > cipher as the encryption key. Digest operations accept input up to the
> > block size of the cipher, and perform a single block encryption operati=
on to
> > produce the ESSIV output.
...
> I agree that moving away from bare block ciphers is generally a good idea=
.  For
> fscrypt I'm fine with moving ESSIV into the crypto API, though I'm not su=
re a
> shash template is the best approach.  Did you also consider making it a s=
kcipher
> template so that users can do e.g. "essiv(cbc(aes),sha256,aes)"?  That wo=
uld
> simplify things much more on the fscrypt side, since then all the ESSIV-r=
elated
> code would go away entirely except for changing the string "cbc(aes)" to
> "essiv(cbc(aes),sha256,aes)".

I will also add that going the skcipher route rather than shash will
allow hardware tfm providers like CryptoCell that can do the ESSIV
part in hardware implement that as a single API call and/or hardware
invocation flow.
For those system that benefit from hardware providers this can be beneficia=
l.

Thanks,
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker

values of =CE=B2 will give rise to dom!
