Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3F26365A0B
	for <linux-fscrypt@vger.kernel.org>; Mon, 23 Feb 2026 13:13:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771852421; cv=none; b=IGIs+gieuHoR0H87NRWiKYlBVjOCb84FNbvkxu5YvuHFoWQ68vXad9TwpNv5pKnCXll0nbvVltOCnoWnjVK2m/tXFTnJFDERg12zWqrTzqHd6AyGHaNlMB5MfCLTL+IfFS9C/odYQJ/J/i2V+18po2nF/go8wfLMo43lAjXZjZ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771852421; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WclwscDWM7nrubniFem0aczcs3XaO8Wq3TRGYMUdl4cBsBdbCT6L1PO1JpFY5XitUiAxbsw65lw3SNgr6q1VoYhxM96GwLYMPMRrdRnXDGaNbQykQC9113Cs72SfzukDupfAXhmO5JB9dYb3+ZDNqmozoHTPbtqrzkj9UT/XyEk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=tq3wFb+A; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tq3wFb+A"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=tq3wFb+A/83Qww07qI+bjaPz9f
	r2HWrPYAc5LQQnj9ppl8hn38dfuzv6Fi1pUT2sew48u+foBbxm44ge+Tzdts6Skoq413eZwM1/YRc
	ihwuQ9U+Ve3vY0lQjxDEvWSUgCEMuAoZ8kcraweAKD0lzpmohmJ8VujbNb/h3W6bZ7h1DVG7XDtTQ
	M7C/05MrA+mPuL0QiaVxIrJ3LBRRWwnesqHgGEUZ+GEE3FzGj8Pfwh5CmPoW/dA/1xs4a0JP83nwt
	XRRqiMurFuzFjsLzvlxRk/i872uxmLy4iKKOMgtaO60nGswzQ7lqvEm67gmBOmrLhSJrw8rNccpDj
	Npb/KWRw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.98.2 #2 (Red Hat Linux))
	id 1vuVkq-00000000Ktk-1ty7;
	Mon, 23 Feb 2026 13:13:40 +0000
Date: Mon, 23 Feb 2026 05:13:40 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] f2fs: remove unreachable code in f2fs_encrypt_one_page()
Message-ID: <aZxShDPF9K4h4ZfI@infradead.org>
References: <20260221201316.22025-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260221201316.22025-1-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

