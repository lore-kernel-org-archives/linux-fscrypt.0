Return-Path: <SRS0=Dhrz=WR=gmail.com=gmazyland@kernel.org>
Subject: Re: [PATCH 6/9] dm crypt: support diskcipher
References: <CGME20190821064230epcas2p1ad7301f2b1331bcab3126e6e37c0e272@epcas2p1.samsung.com>
 <004201d557eb$9b0a4410$d11ecc30$@samsung.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <cc484ef6-aacc-7864-0e6d-313b2e1c5d92@gmail.com>
Date: Wed, 21 Aug 2019 09:13:36 +0200
MIME-Version: 1.0
In-Reply-To: <004201d557eb$9b0a4410$d11ecc30$@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: "boojin.kim" <boojin.kim@samsung.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Mike Snitzer' <snitzer@redhat.com>, dm-devel@redhat.com, linux-kernel@vger.kernel.org
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'" <tytso@mit.edu>, 'Chao Yu' <chao@kernel.org>, 'Jaegeuk Kim' <jaegeuk@kernel.org>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, 'Ulf Hansson' <ulf.hansson@linaro.org>, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 21/08/2019 08:42, boojin.kim wrote:
> This patch supports dm-crypt to use diskcipher in a specific ivmode
> (disk or fmp).
> Dm-crypt allocates diskcipher and sets the key on it.
> Then, dm-crypt sets diskcipher into BIO and submits the BIO without
> any additional data encryption.

NACK.

The whole principle of dm-crypt target is that it NEVER EVER submits
plaintext data down the stack in bio.

If you want to do some lower/higher layer encryption, use key management
on a different layer.
So here, just setup encryption for fs, do not stack it with dm-crypt.

Also, dm-crypt is software-independent solution
(software-based full disk encryption), it must not depend on
any underlying hardware.
Hardware can be of course used used for acceleration, but then
just implement proper crypto API module that accelerates particular cipher.

I really hope we do not want to repeat the same mistake like presented here
https://www.ru.nl/english/news-agenda/news/vm/icis/cyber-security/2018/radboud-university-researchers-discover-security/

Milan

