Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0D2930F52B;
	Sun, 11 Oct 2026 17:16:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739004; cv=none; b=ud47FDL17j93H1J0oAEPoAyq1+VMYP/Y9DoiqX+cAYESHwxl8X3qF5o9epHgkVkCe9BRvKD44tHSWHlvD9ZOtAaqKGNGMtW2LCss82vlK9VvdtRXiz3JpMZzpZqEFJuNEaQ/h01Nv+ZW6RbWrCacsaYVPiEqmr3a6t/1n5Trc08=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739004; c=relaxed/simple;
	bh=zaVsiEPEnxOoV2qavkSgOCbomZyMxQB+l01yalUtWs8=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=nwdSmjrZSRIoOQGOt2ORq4iZvGqs/ljOuVRLNe6x5ejEBuBGLLw9DNtdK4p/E11d1NtSN5IaF+mnqELDIzBPHDOyvLkLhQwtv8X0naJBtTCOYGShrtvsDS1RtQ3V7426Oe6ATHVHofOUI1TajpeKI+eX7++aTYFkgZnIgUXhX3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kOkpSGRK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kOkpSGRK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 064081F0089B;
	Sun, 11 Oct 2026 17:16:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739003;
	bh=zaVsiEPEnxOoV2qavkSgOCbomZyMxQB+l01yalUtWs8=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=kOkpSGRKqtGGbXXX9rBlOjbUPuXpkAIrt7oKs8UmVyiOaSFT2IOwr7hJkmW9u85Hi
	 yHcfTDyR/K7+WJUUXVjr3OSkni2NsQqQdbnooYmleXQZdfLq5ep6S/EIAHbxPzaMuY
	 mw1vym3yxQug42CW1wG6aJPppoQ9GNOi3SNBOwgo9VZw0ksCYJYzhHNRcHtLIf6pXY
	 +mfrYgNIhq6RKeiWVyTlxAYcSiTp01XpOpJ7XtmyO7uLkVvE/DRwqs4mor/hpH07mx
	 KQpTwsYRx+svtvhofR1A/sHU2NW7dG4dbhnb+1GMbm279QBETGjEv1fRgnHLSeJm54
	 w/1Jh3c1b9ukQ==
Message-ID: <sashiko-outbox-167337@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 02/13] ext4: reject encrypted inodes when block size >
 page size
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
In-Reply-To: <20261011170958.1759230-3-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-3-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:16:42 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> From: Alberto Garcia <berto@igalia.com>
>=20
> Encryption is not supported when a filesystem's block size is larger
> than the page size. ext4_check_large_folio() refuses to mount a
> filesystem like that if the "encrypt" feature is already enabled, and
> ext4_set_context() refuses to create encrypted inodes if the feature
> is enabled after mounting.
>=20
> However, a corrupted or hand-crafted filesystem can still have
> encrypted inodes even if the "encrypt" feature is not set, and those
> inodes can be unlocked if they're using v1 policies.
>=20
> Check this in __ext4_iget() and reject them as corrupted.
>=20
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities =
when BS > PS")
> Suggested-by: Eric Biggers <ebiggers@kernel.org>
> Cc: stable@vger.kernel.org # v6.19+
> Signed-off-by: Alberto Garcia <berto@igalia.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D2

