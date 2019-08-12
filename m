Return-Path: <dm-devel-bounces@redhat.com>
References: <20190810094053.7423-1-ard.biesheuvel@linaro.org>
	<20190810094053.7423-4-ard.biesheuvel@linaro.org>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <8679d2f5-b005-cd89-957e-d79440b78086@gmail.com>
Date: Mon, 12 Aug 2019 08:33:32 +0200
MIME-Version: 1.0
In-Reply-To: <20190810094053.7423-4-ard.biesheuvel@linaro.org>
Content-Language: en-US
Subject: Re: [dm-devel] [PATCH v9 3/7] md: dm-crypt: switch to ESSIV crypto
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
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-crypto@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On 10/08/2019 11:40, Ard Biesheuvel wrote:
> Replace the explicit ESSIV handling in the dm-crypt driver with calls
> into the crypto API, which now possesses the capability to perform
> this processing within the crypto subsystem.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  drivers/md/Kconfig    |   1 +
>  drivers/md/dm-crypt.c | 194 ++++----------------
>  2 files changed, 33 insertions(+), 162 deletions(-)
> 
> diff --git a/drivers/md/Kconfig b/drivers/md/Kconfig
> index 3834332f4963..b727e8f15264 100644
> --- a/drivers/md/Kconfig
> +++ b/drivers/md/Kconfig
...
> @@ -2493,6 +2339,20 @@ static int crypt_ctr_cipher_new(struct dm_target *ti, char *cipher_in, char *key
>  	if (*ivmode && !strcmp(*ivmode, "lmk"))
>  		cc->tfms_count = 64;
>  
> +	if (*ivmode && !strcmp(*ivmode, "essiv")) {
> +		if (!*ivopts) {
> +			ti->error = "Digest algorithm missing for ESSIV mode";
> +			return -EINVAL;
> +		}
> +		ret = snprintf(buf, CRYPTO_MAX_ALG_NAME, "essiv(%s,%s)",
> +			       cipher_api, *ivopts);

This is wrong. It works only in length-preserving modes, not in AEAD modes.

Try for example
# cryptsetup luksFormat /dev/sdc -c aes-cbc-essiv:sha256 --integrity hmac-sha256 -q -i1

It should produce Crypto API string
  authenc(hmac(sha256),essiv(cbc(aes),sha256))
while it produces
  essiv(authenc(hmac(sha256),cbc(aes)),sha256)
(and fails).

You can run "luks2-integrity-test" from cryptsetup test suite to detect it.

Just the test does not fail, it prints N/A for ESSIV use cases - we need to deal with older kernels...
I can probable change it to fail unconditionally though.

...
> @@ -2579,9 +2439,19 @@ static int crypt_ctr_cipher_old(struct dm_target *ti, char *cipher_in, char *key
>  	if (!cipher_api)
>  		goto bad_mem;
>  
> -	ret = snprintf(cipher_api, CRYPTO_MAX_ALG_NAME,
> -		       "%s(%s)", chainmode, cipher);
> -	if (ret < 0) {
> +	if (*ivmode && !strcmp(*ivmode, "essiv")) {
> +		if (!*ivopts) {
> +			ti->error = "Digest algorithm missing for ESSIV mode";
> +			kfree(cipher_api);
> +			return -EINVAL;
> +		}
> +		ret = snprintf(cipher_api, CRYPTO_MAX_ALG_NAME,
> +			       "essiv(%s(%s),%s)", chainmode, cipher, *ivopts);

I guess here it is ok, because old forma cannot use AEAD.

Thanks,
Milan

--
dm-devel mailing list
dm-devel@redhat.com
https://www.redhat.com/mailman/listinfo/dm-devel
