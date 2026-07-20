Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F2203D45CB;
	Mon, 20 Jul 2026 09:28:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539705; cv=none; b=TPeVv6Z/Ng6Js+wxUcunE9WTdVryW3zhNBtLf62SbM0XzZkVAsKyqMlgDr1dIVy0X1yG1yciFHWFlo2dguD8NNTfvNVTt4wzTPN6Yai1jxaK5MtF4T83QsVG6QTqTX0HxevH6lsFvxQUbbdQr/7q+a1O29V+padK7iC+8tnGJ7M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539705; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rzqH9efQt/5fa0yRIu7Nld5MZ0oA6guoVmsUe/CeUI6zwr6ulq346LlK2Z37rxSswk0gwVkyrWuny8gTleIJijhV/Hnm8x29eDbxmUCgnxSjeWVBRYeugQzlSnaZLPeBJzGmqTINifApBdsf3BajZ4bEOXZN3hJhV0ajMPq55aY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=OWaguAPB; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OWaguAPB"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=OWaguAPBPm9Z3nVlFcOTZq1jS4
	M/Mlku2fNVmaQdmSbshIWhaSt81nKXLNVFMK/Js7inGFGwBmq9RPsDW388O8B5y7tAmugBPkC6d9w
	ezcOUMN9v0lyeLyKeVhH83etLExlm0XjB1xwHXeaBEUIQs78DDccx9Gzzcu7cClPMuws7IbkMgbWj
	1i5XsIVsKoeErcMYYFVaoOyaUdHUrnJTR1NQcmOR/CjjxgZpQ63mauULzSLbIi08kbhxoIRtw0b2d
	ESqTfuOaOCXI+McxtpDAVzHWuwKaFPnfjgmbut2tQYiTYTMEHfb0H/EodpdGS9Gsr1pwt+yZTeSpg
	IhmYrA0g==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkIR-00000006JiP-3LAd;
	Mon, 20 Jul 2026 09:28:23 +0000
Date: Mon, 20 Jul 2026 02:28:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 5/6] blk-crypto: Remove unused function
 blk_crypto_config_supported()
Message-ID: <al3qN94nsr8H2gUw@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-6-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-6-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
