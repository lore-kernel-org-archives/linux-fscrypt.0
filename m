Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DAEC93976BA;
	Tue,  3 Mar 2026 19:32:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772566349; cv=none; b=YPO5Y7MJkX6pBYmuI2ZYGeS60HbKi6BffCsAoK/rhCGGxINFC4jrPEXCq1EBau5Dlggn+cmFhY4K9C22JMp3kOcL388OM0nBxGSckRnHrm9KtmLg0cJtO5fCB9/bUpytnAeXnxrN+2Q+sFtHJlu3Fp1/iJrB6VeXBgoubD+K4cQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772566349; c=relaxed/simple;
	bh=Qvm9osd3NbM07fGmYu29877ROhWfzaUOKV3/F60cpSY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=EN2/2UsxOLli53h55FgkolsaCE/remnvD55kNv/yMIvFYesKyyn2OHCNpDYqOwVcEkkvDgEf96kMjBuKN95KnIxZrCDe3elSeIgJHdiLWKX2eWtACaveVRdofmoMW0qJcqGUMwRJ+Q8Vf63UORJjlqKmcbLlyyrXjrZtGIs2FAE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZKwV9a/d; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZKwV9a/d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 67D36C19425;
	Tue,  3 Mar 2026 19:32:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772566349;
	bh=Qvm9osd3NbM07fGmYu29877ROhWfzaUOKV3/F60cpSY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ZKwV9a/d/CJfcDyWK37t/bnHWgL25knCd9uHssJ0Ji65kngzXcqLgaloo+3kB4I8j
	 i8FISrqjgtBKQ69fQ4BCHwlWio1ftxdCN4deWjlefRbuZE8GEMLeS/iPbEMuVUb8Rj
	 czIkSF6HnJh9hMqMbzQ9LGtYk40h6u8GxJT/7Q6F7DAiE675Fx56PT3ovZUV5qNigw
	 TyzpQUog05Lhe/SLl9YAAMsoov238FJJTi9kPuRfcR2TctnQZVenT+V11sfkrEXVyn
	 K1v1zn4U0Ng2s6k/vOTzmlG+k4wMFkaAz77dIN6w+7TqLrpdxrq++3c9Qyd5Ndd6Id
	 RemVNWcGWNO9Q==
Date: Tue, 3 Mar 2026 11:31:33 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: dropping the non-inline mode for fscrypt?
Message-ID: <20260303193133.GB2846@sol>
References: <20260302142718.GA25174@lst.de>
 <20260302212236.GA2143@quark>
 <20260303165546.GA10279@lst.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260303165546.GA10279@lst.de>

On Tue, Mar 03, 2026 at 05:55:46PM +0100, Christoph Hellwig wrote:
> On Mon, Mar 02, 2026 at 01:22:36PM -0800, Eric Biggers wrote:
> > On Mon, Mar 02, 2026 at 03:27:18PM +0100, Christoph Hellwig wrote:
> > > After just having run into another issue with missing testing for one of
> > > the path, I'd like to ask if we should look into dropping the non-inline
> > > mode for block based fscrypt?
> > 
> > Yes, I think that's the way to go now.
> > 
> > I do think the default should continue to be to use the well-tested
> > CPU-based encryption code (just accessed via blk-crypto-fallback
> > instead).  Inline encryption hardware should continue to be opt-in via
> > the inlinecrypt mount option, rather than used unconditionally.  To
> > allow this, we'll need to add a field 'allow_hardware' or similar to
> > struct bio_crypt_ctx.  Should be fairly straightforward though.
> 
> Sounds fine.  Given that you're more familiar with this can I sign
> up you to do it?  Otherwise I can add it to my todo list, but chances
> are that I'll get some of the subtle interactions wrong.

Yes, I'll try to find time for this.

- Eric
