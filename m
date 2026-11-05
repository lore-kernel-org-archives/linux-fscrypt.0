Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.112
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793896658;
	b=FamRppQ/3qlT+FWyP61mFTzXrMnudfF3Ox2GkE4ORFtsFqL/vSqm6dqCvsMu4VPMEROy
	 kuJdHAkixHInKEPYQmvcp1bim0METkHwlyg9a4w5VkWp0vIv0SaLfh9qUgQsrUXvfot+P
	 /MWumTlAA4SPPOIysaTomarOS1eBi57XlK03Eamq9t70ZIyNLFzRelVvoNRQ0KD+n6Vkj
	 YT0GpRuqqaid9Y0oankaDVJmn8e44ZuEGRZE6vV0d1mFzqjdkGRbejISC9qF1SCyzJ6MA
	 B3g1L9hXKaf8vYMGHpPyE7bXHngRHZNZEg0l7k25fuNuOJ/6y4OEyNBNxPXXHPfoLOg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793896658;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=csElEp+VhdZG2jnq1WLbmjmoJ99uEQ9BCkuzOTjKEJ4=;
	b=ozXfonuAKUbDZJIijbQYUsuRwiIdsFa9vZeYpHOyqUAx2c/EPZh3dD12aCj4vFbnkSs5
	 tspuEBKcsL1EzSbo26eSlwiaZgrsZ8QQoDBjkPYS29+cVvGtTfjJR3y7J+Hf7lX7MLGmH
	 V8sjN5ULkUR+/HLSU+yBkx04fNkOSGKEJ83M1FEMZ8Bn1MO8WXM9tO9qwY2fMFWbXNld8
	 aZTCm130IWH3Ftc2v0+4qHUPzQ1JkEF26xE57kHSg7o6NFLRGBe8BG52KUIjkBa8p2fSp
	 DttpxO1OsH2WPO2oCxWPb4brckrffnUNxaQ7ecBhZIptchnqo6tHeTZlWFrBcW4iT2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=OADZb1yX;
	arc=none smtp.remote-ip=115.124.30.112
Received: from out30-112.freemail.mail.aliyun.com (out30-112.freemail.mail.aliyun.com [115.124.30.112])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91D5D606CBCD;
	Thu,  5 Nov 2026 16:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 91D5D606CBCD
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=OADZb1yX
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793896652; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=csElEp+VhdZG2jnq1WLbmjmoJ99uEQ9BCkuzOTjKEJ4=;
	b=OADZb1yX25qqRO0W23iOHaPjIk7pHhc5AzDX9N/3sKfGr8PQBpcQ+cZUewCLD55eGxTxHsVf6mVeLGBTW43a7Fg1kr2jh1ZVqqXwEMkNw6ZoZi1ohqUYQEKDwxDMkBXOUHqqNCvuqtdJaodJNzL6jQM4keQ0bVas/8oAYhel0rs=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R811e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XE98I-._1793896650;
Received: from 30.42.176.22(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE98I-._1793896650 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 06 Nov 2026 00:37:31 +0800
Message-ID: <ae6f5ba2-8afc-43db-8d0a-f82d0163702d@linux.alibaba.com>
Date: Fri, 6 Nov 2026 00:37:30 +0800
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
 <922240f9-8233-4466-a787-2f7ddba7c490@linux.alibaba.com>
 <20261104195127.GA1971@quark>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261104195127.GA1971@quark>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2026/11/5 03:51, Eric Biggers wrote:
> On Wed, Nov 04, 2026 at 10:31:46AM +0800, Baokun Li wrote:
>> What I had in mind before was to keep the default as min(bs, PS) and
>> allow DU > PS only when explicitly specified, which seemed to give
>> better compatibility.  Cross-machine or cross-page-size cases seem
>> uncommon, and existing machines have probably already avoided them by
>> specifying a 4K or smaller DU.
>>
>> Keeping the existing default semantics and returning an error in the
>> LBS case for the user to specify seems feasible.  But then
>> test_dummy_encryption and the xfstests cases that use the default would
>> need to specify the DU explicitly, otherwise the LBS + encrypt test
>> coverage would drop a lot.  That is, in the kernel or the tests we
>> always have to set a default DU size.
>>
>> If you confirm that we should take the route where LBS requires an
>> explicit data unit size and the default is rejected, I can adapt the
>> kernel and xfstests in v2.  Or should we go back to the more compatible
>> DU > page size approach?
> 
> It will indeed be annoying to have to explicitly specify the data unit
> size, but I don't see a better solution for now, given the complexity of
> supporting data unit sizes larger than the page size.  I think making
> the on-disk format needing PAGE_SIZE to interpret is a no-go.
> 

Agreed.

> I suppose that in theory, how FS_IOC_SET_ENCRYPTION_POLICY handles
> log2_data_unit_size=0 could be changed: it could start actually writing
> log2_data_unit_size=12 to disk (rather than writing 0 which means the
> filesystem block size).  I think that can still lead to problems,
> though.  For one FS_IOC_GET_ENCRYPTION_POLICY would return something
> different from what was set.

I also considered making the default explicit, e.g. 4096, when the
bs > PS.  GET_ENCRYPTION_POLICY would then report 4096 instead of
the 0 that was set, which I think is fine provided we log it:
an unset field means "use the kernel default", and this just pins
down what that default is.  This works for v2.

I dropped it over test_dummy_encryption: mount options are parsed
before the block size is known, and the policy is const once it is,
so only invasive changes would work.

But the dummy policy is recreated on every mount and never persisted,
so there is no on-disk policy to stay compatible with.  The template
can just use SECTOR_SHIFT (simplest); alternatively, refuse it on such
a fs, or support an explicit du_size through a helper shared by the fs
(most complex).

> 
> Regarding xfstests, take a look at how common/verity adds $FSV_BLOCKSIZE
> to all 'fsverity enable' commands by default, to select some Merkle tree
> block size that the filesystem supports.  Something similar could be
> done with fscrypt.  Yes, this won't work with v1 encryption policies,
> but v1 policies are obsolete.  Most of the xfstests that use v1 policies
> should just be updated to use v2 instead.  The btrfs folks were working
> on that earlier, since they're not planning to support v1 at all.
> 

Agreed on rejecting v1.  The xfstests cases that need it will have to
be skipped or converted to v2; I can do that if nobody else is on it.

So, to enable this by default when bs > PS:

  1. reject v1, and convert the xfstests cases;
  2. in fscrypt_ioctl_set_policy(), make the default 4096 explicit
     and log it;
  3. for dummy, either use SECTOR_SHIFT, refuse it on such a
     fs and skip the tests, or support an explicit du_size?

Looking forward to hearing your thoughts.


Cheers,
Baokun

