Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 356031B3925;
	Sun, 11 Oct 2026 17:22:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739369; cv=none; b=FV5YBR927pgxv3tla9amz0yJSARUBlI9xRMoMbA/sgcaT/U9PaHIZJyIaTBfAd5FSBXE6CjUl01MYHY18yjhmqGdLeXQT/GMEpTclOfLMXmsYRA20TDXzFKlWPgBXEpZdjelMLPnTNnJIBt1ekSmIXctOaUNSJ69mIwnedjIG5k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739369; c=relaxed/simple;
	bh=v0lnwICH8MvIOBo8wW6uPY8Agzc/nqJ/NRdjRkEgLFk=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=KrqzRq+g6QUL1zYMczCbIWLENpvyRfzMF/nwoDq+/K095kiEmV1xokfvaO3k08vlGIyqh7i4gckiu4rv03fu6vSYTsbtrG3sEXPxXssYy6/d+Tylt5ozPoEGlWJItxe8pvHXGLRds2BnYOzJoPO6Z/6MrkDUd182ry0VWqMhyp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VE9hu9tq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VE9hu9tq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D2EFB1F0089B;
	Sun, 11 Oct 2026 17:22:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739368;
	bh=qPXQbGR7wVjMGkk1cuAXZEfWGHqTnD/J9sd10wMpJ5c=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=VE9hu9tqbwqwMqZVtSiWLkC3VvmvjY6VpNwE2NJZFH95UJZn+QOpMxRmb8zTm/UtV
	 lxrBgj8Na88JR1ID6BbDLEs69pBe1oROMvLOtrjWHx/a/4lu32828knNSgbzSN8AAM
	 rbplJftU25lPx8LWw9n4nuolclJ8F8COM8niH3mHfSPQb9t1k0mWzle1N240e9o+L4
	 UbfOYAMPmxE3JC9ghcpbzpMlYveUi6pHRmgRZBOsaPTQ0jvncevznpGC+QgXOeiNWp
	 7MeB5C71i6pNkcrj2Cp0L3smilBU8mIYMQsm6NUlNbtC2qvnYO4XkR5V+sQ7Fkh4Jf
	 S7sI7fnjBMyfA==
Message-ID: <sashiko-outbox-167343@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 12/13] ext4: send folios that cover a wraparound to the
 buffer_head path
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-13-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-13-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:22:47 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> ext4_mpage_readpages() puts a whole folio into a bio with a single
> crypt context, taken from the position of the folio, and blk-crypto
> increments the data unit number for each data unit that follows in
> the bio.
>=20
> By contrast, fscrypt truncates the data unit numbers to 32 bits for
> IV_INO_LBLK_32, the only supported IV generation method whose data
> unit numbers wrap around within a file.
>=20
> The blocks after a wraparound inside a folio are then en/decrypted
> with IVs of 2^32 + i instead of i.  fscrypt_mergeable_bio() only runs
> between folios, so nothing catches this.
>=20
> This is reachable even without a block size larger than the page
> size: when a filesystem is mounted without the encrypt feature,
> [ ... ]
> merges those bios back together.
>=20
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities =
when BS > PS")
> Cc: stable@vger.kernel.org # v6.19+
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D12

