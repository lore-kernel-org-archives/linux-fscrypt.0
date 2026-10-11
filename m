Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10C542989B5;
	Sun, 11 Oct 2026 17:27:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739635; cv=none; b=PAaXo8EUHSngU8S4wEQ2r07PAu+PrD0z79IWMvr5kI9hNu4Ns5+uF11OLCYLpgm86ltJln2QB6QgondYrQ3C5nEQGKcbnEjq118wtA1LBZDg0JGZHEunju/xdB/rQiCuRWKggSsQx35ycz8433wCJbO9MRkCB3DONtiMWgC14gc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739635; c=relaxed/simple;
	bh=guGB/e21XSJGdBmkwyQseye9ugCzEqPvR4ZAVHbWY+Q=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=XGaWRd73P1QWdu/aFc6gCYNWD0teLKYLj1EtfcSGiZ3CrKClix9ypzT90VyPR7/4DVTb7O8c1zd2fr6TiU0upmGQUGvpk+D+sKDqrbVDPRrlznxvdvtBlL3bGeUy9sQvfmc+FUuRoTBNwQghCwJ3pA9KBIlNEfrJd61QJFD2Kqc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J2/SrAZr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J2/SrAZr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C63D51F0089B;
	Sun, 11 Oct 2026 17:27:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739634;
	bh=WF1O8ObFI2G169BSO57qYW5+i9LJkuYBW88TnBCrzdw=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=J2/SrAZrfW58EUIreV/n+cOdmOIYIlLYZCnvR6Z5FpMcG2cFrjJRkTOkxJyXEATeg
	 Jopb618CzC5NQ/5r++KHnNiqu31FmKAqQHHuEjRuq2ztCR8txH9bDsNf2wLyGQIY3s
	 als9RnrBJyHvCcq5hE7PfBDjq+hyyPKIUWzXU+n4aWg/OtuZtGE3Bo2j3InINB0moy
	 xVbyAJ/4emiUyEWD2VgD1KjxWC6p4LHaulDPfRpct3v+7UpkEgBTElHplHIewTENxr
	 iOaZI+3fU7/lYSIRczRQYkA02yRxyQuO7U7fuD9mjorm4yhN4qXKWyrxAAMqB+ZpWk
	 CrGBHWxh1R5SA==
Message-ID: <sashiko-outbox-167350@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 06/13] blk-crypto: support data units larger than a page
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: tytso@mit.edu, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org
In-Reply-To: <20261011170958.1759230-7-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-7-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:27:13 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> blk-crypto-fallback requires each data unit to be contained in a single
> bio_vec, and fails a bio with a larger data unit with BLK_STS_INVAL.
> fscrypt uses the filesystem block size as its data unit size, so
> encrypted files are unusable on filesystems with a block size larger
> than the page size; the write failure is silent and loses the data.
>=20
> Since commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for
> contents on block-based filesystems") there is no fs-layer path left.
> Fix this by describing a data unit by one bio_vec per page: data units
> that fit keep using the bio_vec and the scatterlists in the data unit
> context, and larger ones get arrays from the new blk_crypto_du_ctx_pool.
>=20
> The pool is a mempool backed by a dedicated slab cache, as kmalloc()
> would round the element size up to the next power of two.  It is set
> up when a key with such a data unit size is first used, and one array
> is reused for all data units of a bio.
>=20
> A data unit must start at a data unit boundary (a page boundary for a
> larger one), and the accepted data unit sizes grow to the number of
> pages that fit in one encrypted bio, rounded down to a power of two.
> An encrypted bio can run out of room before the source bio ends; free
> its unused bounce pages with the new blk_crypto_free_enc_pages().
>=20
> One crypto request per data unit is kept, so the ciphertext of data
> units that fit in a page is unchanged, and larger data units produce
> the same ciphertext as inline encryption hardware.
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D6

