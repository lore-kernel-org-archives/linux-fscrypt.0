Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A71E361953;
	Sun, 11 Oct 2026 17:20:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739243; cv=none; b=k0z4NdFoJcRE8KrRSm4hw1Vsppf/aK3C7kJJAtu5xBnKykJCxi6tML+jKjTv81M8gqmOPlj9hKH3jDuqF0EhyFoVZAY8kg9/uHewlY9sq3tFjEWd4QPP/2j3tT8XxPbn19LYWvSuqXIaTUwVgilOSdbsP3zHcOFU2QF5JLRkOrE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739243; c=relaxed/simple;
	bh=dnwRWGU411WCLlWDS3hDaPNX8g5WGTCGTvK7eqOZ0tE=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=Mgl5A8ODCCmiI/ubGjJyCx4e48sqOH9eGy2OfZjb2tL2znZ8EyCkBWg1ch7/optGi9taztX37zxwIFZ5Ai8OtiviAusKeiB0JmAW2NgWnsJ0t0iAsbRBrt49F4/uA16+hx9SBod9l9w2cfyEKWLAA9Ko3MqKMMJtZsLI0xQLrUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nX0mARgL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nX0mARgL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F2B961F0089C;
	Sun, 11 Oct 2026 17:20:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739242;
	bh=SD4P9V+fmY6e2JohcorErfhnVWikseRa7fJxZ5L0kQ0=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=nX0mARgLn46ZnyVXCPslwX+r84DVMn4bADg0cpeCAttkOSqix/zTzxW4cbEcLvHQd
	 IGAxXfdryc67lhBrf5AYNQvVZtEkg7Hz3Fy6bhHFCTMhcrq7Xi0GWTpRoLGF3RiPLJ
	 B5vsURSyICU7V984iAJHA3yiYx+MyMLn8j45AOSqgwCm3pkQb+4brjrKt2OavuK6hl
	 a3LONO4/c6OwbvFc2k7AQpAfloAu8mLVqUrbhdbGVVqyCJKe2UboMycrLgWuhQFWU+
	 7YuuX6qI0cwhn8NgfV/upbtR3sObccNzERH9lMoYHp/NaNo7CrnDbcKEGfqtRUFBI4
	 eEXyflZ57MyuA==
Message-ID: <sashiko-outbox-167342@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 08/13] block: split encrypted bios at data unit
 boundaries
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-9-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-9-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:20:41 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> Splitting a bio advances the remaining bio's data unit number by the
> number of whole data units that were split off:
>=20
>   bio_split()
>    =E2=94=94=E2=94=80 bio_advance()
>       =E2=94=94=E2=94=80 bio_crypt_advance()
>          =E2=94=94=E2=94=80 bio_crypt_dun_increment(dun, bytes >> data_un=
it_size_bits)
>=20
> The shift truncates, so splitting inside a data unit leaves the
> remainder with the wrong data unit number and silently corrupts data.
>=20
> The split size is already rounded down to the logical block size, so
> this is only possible when the data unit size is larger than it, e.g.
> a fscrypt filesystem with a 4K block size on a device with a 512-byte
> logical block size.
>=20
> Fix this by rounding the split size down to a data unit boundary.  The
> split alignment becomes the maximum of the logical block size, the
> data unit size, and the zone write granularity, so a zoned write still
> meets all three requirements.
>=20
> Split bios can be up to one data unit smaller than the queue limits
> allow, so a bio can be split a little more often.  The number of
> segments for the split bio is still counted up to the size before the
> rounding, so it can be larger than needed; it is only used for
> accounting.
>=20
> Fixes: a892c8d52c02 ("block: Inline encryption support for blk-mq")
> Cc: stable@vger.kernel.org
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D8

