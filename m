Return-Path: <SRS0=Jylm=UQ=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org>
 <20190616204419.GE923@sol.localdomain> <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
 <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com>
 <8e58230a-cf0e-5a81-886b-6aa72a8e5265@gmail.com> <CAKv+Gu9sb0t6EC=MwVfqTw5TKtatK-c8k3ryNUhV8O0876NV7g@mail.gmail.com>
 <CAKv+Gu-LFShLW-Tt7hwBpni1vQRvv7k+L_bpP-wU86x88v+eRg@mail.gmail.com> <90214c3d-55ef-cc3a-3a04-f200d6f96cfd@gmail.com>
In-Reply-To: <90214c3d-55ef-cc3a-3a04-f200d6f96cfd@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 17 Jun 2019 16:39:45 +0200
Message-ID: <CAKv+Gu82BLPWrX1UzUBLf7UB+qJT6ZPtkvJ2Sa9t28OpXArhnw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
To: Milan Broz <gmazyland@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Eric Biggers <ebiggers@kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, 17 Jun 2019 at 16:35, Milan Broz <gmazyland@gmail.com> wrote:
>
> On 17/06/2019 15:59, Ard Biesheuvel wrote:
> >
> > So my main question/showstopper at the moment is: which modes do we
> > need to support for ESSIV? Only CBC? Any skcipher? Or both skciphers
> > and AEADs?
>
> Support, or cover by internal test? I think you nee to support everything
> what dmcrypt currently allows, if you want to port dmcrypt to new API.
>
> I know of many systems that use aes-xts-essiv:sha256 (it does not make sense
> much but people just use it).
>
> Some people use serpent and twofish, but we allow any cipher that fits...
>

Sure,  that is all fine

> For the start, run this
> https://gitlab.com/cryptsetup/cryptsetup/blob/master/tests/mode-test
>
> In other words, if you add some additional limit, we are breaking backward compatibility.
> (Despite the configuration is "wrong" from the security point of view.)
>

Yes, but breaking backward compatibility only happens if you break
something that is actually being *used*. So sure,
xts(aes)-essiv:sha256 makes no sense but people use it anyway. But is
that also true for, say, gcm(aes)-essiv:sha256 ?
