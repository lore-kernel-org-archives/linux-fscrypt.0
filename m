Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC783369981;
	Sun, 11 Oct 2026 17:20:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739202; cv=none; b=K7blGlKSfrCNmATfnGef5/GFexcbWgys7ugapJjOvXMjK8RFKiSYVjf3RANz3Fe1aiPVDFPrJ68Jj1FOnCP710qsVwH9mibVzAyT9YuMpxDmqq1DN6ef0jFhxh53szUSICLGyKX8Fh7fXj2RKlLI70Az8ma2sOGsC9KwwNVIqZw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739202; c=relaxed/simple;
	bh=oc0O8XkvUMP2tzBGbWN0OlBTJKtqt699LwmkipZ+kqQ=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=Ci5WcgBRILVmMQ0JwMtAMifonRLRWblehYR/X9UupPaPQoFxXj2LxSJOz0L+MJYCKwSeLT/A7YRmRyo6K8lF9N3Kd5tlS537jLOHjK8vLfCkjNkLGBG1o4vIZE38nXmxDgC5LDlHf9tR2C+YX/EkOO5afyYwTj4vxO1gPYxcRyg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Smp8JCMJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Smp8JCMJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BFF31F0089B;
	Sun, 11 Oct 2026 17:20:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739200;
	bh=H//fAcidb3kNGKMu3EOhq1Xt98UhoUClQZ/kWGD56DA=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=Smp8JCMJfPregBKAlxSG1gRwbySKDdkXOfHuvVI40KGXQS2JNKMVlKxqeNRJf2bTv
	 bTL/p6TSIbvqZpDWJi7noy4U2ATDMkqgOsKtQzQplL41VbPCel2cf45iKojFgHZOxr
	 rUrLGaiZdULH/cCK4uJF8Sx4VmspHbPMykH5bdKm3yqpVTWE2EJHYXwuWTt5XmMvKg
	 RoQswHyhGsoYwyy/q/OcmDbquNO1x4d1P2tNQwZqoTtv9Am0+SLY14lxZzhdDmREAw
	 TcLS/g7Af/gvSSzQDj5K7oTCziiQ0f31RW/7UleMmY4zsRN+d2tZ59xGSYY9TauX2U
	 aA04tSBtJP94A==
Message-ID: <sashiko-outbox-167339@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 04/13] blk-crypto: decrypt one data unit per crypto
 request
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-5-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-5-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:19:59 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> __blk_crypto_fallback_decrypt_bio() decrypts the bio one bio_vec at a
> time: it walks the bio_vecs with __bio_for_each_segment(), requires each
> bio_vec to be data unit aligned and a multiple of the data unit size, and
> decrypts every data unit in it with a scatterlist that covers the whole
> bio_vec.
>=20
> That requires a data unit to be contiguous in memory, and cannot express
> a data unit that spans more than a page.  In preparation for supporting
> such data units, collect the bio_vecs that make up one data unit in the
> new blk_crypto_du_bvecs(), and decrypt the data unit with a single crypto
> request whose scatterlist spans those bio_vecs.
>=20
> Add a struct blk_crypto_du_ctx to describe one data unit, with
> blk_crypto_du_ctx_init() to initialize it and blk_crypto_du_bvecs() to
> fill in its bio_vecs.  The array that holds them is sized for one
> bio_vec and lives on the stack, so a data unit that needs more than
> one bio_vec is rejected with BLK_STS_INVAL for now.
>=20
> Also add a blk_crypto_crypt_du() helper that en/decrypts one data unit.
> Only the decryption path uses it in this patch; the encryption path will
> be restructured the same way in a follow-up patch, with the bounce page
> scatterlist as the destination.
>=20
> No functional change intended.
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D4

