Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9F2A3D6664;
	Mon, 20 Jul 2026 09:25:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539547; cv=none; b=FBp85QHK02sJ4+9B9Or/el9aaqzxsQd4HlHmBe2lnxE8X2FIw+F7YKm/VCpHpGZCoD9fUEmNmOJ8+sTn1EfawkIaghTU5LTGcuosfwAfUMEKTCabG20k6t5ic8rSUkYeEhJ8qrTJWvJTviE20iuWyNI8HwznSlC+vESqla8ygQA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539547; c=relaxed/simple;
	bh=ktnqeQzoVZxgTDKDI/x/2lJe/4VTfiBgNSsaGgP1wpg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MhNmuT65IuKjwNxNpZyaki/lwkDKZeiFk478yBy7frsXR+Mywl4oDV/FJRbbjy5CHQukqVlBLrOwSeTlZOmgl5y9V2QO3DMigGwwr9nA1a0K2Hx1AtIowZbnJ2uySHuQ+pwRMkaPcZFLogVYQ2wCBnBe74QoOqL/Jf0NwY+NuNM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=DbGGECAA; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="DbGGECAA"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=ktnqeQzoVZxgTDKDI/x/2lJe/4VTfiBgNSsaGgP1wpg=; b=DbGGECAAIpJbLuumRxIiPGTbQF
	6HMC5mHQtNwg6i3w47n1tyL1k0qMIEc4N5rPlavMVCLpIpecrOlZiH4eVp1N+3LxwViUg1BxfNB+1
	9u5KixYeidKc2qVQzZylLtQjRUZyE5EI7FJqIKDhoxtgL6fGpEnJubBAk/8QQGHsvvYLqP6VMyx2t
	+u89APcge6Veamkdp398fABSeBGlnLpbv3HWWZ4J2AjznUvJRoPS9s9JRCq+f6lB/r++8jArHH6MK
	ZuJR3+wRNPVM5pfIsNstzOjXl+L7MptJBEAqFC+y2houd22+1in11FD/ugoMG7OPmQQRCun6p8x/H
	27eJp5Fg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkFn-00000006Ifz-0p67;
	Mon, 20 Jul 2026 09:25:39 +0000
Date: Mon, 20 Jul 2026 02:25:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 1/6] fs: Update outdated comment for SB_INLINECRYPT
Message-ID: <al3pk9qhwG3gDzcc@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-2-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-2-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Sat, Jul 18, 2026 at 02:46:50PM -0700, Eric Biggers wrote:
> Update the comment for SB_INLINECRYPT to match the latest code, where
> SB_INLINECRYPT now controls whether blk-crypto uses inline encryption
> hardware rather than whether blk-crypto is used.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

