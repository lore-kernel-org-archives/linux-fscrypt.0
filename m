Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795571096;
	b=RNFLmtCulJeyiBCZAUYA8jlWKW1Kwr8SvF04RIWl7dRbMEP1fOZkLDGXvTDcbRVgeIrY
	 tn/Gy12WzBPcMTDXjznrarFs5zl9deHx9vQF5/2MNqRIge6WXouklQBxv8dAmDtdXbcuj
	 eD1cb5vPCFyMvOJQrhBEQfGx0talmJbMTF+OZXg31cQASwfLXfiUwqBkHa5QD5CSA70Sn
	 eXZCtCzS6Knh9DTZU/wtALcNsU52Lbfr44yMmJYE68ItXu1anFH6xd6R0kyDvQmcdBVRK
	 Vs7HhvhPvBkIO5Vg7jxsUnXWcTdRYzU3ZzbvfHf32cr5Ofh3VbMOhkz29mF2rgPxciw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795571096;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=75zW4Phu6PXTI9gPGLcPCmj4B7p94Zt/j+BgJVF3UqA=;
	b=dV4JNVZ3aoFhkiDX7S0xTaKn/Rq1uKc5jKZajHnE5A/4YKKvpsmfKoQaxlw/tQizGnCF
	 6shXsMTP/tDr0Ikgi08q6bz6La4Ubv843Opbe6v7/NWqn/HK1ilcwiLUMsLIni9faSPWX
	 KXXkSBQHWSz2fJxvUTXonIM5UXBXOdhEfMGfowDApUTg0QH18WOMVicJlmvY7edlpbgiy
	 oSppHrCil9FCxJ3RL8Jg8MvtHjJXZ4E7BgvS9XfDL+5yY6MfbdgVCwp5jnX5RDg96lndF
	 PWQywRjiyNlRW/+sMKPHRsvRL02JfvDQfo8gxSvoI77d9hrVSiVCuPoU1rz4l+yweEw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZNqySscf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABCED606A684;
	Wed, 25 Nov 2026 01:44:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZNqySscf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0EF9E1F000D8;
	Wed, 25 Nov 2026 01:44:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795571096;
	bh=75zW4Phu6PXTI9gPGLcPCmj4B7p94Zt/j+BgJVF3UqA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ZNqySscfzxgbRoGmXo/aFHMB9RG4dr6QvIwOvsEPeXqKYDXXVz/4dy1RfzFWAD1AG
	 IU1IVZxZNHy/VFxNPV4QKnlgVUviFdTfjubawhOuTzL/Lp4YWEjT/E5kOTvLMm8Fia
	 U/+wfWCOBJui+jyFB6xn1USY0vUFK6owi2OmIHODoyPYAJjc8OAjlttKVXpO6nZuFG
	 oD/uNWGmmA1umkGUrkf9/6oidX7PO37N5XweGHLbraUJ2soUALMqkVMo8UqDs1bp2i
	 yyd3GpFHbm0Z+ypUeBnWr1JEjXeZfAWDo4aXXYt75ENtrJFen++bZ6B1zCWYc5VQO7
	 SGEs4JBA1tI1Q==
Date: Tue, 24 Nov 2026 17:44:54 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Laveesh Bansal <laveeshb@laveeshbansal.com>
Cc: Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] blk-crypto: use a NOIO scope while holding
 profile->lock
Message-ID: <20261125014454.GA2461@sol>
References: <20261123181408.62972-1-laveeshb@laveeshbansal.com>
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
In-Reply-To: <20261123181408.62972-1-laveeshb@laveeshbansal.com>

On Mon, Nov 23, 2026 at 10:14:08AM -0800, Laveesh Bansal wrote:
> setkey allocates with GFP_KERNEL (Adiantum)

We should just fix that one:
https://lore.kernel.org/linux-crypto/20261125013553.94480-1-ebiggers@kernel.org/

We should still proceed with this patch, but there is really no need for
the crypto code to allocate memory in random places.  I've been working
on getting rid of cases like this.

> Fixes: 488f6682c832 ("block: blk-crypto-fallback for Inline Encryption")
> Cc: stable@vger.kernel.org # v7.3+

The v7.3+ should not be there.

> @@ -53,11 +54,14 @@ static inline void blk_crypto_hw_enter(struct blk_crypto_profile *profile)
>  	if (profile->dev)
>  		pm_runtime_get_sync(profile->dev);
>  	down_write(&profile->lock);
> +	/* Reclaim evicts keys under this lock; don't recurse into the fs. */
> +	profile->memflags = memalloc_noio_save();
>  }

"don't recurse into the fs" describes memalloc_nofs_save(), but the code
actually uses memalloc_noio_save().  The code is right, so a better
comment might be:

        /* Avoid recursing into I/O or fs reclaim while holding profile->lock */

>  static inline void blk_crypto_hw_exit(struct blk_crypto_profile *profile)
>  	__releases(&profile->lock)
>  {
> +	memalloc_noio_restore(profile->memflags);

Storing the flags in blk_crypto_profile isn't necessary.  It should just
be a stack variable, returned by blk_crypto_hw_enter() and consumed by
blk_crypto_hw_exit().

- Eric
