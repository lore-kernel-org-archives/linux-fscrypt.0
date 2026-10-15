Received: from out30-110.freemail.mail.aliyun.com (out30-110.freemail.mail.aliyun.com [115.124.30.110])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4D35463B62;
	Thu, 15 Oct 2026 13:44:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.110
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792071850; cv=none; b=PppR1bnXyKku1+JyUItcnmcdQL31efX7qvd7tS2ahsC1owQxDv+CyPxex1FxJgN7NNVO+11py963CYBAMKwq8WTJUBdtXpGeX7pVr6usXTDdNLDIri/VpsRv7jOUNOOo0tHyyq/9SOMXKgxdmT2BHNGKChIzKMDybw4MCKSen+4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792071850; c=relaxed/simple;
	bh=ETJGAvWnltGitm2lM5nL3RKAnFgrqvp8jhO3TAH+esQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=WakFSuzRD1APCH/FChNb9V7XbMbNokK8mcKWIwjp8rEb1kb6t7gl6tX4VwharYbeuPNo5D6uNECo941jId/RVhuWnqgN7NDkEveK3AR6n6N+8Sf7g9ki07YX/aKBXFoO0jOBP7ZMHlAvE2K/M+hJNoQkHItn84jh+EvBKufu0+s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=qHWsu5yC; arc=none smtp.client-ip=115.124.30.110
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="qHWsu5yC"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792071843; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=Pwn9AuCkqzzHOOqAR23rfLFfWN42vOaZNb6N6HOsOnA=;
	b=qHWsu5yCQldk5mCze/MA+ivpTk0YFiZLqAyeAZ4xeOr3mRoB9mLE063CfHJQIC/zyDQeix4mTN64vB8AE2JnhtNJoqHrcmWhZUqvxLxqY6EmHO/DaeDbKz3xBL4X4F4o1G/9XljjUdO0CunMV5spyfGxFgkdXSivzQjfhRV5auY=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XCrz3SJ_1792071841;
Received: from 30.170.203.187(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XCrz3SJ_1792071841 cluster:ay36)
          by smtp.aliyun-inc.com;
          Thu, 15 Oct 2026 21:44:02 +0800
Message-ID: <00486052-b981-4b7a-8e82-03a63fb03fc3@linux.alibaba.com>
Date: Thu, 15 Oct 2026 21:44:01 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 1/2] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
To: Eric Biggers <ebiggers@kernel.org>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
 mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
 stable@vger.kernel.org, Sashiko <sashiko-bot@kernel.org>
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014155131.GB322435@quark>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261014155131.GB322435@quark>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On 2026/10/14 23:51, Eric Biggers wrote:
> On Wed, Oct 14, 2026 at 03:18:45PM +0800, Baokun Li wrote:
>> Sashiko reported a possible NULL pointer dereference, triggered by the
>> following flow:
>>
>>   dm-inlinecrypt ctor            # first use of the fallback
>>    ├─ blk_crypto_init_key()      # succeeds, ctx->key.size != 0
>>    ├─ blk_crypto_start_using_key()
>>    │   ├─ hw-wrapped key: -EOPNOTSUPP
>>    │   │    # profile never allocated (NULL)
>>    │   └─ raw key: fallback_start_using_mode()
>>    │      └─ blk_crypto_fallback_init() fails
>>    │         └─ kfree(profile)   # not NULLed
>>    ├─ goto bad
>>    └─ inlinecrypt_dtr()          # evicts whenever key.size is set
>>       └─ blk_crypto_evict_key()
>>          └─ blk_crypto_config_supported_natively() = false
>>             └─ blk_crypto_fallback_evict_key()
>>                └─ __blk_crypto_evict_key(blk_crypto_fallback_profile)
>>                   └─ profile->num_slots # BOOM!!!
>>
>> This issue can be reproduced using the following commands:
>>
>>   dd if=/dev/zero of=/tmp/backing bs=1M count=64
>>   LOOP=$(losetup -f --show /tmp/backing)
>>   SZ=$(blockdev --getsz $LOOP)
>>   KEY=$(head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')
>>   dmsetup create ic --table "0 $SZ inlinecrypt aes-xts-plain64 \
>>     $KEY 0 $LOOP 0 1 keytype:hw-wrapped"
>>
>> And the following oops is triggered:
>>
>>   ==================================================================
>>   blk-crypto: loop0: no support for wrapped keys
>>   Oops: general protection fault, probably for non-canonical address
>>         0xdffffc000000000b: 0000 [#1] SMP KASAN PTI
>>   KASAN: null-ptr-deref in range [0x0000000000000058-0x000000000000005f]
>>   CPU: 5 UID: 0 PID: 901 Comm: dmsetup 7.3.0-rc3 #1 PREEMPT(lazy)
>>   RIP: 0010:__blk_crypto_evict_key+0x2e/0x3b0
>>   Call Trace:
>>    blk_crypto_evict_key+0x24c/0x320
>>    inlinecrypt_dtr+0xf6/0x160
>>    inlinecrypt_ctr+0x2d3/0xbd0
>>    dm_table_add_target+0x661/0xf40
>>    table_load+0x1c4/0x490
>>    ctl_ioctl+0x32f/0x5f0
>>    dm_ctl_ioctl+0xe/0x20
>>   ==================================================================
>>
>> dm-inlinecrypt is the only caller that can evict a key that was never
>> started, as fscrypt frees such a key without evicting it.
>>
>> Fix this by publishing blk_crypto_fallback_profile only after
>> blk_crypto_fallback_init() succeeds, and by returning early from
>> __blk_crypto_evict_key() when the profile is NULL.  The eviction path
>> can then only observe either a NULL profile or a fully initialized
>> profile that is never freed.  A key whose start failed cannot be in a
>> keyslot, so there is nothing to evict.
>>
>> The profile pointer is published and read locklessly, so use
>> smp_store_release()/smp_load_acquire() to guarantee that a reader in
>> the eviction path that observes the pointer also observes the
>> initialized profile.
>>
>> The bug has been latent since commit c984ff1423ae ("blk-crypto:
>> dynamically allocate fallback profile") was merged in v6.5, and only
>> became actually triggerable when commit e7f57d2c47e2 ("dm-inlinecrypt:
>> add target for inline block device encryption") was merged in v7.2.
>>
>> Fixes: c984ff1423ae ("blk-crypto: dynamically allocate fallback profile")
>> Cc: stable@vger.kernel.org
>> Reported-by: Sashiko <sashiko-bot@kernel.org>
>> Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
>> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
>> ---
>>  block/blk-crypto-fallback.c | 31 +++++++++++++++++++------------
>>  block/blk-crypto-profile.c  |  3 +++
>>  2 files changed, 22 insertions(+), 12 deletions(-)
> Wouldn't it be a lot simpler to just make
> blk_crypto_fallback_evict_key() check the existing tfms_inited flag?
>
> 	/*
> 	 * Pairs with smp_store_release() in
> 	 * blk_crypto_fallback_start_using_mode()
> 	 */
> 	if (!smp_load_acquire(&tfms_inited[key->crypto_cfg.crypto_mode]))
> 		return 0;

Indeed, this is a simpler and more straightforward approach.
I will use it in the next iteration.

Thank you for your suggestion!

Regards,
Baokun

