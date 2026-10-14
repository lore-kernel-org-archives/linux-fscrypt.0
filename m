Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EAB852FE35;
	Wed, 14 Oct 2026 15:51:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791993119; cv=none; b=ghmsXRJBQzE+yuXvOkx0Q5DYlDu6WnjIn40iCYVib1F+E57F4R/GikKHLNiM4g1+lWGpbfZF8eCYqbf6KKoLe0tUyCa+Rp1iWgNs+0jPi8g6Kcb7fo7iH4mgOmmVsxUfUPsgOvigc6K8Hl63pBtX8f2ykZNVASGruoKcchmNNCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791993119; c=relaxed/simple;
	bh=eGBV3oIX0ttNPEtQyqm1g7sW6uQVfThYlrI46mP6w1Y=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hZ3MllzHHECqUevQhg0CZAfZ4MyWodl1sb4zpv90RqHyH3wVQmOs4gwJ3N4F0I64/Y7NgGa5d4XUtKcwUCeuCxXps4GaoIvvPT8LX2wkzkhkXUhF9QFAsrxdrJV02rcP2SQ49P8bX4oD8MMG/SgFyZIv6EniXXA64keeuNlwIQs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Swd5SN4t; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Swd5SN4t"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D46591F000C4;
	Wed, 14 Oct 2026 15:51:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791993117;
	bh=iFFBZa2pwJfsr9PJik9gAxui4FyOEFwlI1yivxYxmj0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Swd5SN4tihBjj+47+27hJDhp3VQiPYgBH22OK+DVQRyCY1Yg3/QfyBdmWTjDCUF1R
	 NVm/zKTERrfQiZ9FWIjI/yervNmk9pFciBQmf8iE+g1nZzJtT2cFX0TDDBqwQ41cdD
	 hQgI5oap8bY1hkcf63xD8JOKw+rdroWbnv3plRUARNGk7DRyd/Scd15tjyHtnPF6Bf
	 y07LPPNT9rb0Xfo6qjJr6UWPabEOh7cf2qQqrMkAc/NSDSnmi+cyXqgpkMrHBUcesO
	 R7H7X/YCIPMnBofC9Rv5cxoUFTKWScaTAu+RHlS9Sh+tBiG9Dm+QA0SHFTJAKatCGP
	 7lx8TjQj78EkQ==
Date: Wed, 14 Oct 2026 17:51:31 +0200
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
	stable@vger.kernel.org, Sashiko <sashiko-bot@kernel.org>
Subject: Re: [PATCH v2 1/2] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
Message-ID: <20261014155131.GB322435@quark>
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20261014071846.3666398-1-libaokun@linux.alibaba.com>

On Wed, Oct 14, 2026 at 03:18:45PM +0800, Baokun Li wrote:
> Sashiko reported a possible NULL pointer dereference, triggered by the
> following flow:
> 
>   dm-inlinecrypt ctor            # first use of the fallback
>    ├─ blk_crypto_init_key()      # succeeds, ctx->key.size != 0
>    ├─ blk_crypto_start_using_key()
>    │   ├─ hw-wrapped key: -EOPNOTSUPP
>    │   │    # profile never allocated (NULL)
>    │   └─ raw key: fallback_start_using_mode()
>    │      └─ blk_crypto_fallback_init() fails
>    │         └─ kfree(profile)   # not NULLed
>    ├─ goto bad
>    └─ inlinecrypt_dtr()          # evicts whenever key.size is set
>       └─ blk_crypto_evict_key()
>          └─ blk_crypto_config_supported_natively() = false
>             └─ blk_crypto_fallback_evict_key()
>                └─ __blk_crypto_evict_key(blk_crypto_fallback_profile)
>                   └─ profile->num_slots # BOOM!!!
> 
> This issue can be reproduced using the following commands:
> 
>   dd if=/dev/zero of=/tmp/backing bs=1M count=64
>   LOOP=$(losetup -f --show /tmp/backing)
>   SZ=$(blockdev --getsz $LOOP)
>   KEY=$(head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')
>   dmsetup create ic --table "0 $SZ inlinecrypt aes-xts-plain64 \
>     $KEY 0 $LOOP 0 1 keytype:hw-wrapped"
> 
> And the following oops is triggered:
> 
>   ==================================================================
>   blk-crypto: loop0: no support for wrapped keys
>   Oops: general protection fault, probably for non-canonical address
>         0xdffffc000000000b: 0000 [#1] SMP KASAN PTI
>   KASAN: null-ptr-deref in range [0x0000000000000058-0x000000000000005f]
>   CPU: 5 UID: 0 PID: 901 Comm: dmsetup 7.3.0-rc3 #1 PREEMPT(lazy)
>   RIP: 0010:__blk_crypto_evict_key+0x2e/0x3b0
>   Call Trace:
>    blk_crypto_evict_key+0x24c/0x320
>    inlinecrypt_dtr+0xf6/0x160
>    inlinecrypt_ctr+0x2d3/0xbd0
>    dm_table_add_target+0x661/0xf40
>    table_load+0x1c4/0x490
>    ctl_ioctl+0x32f/0x5f0
>    dm_ctl_ioctl+0xe/0x20
>   ==================================================================
> 
> dm-inlinecrypt is the only caller that can evict a key that was never
> started, as fscrypt frees such a key without evicting it.
> 
> Fix this by publishing blk_crypto_fallback_profile only after
> blk_crypto_fallback_init() succeeds, and by returning early from
> __blk_crypto_evict_key() when the profile is NULL.  The eviction path
> can then only observe either a NULL profile or a fully initialized
> profile that is never freed.  A key whose start failed cannot be in a
> keyslot, so there is nothing to evict.
> 
> The profile pointer is published and read locklessly, so use
> smp_store_release()/smp_load_acquire() to guarantee that a reader in
> the eviction path that observes the pointer also observes the
> initialized profile.
> 
> The bug has been latent since commit c984ff1423ae ("blk-crypto:
> dynamically allocate fallback profile") was merged in v6.5, and only
> became actually triggerable when commit e7f57d2c47e2 ("dm-inlinecrypt:
> add target for inline block device encryption") was merged in v7.2.
> 
> Fixes: c984ff1423ae ("blk-crypto: dynamically allocate fallback profile")
> Cc: stable@vger.kernel.org
> Reported-by: Sashiko <sashiko-bot@kernel.org>
> Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
> ---
>  block/blk-crypto-fallback.c | 31 +++++++++++++++++++------------
>  block/blk-crypto-profile.c  |  3 +++
>  2 files changed, 22 insertions(+), 12 deletions(-)

Wouldn't it be a lot simpler to just make
blk_crypto_fallback_evict_key() check the existing tfms_inited flag?

	/*
	 * Pairs with smp_store_release() in
	 * blk_crypto_fallback_start_using_mode()
	 */
	if (!smp_load_acquire(&tfms_inited[key->crypto_cfg.crypto_mode]))
		return 0;
