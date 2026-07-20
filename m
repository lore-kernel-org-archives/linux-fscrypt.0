Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F5C13D45CF;
	Mon, 20 Jul 2026 09:28:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539729; cv=none; b=YHGXE3OHC7hdHPlzCiY/rzEXPBL6swkBpR2vHjzd+kKRpYd15IVmHWMOJhE10C8h/nVqGWo5UmpsvQ8vi6AKbMfU4wyuDrlH6g76BdXUkeUQtWU1KwOvDCktKaZXG7SdbBc7Z2PA9+LWqJeWaj5eEmRb5t4+jwLD6zy+BpJDXb8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539729; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OVRMsXg7gfG0Yw3tyucSIKofokPKf+WyvKLrFjV2Fg0Yx7eXSlw5HBvjE7sN+lVzH8C+hgT2esW9eIuUbeP1qr2jAaY6hr9wzyNZvD9RrDts12n0i6eV1SoyGcqZ/AGnQztEq5qiNsIkHnbhFEoz1KInaJlr8zO2wlsTAGgxH2M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=WLw8smQN; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WLw8smQN"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=; b=WLw8smQNszrz2YbXzshZ0vNE6e
	eK2eFCdXIVTHyOsBmDO2CBkP7Cw3kDolFMxstUUDi87LJ/yzV0KcvC3GBCuSW9drBykPUjBpkRtXe
	u/NHJnsOESJlKaxFf4RlM/aTOsJz+flyqwTPryE5HsaFhspXQsjHJUZKj8bDC71JheIXij8TXA/Jd
	gkG0MdlxNcyH0ALT1k5BDDYkVDCh2VD/FmHzoG0ZFeTlwAElED9YENHwn+Yv6dFjDrOl7/E7YgFz7
	+p9Vt9dxb/GnHB3fTpD7KdLmtu1AxBkU+ybwnVZeMJEhxt6yCuTj7NrbMn77/bnGXtgvGhe5M2MbO
	ylfAhwaA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkIp-00000006JoT-2VUp;
	Mon, 20 Jul 2026 09:28:47 +0000
Date: Mon, 20 Jul 2026 02:28:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 6/6] blk-crypto: Update docs for blk-crypto-fallback
 motivation
Message-ID: <al3qTyeHDJ2RXBK3@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-7-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-7-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

