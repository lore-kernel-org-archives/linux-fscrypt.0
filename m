Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A79E63D1CB4;
	Mon, 20 Jul 2026 09:23:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539418; cv=none; b=JwaZqshqNFdhdMXaqeqGlqTT2m2rjmPa8KrRCqUZcwERkgwA4zfnWjBFsy1HMmyYcTtIhKqhnBWHIV35mdl5Sm6BvE1q9cV/R75wkrg0QN92qKRM49rFUl/jRI8Pr0wDD+TCB48I47ire4YUMFKBqtfIMBbeTQ8ih8eyHd/hVIs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539418; c=relaxed/simple;
	bh=LHSeMM2AlRs/+WX3B8w3409hRqh4kQMX5YTWMAlxkVI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aM3NiIECsA6ZlV8pXTVhMmhCRz+oeHZEblWYtZZsCPrRWJpNv8/cKAyFQgUlIhFLJBSFyadIacN5YA/PuOf7x8KWsneE9+0LSZwfWdY5RjcZiU7Y6iLmUqt/pQb+YqSHdLLeougw6v2OM1zW1VUGEVvhiWcwaxBZTDhLsVM4WA0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=BZS9VwBq; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BZS9VwBq"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=U50y68bE6mM95Q76lwCVRdyL71et9l/CyD0ewFiY1mc=; b=BZS9VwBq52Cxtlrie89Dr4SDRI
	gNmP+FzpbP5IDQpgjKZG9X1lVWwjuVucJ1sJhHDkplpUWll2v0srZ7UPp24MFl4H8nGXnSj1XtyaI
	tLJmZy+uj97j10UU4zNvtAR3TmDzvFHWEqSgV6VJ8B3ClavoVg0/+AosngfoAW0+t31tYlj/zqRMi
	0V2HiIfElwiObGeJuZzZm8HujShHfKJH0QKXq+XZfN212l63ZNKSeuCS7PZndpJInclZqbmmoSS+D
	ZKAF5EP6E1mcCN/Xh9d9p/MO6TPFSXP6E39gFje/pq1Ni/XM4YsZCNpKswl4Y6DQk6TUZbDQwkXpn
	5XzOO3NA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkDm-00000006IPw-0Ftn;
	Mon, 20 Jul 2026 09:23:34 +0000
Date: Mon, 20 Jul 2026 02:23:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, stable@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Avoid dynamic allocation in
 fscrypt_get_devices()
Message-ID: <al3pFrj8eAV0MSSO@infradead.org>
References: <20260719055602.78828-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260719055602.78828-1-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Sat, Jul 18, 2026 at 10:56:02PM -0700, Eric Biggers wrote:
> For now, let's fix this in the straightforward and easily-backportable
> way by switching to an on-stack array.  Currently the fscrypt
> multi-device functionality is used only by f2fs, which has a hardcoded
> limit of 8 block devices.  An on-stack array works fine for that.

Looks fine as a quick fix:

Reviewed-by: Christoph Hellwig <hch@lst.de>

> (Of course, this solution won't scale up to large number of block
> devices.  For that we'd need a different solution, like moving the block
> device iteration into the filesystem.

I'd love to see this happen rather sooner than later, as that's a much
better architecture.

