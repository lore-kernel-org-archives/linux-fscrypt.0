Return-Path: <dm-devel-bounces@redhat.com>
References: <20190621080918.22809-1-ard.biesheuvel@arm.com>
	<20190621080918.22809-5-ard.biesheuvel@arm.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <af75aefc-438b-9e31-b922-c847879d9dd9@gmail.com>
Date: Mon, 24 Jun 2019 09:05:30 +0200
MIME-Version: 1.0
In-Reply-To: <20190621080918.22809-5-ard.biesheuvel@arm.com>
Content-Language: en-US
Subject: Re: [dm-devel] [PATCH v4 4/6] md: dm-crypt: switch to ESSIV crypto
	API template
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
To: ard.biesheuvel@linaro.org, linux-crypto@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 21/06/2019 10:09, Ard Biesheuvel wrote:
> From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> 
> Replace the explicit ESSIV handling in the dm-crypt driver with calls
> into the crypto API, which now possesses the capability to perform
> this processing within the crypto subsystem.

I tried a few crazy dm-crypt configurations and was not able to crash it this time :-)

So, it definitely need some more testing, but for now, I think it works.

Few comments below for this part:

> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c

>  static const struct crypt_iv_operations crypt_iv_benbi_ops = {
>  	.ctr	   = crypt_iv_benbi_ctr,
>  	.dtr	   = crypt_iv_benbi_dtr,
> @@ -2283,7 +2112,7 @@ static int crypt_ctr_ivmode(struct dm_target *ti, const char *ivmode)
>  	else if (strcmp(ivmode, "plain64be") == 0)
>  		cc->iv_gen_ops = &crypt_iv_plain64be_ops;
>  	else if (strcmp(ivmode, "essiv") == 0)
> -		cc->iv_gen_ops = &crypt_iv_essiv_ops;
> +		cc->iv_gen_ops = &crypt_iv_plain64_ops;

This is quite misleading - it looks like you are switching to plain64 here.
The reality is that it uses plain64 to feed the ESSIV wrapper.

So either it need some comment to explain it here, or just keep simple essiv_iv_ops
and duplicate that plain64 generator (it is 2 lines of code).

For the clarity, I would prefer the second variant (duplicate ops) here.

> @@ -2515,8 +2357,18 @@ static int crypt_ctr_cipher_old(struct dm_target *ti, char *cipher_in, char *key
>  	if (!cipher_api)
>  		goto bad_mem;
>  
> -	ret = snprintf(cipher_api, CRYPTO_MAX_ALG_NAME,
> -		       "%s(%s)", chainmode, cipher);
> +	if (*ivmode && !strcmp(*ivmode, "essiv")) {
> +		if (!*ivopts) {
> +			ti->error = "Digest algorithm missing for ESSIV mode";
> +			return -EINVAL;
> +		}
> +		ret = snprintf(cipher_api, CRYPTO_MAX_ALG_NAME,
> +			       "essiv(%s(%s),%s,%s)", chainmode, cipher,
> +			       cipher, *ivopts);

This becomes quite long string already (limit is now 128 bytes), we should probably
check also for too long string. It will perhaps fail later, but I would better add

	if (ret < 0 || ret >= CRYPTO_MAX_ALG_NAME) {
	...

> +	} else {
> +		ret = snprintf(cipher_api, CRYPTO_MAX_ALG_NAME,
> +			       "%s(%s)", chainmode, cipher);
> +	}
>  	if (ret < 0) {
>  		kfree(cipher_api);
>  		goto bad_mem;
> 

Thanks,
Milan

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
