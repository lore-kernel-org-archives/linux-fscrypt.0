Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47534 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726322AbfFSWhO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jun 2019 18:37:14 -0400
Date: Wed, 19 Jun 2019 15:37:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v3 6/6] crypto: arm64/aes - implement accelerated
 ESSIV/CBC mode
Message-ID: <20190619223710.GC33328@gmail.com>
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-7-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619162921.12509-7-ard.biesheuvel@linaro.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 19, 2019 at 06:29:21PM +0200, Ard Biesheuvel wrote:
> Add an accelerated version of the 'essiv(cbc(aes),aes,sha256)'
> skcipher, which is used by fscrypt, and in some cases, by dm-crypt.
> This avoids a separate call into the AES cipher for every invocation.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

I'm not sure we should bother with this, since fscrypt normally uses AES-256-XTS
for contents encryption.  AES-128-CBC-ESSIV support was only added because
people wanted something that is fast on low-powered embedded devices with crypto
accelerators such as CAAM or CESA that don't support XTS.

In the case of Android, the CDD doesn't even allow AES-128-CBC-ESSIV with
file-based encryption (fscrypt).  It's still the default for "full disk
encryption" (which uses dm-crypt), but that's being deprecated.

So maybe dm-crypt users will want this, but I don't think it's very useful for
fscrypt.

- Eric
