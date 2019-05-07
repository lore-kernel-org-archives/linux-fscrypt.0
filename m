Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl1-f195.google.com ([209.85.214.195]:45102 "EHLO
        mail-pl1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726128AbfEGAhc (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 May 2019 20:37:32 -0400
Subject: Re: [RFC PATCH 1/4] block: Block Layer changes for Inline Encryption
 Support
References: <20190506223544.195371-1-satyat@google.com>
 <20190506223544.195371-2-satyat@google.com>
From: Bart Van Assche <bvanassche@acm.org>
Message-ID: <8d44c89f-cc61-9324-adaa-a343f2373556@acm.org>
Date: Mon, 6 May 2019 17:37:28 -0700
MIME-Version: 1.0
In-Reply-To: <20190506223544.195371-2-satyat@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: Satya Tangirala <satyat@google.com>, linux-block@vger.kernel.org, linux-scsi@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Parshuram Raju Thombare <pthombar@cadence.com>, Ladvine D Almeida <ladvine.dalmeida@synopsys.com>, Barani Muthukumaran <bmuthuku@qti.qualcomm.com>, Kuohong Wang <kuohong.wang@mediatek.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 5/6/19 3:35 PM, Satya Tangirala wrote:
> +#ifdef CONFIG_BLK_CRYPT_CTX
> +static inline void bio_crypt_advance(struct bio *bio, unsigned int bytes)
> +{
> +	if (bio_is_encrypted(bio)) {
> +		bio->bi_crypt_context.data_unit_num +=
> +			bytes >> bio->bi_crypt_context.data_unit_size_bits;
> +	}
> +}
> +
> +void bio_clone_crypt_context(struct bio *dst, struct bio *src)
> +{
> +	if (bio_crypt_swhandled(src))
> +		return;
> +	dst->bi_crypt_context = src->bi_crypt_context;
> +
> +	if (!bio_crypt_has_keyslot(src))
> +		return;
> +
> +	/**

Please use "/*" to start comment blocks other than kernel-doc headers.

> +	 * This should always succeed because the src bio should already
> +	 * have a reference to the keyslot.
> +	 */
> +	BUG_ON(!keyslot_manager_get_slot(src->bi_crypt_context.processing_ksm,
> +					  src->bi_crypt_context.keyslot));

Are you aware that using BUG_ON() if there is a reasonable way to
recover is not acceptable?

> +}
> +
> +bool bio_crypt_should_process(struct bio *bio, struct request_queue *q)
> +{
> +	if (!bio_is_encrypted(bio))
> +		return false;
> +
> +	WARN_ON(!bio_crypt_has_keyslot(bio));
> +	return q->ksm == bio->bi_crypt_context.processing_ksm;
> +}
> +EXPORT_SYMBOL(bio_crypt_should_process);
> +
> +#endif /* CONFIG_BLK_CRYPT_CTX */

Please move these new functions into a separate source file instead of
using #ifdef / #endif. I think the coding style documentation mentions
this explicitly.

> +static struct blk_crypto_keyslot {
> +	struct crypto_skcipher *tfm;
> +	int crypto_alg_id;
> +	union {
> +		u8 key[BLK_CRYPTO_MAX_KEY_SIZE];
> +		u32 key_words[BLK_CRYPTO_MAX_KEY_SIZE/4];
> +	};
> +} *slot_mem;

What is the purpose of the key_words[] member? Is it used anywhere? If
not, can it be left out?

> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 1c9d4f0f96ea..55133c547bdf 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -614,6 +614,59 @@ int blk_rq_map_sg(struct request_queue *q, struct request *rq,
>  }
>  EXPORT_SYMBOL(blk_rq_map_sg);
>  
> +#ifdef CONFIG_BLK_CRYPT_CTX
> +/*
> + * Checks that two bio crypt contexts are compatible - i.e. that
> + * they are mergeable except for data_unit_num continuity.
> + */
> +static inline bool bio_crypt_ctx_compatible(struct bio *b_1, struct bio *b_2)
> +{
> +	struct bio_crypt_ctx *bc1 = &b_1->bi_crypt_context;
> +	struct bio_crypt_ctx *bc2 = &b_2->bi_crypt_context;
> +
> +	if (bio_is_encrypted(b_1) != bio_is_encrypted(b_2) ||
> +	    bc1->keyslot != bc2->keyslot)
> +		return false;
> +
> +	return !bio_is_encrypted(b_1) ||
> +		bc1->data_unit_size_bits == bc2->data_unit_size_bits;
> +}
> +
> +/*
> + * Checks that two bio crypt contexts are compatible, and also
> + * that their data_unit_nums are continuous (and can hence be merged)
> + */
> +static inline bool bio_crypt_ctx_back_mergeable(struct bio *b_1,
> +						unsigned int b1_sectors,
> +						struct bio *b_2)
> +{
> +	struct bio_crypt_ctx *bc1 = &b_1->bi_crypt_context;
> +	struct bio_crypt_ctx *bc2 = &b_2->bi_crypt_context;
> +
> +	if (!bio_crypt_ctx_compatible(b_1, b_2))
> +		return false;
> +
> +	return !bio_is_encrypted(b_1) ||
> +		(bc1->data_unit_num +
> +		(b1_sectors >> (bc1->data_unit_size_bits - 9)) ==
> +		bc2->data_unit_num);
> +}
> +
> +#else /* CONFIG_BLK_CRYPT_CTX */
> +static inline bool bio_crypt_ctx_compatible(struct bio *b_1, struct bio *b_2)
> +{
> +	return true;
> +}
> +
> +static inline bool bio_crypt_ctx_back_mergeable(struct bio *b_1,
> +						unsigned int b1_sectors,
> +						struct bio *b_2)
> +{
> +	return true;
> +}
> +
> +#endif /* CONFIG_BLK_CRYPT_CTX */

Can the above functions be moved into a new file such that the
#ifdef/#endif construct can be avoided?

> +	/* Wait till there is a free slot available */
> +	while (atomic_read(&ksm->num_idle_slots) == 0) {
> +		mutex_unlock(&ksm->lock);
> +		wait_event(ksm->wait_queue,
> +			   (atomic_read(&ksm->num_idle_slots) > 0));
> +		mutex_lock(&ksm->lock);
> +	}

Using an atomic_read() inside code protected by a mutex is suspicious.
Would protecting all ksm->num_idle_slots manipulations with ksm->lock
and making ksm->num_idle_slots a regular integer have a negative
performance impact?

> +struct keyslot_mgmt_ll_ops {
> +	int (*keyslot_program)(void *ll_priv_data, const u8 *key,
> +			       unsigned int data_unit_size,
> +			       /* crypto_alg_id returned by crypto_alg_find */
> +			       unsigned int crypto_alg_id,
> +			       unsigned int slot);
> +	/**
> +	 * Evict key from all keyslots in the keyslot manager.
> +	 * The key, data_unit_size and crypto_alg_id are also passed down
> +	 * so that for e.g. dm layers that have their own keyslot
> +	 * managers can evict keys from the devices that they map over.
> +	 * Returns 0 on success, -errno otherwise.
> +	 */
> +	int (*keyslot_evict)(void *ll_priv_data, unsigned int slot,
> +			     const u8 *key, unsigned int data_unit_size,
> +			     unsigned int crypto_alg_id);
> +	/**
> +	 * Get a crypto_alg_id (used internally by the lower layer driver) that
> +	 * represents the given blk-crypto crypt_mode and data_unit_size. The
> +	 * returned crypto_alg_id will be used in future calls to the lower
> +	 * layer driver (in keyslot_program and keyslot_evict) to reference
> +	 * this crypt_mode, data_unit_size combo. Returns negative error code
> +	 * if a crypt_mode, data_unit_size combo is not supported.
> +	 */
> +	int (*crypto_alg_find)(void *ll_priv_data,
> +			       enum blk_crypt_mode_index crypt_mode,
> +			       unsigned int data_unit_size);
> +	/**
> +	 * Returns the slot number that matches the key,
> +	 * or -ENOKEY if no match found, or negative on error
> +	 */
> +	int (*keyslot_find)(void *ll_priv_data, const u8 *key,
> +			    unsigned int data_unit_size,
> +			    unsigned int crypto_alg_id);
> +};

Have you considered to use kernel-doc format for documenting the members
of the keyslot_mgmt_ll_ops structure?

Thanks,

Bart.
