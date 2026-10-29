Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793293669;
	b=yLxbOBl1jxxW93u/fg1RdDN7ACq5ZzGf9SvlrB2TH66sYjjXpprEtYtSv1gfMBt9oG4r
	 j32jtZrIqeNN9LE/nrFOHHfo7p6Nfp8N7ReKDG7VKGnsUarBAN9E85Iozz//v0BDq0gBw
	 PT2zQjBsLvrDLDulYHS1x7/636v+te588HQ3JssgdPNecU1BZbZ3it0zCwskrUEPsSyUg
	 i27mafIkcdlFm5gyA84s+CM5GqlN9I6V+d3VIQFOn640ZBUdXgHmGeGa+HbYZ/p5ObQ+N
	 qXz4S05rnSpea/mtue74CqWJ64yNYKBGkRUFu0+A8TlVHeZ2NyX1wZJm3rBz2O4i2cg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793293669;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=8RWvSllWX4HWMR+2FjS54MKb/nvXgQ8kmudAoxfSssY=;
	b=VuSUTwB5URbujZ5qFQ6pqu+a51qHsqJMyB9mIZR3fv7PByfUiTxKviSr0eFaHw/1W/Qj
	 heAR7lpCY76fN9fCiXp/9pg83Pr/JhJCQ1q3JqCbzcoKd1YboPuxpPhkyABfAcQeynmHd
	 xt7/daQQinDWMyhXd5KHoafKys7sFpILqUHDyb0Sxi9I7JMSwET+gziTbkZXlmb6O7npU
	 Q7b8nDoo2yBMQe5CHnDDvUa826/FtiPpLWeUxppymVPk1V727ddtAQUa1t7XY9qRq7Qpe
	 Ug12VN8NFLak2tpDdP4k/LAcy6G8uNtip+Ckp34ykEhSOpiQUqETPllDMH3RS//kOFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SQnrmMec;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32071606A321;
	Thu, 29 Oct 2026 17:07:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SQnrmMec
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E013F1F01828;
	Thu, 29 Oct 2026 17:07:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793293668;
	bh=8RWvSllWX4HWMR+2FjS54MKb/nvXgQ8kmudAoxfSssY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SQnrmMecH3/5UiTN/bzWJvwWQwyo+JllLbyU6H6ZB8r+nvcDrwfnouBou15z+6ORt
	 R7rnF5Cy0aQn/iyftocm+y28VXhZJLtgKtfGFLNYcQP523jpt4EBLWDavNzeNTV8ca
	 Ko+8cEzFwzoBIrke62BQPJpLMYwdn+oJdB4cer19qPBgB/47VdjJW9aOnVtcNhKxYh
	 59CjtnzJINKZM/Si7IdsTJ690vPRO5g/74iC4w3S6YI0N2JFwUAiPaEZJ7EknPZ5o0
	 SGMSRveJfWpAH02W+i3uQ/6wI8fVCN9UTI93s1Rq7hQbMNPWGk3tOvxH8wUhSCSHZS
	 Jmg4gnHR3eW3A==
Date: Thu, 29 Oct 2026 10:07:46 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, axboe@kernel.dk,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me,
	stable@vger.kernel.org, Sashiko <sashiko-bot@kernel.org>,
	Baokun Li <libaokun@linux.alibaba.com>
Subject: Re: [PATCH v3] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
Message-ID: <20261029170746.GB1862@quark>
References: <20261023081908.3505413-1-libaokun@linux.alibaba.com>
 <20261023162007.GA2810556@google.com>
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
In-Reply-To: <20261023162007.GA2810556@google.com>

On Fri, Oct 23, 2026 at 04:20:07PM +0000, Eric Biggers wrote:
> On Fri, Oct 23, 2026 at 04:19:08PM +0800, Baokun Li wrote:
> > Fix this by returning early from blk_crypto_fallback_evict_key() when
> > tfms_inited[] is not set for the key's mode.  tfms_inited[] is only set
> > after blk_crypto_fallback_init() has successfully initialized the
> > profile, so the crash above is no longer reachable.
> > 
> > The bug has been latent since commit c984ff1423ae ("blk-crypto:
> > dynamically allocate fallback profile") was merged in v6.5, and only
> > became actually triggerable when commit e7f57d2c47e2 ("dm-inlinecrypt:
> > add target for inline block device encryption") was merged in v7.2.
> > 
> > Fixes: c984ff1423ae ("blk-crypto: dynamically allocate fallback profile")
> > Cc: stable@vger.kernel.org
> > Reported-by: Sashiko <sashiko-bot@kernel.org>
> > Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
> > Suggested-by: Eric Biggers <ebiggers@kernel.org>
> > Link: https://patch.msgid.link/20261014155131.GB322435@quark
> > Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
> 
> Reviewed-by: Eric Biggers <ebiggers@kernel.org>

Jens, could you take this when you have a chance?  Thanks,

- Eric
