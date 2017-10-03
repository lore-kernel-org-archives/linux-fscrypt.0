Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:56906 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753391AbdJCNB7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Oct 2017 09:01:59 -0400
Received: by mail-oi0-f52.google.com with SMTP id v9so1898352oif.13
        for <linux-fscrypt@vger.kernel.org>; Tue, 03 Oct 2017 06:01:59 -0700 (PDT)
MIME-Version: 1.0
From: Nicolas Feignon <nicolas.feignon@mobile-devices.fr>
Date: Tue, 3 Oct 2017 15:01:58 +0200
Message-ID: <CAFadFHRqVe5SmQBZAaFHt2d6+GY5p1mbE9_G40AApfK29oHh8Q@mail.gmail.com>
Subject: Issue with encrypted filenames on UBIFS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

I'm encountering an issue with filesystem encryption on UBIFS. I'm using Ke=
rnel
4.13.3.

The encryption of filenames does not work correctly for filenames of more t=
hat
16 characters. It works fine if the names are shorter. Here's what I get:

[~/writeDir]# touch aaaaaaaaaaaaaaaa # 16 characters
[~/writeDir]# ls
ls: cannot access aaaaaaaaaaaaaaaa>*0=D1=90L9: No such file or directory
aaaaaaaaaaaaaaaa?>??*0?????n??L9

I set the policy with:
[~]# openssl rand 64 > key
[~]# fscryptctl insert_key < key
a5bb6bff407f6f67
[~]# fscryptctl set_policy a5bb6bff407f6f67 writeDir/

I get the issue for all encryption modes and padding values altough the len=
gth
of filenames at which it doesn't work varies.
With the default padding of 32 and AES-256-CTS encryption mode, it does not
work for length >=3D 16 and <=3D 32, length >=3D 48 and <=3D 64...

I took a look at fs/crypto/fname.c but I can't figure out the problem. It s=
eems
like it's an overflow somewhere.


Best regards,
Nicolas
