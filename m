Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48988 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726440AbfICUva (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Sep 2019 16:51:30 -0400
Date: Tue, 3 Sep 2019 16:51:26 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: [PATCH v13 5/6] md: dm-crypt: switch to ESSIV crypto API template
Message-ID: <20190903205126.GA13753@redhat.com>
References: <20190819141738.1231-1-ard.biesheuvel@linaro.org>
 <20190819141738.1231-6-ard.biesheuvel@linaro.org>
 <20190903185537.GC13472@redhat.com>
 <CAKv+Gu8wr3HnP7uVDAOY=o54dWVkPoWm5V43LU_QNVMK_Cc2GA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8wr3HnP7uVDAOY=o54dWVkPoWm5V43LU_QNVMK_Cc2GA@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, device-mapper development <dm-devel@redhat.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Sep 03 2019 at  3:16pm -0400,
Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:

> On Tue, 3 Sep 2019 at 11:55, Mike Snitzer <snitzer@redhat.com> wrote:
> >
> > On Mon, Aug 19 2019 at 10:17am -0400,
> > Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> >
> > > Replace the explicit ESSIV handling in the dm-crypt driver with calls
> > > into the crypto API, which now possesses the capability to perform
> > > this processing within the crypto subsystem.
> > >
> > > Note that we reorder the AEAD cipher_api string parsing with the TFM
> > > instantiation: this is needed because cipher_api is mangled by the
> > > ESSIV handling, and throws off the parsing of "authenc(" otherwise.
> > >
> > > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> >
> > I really like to see this type of factoring out to the crypto API;
> > nicely done.
> >
> > Acked-by: Mike Snitzer <snitzer@redhat.com>
> >
> > Herbert, please feel free to pull this, and the next 6/6 patch, into
> > your crypto tree for 5.4.  I see no need to complicate matters by me
> > having to rebase my dm-5.4 branch ontop of the crypto tree, etc.
> >
> 
> Thanks Mike.
> 
> There is no need to rebase your branch - there is only a single
> dependency, which is the essiv template itself, and the patch that
> adds that (#1 in this series) was acked by Herbert, specifically so
> that it can be taken via another tree. The crypto tree has no
> interdependencies with this template, and the other patches in this
> series are not required for essiv in dm-crypt.

Ah ok, thanks for clarifying.

I just picked up patches 1, 5, and 6 and staged them in linux-next via
dm-5.4, please see:
https://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git/log/?h=dm-5.4

Thanks,
Mike
