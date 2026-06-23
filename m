Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD40D287259;
	Tue, 23 Jun 2026 23:29:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782257369; cv=none; b=bFYzMduokagEsIBA4NA4HtPDmAVNpopQ6M0klJu1gI98JK2HgnIgJ4BonNAQATEiFTWUZSzcBXWS4KM3N6DFO4jue+/FYGF0KGqkqDywq26n9WpCj45eD0e7Qcmikb2/J2x7jZH2ZCDZuD13HsDdIKVsdOvaRLc2Su/gMYgp60E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782257369; c=relaxed/simple;
	bh=6FNlUNVpk6pr2bH5t7+dA4PIvriParbR+VVSn21Bu3g=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=McvE7QyjJFjeRYVQwtJRq+OM8ZHMUQ+rzwmQZnK/lbaZ6TOmdgz/uq+8AblVQEwhhJFYgtkRlQKO1UsgCYGXubydZNSHfeskR+J7OdhPO/VlzBDHB+bMsE/MUFBgwEzC0pcjtBYW3m2o4mhL1cY1+mRNCBtRZogJyLq7kVKDyFU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GofQy6/y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GofQy6/y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 339361F00A3A;
	Tue, 23 Jun 2026 23:29:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782257368;
	bh=MG2chgvKp3NnapFIMPyD3yJcnZQlz6w1e1Zp8agMT60=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=GofQy6/y8GikkwOWVw5H5BvZjXigBICa+iuINQbxMtOxZhvOT2Ls1H+bXY62xMScp
	 IBNOI99ejbAtCzGAB3IorEp9ZZznV7VQoZ+Uz4EwmHsqssyJIEaUMCdoeMPlhw4LUx
	 VZDXpwRqth7ttisI7nevSg4tJfBFGmBIhsGf3SnNndqSgb93wrvlkG0iX6UXaXGR3E
	 14TTbmzrDGsBwmlrBpeZn2JZMBaJIZPRD8JMlX2PeqaBQMCnK58AXDLKpyx+XQW17u
	 nA5DuOixt7eSEYiI8fJWOzRnPygC1m+p5Kzd4ozPK5x+9G5ptisx5a/xbqXP01gkak
	 6t4u3kM2zU5qA==
Date: Tue, 23 Jun 2026 16:29:26 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Chao Yu <chao@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jaegeuk@kernel.org,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] fscrypt,f2fs: introduce fscrypt_finalize_bounce_folio()
 for cleanup
Message-ID: <20260623232926.GA7864@quark>
References: <20260622011539.2292553-1-chao@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260622011539.2292553-1-chao@kernel.org>

On Mon, Jun 22, 2026 at 01:15:39AM +0000, Chao Yu wrote:
> As part of the linux kernel's migration to folio-based APIs, introduce
> fscrypt_finalize_bounce_folio() as the folio equivalent of
> fscrypt_finalize_bounce_page(), and clean up f2fs codes with this new
> helper.
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Cc: Eric Biggers <ebiggers@kernel.org>
> Signed-off-by: Chao Yu <chao@kernel.org>
> ---
> 
> Is it worth to introduce fscrypt_finalize_bounce_folio(), then try to
> do clean in f2fs_write_end_bio() first, and then replace
> fscrypt_finalize_bounce_page() later?

I'm working on making ext4 and f2fs always do file contents
en/decryption using fscrypt_set_bio_crypt_ctx(), which already supports
large folios and doesn't require the filesystem to manage bounce
buffers.  I don't think these minor tweaks to the other implementation
(which don't actually make it support large folios) accomplish anything
useful, and we should focus on removing it instead.

- Eric
