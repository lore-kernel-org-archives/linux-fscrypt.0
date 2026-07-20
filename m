Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2B7433120A;
	Mon, 20 Jul 2026 09:22:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539358; cv=none; b=WGco9bQdAE6UrTVH7aOcfzmSyFhSDAwFAidOC3G1U59CHi3OQhsYqVyyuHqJGrNVlk6iuwcbJkos2kX+MvDlXnAkTBMNDXNCkUbIisHOS/6n3PPsXDcFJzJNKHLnSsByF1K+Dq9mQHfcPAxETm/P005PmUhaTh+77vTFXzCuiJM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539358; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Y5JLH4/05nMr7Haqe8Uc0yxGJSJJcho+7YpHU8BuRWiGzNGY/shqBT8z7VVVnCoMXMV0j8NZp7RaqEZpLlzRHc6uJBJDpeg6SlHt5a/pj5rEXLWD74nxHXrTny5ec7OXMardmFkah55pAnssXK+tBg6gkOSBHVUCMn2ir+qVCKQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=FomMcC0V; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FomMcC0V"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=FomMcC0VtT4lbcl3HHNYMLr8rb
	Djju4j93w7xxijq2VOaAMKiLc+3DnXap1HUgryLBtOVGxO6e8LMLIYf8RmwtZg+cBnmZ6amY23EYK
	M+3C5EaE/2/WOkIKrFeTEwnRvtrDv8Qn1h963G1TDFrFtD/2Hl4l5rEKSMG58nbZKk/LSr5b+0F9T
	pdk/cNTJJv3B7lhb85WwYwLcRuDGL/9BrcI9vsqfOc6SmJzOHaBaDHfDCkIVHpBV865aKiG1nPoBq
	x8WzanuudPKLkHzkg33uawVIiIZVI2iKkD0Jqj9+17X45o7yuW1Vymi/pChR8BI0NXddBEOe/fSza
	1QDJJldA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkCn-00000006IMU-2Cwh;
	Mon, 20 Jul 2026 09:22:33 +0000
Date: Mon, 20 Jul 2026 02:22:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Add missing superblock check in
 find_or_insert_direct_key()
Message-ID: <al3o2TQ29wwxVm0a@infradead.org>
References: <20260719033120.122120-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260719033120.122120-1-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

