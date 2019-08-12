Return-Path: <dm-devel-bounces@redhat.com>
Date: Mon, 12 Aug 2019 12:38:50 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190812193849.GA131059@gmail.com>
References: <20190812145324.27090-1-ard.biesheuvel@linaro.org>
	<20190812145324.27090-2-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190812145324.27090-2-ard.biesheuvel@linaro.org>
Subject: Re: [dm-devel] [PATCH v10 1/7] crypto: essiv - create wrapper
 template for ESSIV generation
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, linux-crypto@vger.kernel.org, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 05:53:18PM +0300, Ard Biesheuvel wrote:
> +	switch (type) {
> +	case CRYPTO_ALG_TYPE_BLKCIPHER:
> +		skcipher_inst = kzalloc(sizeof(*skcipher_inst) +
> +					sizeof(*ictx), GFP_KERNEL);
> +		if (!skcipher_inst)
> +			return -ENOMEM;
> +		inst = skcipher_crypto_instance(skcipher_inst);
> +		base = &skcipher_inst->alg.base;
> +		ictx = crypto_instance_ctx(inst);
> +
> +		/* Block cipher, e.g. "cbc(aes)" */
> +		crypto_set_skcipher_spawn(&ictx->u.skcipher_spawn, inst);
> +		err = crypto_grab_skcipher(&ictx->u.skcipher_spawn,
> +					   inner_cipher_name, 0,
> +					   crypto_requires_sync(algt->type,
> +								algt->mask));
> +		if (err)
> +			goto out_free_inst;

This should say "Symmetric cipher", not "Block cipher".

> +
> +	if (!parse_cipher_name(essiv_cipher_name, block_base->cra_name)) {
> +		pr_warn("Failed to parse ESSIV cipher name from skcipher cra_name\n");
> +		goto out_drop_skcipher;
> +	}

This is missing:
		
		err = -EINVAL;

> +	if (type == CRYPTO_ALG_TYPE_BLKCIPHER) {
> +		skcipher_inst->alg.setkey	= essiv_skcipher_setkey;
> +		skcipher_inst->alg.encrypt	= essiv_skcipher_encrypt;
> +		skcipher_inst->alg.decrypt	= essiv_skcipher_decrypt;
> +		skcipher_inst->alg.init		= essiv_skcipher_init_tfm;
> +		skcipher_inst->alg.exit		= essiv_skcipher_exit_tfm;
> +
> +		skcipher_inst->alg.min_keysize	= crypto_skcipher_alg_min_keysize(skcipher_alg);
> +		skcipher_inst->alg.max_keysize	= crypto_skcipher_alg_max_keysize(skcipher_alg);
> +		skcipher_inst->alg.ivsize	= crypto_skcipher_alg_ivsize(skcipher_alg);
> +		skcipher_inst->alg.chunksize	= crypto_skcipher_alg_chunksize(skcipher_alg);
> +		skcipher_inst->alg.walksize	= crypto_skcipher_alg_walksize(skcipher_alg);
> +
> +		skcipher_inst->free		= essiv_skcipher_free_instance;
> +
> +		err = skcipher_register_instance(tmpl, skcipher_inst);
> +	} else {
> +		aead_inst->alg.setkey		= essiv_aead_setkey;
> +		aead_inst->alg.setauthsize	= essiv_aead_setauthsize;
> +		aead_inst->alg.encrypt		= essiv_aead_encrypt;
> +		aead_inst->alg.decrypt		= essiv_aead_decrypt;
> +		aead_inst->alg.init		= essiv_aead_init_tfm;
> +		aead_inst->alg.exit		= essiv_aead_exit_tfm;
> +
> +		aead_inst->alg.ivsize		= crypto_aead_alg_ivsize(aead_alg);
> +		aead_inst->alg.maxauthsize	= crypto_aead_alg_maxauthsize(aead_alg);
> +		aead_inst->alg.chunksize	= crypto_aead_alg_chunksize(aead_alg);
> +
> +		aead_inst->free			= essiv_aead_free_instance;
> +
> +		err = aead_register_instance(tmpl, aead_inst);
> +	}

'ivsize' is already in a variable, so could use

		skcipher_inst->alg.ivsize       = ivsize;

	and
		aead_inst->alg.ivsize           = ivsize;
		
- Eric

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
