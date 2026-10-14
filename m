Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D00648F854
	for <linux-fscrypt@vger.kernel.org>; Wed, 14 Oct 2026 07:39:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791963563; cv=none; b=rMOuvC/uedNRaKVW7KOwb/UEpj1v8l6SOVi00mrfoVb08JcQkAEql8FGHa0V5KP9pKQF8pFarSwXpEcTFxRFto+o6tbvMV3RmA9gAAhg/cPO+9ROf/ipG/+089kt+ykXUpn5hL2jJdnH2NwJQ2+Q8w2nlEIwm1pBxRr4rMDDjiI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791963563; c=relaxed/simple;
	bh=R+33WnGsrxYrbnSXL1x/ElzSQMixySUf30iGM1FEX6k=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=FDlwXwIzkV/6ssXmyL5CFYWw0K1Whv4Y6voxwkBdDr4iGqdoP8oszFvtTbs8LWfQ/F1B01VAUr+ZYr8GmfIN2CH0ChMGo1Akam6OdfmOZYd4gZGQNNySJvjL2tx/hRJgON/F8HwKbnQVvST2ALa+lYdli+MyEhtxIw6qaVC6isE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=iZiP+SK4; arc=none smtp.client-ip=115.124.30.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="iZiP+SK4"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1791963552; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=a/tt/VmJVwYzXRdhHbwlO1136eoUFV4koQNXLp5Mt8M=;
	b=iZiP+SK4ZAGq2zPN14nmsjboCnOus+hfEoEsKsGfCr5hgc/McguaOMhVw20G9umCm1sjIa/7AyaoediyOfY1wyQjWRlyihVQlyaTqYncH/4MlEiQAmL/CIAnOp0xcUXPbYvi6nA7wdqsLKVSTyJfRWkiB6BkMkb+ScWqWFD/aqY=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033032089153;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0XCoKeQr_1791963550;
Received: from 30.221.131.75(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XCoKeQr_1791963550 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 14 Oct 2026 15:39:11 +0800
Message-ID: <b88049b6-ea4b-4411-8ea9-9f8d7c7fb681@linux.alibaba.com>
Date: Wed, 14 Oct 2026 15:39:10 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
To: sashiko-reviews@lists.linux.dev
Cc: axboe@kernel.dk, ebiggers@kernel.org, linux-fscrypt@vger.kernel.org,
 hch@lst.de, bvanassche@acm.org, mpatocka@redhat.com,
 linlin.zhang@oss.qualcomm.com
References: <20261013095106.881914-1-libaokun@linux.alibaba.com>
 <sashiko-outbox-169471@kernel.org>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <sashiko-outbox-169471@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/10/13 18:13, sashiko-bot@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential issue(s) to consider:
> - [High] block: concurrent UAF in __blk_crypto_evict_key() via lockless global read

Sorry for the noise. I posted v2 to fix this issue, see:

https://patch.msgid.link/20261014071846.3666398-1-libaokun@linux.alibaba.com


Thanks,
Baokun

> --
>
> commit e07e1c7433e60b079101f4843a8706bcb93632f8
> Author: Baokun Li <libaokun@linux.alibaba.com>
> blk-crypto: fix NULL deref and UAF in __blk_crypto_evict_key()
>
> This patch attempts to resolve a NULL pointer dereference and a
> use-after-free by checking for a NULL profile in __blk_crypto_evict_key()
> and clearing the fallback profile pointer after freeing it on the error
> path.
>
> Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
>
>> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
>> index 2a8f40a65158b..b7890ee1951c7 100644
>> --- a/block/blk-crypto-fallback.c
>> +++ b/block/blk-crypto-fallback.c
> [ ... ]
>> @@ -605,6 +605,7 @@ static int blk_crypto_fallback_init(void)
>>  	blk_crypto_profile_destroy(blk_crypto_fallback_profile);
>>  fail_free_profile:
>>  	kfree(blk_crypto_fallback_profile);
>> +	blk_crypto_fallback_profile = NULL;
> [Severity: High]
> Does this change leave a concurrent use-after-free window open?
>
> In blk_crypto_fallback_init(), the global pointer is published before
> initialization is complete:
>
>     blk_crypto_fallback_profile = kzalloc_obj(*blk_crypto_fallback_profile);
>
> If another thread concurrently executes blk_crypto_fallback_evict_key(),
> it can locklessly read the global blk_crypto_fallback_profile. If the
> initialization thread encounters an error and frees the profile:
>
>     kfree(blk_crypto_fallback_profile);
>
> Could the evicting thread end up reading the pointer before the kfree()
> occurs and subsequently dereferencing the freed memory? Setting the pointer
> to NULL after it is freed might not prevent a data race if the pointer was
> already copied by the evicting thread.
>
>>  fail_free_bioset:
>>  	bioset_exit(&enc_bio_set);
>>  out:
>> diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
>> index 53126c091b0be..1c5feca3b856a 100644
>> --- a/block/blk-crypto-profile.c
>> +++ b/block/blk-crypto-profile.c
>> @@ -346,6 +346,9 @@ int __blk_crypto_evict_key(struct blk_crypto_profile *profile,
>>  	struct blk_crypto_keyslot *slot;
>>  	int err;
>>  
>> +	if (!profile)
>> +		return 0;
>> +
>>  	if (profile->num_slots == 0) {
> [Severity: High]
> Because the profile pointer is passed in after being read locklessly by the
> caller, could this pointer still point to freed memory if the initialization
> thread freed it concurrently?
>
> If so, the new NULL check would be bypassed, and reading profile->num_slots
> would trigger a use-after-free.
>