> 
> Cc: Alasdair Kergon <agk@redhat.com>
> Cc: Mike Snitzer <snitzer@redhat.com>
> Cc: dm-devel@redhat.com
> Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
> ---
>  drivers/md/dm-crypt.c | 112
> ++++++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 103 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index 9f8b654..271cfcc 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -37,6 +37,7 @@
>  #include <keys/user-type.h>
>  
>  #include <linux/device-mapper.h>
> +#include <crypto/diskcipher.h>
>  
>  #define DM_MSG_PREFIX "crypt"
>  
> @@ -130,6 +131,8 @@ enum flags { DM_CRYPT_SUSPENDED, DM_CRYPT_KEY_VALID,
>  enum cipher_flags {
>  	CRYPT_MODE_INTEGRITY_AEAD,	/* Use authenticated mode for cihper
> */
>  	CRYPT_IV_LARGE_SECTORS,		/* Calculate IV from sector_size,
> not 512B sectors */
> +	CRYPT_MODE_DISKCIPHER,
> +	CRYPT_MODE_SKCIPHER,
>  };
>  
>  /*
> @@ -170,6 +173,7 @@ struct crypt_config {
>  	union {
>  		struct crypto_skcipher **tfms;
>  		struct crypto_aead **tfms_aead;
> +		struct crypto_diskcipher **tfms_diskc;
>  	} cipher_tfm;
>  	unsigned tfms_count;
>  	unsigned long cipher_flags;
> @@ -955,6 +959,17 @@ static bool crypt_integrity_hmac(struct crypt_config
> *cc)
>  	return crypt_integrity_aead(cc) && cc->key_mac_size;
>  }
>  
> +static bool crypt_mode_diskcipher(struct crypt_config *cc)
> +{
> +	return test_bit(CRYPT_MODE_DISKCIPHER, &cc->cipher_flags);
> +}
> +
> +static bool crypt_mode_skcipher(struct crypt_config *cc)
> +{
> +	return test_bit(CRYPT_MODE_SKCIPHER, &cc->cipher_flags);
> +}
> +
> +
>  /* Get sg containing data */
>  static struct scatterlist *crypt_get_sg_data(struct crypt_config *cc,
>  					     struct scatterlist *sg)
> @@ -1573,13 +1588,13 @@ static void crypt_endio(struct bio *clone)
>  	/*
>  	 * free the processed pages
>  	 */
> -	if (rw == WRITE)
> +	if ((rw == WRITE) && !crypt_mode_diskcipher(cc))
>  		crypt_free_buffer_pages(cc, clone);
>  
>  	error = clone->bi_status;
>  	bio_put(clone);
>  
> -	if (rw == READ && !error) {
> +	if (rw == READ && !error && !crypt_mode_diskcipher(cc)) {
>  		kcryptd_queue_crypt(io);
>  		return;
>  	}
> @@ -1618,6 +1633,11 @@ static int kcryptd_io_read(struct dm_crypt_io *io,
> gfp_t gfp)
>  	crypt_inc_pending(io);
>  
>  	clone_init(io, clone);
> +
> +	if (crypt_mode_diskcipher(cc))
> +		crypto_diskcipher_set(clone,
> +			cc->cipher_tfm.tfms_diskc[0], NULL, 0);
> +
>  	clone->bi_iter.bi_sector = cc->start + io->sector;
>  
>  	if (dm_crypt_integrity_io_alloc(io, clone)) {
> @@ -1907,10 +1927,29 @@ static void crypt_free_tfms_skcipher(struct
> crypt_config *cc)
>  	cc->cipher_tfm.tfms = NULL;
>  }
>  
> +static void crypt_free_tfms_diskcipher(struct crypt_config *cc)
> +{
> +	if (!crypt_mode_diskcipher(cc))
> +		return;
> +
> +	if (cc->cipher_tfm.tfms_diskc[0] &&
> +		!IS_ERR(cc->cipher_tfm.tfms_diskc[0])) {
> +		crypto_diskcipher_clearkey(cc->cipher_tfm.tfms_diskc[0]);
> +		crypto_free_diskcipher(cc->cipher_tfm.tfms_diskc[0]);
> +		cc->cipher_tfm.tfms_diskc[0] = NULL;
> +	}
> +
> +	kfree(cc->cipher_tfm.tfms_diskc);
> +	cc->cipher_tfm.tfms_diskc = NULL;
> +}
> +
> +
>  static void crypt_free_tfms(struct crypt_config *cc)
>  {
>  	if (crypt_integrity_aead(cc))
>  		crypt_free_tfms_aead(cc);
> +	else if (crypt_mode_diskcipher(cc))
> +		crypt_free_tfms_diskcipher(cc);
>  	else
>  		crypt_free_tfms_skcipher(cc);
>  }
> @@ -1934,6 +1973,7 @@ static int crypt_alloc_tfms_skcipher(struct
> crypt_config *cc, char *ciphermode)
>  			return err;
>  		}
>  	}
> +	set_bit(CRYPT_MODE_SKCIPHER, &cc->cipher_flags);
>  
>  	/*
>  	 * dm-crypt performance can vary greatly depending on which crypto
> @@ -1965,10 +2005,34 @@ static int crypt_alloc_tfms_aead(struct crypt_config
> *cc, char *ciphermode)
>  	return 0;
>  }
>  
> +static int crypt_alloc_tfms_diskcipher(struct crypt_config *cc,
> +				char *ciphermode)
> +{
> +	int err;
> +
> +	cc->cipher_tfm.tfms = kmalloc(sizeof(struct crypto_aead *),
> GFP_KERNEL);
> +	if (!cc->cipher_tfm.tfms)
> +		return -ENOMEM;
> +
> +	cc->cipher_tfm.tfms_diskc[0] =
> +	    crypto_alloc_diskcipher(ciphermode, 0, 0, 1);
> +	if (IS_ERR(cc->cipher_tfm.tfms_diskc[0])) {
> +		err = PTR_ERR(cc->cipher_tfm.tfms_diskc[0]);
> +		crypt_free_tfms(cc);
> +		pr_err("%s: no diskcipher with %s\n", __func__, ciphermode);
> +		return err;
> +	}
> +	pr_info("%s is done with %s\n", __func__, ciphermode);
> +
> +	return 0;
> +}
> +
>  static int crypt_alloc_tfms(struct crypt_config *cc, char *ciphermode)
>  {
>  	if (crypt_integrity_aead(cc))
>  		return crypt_alloc_tfms_aead(cc, ciphermode);
> +	else if (crypt_mode_diskcipher(cc))
> +		return crypt_alloc_tfms_diskcipher(cc, ciphermode);
>  	else
>  		return crypt_alloc_tfms_skcipher(cc, ciphermode);
>  }
> @@ -2030,6 +2094,11 @@ static int crypt_setkey(struct crypt_config *cc)
>  			r = crypto_aead_setkey(cc->cipher_tfm.tfms_aead[i],
>  					       cc->key + (i * subkey_size),
>  					       subkey_size);
> +		else if (crypt_mode_diskcipher(cc))
> +			r = crypto_diskcipher_setkey(
> +
> cc->cipher_tfm.tfms_diskc[i],
> +						cc->key + (i * subkey_size),
> +						subkey_size, 1);
>  		else
>  			r = crypto_skcipher_setkey(cc->cipher_tfm.tfms[i],
>  						   cc->key + (i *
> subkey_size),
> @@ -2510,7 +2579,7 @@ static int crypt_ctr_cipher_new(struct dm_target *ti,
> char *cipher_in, char *key
>  			return -ENOMEM;
>  		}
>  		cc->iv_size = crypto_aead_ivsize(any_tfm_aead(cc));
> -	} else
> +	} else if (crypt_mode_skcipher(cc))
>  		cc->iv_size = crypto_skcipher_ivsize(any_tfm(cc));
>  
>  	ret = crypt_ctr_blkdev_cipher(cc);
> @@ -2560,6 +2629,9 @@ static int crypt_ctr_cipher_old(struct dm_target *ti,
> char *cipher_in, char *key
>  	chainmode = strsep(&tmp, "-");
>  	*ivmode = strsep(&tmp, ":");
>  	*ivopts = tmp;
> +	if (*ivmode)
> +		if (!strcmp(*ivmode, "disk") || !strcmp(*ivmode, "fmp"))
> +			set_bit(CRYPT_MODE_DISKCIPHER, &cc->cipher_flags);
>  
>  	/*
>  	 * For compatibility with the original dm-crypt mapping format, if
> @@ -2621,9 +2693,11 @@ static int crypt_ctr_cipher(struct dm_target *ti,
> char *cipher_in, char *key)
>  		return ret;
>  
>  	/* Initialize IV */
> -	ret = crypt_ctr_ivmode(ti, ivmode);
> -	if (ret < 0)
> -		return ret;
> +	if (!crypt_mode_diskcipher(cc)) {
> +		ret = crypt_ctr_ivmode(ti, ivmode);
> +		if (ret < 0)
> +			return ret;
> +	}
>  
>  	/* Initialize and set key */
>  	ret = crypt_set_key(cc, key);
> @@ -2654,6 +2728,11 @@ static int crypt_ctr_cipher(struct dm_target *ti,
> char *cipher_in, char *key)
>  	if (cc->key_string)
>  		memset(cc->key, 0, cc->key_size * sizeof(u8));
>  
> +	pr_info("%s with ivmode:%s, ivopts:%s, aead:%d, diskcipher:%d(%p),
> skcipher:%d\n",
> +			__func__, ivmode, ivopts, crypt_integrity_aead(cc),
> +			crypt_mode_diskcipher(cc),
> cc->cipher_tfm.tfms_diskc[0],
> +			crypt_mode_skcipher(cc));
> +
>  	return ret;
>  }
>  
> @@ -2788,11 +2867,15 @@ static int crypt_ctr(struct dm_target *ti, unsigned
> int argc, char **argv)
>  	ret = crypt_ctr_cipher(ti, argv[0], argv[1]);
>  	if (ret < 0)
>  		goto bad;
> -
>  	if (crypt_integrity_aead(cc)) {
>  		cc->dmreq_start = sizeof(struct aead_request);
>  		cc->dmreq_start += crypto_aead_reqsize(any_tfm_aead(cc));
>  		align_mask = crypto_aead_alignmask(any_tfm_aead(cc));
> +	} else if (crypt_mode_diskcipher(cc)) {
> +		cc->per_bio_data_size = ti->per_io_data_size =
> +			ALIGN(sizeof(struct dm_crypt_io),
> +			ARCH_KMALLOC_MINALIGN);
> +		goto get_bio;
>  	} else {
>  		cc->dmreq_start = sizeof(struct skcipher_request);
>  		cc->dmreq_start += crypto_skcipher_reqsize(any_tfm(cc));
> @@ -2836,6 +2919,7 @@ static int crypt_ctr(struct dm_target *ti, unsigned
> int argc, char **argv)
>  		goto bad;
>  	}
>  
> +get_bio:
>  	ret = bioset_init(&cc->bs, MIN_IOS, 0, BIOSET_NEED_BVECS);
>  	if (ret) {
>  		ti->error = "Cannot allocate crypt bioset";
> @@ -2893,6 +2977,12 @@ static int crypt_ctr(struct dm_target *ti, unsigned
> int argc, char **argv)
>  		goto bad;
>  	}
>  
> +	if (crypt_mode_diskcipher(cc)) {
> +		cc->crypt_queue = NULL;
> +		cc->write_thread = NULL;
> +		goto out;
> +	}
> +
>  	if (test_bit(DM_CRYPT_SAME_CPU, &cc->flags))
>  		cc->crypt_queue = alloc_workqueue("kcryptd/%s",
>  						  WQ_HIGHPRI |
> WQ_CPU_INTENSIVE | WQ_MEM_RECLAIM,
> @@ -2918,6 +3008,7 @@ static int crypt_ctr(struct dm_target *ti, unsigned
> int argc, char **argv)
>  	}
>  	wake_up_process(cc->write_thread);
>  
> +out:
>  	ti->num_flush_bios = 1;
>  
>  	return 0;
> @@ -2981,10 +3072,10 @@ static int crypt_map(struct dm_target *ti, struct
> bio *bio)
>  
>  	if (crypt_integrity_aead(cc))
>  		io->ctx.r.req_aead = (struct aead_request *)(io + 1);
> -	else
> +	else if (crypt_mode_skcipher(cc))
>  		io->ctx.r.req = (struct skcipher_request *)(io + 1);
>  
> -	if (bio_data_dir(io->base_bio) == READ) {
> +	if ((bio_data_dir(io->base_bio) == READ) ||
> crypt_mode_diskcipher(cc)) {
>  		if (kcryptd_io_read(io, GFP_NOWAIT))
>  			kcryptd_queue_read(io);
>  	} else
> @@ -3143,6 +3234,9 @@ static void crypt_io_hints(struct dm_target *ti,
> struct queue_limits *limits)
>  	limits->physical_block_size =
>  		max_t(unsigned, limits->physical_block_size,
> cc->sector_size);
>  	limits->io_min = max_t(unsigned, limits->io_min, cc->sector_size);
> +
> +	if (crypt_mode_diskcipher(cc))
> +		limits->logical_block_size = PAGE_SIZE;
>  }
>  
>  static struct target_type crypt_target = {
> 
