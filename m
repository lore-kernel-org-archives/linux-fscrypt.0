Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f68.google.com ([209.85.221.68]:36091 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726575AbfHPISw (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Aug 2019 04:18:52 -0400
Received: by mail-wr1-f68.google.com with SMTP id r3so725744wrt.3
        for <linux-fscrypt@vger.kernel.org>; Fri, 16 Aug 2019 01:18:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org> <1463bca3-77dc-42be-7624-e8eaf5cfbf32@gmail.com>
In-Reply-To: <1463bca3-77dc-42be-7624-e8eaf5cfbf32@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 16 Aug 2019 11:18:42 +0300
Message-ID: <CAKv+Gu9CtMMAjtjfR=uuB-+x0Lhy8gnme2HhExckW+eVZ8B_Ow@mail.gmail.com>
Subject: Re: [PATCH v12 0/4] crypto: switch to crypto API for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, 16 Aug 2019 at 10:29, Milan Broz <gmazyland@gmail.com> wrote:
>
> Hi Ard,
>
> On 15/08/2019 21:28, Ard Biesheuvel wrote:
> > Changes since v10:
> > - Drop patches against fscrypt and dm-crypt - these will be routed via the
> >   respective maintainer trees during the next cycle
>
> I tested the previous dm-crypt patches (I also try to keep them in my kernel.org tree),
> it works and looks fine to me (and I like the final cleanup :)
>
> Once all maintainers are happy with the current state, I think it should go to
> the next release (5.4; IMO both ESSIV API and dm-crypt changes).
> Maybe you could keep sending dm-crypt patches in the end of the series (to help testing it)?
>

OK. But we'll need to coordinate a bit so that the first patch (the
one that introduces the template) is available in both branches,
otherwise ESSIV will be broken in the dm branch until it hits another
branch (-next or mainline) that also contains cryptodev.

As I suggested before, I can easily create a branch based on v5.3-rc1
containing just the first ESSIV patch (once Herbert is happy with it),
and merge that both into cryptodev and dm. That way, both will
continue to work without having too much overlap. Since adding a
template/file that has no users yet is highly unlikely to break
anything, it doesn't even matter which branch gets pulled first.

Any idea about the status of the EBOIV patch?
