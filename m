Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f67.google.com ([209.85.221.67]:46542 "EHLO
        mail-wr1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727816AbfHaQiC (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 31 Aug 2019 12:38:02 -0400
Received: by mail-wr1-f67.google.com with SMTP id h7so8534776wrt.13
        for <linux-fscrypt@vger.kernel.org>; Sat, 31 Aug 2019 09:38:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
 <20190819141738.1231-2-ard.biesheuvel@linaro.org> <20190830045822.GA17901@gondor.apana.org.au>
In-Reply-To: <20190830045822.GA17901@gondor.apana.org.au>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 31 Aug 2019 19:37:48 +0300
Message-ID: <CAKv+Gu-7c+L4KzC=h=rBxLhZRt3RhK3eO2L2NvVrajR0MX_9+g@mail.gmail.com>
Subject: Re: [PATCH v13 1/6] crypto: essiv - create wrapper template for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, Milan Broz <gmazyland@gmail.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 30 Aug 2019 at 07:58, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> On Mon, Aug 19, 2019 at 05:17:33PM +0300, Ard Biesheuvel wrote:
> > Implement a template that wraps a (skcipher,shash) or (aead,shash) tuple
> > so that we can consolidate the ESSIV handling in fscrypt and dm-crypt and
> > move it into the crypto API. This will result in better test coverage, and
> > will allow future changes to make the bare cipher interface internal to the
> > crypto subsystem, in order to increase robustness of the API against misuse.
> >
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > ---
> >  crypto/Kconfig  |  28 +
> >  crypto/Makefile |   1 +
> >  crypto/essiv.c  | 663 ++++++++++++++++++++
> >  3 files changed, 692 insertions(+)
>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Milan,

Hopefully, this can still be taken for v5.4. If not, please coordinate
with Eric on how to get this queued for v5.5

Thanks,
Ard.
