Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io1-f67.google.com ([209.85.166.67]:40755 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726109AbfFSPp0 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jun 2019 11:45:26 -0400
Received: by mail-io1-f67.google.com with SMTP id n5so39200504ioc.7
        for <linux-fscrypt@vger.kernel.org>; Wed, 19 Jun 2019 08:45:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
 <20190618212749.8995-2-ard.biesheuvel@linaro.org> <CAAUqJDsi_acZj09xiimYGfyJVPt0zo=3-2PHuGnSKSaq82-RQA@mail.gmail.com>
In-Reply-To: <CAAUqJDsi_acZj09xiimYGfyJVPt0zo=3-2PHuGnSKSaq82-RQA@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 19 Jun 2019 17:45:13 +0200
Message-ID: <CAKv+Gu_okSc=Ep9nbdqnbB1hVRmr8O4tChDPm+m7O+jb1pBD_A@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: =?UTF-8?B?T25kcmVqIE1vc27DocSNZWs=?= <omosnacek@gmail.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, 19 Jun 2019 at 17:18, Ondrej Mosn=C3=A1=C4=8Dek <omosnacek@gmail.co=
m> wrote:
>
> Hi Ard,
>
> ut 18. 6. 2019 o 23:28 Ard Biesheuvel <ard.biesheuvel@linaro.org> nap=C3=
=ADsal(a):
> > Implement a template that wraps a (skcipher,cipher,shash) or
> > (aead,cipher,shash) tuple so that we can consolidate the ESSIV handling
> > in fscrypt and dm-crypt and move it into the crypto API. This will resu=
lt
> > in better test coverage, and will allow future changes to make the bare
> > cipher interface internal to the crypto subsystem, in order to increase
> > robustness of the API against misuse.
> >
> > Note that especially the AEAD handling is a bit complex, and is tightly
> > coupled to the way dm-crypt combines AEAD based on the authenc() templa=
te
> > with the ESSIV handling.
>
> Wouldn't it work better to have a template only for skcipher and in
> dm-crypt just inject the essiv() template into the cipher string? For
> example: "authenc(hmac(sha256),cbc(aes))-essiv:sha256" ->
> "authenc(hmac(sha256),essiv(cbc(aes),aes,sha256))". That seems to me a
> much simpler hack. (But maybe I'm missing some issue in that
> approach...)
>

Unfortunately, that doesn't work. When using AEADs, dm-crypt also puts
the IV in the AAD area.
