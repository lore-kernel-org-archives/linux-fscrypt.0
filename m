Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BBAF36494F;
	Sun, 11 Oct 2026 17:30:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739821; cv=none; b=s385SvO9k0UxdhoiUAA+SSTkVGCh901xlT9TyMlMIxVCOdaPpI/h+gPj20nT7hfYleWmtfVpUWAnZ713SMyO7LFHPYf5srIuW5N7DzUn26kb59ejjD4a9K/W3A2BrDtGjlFMj8X9gbzFHsbYln9BDADPIs+TpOTxMAzrcos3FYo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739821; c=relaxed/simple;
	bh=+fPPt/2aQ1G2ZvvUq8orB4lEUzn/TUHLhuRzC1sNDyQ=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=b3v848qwkAzppecdd/rhNKGK7BqAUYi7ifyWhpgp0goKsLIRz4lPi9jB4MgwJVrGAKf1zB7stelcralPnFxuWvxjX9FmwPFs2HeAu/VgKQV92t2a83LIK6sOiC1hcT53/ml6EFa7czyp8ur5ejE7JfiNi808kbHOlAlNUh9ERHc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BW6StzSm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BW6StzSm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99D321F0089B;
	Sun, 11 Oct 2026 17:30:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739819;
	bh=NYU7FOEBMic821rZTpgfLyf/WTujF/kjx/PAJBKKlUA=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=BW6StzSmJ2ZPfO4GEZrXQab7ZF+njwnpLxS7rWFB1esKYT6c8HkfdhPfjHRlWtAgw
	 V8svoRfwjmQ8CBPDPGuqhRul7QFqaUmjp7fD9iWsq+HnvbW09mSQg3WV4Lww7Gq/p1
	 DHkgST8oIMAKUmt8XHWmUVlqU58KCRwH4bUx03oL5rMTGF5Il2dgz3suVcLyITzuPJ
	 TXIxpE8s2rZWQVo5RPBBxVfk415XwdayuU4W0aUCOCTRZCFHmd2q7kETnNqvX2Ub7U
	 s+oLOwFk53cUIp//nSzFi1zduuiRj7M2CXDL9hJbeoObBVTlVBRdsFl9WXavLN+1mF
	 cpZgQZzzMlM3A==
Message-ID: <sashiko-outbox-167351@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 11/13] ext4: allow encryption with a block size larger
 than the page size
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
In-Reply-To: <20261011170958.1759230-12-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-12-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:30:19 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> ext4 refuses encryption when the block size is larger than the page
> size, both at mount time and on a mounted filesystem, and refuses to
> load an existing encrypted inode.  The checks exist because such a
> block size needs folios that cover a whole block, while file contents
> were encrypted page by page in the fs-layer path, which cannot handle a
> folio that covers several data units.
>=20
> Since commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for contents
> on block-based filesystems") file contents are always encrypted through
> blk-crypto, and after the adaptations in the preceding patches, both
> inline encryption hardware and blk-crypto-fallback support data units
> larger than a page, so the checks can be removed.
>=20
> Encrypted filesystems still keep their folio order at s_min_folio_order;
> allowing large folios needs additional work and will be enabled later.
>=20
> Performance:
>=20
> Hardware: 96-core machine, 3.84T NVMe, 512G memory
> Filesystem: ext4, encryption on the fallback path
>=20
> Buffered sequential 1M writes and reads (1G, fsync) in MiB/s; medians
> of 3 runs.
>=20
>   job          4k plain      4k enc    32k plain    32k enc    4k->32k
>   ---------    --------    --------    ---------    -------    -------
>   seqwrite         1981        1044         2062       1399       +34%
>   seqread          1139         931         1791       1793       +93%
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D11

