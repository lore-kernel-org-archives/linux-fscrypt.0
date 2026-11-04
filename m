Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793759512;
	b=eSU9yNfQqx/EsLqLwa2KXYk3b+4tExOEQ+uvRVQtc/ZAFS0nNaAPybFE7CUKB7Tdv/33
	 rKv4p2qTiCtcYuYBsjCGWiBPTFZhyUUYVHIewHXY+rtT6Dvh5Sa4Kjq8Z/9oCr0qEEPBq
	 j1nntrXkckAG0+Lh6FrAV0QDzHmiPaFh9InMwkqCqvu2fdiWoucCDpCb2dbPljb/2qtdd
	 L95lVWg1WV/vOwViiVrO0Rox2Ed+SlMgypdTK4uwkTuWWyat3iuycp2L1q9tVlG0UiM6I
	 3I6+eegRFd4eniTTDfbHwA3PnkGVDkbV/QQnQZaIk61RdCWpuosPWt5q9AnXEOsoF0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793759512;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=CLjlAhK88hPBCjk1t6tnIG3Isu3g2YYgjIIVTxIgq2I=;
	b=B9w8PH1ERc9DTu0ANFspInb+kd0HdhcrCWvHU/yVaUsdWw3xGj8BrH7j3dh4fYJbjaTU
	 K6dkBQa5NFPUCZDvDkOb8KRhpp7cUYfU7HcWtxCZAChTtN//4JygKom/eeS3tNyf9d9tg
	 JySnpcUgYwEIaVryUmUA/Bddvl/ZPjEWj/8Z+6jDLAa1A905JcUlzcuM4u6tGxARQTX0n
	 dgSgqIiNQn/GYLagIVy6rbmw1/859RUfpmKV9SsyCAe3WDq2SVoTlHLtK4RRHw80MwAg6
	 VZ0m1FYD8b4uRHn6HM2S0oyi1X0j1l+mIFNLUZ8PC35F4FclSJBNoQJY4grT7gUGDJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=KXX9sqou;
	arc=none smtp.remote-ip=115.124.30.98
Received: from out30-98.freemail.mail.aliyun.com (out30-98.freemail.mail.aliyun.com [115.124.30.98])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7248D606A32D;
	Wed,  4 Nov 2026 02:31:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7248D606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=KXX9sqou
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793759508; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=CLjlAhK88hPBCjk1t6tnIG3Isu3g2YYgjIIVTxIgq2I=;
	b=KXX9sqouKslSC5rwUSgsFfkCfpKZi855/Y5CmR1WrJv7M0ZXwvC7HL9DYtMenu7bIQdQgkDckGM9UPmdDIkdRRGWfR+ZUniTC80hZacof7EHUtUEVw4ZejW08RLz6s/OFqQDiqxGU1zDOGGFvOMJvu/MqmYypbRoOIdm2AGeQ6g=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R721e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045133197;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XE4LGOC_1793759506;
Received: from 30.221.132.49(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE4LGOC_1793759506 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 04 Nov 2026 10:31:47 +0800
Message-ID: <922240f9-8233-4466-a787-2f7ddba7c490@linux.alibaba.com>
Date: Wed, 4 Nov 2026 10:31:46 +0800
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
Subject: Re: [PATCH 1/4] fscrypt: Cap data units at the page size
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu,
 linux-ext4@vger.kernel.org, adilger.kernel@dilger.ca, jack@suse.cz,
 yi.zhang@huawei.com, ojaswin@linux.ibm.com, ritesh.list@gmail.com,
 linux-kernel@vger.kernel.org
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
 <20261103153132.4154855-2-libaokun@linux.alibaba.com>
 <20261103224006.GC2281@quark>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261103224006.GC2281@quark>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Eric,

Thank you for your feedback.

On 2026/11/4 06:40, Eric Biggers wrote:
> On Tue, Nov 03, 2026 at 11:31:29PM +0800, Baokun Li wrote:
>> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
>> index e602c31b3844..0dc158563e71 100644
>> --- a/fs/crypto/fscrypt_private.h
>> +++ b/fs/crypto/fscrypt_private.h
>> @@ -203,7 +203,9 @@ static inline int
>>  fscrypt_policy_v2_du_bits(const struct fscrypt_policy_v2 *policy,
>>  			  const struct inode *inode)
>>  {
>> -	return policy->log2_data_unit_size ?: inode->i_blkbits;
>> +	if (policy->log2_data_unit_size)
>> +		return policy->log2_data_unit_size;
>> +	return min_t(unsigned int, inode->i_blkbits, PAGE_SHIFT);
>>  }
> 
> This would make the interpretation of the default value
> log2_data_unit_size=0 depend on the page size, which (unlike i_blkbits)
> is not part of the filesystem's on-disk format.


This is indeed a point we struggled with before.

The problem is that on a filesystem with LBS enabled, once fscrypt is
enabled, log2_data_unit_size=0 causes data corruption.  So we default
to a sub-block data unit size to avoid it.

In the previous discussion it was said that for cross-machine
compatibility, users would explicitly set a data unit size of 4K or
smaller.  So this change did not consider cross-machine or cross-page-
size compatibility.

> 
> I think that for a sub-block data unit size to be used, it should need
> to continue to be explicitly specified.  Otherwise the default would
> become ambiguous.

This does change the semantics of the default value, and supporting a
data unit size larger than the page size later would be even worse.

What I had in mind before was to keep the default as min(bs, PS) and
allow DU > PS only when explicitly specified, which seemed to give
better compatibility.  Cross-machine or cross-page-size cases seem
uncommon, and existing machines have probably already avoided them by
specifying a 4K or smaller DU.

Keeping the existing default semantics and returning an error in the
LBS case for the user to specify seems feasible.  But then
test_dummy_encryption and the xfstests cases that use the default would
need to specify the DU explicitly, otherwise the LBS + encrypt test
coverage would drop a lot.  That is, in the kernel or the tests we
always have to set a default DU size.

If you confirm that we should take the route where LBS requires an
explicit data unit size and the default is rejected, I can adapt the
kernel and xfstests in v2.  Or should we go back to the more compatible
DU > page size approach?

Looking forward to hearing your thoughts.


Cheers,
Baokun

