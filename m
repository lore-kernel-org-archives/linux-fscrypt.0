Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f67.google.com ([209.85.221.67]:34482 "EHLO
        mail-wr1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726079AbfICTQv (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Sep 2019 15:16:51 -0400
Received: by mail-wr1-f67.google.com with SMTP id s18so18714720wrn.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 03 Sep 2019 12:16:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
 <20190819141738.1231-6-ard.biesheuvel@linaro.org> <20190903185537.GC13472@redhat.com>
In-Reply-To: <20190903185537.GC13472@redhat.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 3 Sep 2019 12:16:37 -0700
Message-ID: <CAKv+Gu8wr3HnP7uVDAOY=o54dWVkPoWm5V43LU_QNVMK_Cc2GA@mail.gmail.com>
Subject: Re: [PATCH v13 5/6] md: dm-crypt: switch to ESSIV crypto API template
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Mike Snitzer <snitzer@redhat.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, 3 Sep 2019 at 11:55, Mike Snitzer <snitzer@redhat.com> wrote:
>
> On Mon, Aug 19 2019 at 10:17am -0400,
> Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> > Replace the explicit ESSIV handling in the dm-crypt driver with calls
> > into the crypto API, which now possesses the capability to perform
> > this processing within the crypto subsystem.
> >
> > Note that we reorder the AEAD cipher_api string parsing with the TFM
> > instantiation: this is needed because cipher_api is mangled by the
> > ESSIV handling, and throws off the parsing of "authenc(" otherwise.
> >
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>
> I really like to see this type of factoring out to the crypto API;
> nicely done.
>
> Acked-by: Mike Snitzer <snitzer@redhat.com>
>
> Herbert, please feel free to pull this, and the next 6/6 patch, into
> your crypto tree for 5.4.  I see no need to complicate matters by me
> having to rebase my dm-5.4 branch ontop of the crypto tree, etc.
>

Thanks Mike.

There is no need to rebase your branch - there is only a single
dependency, which is the essiv template itself, and the patch that
adds that (#1 in this series) was acked by Herbert, specifically so
that it can be taken via another tree. The crypto tree has no
interdependencies with this template, and the other patches in this
series are not required for essiv in dm-crypt.

If you feel it is too late in the cycle, we can defer to v5.5, but in
this case, we should align with Eric, which will depend on the essiv
template for fscrypt as well.

In any case, it is up to you, Eric and Herbert to align on this. For
me, it doesn't really matter whether this lands in v5.4 or v5.5. There
is some followup work based on this, but that is further out still.

Thanks,
Ard.
