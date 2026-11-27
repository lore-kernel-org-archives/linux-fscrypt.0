Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795805294;
	b=OxpIgAspnxJc7NpUUKNs7EWWY9wTHwMKOFi4Qkn+eEjTdvanqZE8cjvaWGfe5TYJJ837
	 CuCZ2GUWuxeSeHXPwdP3OfNzYOP+0pfkHA7+56EZArB1PoJjJPGkbtcVSbrOh2QONDhej
	 IMzxOAfQtxFzWWt9f2ckVUmPQfUqMS6zhgS9NR7jHdzZC7H4Mv9b128KXM7zasgitLuD9
	 kGpTOgDd573REqPMnhK4ph/WSgwT8ZTeDhrNjvR4vD7RKxlAi/3nZqKOHoaKdf+h7kPl0
	 ZWtmZ2hxUIeAscYhM15kxGpIqtt3RV89d94X9EoYyY2vfEjovaiv9VI36W9htzRQoOQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795805294;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=kTWfwLU9AK6CypFMW27FabInezsO4qPOmYZqmCY8gzk=;
	b=cQwLGy+cDdNhstdCNtPRcuAsDRsOMa/8V5kqNy0e8DV1OJQGR0F62VwZutprvwF7Hepu
	 CivMr9O9HneCNQgCapc0aVUStXiNvNwW0sGmsXdqEN63tTItb53N7CLX8Hq0KM/0WjXr0
	 G/NCIpr3k6vHQ/VM/y8SZmvqb9zThhL1kclhmK4diCA3QqL6UzL6+QcGBwAgBmBp6dv2N
	 sSczhDybwKW7hNgZBpmFs4TTmyedCaz2XITM+jk0Gf+ufi6OCL9pqWtAZsPpx+Vh7E4I/
	 NezZColMzEJoicYEizAA3P+bJ3EbgbsU5C0XWMgBgfXqm+8kXFNGA34kmFyTIcVZ4XA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RQDG1jY3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CEB4606A31C;
	Fri, 27 Nov 2026 18:48:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=RQDG1jY3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98EA81F0089A;
	Fri, 27 Nov 2026 18:48:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795805294;
	bh=kTWfwLU9AK6CypFMW27FabInezsO4qPOmYZqmCY8gzk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=RQDG1jY3KRmCfeLg/3+43yn0523AOmfpBepgIF+hHdw2zdHKqvTNN91SZVu3I6YzP
	 CRvLyJfFDbxlmZ9s5IvhBXVJPZ57m3wu8fIqE2BpEmW8DS6hz/w/zlb8eA5+xan9BM
	 z0juE95k+S0Q+uPUXtWCL/lu6KckkbcKRJ77qtNTrHp4DHwX3RMVlfuLWHZIPUH5Fp
	 Xs5R4SWilSG1tnUm3jBvfqQ+U4HLHfI4rFRZbxDzK9QnnqUL+SDcuD0hWS/4LLUvQb
	 9IAQZGkI19cxmbmnPJiMNfDo58kZnU68ep7drZem52tZ07boy0TwZxfqlTjkc9zsr4
	 hiP7BEGw8vYnA==
Date: Fri, 27 Nov 2026 10:48:12 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Laveesh Bansal <laveeshb@laveeshbansal.com>
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] blk-crypto: use a NOIO scope while holding
 profile->lock
Message-ID: <20261127184812.GC1974@quark>
References: <20261125081417.77674-1-laveeshb@laveeshbansal.com>
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
In-Reply-To: <20261125081417.77674-1-laveeshb@laveeshbansal.com>

On Wed, Nov 25, 2026 at 12:14:17AM -0800, Laveesh Bansal wrote:
> Setting a key in blk-crypto-fallback can deadlock on profile->lock.
> blk_crypto_get_keyslot() holds it across keyslot_program, whose setkey
> allocates with GFP_KERNEL (Adiantum); direct reclaim can evict an fscrypt
> inode, and blk_crypto_evict_key() then takes profile->lock again. syzbot
> reports it as an fs_reclaim vs profile->lock cycle. Since
> commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for contents on
> block-based filesystems") hitting it no longer needs -o inlinecrypt.
> 
> Enter a NOIO scope in blk_crypto_hw_enter() and leave it in
> blk_crypto_hw_exit(), so allocations made under the lock, by the
> fallback or a hardware driver, can't recurse into I/O or fs reclaim.
> blk_crypto_reprogram_all_keys() takes the lock directly, so it gets the
> same scope.
> 
> Fixes: 488f6682c832 ("block: blk-crypto-fallback for Inline Encryption")
> Cc: stable@vger.kernel.org
> Reported-by: syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com
> Closes: https://lore.kernel.org/r/6a9b25c3.b5d4176b.238c3e.0004.GAE@google.com
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Laveesh Bansal <laveeshb@laveeshbansal.com>

Reviewed-by: Eric Biggers <ebiggers@kernel.org>

- Eric
