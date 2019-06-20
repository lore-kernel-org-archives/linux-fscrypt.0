Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-vk1-f193.google.com ([209.85.221.193]:38412 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725872AbfFTHIK (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 20 Jun 2019 03:08:10 -0400
Received: by mail-vk1-f193.google.com with SMTP id f68so365328vkf.5
        for <linux-fscrypt@vger.kernel.org>; Thu, 20 Jun 2019 00:08:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
In-Reply-To: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Thu, 20 Jun 2019 10:07:57 +0300
Message-ID: <CAOtvUMc0J3ufp3QyPwERdkRKfKzB_avPBoXSNWiCDS03jkNUzg@mail.gmail.com>
Subject: Re: [PATCH v3 0/6] crypto: switch to crypto API for ESSIV generation
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 19, 2019 at 7:29 PM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> This series creates an ESSIV template that produces a skcipher or AEAD
> transform based on a tuple of the form '<skcipher>,<cipher>,<shash>'
> (or '<aead>,<cipher>,<shash>' for the AEAD case). It exposes the
> encapsulated sync or async skcipher/aead by passing through all operation=
s,
> while using the cipher/shash pair to transform the input IV into an ESSIV
> output IV.
>
> This matches what both users of ESSIV in the kernel do, and so it is prop=
osed
> as a replacement for those, in patches #2 and #4.
>
> This code has been tested using the fscrypt test suggested by Eric
> (generic/549), as well as the mode-test script suggested by Milan for
> the dm-crypt case. I also tested the aead case in a virtual machine,
> but it definitely needs some wider testing from the dm-crypt experts.
>
> Changes since v2:
> - fixed a couple of bugs that snuck in after I'd done the bulk of my
>   testing
> - some cosmetic tweaks to the ESSIV template skcipher setkey function
>   to align it with the aead one
> - add a test case for essiv(cbc(aes),aes,sha256)
> - add an accelerated implementation for arm64 that combines the IV
>   derivation and the actual en/decryption in a single asm routine
>
> Scroll down for tcrypt speed test result comparing the essiv template
> with the asm implementation. Bare cbc(aes) tests included for reference
> as well. Taken on a 2GHz Cortex-A57 (AMD Seattle)
>
> Code can be found here
> https://git.kernel.org/pub/scm/linux/kernel/git/ardb/linux.git/log/?h=3De=
ssiv-v3


Thank you Ard for this work. It is very useful. I am testing this now
with the essiv implementation inside CryptoCell.

One possible future optimization this opens the door for is having the
template auto-increment the sector number.

This will allow the device manager or fscrypt code to ask for crypto
services on buffer spanning over a single sector size
and have the crypto code automatically increment the sector number
when processing the buffer.

This may potentially shave a few cycles because it can potentially
turn multiple calls into the crypto API in one, giving
the crypto code a larger buffer to work on.

This is actually supported by CryptoCell hardware and to the best of
my knowledge also by a similar HW from Qualcomm
via out-of-tree patches found in the Android tree.

If this makes sense to you perhaps it is a good idea to have the
template format be:

<skcipher>,<cipher>,<shash>, <sector size>

Where for now we will only support a sector size of '0' (i.e. do not
auto-increment) and later extend or am I over engineering? :-)

Thanks,
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker

values of =CE=B2 will give rise to dom!
