Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792772409;
	b=mY7sFUATlYFlvCQeJVOcryeDPuAyh8BLllPRK311OLGaSq+R0AO3+9/FN9hBuUxIRlIQ
	 vW3BVAh1jy7nxMh412vkX1yArHpDEb4i5ZLHP5v3sfMWsI7TWrhjCAMg0RxFsg9m/fHWZ
	 jXmsqo2Y2J36D4SM1INg6K0sgjJ6pFF6NQYVlX198M3Axv886Cs2GHPaP2IdAiFtBqdmz
	 oKAyp3FFMoziV/F9J8hFMxA38SAI97wBPgN5Qyde1kxBo2KmdXu7GHMrkVxOvAEdvSJei
	 RbJ4iDXSSScTqoFCqTWSqESA1tB5EK14nSSrzSTgN+a2juBVOdS3I67Ztoso+cZE4hQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792772409;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=lFKXhdz7b29163w5ty1D2Chrsll2Yyt/yyzKi1Ft4hU=;
	b=1wMb+qxWrNcrRUeY9krrkz8vI2rKqJO3V9s6d0gAqJnnqL2iXwQQSZvnNbNoyDasELif
	 b0u+5EKjA3cI22luAYBKfgHHfCeWysq6j12XWKJI4h4GlpOTsP079IATKfNrto93s8keO
	 49n8lRLY/iTFsWxiRWShgbmNcl3uUEB6ldon9g7qwpK3KMbM2ZOHlWYGEf7StVwrze9kd
	 29OMaVNFe+dU0IRuKS/e7H5zEs2vUQsTnDANB1dgcXmU3mT1Ph7n093ibchaYHoB4gboN
	 WoLpDIKwac5HX+2oL1W+TCEki0yhFQqt2ZBCbeeZakW21UWeFjljM64RZz89XOSEx9A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NYX6apH4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C3C1606A323;
	Fri, 23 Oct 2026 16:20:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NYX6apH4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D85E31F01825;
	Fri, 23 Oct 2026 16:20:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792772409;
	bh=lFKXhdz7b29163w5ty1D2Chrsll2Yyt/yyzKi1Ft4hU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=NYX6apH4XjsuZbhZ2nkea+lMVyIY944cl0LUHsen297ujJ8tYK0Bbm8WYyHbavD1V
	 HBlPPC7XJpUoofs/uOB6pSPlWMa8saidr1rTg8SgSH/Q1k9tGrngoixXjljR6B6PAq
	 rzI90tjtjcS8jL38d09abhDYkW8EpDURsDwyv0FOUS5umplK24ggOyDQda12SLmuTg
	 3NMURHfzk/s+xOrQHzLP9T/lezpnJj98PKqY9MIRcb3pKE9uDDYPmPMi1+7MNbPbVk
	 Mcmy1jtKYbWmqjaYoDaLumIKZpfq/YG060V8fziI+xTT3xCvpffOsDzc8UTVV67VCn
	 mtFaW+fA77OzA==
Date: Fri, 23 Oct 2026 16:20:07 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: linux-block@vger.kernel.org, axboe@kernel.dk,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me,
	stable@vger.kernel.org, Sashiko <sashiko-bot@kernel.org>
Subject: Re: [PATCH v3] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
Message-ID: <20261023162007.GA2810556@google.com>
References: <20261023081908.3505413-1-libaokun@linux.alibaba.com>
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
In-Reply-To: <20261023081908.3505413-1-libaokun@linux.alibaba.com>

On Fri, Oct 23, 2026 at 04:19:08PM +0800, Baokun Li wrote:
> Fix this by returning early from blk_crypto_fallback_evict_key() when
> tfms_inited[] is not set for the key's mode.  tfms_inited[] is only set
> after blk_crypto_fallback_init() has successfully initialized the
> profile, so the crash above is no longer reachable.
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
> Suggested-by: Eric Biggers <ebiggers@kernel.org>
> Link: https://patch.msgid.link/20261014155131.GB322435@quark
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Reviewed-by: Eric Biggers <ebiggers@kernel.org>

- Eric
