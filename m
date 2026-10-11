Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04E4F2FD7C3;
	Sun, 11 Oct 2026 17:25:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739517; cv=none; b=qLR3xfPIwC1y282VhTEh34FKoamKO+uAylmOvEOHcn3g7+n+D1CImukGNI1Gx/UDU1ch/FKfseaA5RGy0wSf7Gkl83GrdjTE4Le4IrF41I29qApsOa/otRnLYgJjgf08vmZUMYco+1j4QZTNdUoFerWjOGaCcfc2JgSsLS2Yd9Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739517; c=relaxed/simple;
	bh=jIxJDFQiZGzw/PCfavsGFxQ8DuCxgNKEdhp5TRmjSqU=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=f8CBQvn/EXAi3u9SM/86aMpF0ycOBKOu4t4qEz/PdCf5C3VBDtc1k/gUT1fY9x5MZH6dSqwPsan8+NckDDqhLmL0eQjQE1nrvQvx64V9OmoI/PV/PI18Aa8SAYUq30o6Ho6mcsJ0oUWk5pq7anMK4+wNi5oMG6F7SY7NCSuqshg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RYsYce5T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RYsYce5T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B3641F0089B;
	Sun, 11 Oct 2026 17:25:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739516;
	bh=dZuCxQRvQCO1UR7Jx8Ch8NljdeK8gwRIza8EqD9SKSs=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=RYsYce5TtlQ+6c8Xdp4QCEI0lxXF2z0CR5cnY4OWLuW+Qt4LLs9H0Ce/CjpHYF03A
	 NBQEQohFojr1ZNkkutSqjWBEJmuQZryjtH5WvX+lfKD5GhsGPqsc6UI/euFReG3Dlu
	 /veCa6mJfnNFRJKZiSmQgorWwXeiMEznsUWjLS7DrWahJ1teEzdN3ZNU013nz/U1aj
	 b63VSHJ7da9iIAcmDkPaTSUUfxeRtyHodBGbX8/rDEX7qLbladKMo6Fs41otemUGrb
	 Yr5GTwFXPR98ASEYkTOoxLKVIik09YIxjJYKTUITq7UcqhhchKSNd0XjxV7r3w7Ppr
	 umD1LaCKiHduw==
Message-ID: <sashiko-outbox-167347@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 07/13] iomap: align the direct I/O bios of encrypted
 files to the block size
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-8-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-8-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:25:15 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> A bio that carries an encryption context must cover a whole number of
> data units: its data unit number is generated from its first data unit
> (see bio_crypt_set_ctx()), and it is only split at data unit
> boundaries.
>=20
> iomap attaches the encryption context of an encrypted file to the bios
> that it builds for direct I/O, but it only cuts them at the logical
> block size of the device.  A bio ends where the bio_vecs that fit into
> it end, not at a fixed number of bytes: the extraction stops when the
> bio is out of bio_vecs or when the iterator is exhausted, and a
> bio_vec can cover a whole folio.
>=20
> A bio can end in the middle of a data unit, and a data unit that is
> larger than a page makes this reachable without any misaligned input
> at all: the extraction then stops in the middle of a folio, and a cut
> [ ... ]
> the logical block size of the device on to iomap expecting it to fail
> with -EINVAL, while iomap checks only the file position and the
> length, so such a request can reach bio submission.
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D7

