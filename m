Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm1-f65.google.com ([209.85.128.65]:50771 "EHLO
        mail-wm1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728220AbfGAI7z (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 1 Jul 2019 04:59:55 -0400
Subject: Re: [PATCH v6 4/7] md: dm-crypt: switch to ESSIV crypto API template
References: <20190628152112.914-1-ard.biesheuvel@linaro.org>
 <20190628152112.914-5-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <f068888f-1a13-babf-0144-07939a79d9d9@gmail.com>
Date: Mon, 1 Jul 2019 10:59:51 +0200
MIME-Version: 1.0
In-Reply-To: <20190628152112.914-5-ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 28/06/2019 17:21, Ard Biesheuvel wrote:
> Replace the explicit ESSIV handling in the dm-crypt driver with calls
> into the crypto API, which now possesses the capability to perform
> this processing within the crypto subsystem.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

>  drivers/md/dm-crypt.c | 200 ++++----------------

...

> -/* Wipe salt and reset key derived from volume key */
> -static int crypt_iv_essiv_wipe(struct crypt_config *cc)

Do I understand it correctly, that this is now called inside the whole cipher
set key in wipe command (in crypt_wipe_key())?

(Wipe message is meant to suspend the device and wipe all key material
from memory without actually destroying the device.)

> -{
> -	struct iv_essiv_private *essiv = &cc->iv_gen_private.essiv;
> -	unsigned salt_size = crypto_shash_digestsize(essiv->hash_tfm);
> -	struct crypto_cipher *essiv_tfm;
> -	int r, err = 0;
> -
> -	memset(essiv->salt, 0, salt_size);
> -
> -	essiv_tfm = cc->iv_private;
> -	r = crypto_cipher_setkey(essiv_tfm, essiv->salt, salt_size);
> -	if (r)
> -		err = r;
> -
> -	return err;
> -}

...

> @@ -2435,9 +2281,19 @@ static int crypt_ctr_cipher_new(struct dm_target *ti, char *cipher_in, char *key
>  	}
>  
>  	ret = crypt_ctr_blkdev_cipher(cc, cipher_api);
> -	if (ret < 0) {
> -		ti->error = "Cannot allocate cipher string";
> -		return -ENOMEM;
> +	if (ret < 0)
> +		goto bad_mem;
> +
> +	if (*ivmode && !strcmp(*ivmode, "essiv")) {
> +		if (!*ivopts) {
> +			ti->error = "Digest algorithm missing for ESSIV mode";
> +			return -EINVAL;
> +		}
> +		ret = snprintf(buf, CRYPTO_MAX_ALG_NAME, "essiv(%s,%s,%s)",
> +			       cipher_api, cc->cipher, *ivopts);
> +		if (ret < 0 || ret >= CRYPTO_MAX_ALG_NAME)
> +			goto bad_mem;

Hm, nitpicking, but goto from only one place while we have another -ENOMEM above...

Just place this here without goto?

> +	ti->error = "Cannot allocate cipher string";
> +	return -ENOMEM;

Otherwise

Reviewed-by: Milan Broz <gmazyland@gmail.com>

Thanks,
Milan
