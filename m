Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03CA3DDAEF;
	Mon, 20 Jul 2026 09:26:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784539576; cv=none; b=DS3Q3MNjjw+370NY1tQoW3S4yjZJZulQERrxNPjCa5lYyqROr5ZDOLbIA2bMTG/p9DwlOb1lpsI3V4OhijKzCyP53VxWbTGdmFrAsV+m1N3hsifTRAjYNhV76RCmO03KbozfPTzu8A/xousKEhBIL7rqwrB+Baa5/rTQJPwH32M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784539576; c=relaxed/simple;
	bh=tiCx66AlGna+xBmrBs7eIX/6/nKY42n38/7bfdUQq3k=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=H3+eLhJ0PB1JfOh7imXVldhjhsc3F1hWijL9n78YnOu+uUG0LC1bLPwrUGlWJWClwfVxuuTb2LHt3D2QzvhXFBQiSjimuPN2LYg1e19c4Te5pNnnHPHMkBrt4ljOMSNS7M9M0Vu8ig5fk8l4bNByOQP8+3jYpMopr1TeDaZh2Ic=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=nxqhBiTG; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nxqhBiTG"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=tiCx66AlGna+xBmrBs7eIX/6/nKY42n38/7bfdUQq3k=; b=nxqhBiTGZK4biDel3/DKz1yQ7M
	b3hgqbOtQSwSED8adwzBwgMT1x4AXauQ7C6bipD8at2zj2eFKlGa0br3EaQWy4h5yGiudeWBUoX1/
	tu42xkd1LEd23DYg444Zw0dA8hQGc7eVe8Pe1L88l8j7PLibWXIwBwjOE+pDiYZvaUU6gbyasf5h6
	31dTHduQIlu+K5R0nQemjDB1kidUhgxX1feQBVjjKKJAhcTtzvFMt1jRBDPcQx1lm55YEooFCzLHm
	WQlVnfrMHpT6kwdUokaA1tx1Moj4sAzoMwKrAPJiRbI+5GU8lowqGugHmKz4tBA98QlI5OPzUuYo6
	oZJepCYQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wlkGL-00000006J6X-0XAL;
	Mon, 20 Jul 2026 09:26:13 +0000
Date: Mon, 20 Jul 2026 02:26:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-doc@vger.kernel.org
Subject: Re: [PATCH 3/6] fscrypt: Remove unused function
 fscrypt_finalize_bounce_page()
Message-ID: <al3ptX9UJDgCfj7j@infradead.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
 <20260718214655.63186-4-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-4-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Sat, Jul 18, 2026 at 02:46:52PM -0700, Eric Biggers wrote:
> fscrypt_finalize_bounce_page() is no longer called, so remove it.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

