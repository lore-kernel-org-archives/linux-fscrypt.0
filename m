Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3F693D9049;
	Mon, 20 Jul 2026 09:26:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539565; cv=none; b=G4PfeSF0jgauHgq55ITXSn+wC3MVFgynUvzuli30efGV+y6kq2zNruYtPhdqPDNFELQvaWu1pb98+FWYAirOr+EcLtclY0XHbka9uoZCI9iQj1+cktYWSoiFsTutJNzBsOz82ZJJCt5RdpH/foS8LAm8+arBzEpiFC0YgFEQdlo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539565; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=f27VPjqBt0DOqYiAHZHckaR2f3C7WFjh3drbrpQ1zxxEGTUH7dJ/66us6VYVQkGXLgpA9tXwoOxU66IdAirHVXMgY/Xo1EKytR7IJHWeo5hpKyNmtn28YgOhHBpsnR5JiYl1/NgeV6vRg7zWRc1xsnb9XNnWQiZbIm/zM7SFEmE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=e9E9Gdha; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e9E9Gdha"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=e9E9GdhaYpWBg0zfbImyDpxVVm
	IP690Pa53vLdE6hUHWUOOJ4u86LUfAubagnYZsWNkxNv8ptBSAVeIc6HwopqwH42uVCLEB0HEyD9o
	pqmBQzXy93KbgT6zFyZf45BbM4/amui1AFhdkx8iMpkMOZb//HL1MiGLkR3kXnZk57ujiVCKlcXot
	wDhpHqRosB0jvAR/5WbwhII1WRqNFDrz6LOtoW3rpWvHJQSlwcLi9jDs1LhJp1R40vWxzK0/D051L
	DvtaXJkk8QPnVwNRUShpNUnsxpABml739f4s5q01GweZvbsXXmivYhV6MtxvDJZ09DPRdoc14RYBI
	dEljN0RQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkG4-00000006Irq-1E9y;
	Mon, 20 Jul 2026 09:25:56 +0000
Date: Mon, 20 Jul 2026 02:25:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 2/6] f2fs: Update outdated comment in f2fs_write_begin()
Message-ID: <al3ppFbNU5_irmgc@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-3-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-3-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

