Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.113
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795405167;
	b=j4b3m3GoNVJXfLs4IJa7d8bHMwc/rWkWl0TiK8AEdkFNEge3MNkyhPGlVOQRwG8e+BO2
	 eJTlhuIxscDpb5/7XBcLNktXZWgffu0JNU4107fGhXHFkEXa+xoy1sUCWxWa0krdmYCq2
	 FYdIKV9f3I8b93TYRtXCjUv5YwrtRSEeCY5o9DyyBTmLfX1Mr/4Gi47rdHAaNM6TVdEaT
	 Jt5/bKpGNkQkFU7odzj+13KowhIRqLsG6o6wW5hQEBNHhj6yLo7WooZZcQZVwAPAUV8Kj
	 wEIOCn+6W3xBe2d7AzmM0mudhd0X7LkeqZivIvug4zptikMXDHSpLOg/BWjPiIFD4qA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795405167;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:References:Content-Language:
	 Cc:From:In-Reply-To:Content-Type:Content-Transfer-Encoding;
	bh=T1PTWvwFn/wbYQN3ucBdR3DJrn6KnnE98b1wRi3pEIo=;
	b=SfaOwZa5EYae40YrqyxIXMhtWhVN37D/Jsl/IhriktdnptjK/yLUPy1C9i5Js7SOQh0o
	 YTWsj3OSGaj4BPXX0zvSWgMJ77UN4b0+QPLAFF4o9D72nqJOG2BHXe3YAZ5KdAY/5uiO3
	 1JRoOcPloYdRXxPTSoYrP6WsSmfU6ciXnnwdalwb+EgtED3kkMxKxlxhLH6BjPLPKX2zW
	 uTSBpESHj1bdKJ+JSYFeDwTqtF3/AWcuB5Kf+mNqUrDJOP94qMZfI7riNigbS08jPY11L
	 itykdh1JeZeb0XvgaZjKP75QTiyi5ekhBWrQZS6UJZvh3WSPJBKufNL+TnkcqIVjTWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=DsxXnwVg;
	arc=none smtp.remote-ip=115.124.30.113
Received: from out30-113.freemail.mail.aliyun.com (out30-113.freemail.mail.aliyun.com [115.124.30.113])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2B31606A31A;
	Mon, 23 Nov 2026 03:39:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E2B31606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=DsxXnwVg
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1795405162; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=T1PTWvwFn/wbYQN3ucBdR3DJrn6KnnE98b1wRi3pEIo=;
	b=DsxXnwVgEC0GBfv6rr/YMMo4mSeFgPLFoqFsKWiIJWsyGsANEctKP78v7KkVmAGObJIrHStUzmBkY0VbLPNk7szt2KXQXgl2G54tLjzHMCH5eQGCtXQbYPSW1sNjHlrDLJEu436OtYvLXxHY/e5XGHZTSrBjXst2qaQT91d6z5E=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037009110;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0XFCGc6V_1795405161;
Received: from 30.221.149.19(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XFCGc6V_1795405161 cluster:ay36)
          by smtp.aliyun-inc.com;
          Mon, 23 Nov 2026 11:39:21 +0800
Message-ID: <a5ad29d3-eb4d-479d-af48-b679fe8b5d23@linux.alibaba.com>
Date: Mon, 23 Nov 2026 11:39:19 +0800
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
Subject: Re: [PATCH] common/encrypt: support block sizes larger than the page
 size
To: Zorro Lang <zlang@kernel.org>
References: <20261103160906.188544-1-libaokun@linux.alibaba.com>
 <awHJso_ELIgRjbdg@zlang-mailbox>
Content-Language: en-US
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org,
 ebiggers@kernel.org, jaegeuk@kernel.org, tytso@mit.edu,
 linux-ext4@vger.kernel.org, adilger.kernel@dilger.ca, jack@suse.cz,
 yi.zhang@huawei.com, ojaswin@linux.ibm.com, ritesh.list@gmail.com,
 linux-kernel@vger.kernel.org
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <awHJso_ELIgRjbdg@zlang-mailbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Zorro,

Thank you for your review!

On 2026/11/22 01:04, Zorro Lang wrote:
> On Wed, Nov 04, 2026 at 12:09:06AM +0800, Baokun Li wrote:
>> +	#
>> +	# If the test requires a v2 policy, don't probe with a v1 policy:
>> +	# v1 policies are not supported when the block size exceeds the page
>> +	# size.  _require_encryption_policy_support() will check for the
>> +	# requested policy version below.
>> +	if [ "$policy_version" -le 1 ]; then
>> +		mkdir $SCRATCH_MNT/tmpdir
>> +		if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
>> +			grep -Eq 'Inappropriate ioctl for device|Operation not supported'
>> +		then
>> +			_notrun "kernel does not support $FSTYP encryption"
>> +		fi
>> +		rmdir $SCRATCH_MNT/tmpdir
>> +
>> +		# v1 policies use the block size as their data unit size,
>> +		# which doesn't work if the block size exceeds the page size.
>> +		_require_v1_encryption_support
> 
> How about do _require_v1_encryption_support at first:
> 
>   if [ "$policy_version" -le 1 ]; then
>       _require_v1_encryption_support
>       mkdir $SCRATCH_MNT/tmpdir
>       if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
> 
> In that case, if block_size > page_size, we can directly skip the test
> with an explicit reason, avoids a redundant mkdir/rmdir and ioctl call.
> 

Yes, this can avoid some unnecessary operations.


>>  # FS QA Test No. ext4/309
>>  #
>>  # Verify that file contents encryption works on a filesystem with a block size
>> -# larger than the page size.  fscrypt uses the block size as the data unit size
>> -# by default, so this tests data units that span multiple pages, both for the
>> -# writeback path and for the on-disk ciphertext.
>> +# larger than the page size.  fscrypt uses min(block size, page size) as the
>> +# default data unit size, so this tests 4K data units on a 32K-block
> 
> Does ext4/309 hardcode 32k ?
> 

No, that's actually just an example using a block size of 32k; I'll
rephrase that.

Additionally, the final plan has not been fully confirmed yet. I am
still working on the details with Eric. It is expected that all v1 use
cases will be converted to v2 later, and in the testing process, the
data unit size will be explicitly specified. Please refer to:

  https://lore.kernel.org/r/20261104195127.GA1971@quark


Cheers,
Baokun

