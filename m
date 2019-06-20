Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm1-f65.google.com ([209.85.128.65]:38055 "EHLO
        mail-wm1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726391AbfFTLXB (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 20 Jun 2019 07:23:01 -0400
Subject: Re: [PATCH v3 0/6] crypto: switch to crypto API for ESSIV generation
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <459f5760-3a1c-719d-2b44-824ba6283dd7@gmail.com>
Date: Thu, 20 Jun 2019 13:22:57 +0200
MIME-Version: 1.0
In-Reply-To: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 19/06/2019 18:29, Ard Biesheuvel wrote:
> This series creates an ESSIV template that produces a skcipher or AEAD
> transform based on a tuple of the form '<skcipher>,<cipher>,<shash>'
> (or '<aead>,<cipher>,<shash>' for the AEAD case). It exposes the
> encapsulated sync or async skcipher/aead by passing through all operations,
> while using the cipher/shash pair to transform the input IV into an ESSIV
> output IV.
> 
> This matches what both users of ESSIV in the kernel do, and so it is proposed
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

I run tests for the whole patchset, including some older scripts and seems
it works for dm-crypt now.

For the new CRYPTO_ESSIV option - dm-crypt must unconditionally
select it (we rely on all IV generators availability in userspace),
but that's already done in patch 4.

Thanks,
Milan
