Return-Path: <SRS0=Jylm=UQ=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org>
 <20190616204419.GE923@sol.localdomain> <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
 <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com> <20190617092012.gk7wrazxh7bwfmjk@gondor.apana.org.au>
In-Reply-To: <20190617092012.gk7wrazxh7bwfmjk@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 17 Jun 2019 11:24:31 +0200
Message-ID: <CAKv+Gu_34nOAcTBJPi7cR2W7w-1c27ofgoDaXZtuZh8qaaQJSQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 17 Jun 2019 at 11:20, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Mon, Jun 17, 2019 at 11:15:01AM +0200, Ard Biesheuvel wrote:
> >
> > Ah yes, thanks for reminding me. There was some debate in the past
> > about this, but I don't remember the details.
>
> I think there were some controversy regarding whether the resulting
> code lived in drivers/md or crypto.  I think as long as drivers/md
> is the only user of the said code then having it in drivers/md should
> be fine.
>
> However, if we end up using/reusing the same code for others such as
> fs/crypto then it might make more sense to have them in crypto.
>

Agreed. We could more easily test it in isolation and ensure parity
between different implementations, especially now that we have Eric's
improved testing framework that tests against generic implementations.
