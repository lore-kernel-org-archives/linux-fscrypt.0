Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm1-f67.google.com ([209.85.128.67]:40102 "EHLO
        mail-wm1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726622AbfHPH3o (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Aug 2019 03:29:44 -0400
Subject: Re: [PATCH v12 0/4] crypto: switch to crypto API for ESSIV generation
References: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <1463bca3-77dc-42be-7624-e8eaf5cfbf32@gmail.com>
Date: Fri, 16 Aug 2019 09:29:39 +0200
MIME-Version: 1.0
In-Reply-To: <20190815192858.28125-1-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On 15/08/2019 21:28, Ard Biesheuvel wrote:
> Changes since v10:
> - Drop patches against fscrypt and dm-crypt - these will be routed via the
>   respective maintainer trees during the next cycle

I tested the previous dm-crypt patches (I also try to keep them in my kernel.org tree),
it works and looks fine to me (and I like the final cleanup :)

Once all maintainers are happy with the current state, I think it should go to
the next release (5.4; IMO both ESSIV API and dm-crypt changes).
Maybe you could keep sending dm-crypt patches in the end of the series (to help testing it)?

(Just for for now I am completely distracted by other urgent unrelated issues.)

Milan
