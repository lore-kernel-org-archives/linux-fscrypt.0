Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E9F144C672;
	Mon, 20 Jul 2026 17:43:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569445; cv=none; b=ZNDIICeorCWMa1u52scZ1VePN/XBZCMdmQEE9Foo+LZwgKgntSBbMeVCPPAaB/kvHX6DS1bUQt0kotBlZ3IakqoHRUK6BH/zDTUvskqUYMYuCd9r0dNfC2dUOqIFGlW4OithnNgLuNleHUN8iHvpeZYfnEzyNCm0XRzpI0ayRX8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569445; c=relaxed/simple;
	bh=SbujFHaK5m2//YKAMCG51gKVIImMsHPC387NjCgiOVw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WD/wLSD1I6HEVjE7DC6bKVGSXTRHNyrXuX/pdVLKbo6NVDukORL6jyBWkeq2ZSUjP3L8VryDpUDLTXloKW5MCbwebJQh8C4m8RT7Xp84RURN85Ou9vVhpxTLkTfIfqFSF6wuXkKqazdXiTYLrlzaDp0RHgRNWCS5tlJX4mDctUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NHdVmGWv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NHdVmGWv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4501E1F000E9;
	Mon, 20 Jul 2026 17:43:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569437;
	bh=RP+TS9ppCdXYY/44nHU15MLi2hbKUCvk+juRAlVs5XA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=NHdVmGWvjoGKuK/wead7GtVxZq90L6N9zGUQshGVF2UcHY8n/C6nGC5wGEB9sI4/N
	 DNTqSpjB1oJVIZ8ongqH4W5GfD+5c4NBnP4Io9DtJ2Dzjyw49FpMHY09iNiWWL6/do
	 BW+EFFlSQLIOrFofF15bpCuzlsqkn4d1TH392FjgrwbpOA7P+o5xTlU+wF9cwoYcS1
	 rPLBP6AlES47Z8viBBSpP44E8jCQB+GT18zyWnMVc9YeJ8luqK8lTnGGl5qVYCZoPd
	 xNGLbGJzlcGa9uw2JCdasT8bqucbtdASl74rVZpn2OVv4PHEP1/7us+vA/ADBp/UJm
	 MbVieH7L/Di0g==
Date: Mon, 20 Jul 2026 10:43:56 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org
Subject: Re: [PATCH 0/6] More fscrypt and blk-crypto doc updates and code
 removals
Message-ID: <20260720174356.GB1865@quark>
References: <20260718214655.63186-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718214655.63186-1-ebiggers@kernel.org>

On Sat, Jul 18, 2026 at 02:46:49PM -0700, Eric Biggers wrote:
> This series applies on top of
> "[PATCH v3 00/17] fscrypt: Standardize on blk-crypto"
> (https://lore.kernel.org/linux-fscrypt/20260713023708.9245-1-ebiggers@kernel.org/).
> It gets more documentation up to date, and it
> removes a couple more functions that are no longer used.
> I'm planning to take both series via the fscrypt tree.
> 
> Eric Biggers (6):
>   fs: Update outdated comment for SB_INLINECRYPT
>   f2fs: Update outdated comment in f2fs_write_begin()
>   fscrypt: Remove unused function fscrypt_finalize_bounce_page()
>   fscrypt: Update docs for data path
>   blk-crypto: Remove unused function blk_crypto_config_supported()
>   blk-crypto: Update docs for blk-crypto-fallback motivation

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
