Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795426301;
	b=cMLFaJ5qVWzjy5TlG0oXnM6F8lJP7trN0fgV/cwzel6lCrieNXh4Fs6xTQ1BsYDZgHgu
	 Lf9h+gfbWsAB2G0lSIvfIFiLHyyW2UoN6yEDdBxpGGlpQDiaJwvt316zxNUwLCnd5oJhM
	 sXT7luxBh32al+J9t9MQxPlYImsSEP4sqJSSR855XAp7aXEKgcU+doaGxGGEQHlEFEvlJ
	 osKvARlayC23feXraSCKRowiRR+PYjFSobqXfx6F3tBUM3hE2wZ9qxQ52HsT//+2ECKMF
	 H9z12tbx4O0knLfROV8vQDZhxwe8mYIMfBrG018vFY2CrDVDrfxaoOZM7V7RutkMzwA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795426301;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=qTfZwRq4CVPyDhqahNCbHKrfBgzSh0zQAJnCCnO1BqA=;
	b=Z3D7ulNtRou5zk8p6zh1CXbW6t3cxAbO+joN2s0otld8tE7QBt9mty04bZxugrOlooqD
	 50EQkl1d9LLIersaIoksCQgDGmgn/Kpun2Rz2DgUWKm5N3UCrQg70WJmBZ0sKIah5cToL
	 I3C8RYBqGJ4p2eAhtZ7r3B0vF+/4zzndgX27CoOJ8dnkGfKahZh2z2vdvaDEaJ7R9eKTr
	 D/qhO6nqZRzNKeEiN4ud03i1aX0C4w/S1V/q5DpCYE5jbglJR6yD2ulQkUfZMexXaWjxf
	 SB83eFOXL0pzQVIhQU+9dmXAxLZPf15U6cPQ3MPqMgWBXELs44BUq/5KYDnUvTuwUrg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33632606A321;
	Mon, 23 Nov 2026 09:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 33632606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B75C368B05; Mon, 23 Nov 2026 10:31:34 +0100 (CET)
Date: Mon, 23 Nov 2026 10:31:34 +0100
From: Christoph Hellwig <hch@lst.de>
To: Laveesh Bansal <laveeshb@laveeshbansal.com>
Cc: Jens Axboe <axboe@kernel.dk>, Eric Biggers <ebiggers@kernel.org>,
	Christoph Hellwig <hch@lst.de>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] blk-crypto: avoid fs reclaim under profile->lock in
 the fallback
Message-ID: <20261123093134.GA23224@lst.de>
References: <20261122213120.20974-1-laveeshb@laveeshbansal.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261122213120.20974-1-laveeshb@laveeshbansal.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Sun, Nov 22, 2026 at 01:31:20PM -0800, Laveesh Bansal wrote:
> Setting a key in blk-crypto-fallback can deadlock on profile->lock.
> blk_crypto_get_keyslot() holds it across keyslot_program, whose setkey
> allocates with GFP_KERNEL (Adiantum); direct reclaim can evict an fscrypt
> inode, and blk_crypto_evict_key() then takes profile->lock again. syzbot
> reports it as an fs_reclaim vs profile->lock cycle. Since
> commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for contents on
> block-based filesystems") hitting it no longer needs -o inlinecrypt.
> 
> Use memalloc_noio_save() around both setkey calls (keyslot_program and
> the blank-key clear in evict_keyslot), as blk_crypto_alloc_enc_bio()
> does.

Pleawe move these into blk_crypto_hw_enter/exit so that it is tied
to the lock for which you enforce the NOIO context instead of hacking
around the issue for specific allocations.

