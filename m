Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wr1-f67.google.com ([209.85.221.67]:44807 "EHLO
        mail-wr1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728190AbfGAI6v (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 1 Jul 2019 04:58:51 -0400
Subject: Re: [PATCH v6 3/7] md: dm-crypt: infer ESSIV block cipher from cipher
 string directly
References: <20190628152112.914-1-ard.biesheuvel@linaro.org>
 <20190628152112.914-4-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <767ec609-d805-9bc2-1a73-d5000ce7f109@gmail.com>
Date: Mon, 1 Jul 2019 10:58:47 +0200
MIME-Version: 1.0
In-Reply-To: <20190628152112.914-4-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 28/06/2019 17:21, Ard Biesheuvel wrote:
> Instead of allocating a crypto skcipher tfm 'foo' and attempting to
> infer the encapsulated block cipher from the driver's 'name' field,
> directly parse the string that we used to allocated the tfm. These
> are always identical (unless the allocation failed, in which case
> we bail anyway), but using the string allows us to use it in the
> allocation, which is something we will need when switching to the
> 'essiv' crypto API template.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

>  drivers/md/dm-crypt.c | 35 +++++++++-----------

> @@ -2445,21 +2451,10 @@ static int crypt_ctr_cipher_new(struct dm_target *ti, char *cipher_in, char *key
>  
>  	/* Alloc AEAD, can be used only in new format. */

^^ This comment is now obsolete, please move it with the code or remove it.

>  	if (crypt_integrity_aead(cc)) {
> -		ret = crypt_ctr_auth_cipher(cc, cipher_api);
> -		if (ret < 0) {
> -			ti->error = "Invalid AEAD cipher spec";
> -			return -ENOMEM;
> -		}
>  		cc->iv_size = crypto_aead_ivsize(any_tfm_aead(cc));
>  	} else
>  		cc->iv_size = crypto_skcipher_ivsize(any_tfm(cc));

Otherwise

Reviewed-by: Milan Broz <gmazyland@gmail.com>

Thanks,
Milan
