Return-Path: <SRS0=Jylm=UQ=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org>
 <20190616204419.GE923@sol.localdomain> <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
 <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com> <8e58230a-cf0e-5a81-886b-6aa72a8e5265@gmail.com>
In-Reply-To: <8e58230a-cf0e-5a81-886b-6aa72a8e5265@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 17 Jun 2019 12:58:40 +0200
Message-ID: <CAKv+Gu9sb0t6EC=MwVfqTw5TKtatK-c8k3ryNUhV8O0876NV7g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
To: Milan Broz <gmazyland@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Eric Biggers <ebiggers@kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 17 Jun 2019 at 12:39, Milan Broz <gmazyland@gmail.com> wrote:
>
> On 17/06/2019 11:15, Ard Biesheuvel wrote:
> >> I will also add that going the skcipher route rather than shash will
> >> allow hardware tfm providers like CryptoCell that can do the ESSIV
> >> part in hardware implement that as a single API call and/or hardware
> >> invocation flow.
> >> For those system that benefit from hardware providers this can be beneficial.
> >>
> >
> > Ah yes, thanks for reminding me. There was some debate in the past
> > about this, but I don't remember the details.
> >
> > I think implementing essiv() as a skcipher template is indeed going to
> > be the best approach, I will look into that.
>
> For ESSIV (that is de-facto standard now), I think there is no problem
> to move it to crypto API.
>
> The problem is with some other IV generators in dm-crypt.
>
> Some do a lot of more work than just IV (it is hackish, it can modify data, this applies
> for loop AES "lmk" and compatible TrueCrypt "tcw" IV implementations).
>
> For these I would strongly say it should remain "hacked" inside dm-crypt only
> (it is unusable for anything else than disk encryption and should not be visible outside).
>
> Moreover, it is purely legacy code - we provide it for users can access old systems only.
>
> If you end with rewriting all IVs as templates, I think it is not a good idea.
>
> If it is only about ESSIV, and patch for dm-crypt is simple, it is a reasonable approach.
>
> (The same applies for simple dmcryp IVs like "plain" "plain64", "plain64be and "benbi" that
> are just linear IVs in various encoded variants.)
>

Agreed.

I am mostly only interested in ensuring that the bare 'cipher'
interface is no longer used outside of the crypto subsystem itself.
Since ESSIV is the only one using that, ESSIV is the only one I intend
to change.
