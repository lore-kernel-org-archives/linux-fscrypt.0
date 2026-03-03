Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0571B3ACA5D;
	Tue,  3 Mar 2026 16:55:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772556954; cv=none; b=NBIIWZpt1diixhsyUoQEgP8ghhJXg2EBSCRlaLUuTdaQpkerBOUxK97CiHuzSVY51JoV3uWbBOtkJSlV3W54Dap1COjobVX2Vy3o5wN0BmaqaqbZwMF2TJzNYZkPIGhqDJ3rTirebQzy8wTXE/iXoVsugmVLVe5PiOyyC1bUSyI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772556954; c=relaxed/simple;
	bh=79X5NrHvvHxgfkw5HXWmqlDll4X75GNj1FkPLgg6Ehg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=alRS2rD0X+Nbl39PmsAQOppCyrL3/a/rrIE11GV6e0U8KP2uA+czIGtSf0XirJyQPySjiRlS53m7/0RiNqOCpAVCKuEn5sl2/OWN8k0FTg1My13icU2Hm8z0Fgx6jn0dnl9qhcyY9sbAvta3ofuiFAu5C4gEHavLhpel6Bib/9M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D7B6F68BEB; Tue,  3 Mar 2026 17:55:47 +0100 (CET)
Date: Tue, 3 Mar 2026 17:55:46 +0100
From: Christoph Hellwig <hch@lst.de>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: dropping the non-inline mode for fscrypt?
Message-ID: <20260303165546.GA10279@lst.de>
References: <20260302142718.GA25174@lst.de> <20260302212236.GA2143@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260302212236.GA2143@quark>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Mon, Mar 02, 2026 at 01:22:36PM -0800, Eric Biggers wrote:
> On Mon, Mar 02, 2026 at 03:27:18PM +0100, Christoph Hellwig wrote:
> > After just having run into another issue with missing testing for one of
> > the path, I'd like to ask if we should look into dropping the non-inline
> > mode for block based fscrypt?
> 
> Yes, I think that's the way to go now.
> 
> I do think the default should continue to be to use the well-tested
> CPU-based encryption code (just accessed via blk-crypto-fallback
> instead).  Inline encryption hardware should continue to be opt-in via
> the inlinecrypt mount option, rather than used unconditionally.  To
> allow this, we'll need to add a field 'allow_hardware' or similar to
> struct bio_crypt_ctx.  Should be fairly straightforward though.

Sounds fine.  Given that you're more familiar with this can I sign
up you to do it?  Otherwise I can add it to my todo list, but chances
are that I'll get some of the subtle interactions wrong.

> I think it would be pretty safe to drop support for IV_INO_LBLK_32 with
> blocksize != PAGE_SIZE entirely, given that that case already doesn't
> work with inlinecrypt.  The whole point of IV_INO_LBLK_32 is to be able
> to use eMMC inline encryption hardware that support only 32-bit IVs.

That sounds even better.

