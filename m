Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792641072;
	b=MHuAh+k98G6NCzNlO40b6QY8oQVTOtDuG8oH+5vtJkGClz8vNTNb3tC4M1FmbEPsRI8f
	 aX2K6E/+cweSE4zIhOya+StWGuuvsN1DIhj4VcZRDUizHcClp4Ix8qrwy+C2xyvZEZz7t
	 knzA9couoqzLThvAKhoCAbhsJ+6CRQCmlp7ytNnpvkd76eAvTvlwxu1VAgH+9PclVRW4O
	 RQqXrkI8QKhdth0u61Zs4NMInZc+gcjemkA9let94UgzEMEEMLfdG90JnMCgTpMGkW5Vu
	 X9UfJ+hHlzm6fCk8i29bMX3RguXe8a5BrKaM53a7baGB+70tgDJwj9v4be1LsR5Z0pw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792641072;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=WLXKEcGY2+EVzk8m/YodrwKLI6aWEvkhGRBliNH9xCk=;
	b=v2xUvRBIiPfP5A3MKqcmvw8cp/NZyTe2HY8XnkqYj1MICiwoQCuYWM8qGNvupTMUWd05
	 6bslog+EOVl0ovfGwLD1k/9MPKWpw5uvn4hd2YMFqS9kxNRB+SlG+P6FAiYDp3skup1aZ
	 zYIYk2wvH5OXtdCm33vU7KjJ17tf1H3FqVF0HSNQsyKyvLr4WLbUEpFC35d3SGxDQYFh7
	 5laIFands6J2EcTGqyJbrxz75OLFsXf3FqZfij8hEOzzR4FEIcDqewoQvFzsaw7la5Rui
	 i8BTQ2lu2UlKwikliYA/3fHxTsbCZM/lRZEnRMvRjXSUp7u4PSyrUK5aORMtZAWkEHg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=PX0TYjgc;
	arc=none smtp.remote-ip=115.124.30.98
Received: from out30-98.freemail.mail.aliyun.com (out30-98.freemail.mail.aliyun.com [115.124.30.98])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 596FA606A319;
	Thu, 22 Oct 2026 03:51:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 596FA606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=PX0TYjgc
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792641061; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=WLXKEcGY2+EVzk8m/YodrwKLI6aWEvkhGRBliNH9xCk=;
	b=PX0TYjgcDep93uUemFCALrIqUKjisXkoYeo/kffcGsPZBsoJHzuSQwqtCYf1FhyXBUIFSsJx64z6EtSXwyagHxhRlHT/CDCxHN/dSc3HojTY8wGGyoirV2dbUNg4xDsPYYPEH8mnMnw2vdd1VaxkDh8o/qyMXlXN/di4KmtIyNE=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R761e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0XDI-bNt_1792641059;
Received: from 30.221.132.50(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDI-bNt_1792641059 cluster:ay36)
          by smtp.aliyun-inc.com;
          Thu, 22 Oct 2026 11:51:00 +0800
Message-ID: <f113d4bc-2db5-4ed4-b34f-fe972099ad12@linux.alibaba.com>
Date: Thu, 22 Oct 2026 11:50:59 +0800
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
 <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>
 <20261015183200.GC2170687@google.com>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261015183200.GC2170687@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi Eric,

Sorry for the late reply.

