Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62A083D4117;
	Mon, 20 Jul 2026 09:28:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539688; cv=none; b=lDzkJSZDa6hUUdxKBHHOZlbwJkwDngDOLA45Y2SLSFByNbRa56Xuxb5mChE3J0KmvLryaLLZOwMzpt0MoTkJfktZ4jNVCjW4iPi7MVe83MfsfDX0b0lyllpJA3Mv14T7+S6mXMQDHkqrxMt8gfwJ7toOsmAEsuhFvy2PmexXdn4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539688; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=PDUbSV3bIG9yujfLwtGh3iXCfdcC5XrKOIGKnQq70kBeIMK9vWpkZxdHbRqSMbBsdjxF11+ikssHglADLoPlXqikbNQ9Trki9KSfxWwKLRSjFQSks3CJhNG/fkvvwolZ7YD9L1PDRgQrW50dg4Ar6STldleq1Tkuka42DezXNAM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=jRCHmPR4; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jRCHmPR4"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=jRCHmPR4OkH/9bKuKrO+WuxEZc
	g4USR9sRCQItSSArZ7S5UR5A2/NwP/iU1OQwgkDJCmXkt+d16x+8kzaUtmDXQquxqFtULp4SzGmMP
	1ieKiDKuA0Ssr/owKQJiQDxlRtH8EIz/r25xhANC19AMpuY5OcN7+jpOl06G7N5eXux7DpDEXmreI
	Lgle4s7iG+45l6zm5B5kCtOWpyfnWEFkyzqCOgYxEL3KsGNv3ZV4K0OBsEyzO/YLqo4mxTvEkZgBN
	qJEcAoW72p7CkhJj0v9PicqJjHwIx3WL2xWKFSFypb6IpRXjlufQCjFFMSr6dARUxu+7tFuThMwZx
	jQwCAZJw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkIA-00000006Jfh-3TrC;
	Mon, 20 Jul 2026 09:28:06 +0000
Date: Mon, 20 Jul 2026 02:28:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 4/6] fscrypt: Update docs for data path
Message-ID: <al3qJtv65Wjuuyp-@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-5-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-5-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

