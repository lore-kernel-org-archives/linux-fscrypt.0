Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792835599;
	b=aRT6DfehCVUcOAL8lZ0ToKFxfsjvpHlcIeCP9nM+SAzpq6PM43+YXistGQ7J7tHt5lDE
	 ASiWV4Brurx+0ds4clYaP34dyc6bPJGjXGVXd8Y0fAMLLLd8HnpF4oWgM42dSe9kPWb5K
	 k/uaDmXmebhB2t9YAcbNX4N3hIIhzU/bfuGfNPPy1GA/iPRP7VmgCQws42rbQn8ypA+Nh
	 BJHgkn0nOWgq0Lz134vApjTCbt0B7lJFtyMz3nm6shUlF0q2zYV/2U9jJhOICwgPcqQIz
	 YPo2I9T6+I6nWXMepzzWISPOkrYhaIchrn5EDtWYVqexRPgiDJoYTr/hHAnpRz+Hefg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792835599;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=hvXZ9YrkHTgh+q22WBEXAJRkcKBNZDKyybIuDUgHaVQ=;
	b=JEt1D3U9m3/7x6xpSW1G6n0/88Mlgz5td1ghqXdQ1IDxjOrRaG75AUOm33xmLU8S/R5v
	 onoY5goiY9X5rjytWmxhLpUXb4DLkX6voKeJMGrmyPN/vlI/iDAFpcGwniFs9ggZUAXmN
	 jfq+g6SCI4il0ZBjThIwNvoUSkNJKNAYBUT/lejl5Un2XoLYH8MD3LW+ugwPFSo3oAyKs
	 AO/P7cxuAEbKqay9bHs0uhV+/LJiWop27OGVZvEDBkOiKvdRpj7j7DeiEslXCWQLcbLDS
	 QPC2QKqd61+lbtnRfAEJjso/5OXruzBxqzSnmuEbgX5jAYQaPHa0Ac+IW+DS6PyLdFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=r+Mgk8n3;
	arc=none smtp.remote-ip=115.124.30.130
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com [115.124.30.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D007606A31A;
	Sat, 24 Oct 2026 09:53:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5D007606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=r+Mgk8n3
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792835588; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=hvXZ9YrkHTgh+q22WBEXAJRkcKBNZDKyybIuDUgHaVQ=;
	b=r+Mgk8n3KCVi0zIXOhkP1n4CkPfVlZKSFpWGN0uokMZ9tmw9fkRp/KP4yj7ZZlTtIeb1C4ZKToEpcSJWok3JOsGx3mUvBqCbMOYiiF8nGsK6MopAEpuNGHqVely/lMm6bwBTYvxaii1Pz8WRtlP8+qg9UULOaes4j40o/eLNt0A=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R201e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0XDNzCOu_1792835587;
Received: from 30.134.34.157(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDNzCOu_1792835587 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 24 Oct 2026 17:53:08 +0800
Message-ID: <d9bca9b2-e051-4c06-93eb-255d5e33844d@linux.alibaba.com>
Date: Sat, 24 Oct 2026 17:53:07 +0800
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3] fscrypt: Fix missing barrier in
 fscrypt_find_mode_key()
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
 stable@vger.kernel.org
References: <20261023160747.1382973-1-libaokun@linux.alibaba.com>
 <20261023193821.GA3091192@google.com>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261023193821.GA3091192@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/10/24 03:38, Eric Biggers wrote:
> On Sat, Oct 24, 2026 at 12:07:47AM +0800, Baokun Li wrote:
>> dm-inlinecrypt reaches its key only through srcu_dereference(md->map),
>> with no acquire anywhere on the I/O path.
> 
> The above seems like a stray sentence that should be deleted.
> 

Okay.

>> Suggested-by: Eric Biggers <ebiggers@kernel.org>
>> Link: https://patch.msgid.link/20261014161153.GC322435@quark
> 
> Nit: lore.kernel.org instead of patch.msgid.link, since it links to a
> discussion (in response to a patch) rather than directly to a patch.
> 

That makes sense; I hadn't noticed that difference before.

>> diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
>> index 892044ebcaca..984ef43982a3 100644
>> --- a/fs/crypto/keysetup.c
>> +++ b/fs/crypto/keysetup.c
>> @@ -205,8 +205,14 @@ fscrypt_find_mode_key(struct fscrypt_master_key *mk, u8 hkdf_context,
>>  		if (node->hkdf_context == hkdf_context &&
>>  		    node->mode_num == mode_num &&
>>  		    node->data_unit_bits == ci->ci_data_unit_bits &&
>> -		    fscrypt_is_key_prepared(&node->key, ci))
>> +		    fscrypt_is_key_prepared(&node->key, ci)) {
>> +			/*
>> +			 * Pairs with list_add_tail_rcu() in
>> +			 * setup_per_mode_enc_key().
>> +			 */
>> +			smp_acquire__after_ctrl_dep();
>>  			return &node->key;
>> +		}
>>  	}
> 
> I think a better comment would be:
> 
> 			/*
> 			 * Upgrade the RCU dereference to a full ACQUIRE, so
> 			 * that blk-crypto global state is seen as initialized.
> 			 */
> 
> That helps convey why the pre-existing RCU dereference isn't enough.
> 

Yeah, that looks much clearer.

> Other than that this patch looks good.  I can fix all the above when
> applying, if you agree, or you can just resend.  Thanks!
>

Thank you for your review!

I'll send v2 right away.


Cheers,
Baokun