On 2026/10/16 02:32, Eric Biggers wrote:
> On Fri, Oct 16, 2026 at 01:36:17AM +0800, Baokun Li wrote:
>> That's what I was about to do for v3, but while looking for other
>> callers that inherit a key without calling start_using_key()
>> themselves, I found that dm-inlinecrypt has the same shape, so fixing
>> fscrypt alone wouldn't cover it -- only the constructor calls
>> start_using_key(), and the task submitting I/O reaches the key through
>> md->map:
>>
>>   dmsetup (ctr)                      I/O task
>>   ---------------------------------- -------------------------------
>>   blk_crypto_start_using_key()
>>    fallback_start_using_mode()
>>     init profile, keyslots, tfms[]
>>     smp_store_release(tfms_inited[m])
>>   rcu_assign_pointer(md->map, t)
>>                                      srcu_dereference(md->map)
>>                                       -> ti->private -> &ctx->key
>>                                      inlinecrypt_map() -> bio_prep()
>>                                        tfms_inited[m]  addr-dep, ok
>>                                        profile/keyslots/tfms[]  not
>>
>> dm's own grace periods would cover this, but all three are conditional:
>>
>>   drivers/md/dm.c:2533       if (old_map) dm_sync_table(md);
>>   drivers/md/dm.c:3015,3039  if (map) synchronize_srcu(&md->io_barrier);
>>   drivers/md/dm-ioctl.c:1651 add_disk() only when type == DM_TYPE_NONE
>>
>> so e.g. this sequence has no happens-before:
>>
>>   DM_DEV_CREATE
>>   DM_TABLE_LOAD (linear)       add_disk(), md->type set, not resumed
>>                                  -> a task opens the device here
>>   DM_TABLE_CLEAR
>>   DM_TABLE_LOAD (inlinecrypt)  ctr sets tfms_inited[]; no add_disk()
>>   DM_DEV_SUSPEND (resume)      old_map == NULL, all three skipped
>>                                  -> the already-open task does I/O
>>
>> This needs a weakly ordered machine and a deliberate ioctl order, so
>> it's not urgent.  Which would you prefer?
>>
>>   1. Leave it for now and fix only fscrypt_find_mode_key().
>>
>>   2. A separate smp_rmb() in inlinecrypt_map(), paired with the
>>      rcu_assign_pointer(md->map) in __bind().  Keeps the cost on
>>      dm-inlinecrypt only, but means a second site to get right.
>>
>>   3. Keep the barrier in blk_crypto_fallback_bio_prep() after all,
>>      documented as ordering the loads after the check rather than the
>>      flag itself.  One site covers both callers and any future one,
>>      at the cost of blk-crypto no longer relying on the caller for
>>      this part.
> So the device-mapper core doesn't order target_type::ctr before
> target_type::map?  Nearly every dm target's map function relies on the
> constructor having run first.  If this is an issue, it isn't specific to
> dm-inlinecrypt and it will need to be fixed in the device-mapper core.

It does, for everything map() reaches through the table:

  ctr                               map
  ------------------------------    -------------------------------
  ctx->foo = ...                    map = srcu_dereference(md->map)
  ti->private = ctx                 ti  = map->targets[i]
  rcu_assign_pointer(md->map, t)    ctx = ti->private
          ^ release                   ctx->foo     ordered (addr-dep)
                                      some_global  not ordered

The address dependency covers the whole object graph hanging off
ti->private, so no barrier needed there.

But dm-inlinecrypt initializes globals from the ctr:

  inlinecrypt_ctr()
    blk_crypto_start_using_key()
      blk_crypto_fallback_start_using_mode()
        blk_crypto_fallback_init()
          blk_crypto_fallback_profile = ...      global
          blk_crypto_keyslots = ...              global
        slotp->tfms[mode] = ...                  global
        smp_store_release(tfms_inited[mode])

  inlinecrypt_map()
    __blk_crypto_submit_bio()
      blk_crypto_fallback_bio_prep()
        tfms_inited[bc->bc_key->...]   addr-dep on the key, ordered
        blk_crypto_fallback_profile    no dependency
        blk_crypto_keyslots            no dependency
        slotp->tfms[mode]              no dependency

Those three don't depend on md->map, so nothing stops the CPU from
reading them before it.

No other target does this, and neither of the usual patterns helps
here.

Some targets create their globals at module_init (journal_io_cache,
dm_bufio_wq).  That isn't available to us:

  * the state belongs to blk-crypto, not to dm;
  * nothing in blk-crypto-fallback.c is exported;
  * blk_crypto_start_using_key() needs the bdev and the key from the
    table line, neither of which exists at module_init.

The others keep state per-target under ti->private (dm-crypt's cc->bs,
dm-verity's v->verify_wq, dm-integrity's ic->*).  The equivalent here
would be hanging the fallback state off struct blk_crypto_key, which
already lives in ti->private -- then the whole chain is
address-dependent and needs no barrier at all.  But that means:

  * a profile pointer in an exported struct;
  * moving blk_crypto_keyslots into the profile as well, since
    blk_crypto_fallback_tfm() reads it as a bare global.

That is far more than this bug is worth.

A core fix can't go on the publish side either.  An unconditional
dm_sync_table() in __bind() still lets a reader that overlaps the grace
period see the new md->map with the stale globals.  That leaves an
acquire in dm_get_live_table(), i.e. a barrier per bio on every dm
device, for one target.

So I still think the smallest fix is the single barrier from the
original patch.  That line carries two meanings:

  if (WARN_ON_ONCE(!smp_load_acquire(&tfms_inited[cfg->crypto_mode])))

  * False means start_using_key() was never called and we bail out.
    You're right that this half needs no barrier: the index is
    address-dependent on bc->bc_key, so the flag is read accurately
    either way.

  * True means the mode was initialized and the globals behind the
    flag are safe to use.  That is the half that needs it -- without
    the barrier, nothing orders blk_crypto_fallback_profile,
    blk_crypto_keyslots and slotp->tfms[] against the initialization
    that smp_store_release() published.

Any thoughts?


Regards,
Baokun

