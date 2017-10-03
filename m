Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:45996 "EHLO
        mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751962AbdJCPmT (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Oct 2017 11:42:19 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: Issue with encrypted filenames on UBIFS
From: David Gstir <david@sigma-star.at>
In-Reply-To: <CAFadFHRqVe5SmQBZAaFHt2d6+GY5p1mbE9_G40AApfK29oHh8Q@mail.gmail.com>
Date: Tue, 3 Oct 2017 17:42:18 +0200
Content-Transfer-Encoding: 8BIT
Message-Id: <34D12043-D369-458C-BEEA-B0B7463B3242@sigma-star.at>
References: <CAFadFHRqVe5SmQBZAaFHt2d6+GY5p1mbE9_G40AApfK29oHh8Q@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Nicolas Feignon <nicolas.feignon@mobile-devices.fr>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Nicolas,

> On 3 Oct 2017, at 15:01, Nicolas Feignon <nicolas.feignon@mobile-devices.fr> wrote:
> 
> Hi,
> 
> I'm encountering an issue with filesystem encryption on UBIFS. I'm using Kernel
> 4.13.3.
> 
> The encryption of filenames does not work correctly for filenames of more that
> 16 characters. It works fine if the names are shorter. Here's what I get:
> 
> [~/writeDir]# touch aaaaaaaaaaaaaaaa # 16 characters
> [~/writeDir]# ls
> ls: cannot access aaaaaaaaaaaaaaaa>*0ѐL9: No such file or directory
> aaaaaaaaaaaaaaaa?>??*0?????n??L9
> 
> I set the policy with:
> [~]# openssl rand 64 > key
> [~]# fscryptctl insert_key < key
> a5bb6bff407f6f67
> [~]# fscryptctl set_policy a5bb6bff407f6f67 writeDir/
> 
> I get the issue for all encryption modes and padding values altough the length
> of filenames at which it doesn't work varies.
> With the default padding of 32 and AES-256-CTS encryption mode, it does not
> work for length >= 16 and <= 32, length >= 48 and <= 64...
> 
> I took a look at fs/crypto/fname.c but I can't figure out the problem. It seems
> like it's an overflow somewhere.

Do you use a hardware crypto accelerator for AES? I saw the same issue with the CAAM driver (see issue 1 here [1]) some time ago.

Specifically, the blockcipher driver code is required to update ->iv of skcipher_request after encryption/decryption. This is used by the CTS-mode code. Here's the fix that got merged for the CAAM driver [2].

- David

[1] https://marc.info/?l=linux-crypto-vger&m=149640631518134&w=2
[2] https://marc.info/?l=linux-crypto-vger&m=149865646825902&w=2