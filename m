Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:51409 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdJDQOV (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 4 Oct 2017 12:14:21 -0400
Received: by mail-oi0-f42.google.com with SMTP id n82so20341277oib.8
        for <linux-fscrypt@vger.kernel.org>; Wed, 04 Oct 2017 09:14:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <34D12043-D369-458C-BEEA-B0B7463B3242@sigma-star.at>
References: <CAFadFHRqVe5SmQBZAaFHt2d6+GY5p1mbE9_G40AApfK29oHh8Q@mail.gmail.com>
 <34D12043-D369-458C-BEEA-B0B7463B3242@sigma-star.at>
From: Nicolas Feignon <nicolas.feignon@mobile-devices.fr>
Date: Wed, 4 Oct 2017 18:14:20 +0200
Message-ID: <CAFadFHQLbHNpQCP6tDsGFOSw7ZsujRaiBzQBbXx7-_QOjZwuPw@mail.gmail.com>
Subject: Re: Issue with encrypted filenames on UBIFS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: David Gstir <david@sigma-star.at>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

I was indeed using a hardware crypto accelerator on a Atmel SAMA5D2 platfor=
m.
It works correctly after removing it. I'll work on a patch.

Thank you!
Nicolas

2017-10-03 17:42 GMT+02:00 David Gstir <david@sigma-star.at>:
> Hi Nicolas,
>
>> On 3 Oct 2017, at 15:01, Nicolas Feignon <nicolas.feignon@mobile-devices=
.fr> wrote:
>>
>> Hi,
>>
>> I'm encountering an issue with filesystem encryption on UBIFS. I'm using=
 Kernel
>> 4.13.3.
>>
>> The encryption of filenames does not work correctly for filenames of mor=
e that
>> 16 characters. It works fine if the names are shorter. Here's what I get=
:
>>
>> [~/writeDir]# touch aaaaaaaaaaaaaaaa # 16 characters
>> [~/writeDir]# ls
>> ls: cannot access aaaaaaaaaaaaaaaa>*0=D1=90L9: No such file or directory
>> aaaaaaaaaaaaaaaa?>??*0?????n??L9
>>
>> I set the policy with:
>> [~]# openssl rand 64 > key
>> [~]# fscryptctl insert_key < key
>> a5bb6bff407f6f67
>> [~]# fscryptctl set_policy a5bb6bff407f6f67 writeDir/
>>
>> I get the issue for all encryption modes and padding values altough the =
length
>> of filenames at which it doesn't work varies.
>> With the default padding of 32 and AES-256-CTS encryption mode, it does =
not
>> work for length >=3D 16 and <=3D 32, length >=3D 48 and <=3D 64...
>>
>> I took a look at fs/crypto/fname.c but I can't figure out the problem. I=
t seems
>> like it's an overflow somewhere.
>
> Do you use a hardware crypto accelerator for AES? I saw the same issue wi=
th the CAAM driver (see issue 1 here [1]) some time ago.
>
> Specifically, the blockcipher driver code is required to update ->iv of s=
kcipher_request after encryption/decryption. This is used by the CTS-mode c=
ode. Here's the fix that got merged for the CAAM driver [2].
>
> - David
>
> [1] https://marc.info/?l=3Dlinux-crypto-vger&m=3D149640631518134&w=3D2
> [2] https://marc.info/?l=3Dlinux-crypto-vger&m=3D149865646825902&w=3D2
