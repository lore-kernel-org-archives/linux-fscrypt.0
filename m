Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm1-f66.google.com ([209.85.128.66]:50518 "EHLO
        mail-wm1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727126AbfFSNIp (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jun 2019 09:08:45 -0400
Subject: Re: [PATCH v2 0/4] crypto: switch to crypto API for ESSIV generation
References: <20190618212749.8995-1-ard.biesheuvel@linaro.org>
 <099346ee-af6e-a560-079d-3fb68fb4eeba@gmail.com>
 <CAKv+Gu9MTGSwZgaHyxJKwfiBQzqgNhTs5ue+TC1Ehte-+VBXqg@mail.gmail.com>
 <CAKv+Gu9q5qTgEeTLCW6ZM6Wu6RK559SjFhsgWis72_6-p6RrZA@mail.gmail.com>
 <f5de99dd-0b6a-9f7e-46b7-cd3c5ed3100e@gmail.com>
 <CAKv+Gu9NW2H-TDd66quKSUMpEWGwqEjN-vmf_zueo1tEJLa-xg@mail.gmail.com>
 <b5b013eb-9cab-4985-9c24-563cc57c140e@gmail.com>
 <CAKv+Gu91RHpwE6XzdFYcsN77DRJ-4OsFRjxNAyKk92Q3q6dCYw@mail.gmail.com>
 <CAKv+Gu_XFbB9TTjMO+=QmZ40H1LV5DB57-zeUEb9dN3yNyia=w@mail.gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <dea2ec13-61d4-5009-df04-9508bb8e7827@gmail.com>
Date: Wed, 19 Jun 2019 15:08:41 +0200
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_XFbB9TTjMO+=QmZ40H1LV5DB57-zeUEb9dN3yNyia=w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Milan Broz <gmazyland@gmail.com>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 19/06/2019 14:49, Ard Biesheuvel wrote:
> On Wed, 19 Jun 2019 at 14:36, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>>
>> On Wed, 19 Jun 2019 at 13:33, Milan Broz <gmazyland@gmail.com> wrote:
>>>
>>> On 19/06/2019 13:16, Ard Biesheuvel wrote:
>>>>> Try
>>>>>   cryptsetup open --type plain -c null /dev/sdd test -q
>>>>> or
>>>>>   dmsetup create test --table " 0 417792 crypt cipher_null-ecb - 0 /dev/sdd 0"
>>>>>
>>>>> (or just run full cryptsetup testsuite)
>>>>>
>>>>
>>>> Is that your mode-test script?
>>>>
>>>> I saw some errors about the null cipher, but tbh, it looked completely
>>>> unrelated to me, so i skipped those for the moment. But now, it looks
>>>> like it is related after all.
>>>
>>> This was triggered by align-test, mode-test fails the same though.
>>>
>>> It is definitely related, I think you just changed the mode parsing in dm-crypt.
>>> (cipher null contains only one dash I guess).
>>>
>>
>> On my unpatched 4.19 kernel, mode-test gives me
>>
>> $ sudo ./mode-test
>> aes                            PLAIN:[table OK][status OK]
>> LUKS1:[table OK][status OK] CHECKSUM:[OK]
>> aes-plain                      PLAIN:[table OK][status OK]
>> LUKS1:[table OK][status OK] CHECKSUM:[OK]
>> null                           PLAIN:[table OK][status OK]
>> LUKS1:[table OK][status OK] CHECKSUM:[OK]
>> cipher_null                    PLAIN:[table FAIL]
>>  Expecting cipher_null-ecb got cipher_null-cbc-plain.
>> FAILED at line 64 ./mode-test
>>
>> which is why I commented out those tests in the first place.
>>
>> I can reproduce the crash after I re-enable them again, so I will need
>> to look into that. But something seems to be broken already.
>> Note that this is running on arm64 using a kconfig based on the Debian kernel.
> 
> Actually, could this be an issue with cryptsetup being out of date? On
> another arm64 system with a more recent distro, it works fine

Ah yes, it was changed because we hardened dm-crypt mode validation in kernel
https://gitlab.com/cryptsetup/cryptsetup/commit/aeea93fa9553ad70ed57f273aecb233113b204d6#f40cab3037a50bf28ce20d8aae52bfa6a0c0e2c4_137_137

So either use test form the released version of cryptsetup (all version are here)
https://mirrors.edge.kernel.org/pub/linux/utils/cryptsetup/

Or better use upstream git, we added a lot of tests anyway.

Milan
