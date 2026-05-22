Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13F503B7B76;
	Fri, 22 May 2026 09:19:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779441600; cv=none; b=KsflokWH4fjaCzEU3bF2gE/blc40pZb1KU7W3uzQ7N+8MMpjWo0M3MGIzRt+ws1MYxp6mY8SlyJYYkC3dubt/YmXA/jcehjFiXc0gMSgniqh9IHz5kF8NM5fGgG/T/LF/e90m0+x7k8Vcsk671XDOk3cLjdGJE7khkNkEYKR5Qg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779441600; c=relaxed/simple;
	bh=SJ68KPsEZ9VkEyWr8Acf0SqIVLkr7OFf5mS/PhPMjHc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pagCRSN3nSEEhLvOZ6TF7+3uV4Fjrbrj0J9yKzhIsSoQurKM9t2qAwLZSHrwvVIhsGlE6o/83ukETzj2JvlT6W/QMD2ButvFjC6evw5TFLB0QNb06NxWhuQxpC6almwvP8tiJgCz0oA3tocqBQHNWjOZOAfRy7pjeFxrdh3WFP8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=sZLSITCG; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sZLSITCG"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=jPeJkYiueAxXbzS7AayD31qPpHSAGv/gBivpIVqydsw=; b=sZLSITCGtKSASYmQ1ielmTa/AF
	9G+z6xtTGYDkF8LKOZZFgeww68yytEyckBpeyiZLvmdaJ0VOR5df6xOn93gejjuhIHKC7FaOzK2sS
	nUcvUXsTFnD8/58mvxJ4E08mpzJJTK0wEhQBlUjfINe2Zm9x/xHq8TxtP4EMj07LNxVP/gqMWGeIS
	fMVNrGURpT9pa4/TFQjf1Wyb3DuuHOe2ttT+20cdE/GywxmpJP69S2Dv51KMeeNIM0w5+GhX1ePdn
	03ASIkSvzculwNCZ+EOW+97M2OGf/o7uN8yM8SjOzcOvnPx6X5cKPnnH59ipdxaRiVTuerUwtQJO/
	Lr+7HJcw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wQM2u-0000000AJDr-1iAn;
	Fri, 22 May 2026 09:19:56 +0000
Date: Fri, 22 May 2026 02:19:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Daniel Vacek <neelx@suse.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: Re: [PATCH v7 17/43] btrfs: add get_devices hook for fscrypt
Message-ID: <ahAfvPa_yl6AKZoW@infradead.org>
References: <20260513085340.3673127-1-neelx@suse.com>
 <20260513085340.3673127-18-neelx@suse.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260513085340.3673127-18-neelx@suse.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Wed, May 13, 2026 at 10:52:51AM +0200, Daniel Vacek wrote:
> From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
> 
> Since extent encryption requires inline encryption, even though we
> expect to use the inlinecrypt software fallback most of the time, we
> need to enumerate all the devices in use by btrfs.

How does this handled adding/removing devices at runtime?

