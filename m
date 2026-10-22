Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792653064;
	b=ejRJqkJYoNoOnqOeUbj9EsIyRgmqskdaKj65tvCOysbbVjjg0oH513vcshgmMYLJHzBA
	 ULoOyChDZ+IJRCJ4t8LSJ0fLHmvn/PhVjsB8F3XWvQNZy0uXs7olGHckiEMooG6+nUc6m
	 vcVMZzw3xntXV2SQcGI/5Htm1tC4LyQOZhOHS6/nGYpAg/cxqSWKTUvZaMTOqQwAeinWT
	 M5ix6kJ4D69nAo5JxDkNzrWtDzCFSuv8uSFXahfvRAR21pSr3zdAy7LJXKN7pQIrjxZuc
	 ApQas1FVzkBjj5gz3k/TJicaj6hY5yXI45co39YOQC855W9qyPq3pJj7jWMSoC7kEMg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792653064;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=RO4O3xrSDxHNDaVbz+rNfXkoLE+vdkQ3B9aB8C7xQMI=;
	b=0ysj8KLv06122NPZbsllhbnR7MzJuupRTlrWuAGYNfUIqOd3tNd/seP9G8hPSfYyHB5d
	 1ZJCyJcEmfoSZXFKcDkhUNoeCYrQ4ML8dJfA2/AzY1jTXyoV304sUKtQDZbOHPPjEtG4K
	 ar8ZUMjetg6KHj9oSWBbgjNxan4YpVmdJ3cxWTfHZKkY0Mzw9b1PIT5o/72xKhvsiDJaa
	 yF69t5B8d/OOGIF7Dd6FwyguAtNFLAdJ7QXEH+KKs8FYYp0qfwtHn+hsGjtSDwxLyZPuF
	 xYjIA4AX1r4RQdHGDxbBTHilBbeMIFXmYbuHOIORkPa99Rrwf2jiCDqNF7Epkci4ZRg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WcYU7OXe;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB1C2606A319;
	Thu, 22 Oct 2026 07:11:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WcYU7OXe
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C97A1F000C1;
	Thu, 22 Oct 2026 07:11:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792653063;
	bh=RO4O3xrSDxHNDaVbz+rNfXkoLE+vdkQ3B9aB8C7xQMI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=WcYU7OXenb4CSmaPFPn9f7Mf9fn8IWaqKmYQve0aOXepRWHCMOfKzscUjVc9jDPFB
	 UXnJeVTByoHd1N32CLSLLtLsknHlEY3fqtEcwwGiE0jgfdBaZIvHqCglDQoNwSbch7
	 1R6YoXnsTR7eA275KlQ8h/IY5SRFlhk0qmhNUAzalEpu2scbCxVwSJf8J1MAf/nDB7
	 KqQl7dsaB38oj6Nz3ASmVU/oDuKdDk5FWszGTCOIjbUA6Ii6tDULTp/F9jhrULAqR4
	 8cZyjZqlThlgDIP2e+Ot/Jkwa5W/LWIg+lSTPJCI6qSdsKVrroLIwSpQY0eLVFdinu
	 zGoUxeXJ7kMHQ==
Date: Thu, 22 Oct 2026 00:11:01 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
	stable@vger.kernel.org
Subject: Re: [PATCH v2 2/2] blk-crypto: fix missing smp_load_acquire() for
 tfms_inited[]
Message-ID: <20261022071101.GA1857@sol>
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014071846.3666398-2-libaokun@linux.alibaba.com>
 <20261014161153.GC322435@quark>
 <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>
 <20261015183200.GC2170687@google.com>
 <f113d4bc-2db5-4ed4-b34f-fe972099ad12@linux.alibaba.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f113d4bc-2db5-4ed4-b34f-fe972099ad12@linux.alibaba.com>

