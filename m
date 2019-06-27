Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36722 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725770AbfF0Qks (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 27 Jun 2019 12:40:48 -0400
Date: Thu, 27 Jun 2019 09:40:45 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v5 7/7] crypto: arm64/aes - implement accelerated
 ESSIV/CBC mode
Message-ID: <20190627164045.GE686@sol.localdomain>
References: <20190626204047.32131-1-ard.biesheuvel@linaro.org>
 <20190626204047.32131-8-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626204047.32131-8-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 26, 2019 at 10:40:47PM +0200, Ard Biesheuvel wrote:
> Add an accelerated version of the 'essiv(cbc(aes),aes,sha256'
> skcipher, which is used by fscrypt, and in some cases, by dm-crypt.
> This avoids a separate call into the AES cipher for every invocation.

This technically should say "in some cases by fscrypt and dm-crypt", since as
we've discussed previously, most of the time this is not what fscrypt uses.

- Eric
