Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io1-f65.google.com ([209.85.166.65]:44218 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727244AbfFSMtN (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jun 2019 08:49:13 -0400
Received: by mail-io1-f65.google.com with SMTP id s7so37722735iob.11
        for <linux-fscrypt@vger.kernel.org>; Wed, 19 Jun 2019 05:49:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
 <099346ee-af6e-a560-079d-3fb68fb4eeba@gmail.com> <CAKv+Gu9MTGSwZgaHyxJKwfiBQzqgNhTs5ue+TC1Ehte-+VBXqg@mail.gmail.com>
 <CAKv+Gu9q5qTgEeTLCW6ZM6Wu6RK559SjFhsgWis72_6-p6RrZA@mail.gmail.com>
 <f5de99dd-0b6a-9f7e-46b7-cd3c5ed3100e@gmail.com> <CAKv+Gu9NW2H-TDd66quKSUMpEWGwqEjN-vmf_zueo1tEJLa-xg@mail.gmail.com>
 <b5b013eb-9cab-4985-9c24-563cc57c140e@gmail.com> <CAKv+Gu91RHpwE6XzdFYcsN77DRJ-4OsFRjxNAyKk92Q3q6dCYw@mail.gmail.com>
In-Reply-To: <CAKv+Gu91RHpwE6XzdFYcsN77DRJ-4OsFRjxNAyKk92Q3q6dCYw@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 19 Jun 2019 14:49:02 +0200
Message-ID: <CAKv+Gu_XFbB9TTjMO+=QmZ40H1LV5DB57-zeUEb9dN3yNyia=w@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] crypto: switch to crypto API for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Milan Broz <gmazyland@gmail.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, 19 Jun 2019 at 14:36, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>
> On Wed, 19 Jun 2019 at 13:33, Milan Broz <gmazyland@gmail.com> wrote:
> >
> > On 19/06/2019 13:16, Ard Biesheuvel wrote:
> > >> Try
> > >>   cryptsetup open --type plain -c null /dev/sdd test -q
> > >> or
> > >>   dmsetup create test --table " 0 417792 crypt cipher_null-ecb - 0 /dev/sdd 0"
> > >>
> > >> (or just run full cryptsetup testsuite)
> > >>
> > >
> > > Is that your mode-test script?
> > >
> > > I saw some errors about the null cipher, but tbh, it looked completely
> > > unrelated to me, so i skipped those for the moment. But now, it looks
> > > like it is related after all.
> >
> > This was triggered by align-test, mode-test fails the same though.
> >
> > It is definitely related, I think you just changed the mode parsing in dm-crypt.
> > (cipher null contains only one dash I guess).
> >
>
> On my unpatched 4.19 kernel, mode-test gives me
>
> $ sudo ./mode-test
> aes                            PLAIN:[table OK][status OK]
> LUKS1:[table OK][status OK] CHECKSUM:[OK]
> aes-plain                      PLAIN:[table OK][status OK]
> LUKS1:[table OK][status OK] CHECKSUM:[OK]
> null                           PLAIN:[table OK][status OK]
> LUKS1:[table OK][status OK] CHECKSUM:[OK]
> cipher_null                    PLAIN:[table FAIL]
>  Expecting cipher_null-ecb got cipher_null-cbc-plain.
> FAILED at line 64 ./mode-test
>
> which is why I commented out those tests in the first place.
>
> I can reproduce the crash after I re-enable them again, so I will need
> to look into that. But something seems to be broken already.
> Note that this is running on arm64 using a kconfig based on the Debian kernel.

Actually, could this be an issue with cryptsetup being out of date? On
another arm64 system with a more recent distro, it works fine