On Thu, Oct 22, 2026 at 11:50:59AM +0800, Baokun Li wrote:
> Hi Eric,
> 
> Sorry for the late reply.
> 
> On 2026/10/16 02:32, Eric Biggers wrote:
> > On Fri, Oct 16, 2026 at 01:36:17AM +0800, Baokun Li wrote:
> >> That's what I was about to do for v3, but while looking for other
> >> callers that inherit a key without calling start_using_key()
> >> themselves, I found that dm-inlinecrypt has the same shape, so fixing
> >> fscrypt alone wouldn't cover it -- only the constructor calls
> >> start_using_key(), and the task submitting I/O reaches the key through
> >> md->map:
> >>
> >>   dmsetup (ctr)                      I/O task
> >>   ---------------------------------- -------------------------------
> >>   blk_crypto_start_using_key()
> >>    fallback_start_using_mode()
> >>     init profile, keyslots, tfms[]
> >>     smp_store_release(tfms_inited[m])
> >>   rcu_assign_pointer(md->map, t)
> >>                                      srcu_dereference(md->map)
> >>                                       -> ti->private -> &ctx->key
> >>                                      inlinecrypt_map() -> bio_prep()
> >>                                        tfms_inited[m]  addr-dep, ok
> >>                                        profile/keyslots/tfms[]  not
> >>
> >> dm's own grace periods would cover this, but all three are conditional:
> >>
> >>   drivers/md/dm.c:2533       if (old_map) dm_sync_table(md);
> >>   drivers/md/dm.c:3015,3039  if (map) synchronize_srcu(&md->io_barrier);
> >>   drivers/md/dm-ioctl.c:1651 add_disk() only when type == DM_TYPE_NONE
> >>
> >> so e.g. this sequence has no happens-before:
> >>
> >>   DM_DEV_CREATE
> >>   DM_TABLE_LOAD (linear)       add_disk(), md->type set, not resumed
> >>                                  -> a task opens the device here
> >>   DM_TABLE_CLEAR
> >>   DM_TABLE_LOAD (inlinecrypt)  ctr sets tfms_inited[]; no add_disk()
> >>   DM_DEV_SUSPEND (resume)      old_map == NULL, all three skipped
> >>                                  -> the already-open task does I/O
> >>
> >> This needs a weakly ordered machine and a deliberate ioctl order, so
> >> it's not urgent.  Which would you prefer?
> >>
> >>   1. Leave it for now and fix only fscrypt_find_mode_key().
> >>
> >>   2. A separate smp_rmb() in inlinecrypt_map(), paired with the
> >>      rcu_assign_pointer(md->map) in __bind().  Keeps the cost on
> >>      dm-inlinecrypt only, but means a second site to get right.
> >>
> >>   3. Keep the barrier in blk_crypto_fallback_bio_prep() after all,
> >>      documented as ordering the loads after the check rather than the
> >>      flag itself.  One site covers both callers and any future one,
> >>      at the cost of blk-crypto no longer relying on the caller for
> >>      this part.
> > So the device-mapper core doesn't order target_type::ctr before
> > target_type::map?  Nearly every dm target's map function relies on the
> > constructor having run first.  If this is an issue, it isn't specific to
> > dm-inlinecrypt and it will need to be fixed in the device-mapper core.
> 
> It does, for everything map() reaches through the table:
> 
>   ctr                               map
>   ------------------------------    -------------------------------
>   ctx->foo = ...                    map = srcu_dereference(md->map)
>   ti->private = ctx                 ti  = map->targets[i]
>   rcu_assign_pointer(md->map, t)    ctx = ti->private
>           ^ release                   ctx->foo     ordered (addr-dep)
>                                       some_global  not ordered
> 
> The address dependency covers the whole object graph hanging off
> ti->private, so no barrier needed there.
> 
> But dm-inlinecrypt initializes globals from the ctr:
> 
>   inlinecrypt_ctr()
>     blk_crypto_start_using_key()
>       blk_crypto_fallback_start_using_mode()
>         blk_crypto_fallback_init()
>           blk_crypto_fallback_profile = ...      global
>           blk_crypto_keyslots = ...              global
>         slotp->tfms[mode] = ...                  global
>         smp_store_release(tfms_inited[mode])
> 
>   inlinecrypt_map()
>     __blk_crypto_submit_bio()
>       blk_crypto_fallback_bio_prep()
>         tfms_inited[bc->bc_key->...]   addr-dep on the key, ordered
>         blk_crypto_fallback_profile    no dependency
>         blk_crypto_keyslots            no dependency
>         slotp->tfms[mode]              no dependency
> 
> Those three don't depend on md->map, so nothing stops the CPU from
> reading them before it.
> 
> No other target does this, and neither of the usual patterns helps
> here.
> 
> Some targets create their globals at module_init (journal_io_cache,
> dm_bufio_wq).  That isn't available to us:
> 
>   * the state belongs to blk-crypto, not to dm;
>   * nothing in blk-crypto-fallback.c is exported;
>   * blk_crypto_start_using_key() needs the bdev and the key from the
>     table line, neither of which exists at module_init.
> 
> The others keep state per-target under ti->private (dm-crypt's cc->bs,
> dm-verity's v->verify_wq, dm-integrity's ic->*).  The equivalent here
> would be hanging the fallback state off struct blk_crypto_key, which
> already lives in ti->private -- then the whole chain is
> address-dependent and needs no barrier at all.  But that means:
> 
>   * a profile pointer in an exported struct;
>   * moving blk_crypto_keyslots into the profile as well, since
>     blk_crypto_fallback_tfm() reads it as a bare global.
> 
> That is far more than this bug is worth.
> 
> A core fix can't go on the publish side either.  An unconditional
> dm_sync_table() in __bind() still lets a reader that overlaps the grace
> period see the new md->map with the stale globals.  That leaves an
> acquire in dm_get_live_table(), i.e. a barrier per bio on every dm
> device, for one target.
> 
> So I still think the smallest fix is the single barrier from the
> original patch.  That line carries two meanings:
> 
>   if (WARN_ON_ONCE(!smp_load_acquire(&tfms_inited[cfg->crypto_mode])))
> 
>   * False means start_using_key() was never called and we bail out.
>     You're right that this half needs no barrier: the index is
>     address-dependent on bc->bc_key, so the flag is read accurately
>     either way.
> 
>   * True means the mode was initialized and the globals behind the
>     flag are safe to use.  That is the half that needs it -- without
>     the barrier, nothing orders blk_crypto_fallback_profile,
>     blk_crypto_keyslots and slotp->tfms[] against the initialization
>     that smp_store_release() published.
> 
> Any thoughts?

Well, it isn't great to be adding another barrier to every bio submitted
to work around insufficient ordering during one-time setup.  The fscrypt
case is easily fixable by the change I mentioned.  The dm case I'm not
sure is a real problem.  For one, dm_get_live_table() actually already
has an smp_mb() in it; it's inside srcu_read_lock().

- Eric
