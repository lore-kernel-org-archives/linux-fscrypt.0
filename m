Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA1742FD7C3;
	Sun, 11 Oct 2026 17:26:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739568; cv=none; b=eOfn+ASDkdp+nNVMrivEyLnKA/UX4nnvGXqpHIf3LdXUl1O4WIgTIacT76F5axZr6suXJmdM4pcAIu9WGWKJQy8XF/ADHcwNBE5DAhwdH8AANGZ9aGKcEpGb83QvwopLBMtaibut3Hybl2krvzTHF2Gvlu1bDHo1+4cAjXc4i4U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739568; c=relaxed/simple;
	bh=4jEv1Qx9yFjeKil1OJfXmbTcY7VtJ6zldEYTskfvar0=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=BOPyRifbaGAPF4mX2DHY+yxaTkj57ghl3M22kFDhKws0/jgkF5o3EDhLPfgxQcNYa2EzcN9zpE1Iq7wX8DW2Qwq5gxcapFuM7knLDzehyLN/WUoi+2r9YjDsF/qq6TwqVbW6sSsG0/Mo8KKICt+ff3LLl8y9s12fSFU9OmdwlG0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HmfUhQAT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HmfUhQAT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C3CC1F0089B;
	Sun, 11 Oct 2026 17:26:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739567;
	bh=4jEv1Qx9yFjeKil1OJfXmbTcY7VtJ6zldEYTskfvar0=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=HmfUhQAT1qzxLLTTT2EUNphv3EWlsENLVqRWHHHM8NJP3nvkbmOg4niHdPFRSJiv9
	 TNX2cpydJy5z7a3zuVaC9xZNo/R1J3Br2i2Tl4UOe7jAdKVJdcCMFgQDWCv61VUIs0
	 bem/+gnj/p1KUpoXB1K7NmG8Mdwhx8t112oTXKbe5WRKxJPnTYYMJj8zLfaddcOYs6
	 9aPl5+rUxn4iNksydDMs4SAPqXJKZajUuBPgqn4aFOA/p86eNuntcFRObSC8FAPZ+N
	 5sQcTL9YRxAVkD7Z/l86i9zRBdy71Qp/58mX9xUZuCPzKMiZyBWJ1e7B9flhi92IDi
	 ESVZzYbz8MbLQ==
Message-ID: <sashiko-outbox-167348@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 05/13] blk-crypto: encrypt one data unit per crypto
 request
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-6-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-6-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:26:06 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> __blk_crypto_fallback_encrypt_bio() encrypts the source bio one bio_vec
> at a time: it walks the bio with bio_iter_iovec(), which clamps each
> bio_vec to a single page, encrypts all the data units of that bio_vec
> into its bounce page with one crypto request per data unit, and starts a
> new encrypted bio when all of its pages are in use.
>=20
> That structure cannot express a data unit that spans more than a page.
> In preparation for supporting such data units, restructure the loop
> around the data unit, the same way as the decryption path: collect the
> bio_vecs that make up one data unit in blk_crypto_du_bvecs(), encrypt it
> with a single crypto request whose scatterlist covers exactly those
> bio_vecs, and advance the source bio by one data unit.
>=20
> Unlike the decryption path, which decrypts in place using one
> scatterlist for both sides, the encryption path writes the ciphertext
> to the bounce pages, so it fills the scatterlist for each side of the
> crypto request, and calls the same blk_crypto_crypt_du() helper, with
> the encryption direction and the bounce page scatterlist as the
> destination.
>=20
> A data unit is now encrypted as soon as it is complete instead of when
> all the data units of its bio_vec are, and the first bio_vec of a data
> unit is added to the encrypted bio with the whole length of the source
> bio_vec it starts in, as the data units that follow it in that bio_vec
> share its bounce page.
>=20
> No functional change intended.
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D5

