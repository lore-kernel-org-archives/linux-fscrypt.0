Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31A3A1B3925;
	Sun, 11 Oct 2026 17:23:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739400; cv=none; b=uSM0Fdc2vr/2UIA0gyaTn41GuamUoQ7EMhZ7lOwNHM6RkslYIZxpub8935HCeMlH4vnlcnAUH9AIvvT+QqlsVSDXp0WL/wZMGvtFDEPGF8XRJsMj2kjEukFPDbVtgqOFK+vVXX7gmMAslafwEoM15M+/o6o2YtYC3uey3CBBDaE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739400; c=relaxed/simple;
	bh=pYpJEeLM4sGXvJvksKNy23CjoQS0xkXLE8ZWr6Bv1VM=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=lOCuTktHHFMbEzOOLFx9tmLgJodyxMH/81TNFbbQRqoa1ps9Ooa45SvU2pLUVFS/ancc5XLkchYBQkiQz21YwizJfGYQeKYcYMUpcPGnZDJnIwUexiUyQWG9pCOOieOmJLZuOk+ufkCrrJNd7h0/HUjhZmOpcuqwm9ZyJcQsO6s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MMtzEVUW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MMtzEVUW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6CBD1F0089C;
	Sun, 11 Oct 2026 17:23:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739398;
	bh=Oj3EDVKaoVWJOHyTjPFoJ0Wq+gpKoTjloESsko8cI/I=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=MMtzEVUWhc175UL3Bku+WUaIhJTe1GSb1/v8m/BAR1kJN6t8FnatVQNDM4lBB3Q9o
	 31KGHuNFayXK4BmMI66SC48j/yw5YS2016WdjXpN1kdsUuFHarZE5OoDDRt2ZI94rX
	 9jsNAukt3HQ9Mhma8vT8Py+FMqy9QCD+wUpY6g8YEJoHkHz8y1/gClVR/itqv8tnVf
	 BTFpNEh7XE4J4ux+QHPqAUigt6toQ108NnijI5ZZyekvJFknGQs4KaG94tmWcLoknN
	 3ooVXCwS0xB+F7bn/Sy1Gkse+kr0ZqXx5R2SCi5ubB/Yo23jipDw8fNgfNTz5qkpJM
	 ZYa9g3g08xbEQ==
Message-ID: <sashiko-outbox-167344@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 13/13] ext4: allow large folios for encrypted files
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
In-Reply-To: <20261011170958.1759230-14-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-14-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:23:18 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> Encrypted filesystems keep their folio order at s_min_folio_order,
> because the read path could not handle a folio that covers a data
> unit number wraparound.  The read path now sends such folios to the
> buffer_head based path, so drop the restriction and give large folios
> to all encrypted files, including the ones whose block size is not
> larger than the page size.
>=20
> Writes and direct I/O don't need the same treatment: ext4_writepages()
> checks fscrypt_mergeable_bio() for every block, so a write bio never
> spans a wraparound, and the bios of direct I/O are cut at the block
> size.
>=20
> Performance:
>=20
> Hardware: 96-core machine, 3.84T NVMe, 512G memory
> Filesystem: ext4 with a 4k block size, encryption on the fallback path
>=20
> Buffered sequential writes (1G, fsync) in MiB/s; medians of 3 runs.
>=20
>   bs      Before     After    gain
>   ----    ------    ------    ----
>   4k        1118      1162     +4%
>   16k       1260      1756    +39%
>   64k       1272      1977    +55%
>   256k      1308      2081    +59%
>   1M        1260      1455    +15%
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D13

