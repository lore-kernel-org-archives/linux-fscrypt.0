Received: from out30-119.freemail.mail.aliyun.com (out30-119.freemail.mail.aliyun.com [115.124.30.119])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3693F56260A;
	Thu, 15 Oct 2026 17:36:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.119
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792085798; cv=none; b=Eh84g0OK4bdkESAAfeQWGi6++AVGIchRrPe+r32fsev+c/nFMFmzaITNOtXmwcDspBC6QGfs9sSllAflwg9Wt8GjupDzmdKDNtYljNTCZZDbcsHA/eDLRFOF6ifn8Mf01xHYDXWyz8bTM8UbDsviTKtExkQcH1t0q/6Eyp2Eh0o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792085798; c=relaxed/simple;
	bh=SsAX70hkztxr3lXUejP7fw9k5bXsDS+j8dp7p+FMWsM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Ab83CNGN5v5Rkh69aQlsNzUGrAe5qXlfZ/8Q5FuFoMXcJXBDY+7GX5sTlv5U9ZimhyP7Yu7SOq3KduzwFlht3U3vCMyzH9N7gJUa+HIGda65QOVwfeH3N6oFbQQBKMbEDCqcaz+O1mas67cXa61soLy4d3IpDfj0CZq4Y5JF5ek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=N54WOdun; arc=none smtp.client-ip=115.124.30.119
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="N54WOdun"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792085780; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=9YnrwI+/iPNmoh1SsSb82TY/9geUY5RwvCpBUzwgTd8=;
	b=N54WOdunucmUbKqHgXyVo928Msf3sEV8E3iu1tvmwsRzEKUmrXGVBe/y0jTOsXZ/6PMFOQQbGR1UjYqcYZ8VlCbCkcVrvI4OQih4i8i5RBY7tfsjjVqRFFZ9yzDb4+bcECS5R2arpyDOoSzcGTcoVaxGuteLKtbLMzxDEsqub+E=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R531e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037009110;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0XCsJh-j_1792085778;
Received: from 30.170.203.187(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XCsJh-j_1792085778 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 16 Oct 2026 01:36:19 +0800
Message-ID: <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>
Date: Fri, 16 Oct 2026 01:36:17 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 2/2] blk-crypto: fix missing smp_load_acquire() for
 tfms_inited[]
To: Eric Biggers <ebiggers@kernel.org>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
 mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
 stable@vger.kernel.org
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014071846.3666398-2-libaokun@linux.alibaba.com>
 <20261014161153.GC322435@quark>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261014161153.GC322435@quark>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi Eric,

Thank you for your feedback!

On 2026/10/15 00:11, Eric Biggers wrote:
> On Wed, Oct 14, 2026 at 03:18:46PM +0800, Baokun Li wrote:
> [trim LLM-generated text]
>
>> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
>> index b5dbb092caea..31f76d117593 100644
>> --- a/block/blk-crypto-fallback.c
>> +++ b/block/blk-crypto-fallback.c
>> @@ -488,15 +488,17 @@ static void blk_crypto_fallback_decrypt_endio(struct bio *bio)
>>  bool blk_crypto_fallback_bio_prep(struct bio *bio)
>>  {
>>  	struct bio_crypt_ctx *bc = bio->bi_crypt_context;
>> +	const struct blk_crypto_config *cfg = &bc->bc_key->crypto_cfg;
>>  	struct bio_fallback_crypt_ctx *f_ctx;
>>  
>> -	if (WARN_ON_ONCE(!tfms_inited[bc->bc_key->crypto_cfg.crypto_mode])) {
>> +	/* Pairs with the release in blk_crypto_fallback_start_using_mode(). */
>> +	if (WARN_ON_ONCE(!smp_load_acquire(&tfms_inited[cfg->crypto_mode]))) {
>>  		/* User didn't call blk_crypto_start_using_key() first */
>>  		bio_io_error(bio);
>>  		return false;
>>  	}
> No, anyone submitting encrypted I/O is required to ensure that
> blk_crypto_start_using_key() was called first, in which case the
> additional barrier here during I/O submission isn't needed.  If the
> caller didn't ensure that, then it's a bug, and we WARN.  This patch is
> inconsistent with that.

You're right that the flag can't be observed as false here: the index
comes from bc->bc_key, so that load is address-dependent on the key
pointer, and a submitter that reached the key through a published
structure will in practice only ever see 'true'.  The WARN is fine.

The barrier wasn't meant to make the flag read reliable, though -- it
was for the loads *after* the if:

  if (!tfms_inited[mode])          <- addr-dep on bc->bc_key, ordered
          ...
  blk_crypto_fallback_profile      <- no dependency on anything
  blk_crypto_keyslots              <- no dependency on anything
  slotp->tfms[mode]                <- no dependency on anything

i.e. to make observing 'true' imply that those are initialized.  My
subject and commit message claimed the opposite, which is what made the
patch look inconsistent with the WARN next to it.  Sorry about that.

> I think this can be considered a bug report that the ordering of
> fscrypt_find_mode_key() is too weak now, as it just uses
> list_for_each_entry_rcu().  It looks like it should do
> smp_acquire__after_ctrl_dep() after it finds the right entry in the
> list.

That's what I was about to do for v3, but while looking for other
callers that inherit a key without calling start_using_key()
themselves, I found that dm-inlinecrypt has the same shape, so fixing
fscrypt alone wouldn't cover it -- only the constructor calls
start_using_key(), and the task submitting I/O reaches the key through
md->map:

  dmsetup (ctr)                      I/O task
  ---------------------------------- -------------------------------
  blk_crypto_start_using_key()
   fallback_start_using_mode()
    init profile, keyslots, tfms[]
    smp_store_release(tfms_inited[m])
  rcu_assign_pointer(md->map, t)
                                     srcu_dereference(md->map)
                                      -> ti->private -> &ctx->key
                                     inlinecrypt_map() -> bio_prep()
                                       tfms_inited[m]  addr-dep, ok
                                       profile/keyslots/tfms[]  not

dm's own grace periods would cover this, but all three are conditional:

  drivers/md/dm.c:2533       if (old_map) dm_sync_table(md);
  drivers/md/dm.c:3015,3039  if (map) synchronize_srcu(&md->io_barrier);
  drivers/md/dm-ioctl.c:1651 add_disk() only when type == DM_TYPE_NONE

so e.g. this sequence has no happens-before:

  DM_DEV_CREATE
  DM_TABLE_LOAD (linear)       add_disk(), md->type set, not resumed
                                 -> a task opens the device here
  DM_TABLE_CLEAR
  DM_TABLE_LOAD (inlinecrypt)  ctr sets tfms_inited[]; no add_disk()
  DM_DEV_SUSPEND (resume)      old_map == NULL, all three skipped
                                 -> the already-open task does I/O

This needs a weakly ordered machine and a deliberate ioctl order, so
it's not urgent.  Which would you prefer?

  1. Leave it for now and fix only fscrypt_find_mode_key().

  2. A separate smp_rmb() in inlinecrypt_map(), paired with the
     rcu_assign_pointer(md->map) in __bind().  Keeps the cost on
     dm-inlinecrypt only, but means a second site to get right.

  3. Keep the barrier in blk_crypto_fallback_bio_prep() after all,
     documented as ordering the loads after the check rather than the
     flag itself.  One site covers both callers and any future one,
     at the cost of blk-crypto no longer relying on the caller for
     this part.


Thanks,
Baokun

