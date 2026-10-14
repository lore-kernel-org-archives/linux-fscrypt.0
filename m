Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 161343F44CD;
	Wed, 14 Oct 2026 16:12:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791994347; cv=none; b=PD4Y6WDfVVwnoa5iO798EXhNbBqxfGz6quaeJYODb80Ao9oIJMcPFoO6iabPDs6evG7p2fdL3ZaTwEH/rk3Z7/WS17OmhRAhK3rms2bozu1ql4UB7HTBmPjKyor2w4KIar2Se13Hbwxsgx9cZ7G8x6RcSUPzzKmUfyTeWqf6LII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791994347; c=relaxed/simple;
	bh=GyTPyss8tgeWbxcBuiqgsQXXRwq9GQZBW+1hIGvc41E=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=mSmDY8/SWYyrOTUb2BwYWeVQT7x9tsK7a30LEcKK/5GMYXb2B4lmFsR1TX+mmRuOlMXIRQhYseis/+kKOfMAWHMGa+S1jhLGXCJ8elsYetPdqk+7pCBniiNl5rFagSapp7UJPGqewcsyILluvyDDy/5wSk01jzKrTQxlZDEWFvo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UdQpueJX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UdQpueJX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 690BE1F000C4;
	Wed, 14 Oct 2026 16:12:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791994334;
	bh=x5WE3Q/70UvLQSpXvFgVPVd4kF4JaF8U/PXOcBtopZk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=UdQpueJXlNKxtoSFIT83WW49n6u19pifjoG9ubz9UM0hwy1A6pBQGQPvNGMaCIqqf
	 EgC0PjoXGz3k5TJh/nKXTrri+PedfGo38PGzOn/B7jQtJZcwrjKSzkOB7pNPhMJpgd
	 wRYFe68WBpClCE7+u+sWTF36kY9TsT23Ac6lyLcD1uTVFpOFRlx024WzYL0US/4Kl6
	 5dmQARHWiDFXJlih0nNSJDcSj2eD+taB1oDbnP2ib6YQtjzGkUrKZb1nVoVy4Z8gWi
	 QmIy8N+FLTGbn3n/AnZf4tL/RPFp4VWOLnk+lvyfGPdH492nnYM1aZN+aDaVeNAqFG
	 Pb8t8RitiAWng==
Date: Wed, 14 Oct 2026 18:11:53 +0200
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: axboe@kernel.dk, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, hch@lst.de, dm-devel@lists.linux.dev,
	mpatocka@redhat.com, sweettea-kernel@dorminy.me, satyat@google.com,
	stable@vger.kernel.org
Subject: Re: [PATCH v2 2/2] blk-crypto: fix missing smp_load_acquire() for
 tfms_inited[]
Message-ID: <20261014161153.GC322435@quark>
References: <20261014071846.3666398-1-libaokun@linux.alibaba.com>
 <20261014071846.3666398-2-libaokun@linux.alibaba.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261014071846.3666398-2-libaokun@linux.alibaba.com>

On Wed, Oct 14, 2026 at 03:18:46PM +0800, Baokun Li wrote:
>
[trim LLM-generated text]

> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
> index b5dbb092caea..31f76d117593 100644
> --- a/block/blk-crypto-fallback.c
> +++ b/block/blk-crypto-fallback.c
> @@ -488,15 +488,17 @@ static void blk_crypto_fallback_decrypt_endio(struct bio *bio)
>  bool blk_crypto_fallback_bio_prep(struct bio *bio)
>  {
>  	struct bio_crypt_ctx *bc = bio->bi_crypt_context;
> +	const struct blk_crypto_config *cfg = &bc->bc_key->crypto_cfg;
>  	struct bio_fallback_crypt_ctx *f_ctx;
>  
> -	if (WARN_ON_ONCE(!tfms_inited[bc->bc_key->crypto_cfg.crypto_mode])) {
> +	/* Pairs with the release in blk_crypto_fallback_start_using_mode(). */
> +	if (WARN_ON_ONCE(!smp_load_acquire(&tfms_inited[cfg->crypto_mode]))) {
>  		/* User didn't call blk_crypto_start_using_key() first */
>  		bio_io_error(bio);
>  		return false;
>  	}

No, anyone submitting encrypted I/O is required to ensure that
blk_crypto_start_using_key() was called first, in which case the
additional barrier here during I/O submission isn't needed.  If the
caller didn't ensure that, then it's a bug, and we WARN.  This patch is
inconsistent with that.

I think this can be considered a bug report that the ordering of
fscrypt_find_mode_key() is too weak now, as it just uses
list_for_each_entry_rcu().  It looks like it should do
smp_acquire__after_ctrl_dep() after it finds the right entry in the
list.

- Eric
