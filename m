Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.133
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792662793;
	b=HCTfvrbghTGIC4kSINhs/8QIieYLr596YcwDTE5isdTEj03+eXIstptUVOMp9KZROGDq
	 vDOtkFzwMDWIaW5FeIz5WMVBsDSbioqTsnxsVR7uJBTtF1EIKTelh3nwuopeajHLlklnC
	 dHr1fu1SjGLf1wdXROKTwuj14HumRpWGuyYfenIcv5sBF3hVBIHFhpEJG7z7RjD33uyP7
	 6EUCPi0P8EjjJAblgFus8+juL9UKaDqrhhqIfkvBHy266cRbti5CiPi8HVXazFPEM81Gm
	 izmn8IyyVpurvO6N+u2IZps0ilxGNhAIyOh5xObmeMBwKbNu3sKtP+/ONprFcQgZ5rA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792662793;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:Cc:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=3hFAvKk9tBYmSX3HTuZG8avtf81VKRoZtIyjamHt2Ns=;
	b=SR85kHdezHTq5EElRSa3FvCSI+ybjINQcqysMyyjJ7lPiKE3h/EGDsYvEltZYU9Dvvg3
	 zkXe5jwXJ4OgaIwG96aRZ3ZJfASzmq4eZpwFzEk+ETiMssxvbxRDEanzob+Z3XiK6Hsvs
	 IBLOv+REWweqKAnS+PoFiJuXMRDOSrPiiFyAwukAfgh3XP/iT1qngzIBJdifvAB5sOBSo
	 6iR1r0GEMgujXp6vEW6BdfuNFaK1KUW/HyDh5Zkk7o4oROMuUkVAoIR4y2K55YwClwg3W
	 GspbraY8dpgYYBLx9GhG4v6yEBK89YgDn9AsupNmB/kBOC4x91OgefcJqlsF7PF8aNw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=YubF1mf5;
	arc=none smtp.remote-ip=115.124.30.133
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com [115.124.30.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF1E5606A31A;
	Thu, 22 Oct 2026 09:53:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AF1E5606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=YubF1mf5
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792662787; h=Message-ID:Date:MIME-Version:Subject:To:From:Content-Type;
	bh=3hFAvKk9tBYmSX3HTuZG8avtf81VKRoZtIyjamHt2Ns=;
	b=YubF1mf5Lp2GjZ4jFEFpyL+gPMHQ6ez6kgRijKFWzE8npNmfUvAj6SSMMqm+BPfDAnZnD4mmOE9ITnuzT61442osYJ8+s09K/E/nwl/LhwZDp58afXkiliSZ5fXFqJr9xJudhkk9T9ObAxvPnIBGRBSn8IE2tx3Kh2FKuTuQatw=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037009110;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0XDIreVh_1792662786;
Received: from 30.221.132.50(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDIreVh_1792662786 cluster:ay36)
          by smtp.aliyun-inc.com;
          Thu, 22 Oct 2026 17:53:06 +0800
Message-ID: <2810a9f7-4988-4e10-bac4-efa35458dfcd@linux.alibaba.com>
Date: Thu, 22 Oct 2026 17:53:05 +0800
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
 mpatocka@redhat.com, sweettea-kernel@dorminy.me, stable@vger.kernel.org
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014071846.3666398-2-libaokun@linux.alibaba.com>
 <20261014161153.GC322435@quark>
 <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>
 <20261015183200.GC2170687@google.com>
 <f113d4bc-2db5-4ed4-b34f-fe972099ad12@linux.alibaba.com>
 <20261022071101.GA1857@sol>
Content-Language: en-US
From: Baokun Li <libaokun@linux.alibaba.com>
In-Reply-To: <20261022071101.GA1857@sol>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On 2026/10/22 15:11, Eric Biggers wrote:
> On Thu, Oct 22, 2026 at 11:50:59AM +0800, Baokun Li wrote:
>> Hi Eric,
>>
>> Sorry for the late reply.
>>
>> On 2026/10/16 02:32, Eric Biggers wrote:
>>> On Fri, Oct 16, 2026 at 01:36:17AM +0800, Baokun Li wrote:
>>>> That's what I was about to do for v3, but while looking for other
>>>> callers that inherit a key without calling start_using_key()
>>>> themselves, I found that dm-inlinecrypt has the same shape, so fixing
>>>> fscrypt alone wouldn't cover it -- only the constructor calls
>>>> start_using_key(), and the task submitting I/O reaches the key through
>>>> md->map:
>>>>
>>>>   dmsetup (ctr)                      I/O task
>>>>   ---------------------------------- -------------------------------
>>>>   blk_crypto_start_using_key()
>>>>    fallback_start_using_mode()
>>>>     init profile, keyslots, tfms[]
>>>>     smp_store_release(tfms_inited[m])
>>>>   rcu_assign_pointer(md->map, t)
>>>>                                      srcu_dereference(md->map)
>>>>                                       -> ti->private -> &ctx->key
>>>>                                      inlinecrypt_map() -> bio_prep()
>>>>                                        tfms_inited[m]  addr-dep, ok
>>>>                                        profile/keyslots/tfms[]  not
>>>>
>>>> dm's own grace periods would cover this, but all three are conditional:
>>>>
>>>>   drivers/md/dm.c:2533       if (old_map) dm_sync_table(md);
>>>>   drivers/md/dm.c:3015,3039  if (map) synchronize_srcu(&md->io_barrier);
>>>>   drivers/md/dm-ioctl.c:1651 add_disk() only when type == DM_TYPE_NONE
>>>>
>>>> so e.g. this sequence has no happens-before:
>>>>
>>>>   DM_DEV_CREATE
>>>>   DM_TABLE_LOAD (linear)       add_disk(), md->type set, not resumed
>>>>                                  -> a task opens the device here
>>>>   DM_TABLE_CLEAR
>>>>   DM_TABLE_LOAD (inlinecrypt)  ctr sets tfms_inited[]; no add_disk()
>>>>   DM_DEV_SUSPEND (resume)      old_map == NULL, all three skipped
>>>>                                  -> the already-open task does I/O
>>>>
>>>> This needs a weakly ordered machine and a deliberate ioctl order, so
>>>> it's not urgent.  Which would you prefer?
>>>>
>>>>   1. Leave it for now and fix only fscrypt_find_mode_key().
>>>>
>>>>   2. A separate smp_rmb() in inlinecrypt_map(), paired with the
>>>>      rcu_assign_pointer(md->map) in __bind().  Keeps the cost on
>>>>      dm-inlinecrypt only, but means a second site to get right.
>>>>
>>>>   3. Keep the barrier in blk_crypto_fallback_bio_prep() after all,
>>>>      documented as ordering the loads after the check rather than the
>>>>      flag itself.  One site covers both callers and any future one,
>>>>      at the cost of blk-crypto no longer relying on the caller for
>>>>      this part.
>>> So the device-mapper core doesn't order target_type::ctr before
>>> target_type::map?  Nearly every dm target's map function relies on the
>>> constructor having run first.  If this is an issue, it isn't specific to
>>> dm-inlinecrypt and it will need to be fixed in the device-mapper core.
>> It does, for everything map() reaches through the table:
>>
>>   ctr                               map
>>   ------------------------------    -------------------------------
>>   ctx->foo = ...                    map = srcu_dereference(md->map)
>>   ti->private = ctx                 ti  = map->targets[i]
>>   rcu_assign_pointer(md->map, t)    ctx = ti->private
>>           ^ release                   ctx->foo     ordered (addr-dep)
>>                                       some_global  not ordered
>>
>> The address dependency covers the whole object graph hanging off
>> ti->private, so no barrier needed there.
>>
>> But dm-inlinecrypt initializes globals from the ctr:
>>
>>   inlinecrypt_ctr()
>>     blk_crypto_start_using_key()
>>       blk_crypto_fallback_start_using_mode()
>>         blk_crypto_fallback_init()
>>           blk_crypto_fallback_profile = ...      global
>>           blk_crypto_keyslots = ...              global
>>         slotp->tfms[mode] = ...                  global
>>         smp_store_release(tfms_inited[mode])
>>
>>   inlinecrypt_map()
>>     __blk_crypto_submit_bio()
>>       blk_crypto_fallback_bio_prep()
>>         tfms_inited[bc->bc_key->...]   addr-dep on the key, ordered
>>         blk_crypto_fallback_profile    no dependency
>>         blk_crypto_keyslots            no dependency
>>         slotp->tfms[mode]              no dependency
>>
>> Those three don't depend on md->map, so nothing stops the CPU from
>> reading them before it.
>>
>> No other target does this, and neither of the usual patterns helps
>> here.
>>
>> Some targets create their globals at module_init (journal_io_cache,
>> dm_bufio_wq).  That isn't available to us:
>>
>>   * the state belongs to blk-crypto, not to dm;
>>   * nothing in blk-crypto-fallback.c is exported;
>>   * blk_crypto_start_using_key() needs the bdev and the key from the
>>     table line, neither of which exists at module_init.
>>
>> The others keep state per-target under ti->private (dm-crypt's cc->bs,
>> dm-verity's v->verify_wq, dm-integrity's ic->*).  The equivalent here
>> would be hanging the fallback state off struct blk_crypto_key, which
>> already lives in ti->private -- then the whole chain is
>> address-dependent and needs no barrier at all.  But that means:
>>
>>   * a profile pointer in an exported struct;
>>   * moving blk_crypto_keyslots into the profile as well, since
>>     blk_crypto_fallback_tfm() reads it as a bare global.
>>
>> That is far more than this bug is worth.
>>
>> A core fix can't go on the publish side either.  An unconditional
>> dm_sync_table() in __bind() still lets a reader that overlaps the grace
>> period see the new md->map with the stale globals.  That leaves an
>> acquire in dm_get_live_table(), i.e. a barrier per bio on every dm
>> device, for one target.
>>
>> So I still think the smallest fix is the single barrier from the
>> original patch.  That line carries two meanings:
>>
>>   if (WARN_ON_ONCE(!smp_load_acquire(&tfms_inited[cfg->crypto_mode])))
>>
>>   * False means start_using_key() was never called and we bail out.
>>     You're right that this half needs no barrier: the index is
>>     address-dependent on bc->bc_key, so the flag is read accurately
>>     either way.
>>
>>   * True means the mode was initialized and the globals behind the
>>     flag are safe to use.  That is the half that needs it -- without
>>     the barrier, nothing orders blk_crypto_fallback_profile,
>>     blk_crypto_keyslots and slotp->tfms[] against the initialization
>>     that smp_store_release() published.
>>
>> Any thoughts?
> Well, it isn't great to be adding another barrier to every bio submitted
> to work around insufficient ordering during one-time setup. 

Agree. But in fact, the overhead of smp_load_acquire() is very small,
and it is almost imperceptible even for hot paths.

>  The fscrypt case is easily fixable by the change I mentioned.  
Yes.
> The dm case I'm not
> sure is a real problem.  For one, dm_get_live_table() actually already
> has an smp_mb() in it; it's inside srcu_read_lock().

It's there, but it lands before both loads rather than between them:

  dm_submit_bio()
    dm_get_live_table()
      srcu_read_lock()
        __srcu_read_lock()
          smp_mb()                      /* B */
      srcu_dereference(md->map)         <- load A
    inlinecrypt_map()
      __blk_crypto_submit_bio()
        blk_crypto_fallback_bio_prep()
          blk_crypto_fallback_profile   <- load B

I couldn't find a good way to fix it from the setup side. 

However, hitting this needs a weakly ordered machine and a deliberate
ioctl sequence, so I'm fine leaving it alone for now and revisiting
if someone actually runs into it -- by then there may be a better
answer than either of these.

Any better ideas?


Thanks,
Baokun


