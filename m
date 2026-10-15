Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36CA93D9DC9;
	Thu, 15 Oct 2026 18:32:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792089125; cv=none; b=BP9Wh7y7MfzrvdWkRDBZGcRwuBbZ9jbuTUvOndUbaeEA14/JfGftMZh/qRKuhl78X4oJNhSLGasrkb4vw1vgCyxKJmXUW1tYu/+O8SekrT2qMHDZkcow/xrJ2qxOci2dUaKbhxnCdeRnkX8yCf9kFXHHX8sndsY7vG6G9tI+cMg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792089125; c=relaxed/simple;
	bh=7yDyzvs7uVP3KOZW6RRGV80I/9y+30yFGC34WJxSIHA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NYss+uJ3Lcu3NjheuCgIWeC82WSJhiD1HA8BoCzLlAjF1NrJ7svW3wwMMnH90TN+Nwj12nrCs713T+SO/W9/Ug28Fk2EJ/VHffivprPS9zPX3uH7vxqZuO2Wz3uFsGjJVeSQBV1i8ZFbDafUZVlISqwvn00Ydd0SQZlGDH1xAHU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nYxIqlQV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nYxIqlQV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 23EE11F000C4;
	Thu, 15 Oct 2026 18:32:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792089122;
	bh=lKwnKAHlNDFtB+osm/iAd4JMHdYg0fdZdGA3O4FaH7k=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=nYxIqlQV3edaJQA5zgYo6mdg8NbpwE3fnFN1Wi8+JMvTHxFrm71smxLYgr9GtEbLh
	 dGS6TC/h1+vpgNPwrcvb4YWlhHxDkvSFiSVBLaX1X/48hJIjraPFKbLODrAk13s4sv
	 csLHrALV3xMsoLyIMI9yOg3JP4ATrLfejU5Acef9MKMw55lTc3BujBfW7JgovPHzrB
	 TIGZL3i+a3Fg32xKsW45ExY4uOJIaqv4gvgcC5U6swRmfLLKVm+P1F/OxjUXTZ9Yy8
	 bNZn32CEOE4ouiqzuTmRz4eW6EcMSiRv3Fb01htraUJ4Q9yqByKppMpkc29upl9N4p
	 NcTKMJVx/WGjw==
Date: Thu, 15 Oct 2026 18:32:00 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
	stable@vger.kernel.org
Subject: Re: [PATCH v2 2/2] blk-crypto: fix missing smp_load_acquire() for
 tfms_inited[]
Message-ID: <20261015183200.GC2170687@google.com>
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014071846.3666398-2-libaokun@linux.alibaba.com>
 <20261014161153.GC322435@quark>
 <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <006e3804-7e5e-4b8d-a299-3a47b8b643b3@linux.alibaba.com>

On Fri, Oct 16, 2026 at 01:36:17AM +0800, Baokun Li wrote:
> That's what I was about to do for v3, but while looking for other
> callers that inherit a key without calling start_using_key()
> themselves, I found that dm-inlinecrypt has the same shape, so fixing
> fscrypt alone wouldn't cover it -- only the constructor calls
> start_using_key(), and the task submitting I/O reaches the key through
> md->map:
> 
>   dmsetup (ctr)                      I/O task
>   ---------------------------------- -------------------------------
>   blk_crypto_start_using_key()
>    fallback_start_using_mode()
>     init profile, keyslots, tfms[]
>     smp_store_release(tfms_inited[m])
>   rcu_assign_pointer(md->map, t)
>                                      srcu_dereference(md->map)
>                                       -> ti->private -> &ctx->key
>                                      inlinecrypt_map() -> bio_prep()
>                                        tfms_inited[m]  addr-dep, ok
>                                        profile/keyslots/tfms[]  not
> 
> dm's own grace periods would cover this, but all three are conditional:
> 
>   drivers/md/dm.c:2533       if (old_map) dm_sync_table(md);
>   drivers/md/dm.c:3015,3039  if (map) synchronize_srcu(&md->io_barrier);
>   drivers/md/dm-ioctl.c:1651 add_disk() only when type == DM_TYPE_NONE
> 
> so e.g. this sequence has no happens-before:
> 
>   DM_DEV_CREATE
>   DM_TABLE_LOAD (linear)       add_disk(), md->type set, not resumed
>                                  -> a task opens the device here
>   DM_TABLE_CLEAR
>   DM_TABLE_LOAD (inlinecrypt)  ctr sets tfms_inited[]; no add_disk()
>   DM_DEV_SUSPEND (resume)      old_map == NULL, all three skipped
>                                  -> the already-open task does I/O
> 
> This needs a weakly ordered machine and a deliberate ioctl order, so
> it's not urgent.  Which would you prefer?
> 
>   1. Leave it for now and fix only fscrypt_find_mode_key().
> 
>   2. A separate smp_rmb() in inlinecrypt_map(), paired with the
>      rcu_assign_pointer(md->map) in __bind().  Keeps the cost on
>      dm-inlinecrypt only, but means a second site to get right.
> 
>   3. Keep the barrier in blk_crypto_fallback_bio_prep() after all,
>      documented as ordering the loads after the check rather than the
>      flag itself.  One site covers both callers and any future one,
>      at the cost of blk-crypto no longer relying on the caller for
>      this part.

So the device-mapper core doesn't order target_type::ctr before
target_type::map?  Nearly every dm target's map function relies on the
constructor having run first.  If this is an issue, it isn't specific to
dm-inlinecrypt and it will need to be fixed in the device-mapper core.

- Eric
