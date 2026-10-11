Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9740E3546F3;
	Sun, 11 Oct 2026 17:26:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739614; cv=none; b=XVp7FC1BDLK+49q6xAy15avp6+1/dknkkQ0jXHObe8/ZRjYtCAVLeM/RQdKHwzYqBHes3Oul0Fd0iYyfkjnpqrjofj2S8knilX71SCwikaVEZgB9gJgJ20Zez9dIbxECsUGPhLC6VjFJ5jF1yVu9zchEz1bhHNSwCpF+pgLVpdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739614; c=relaxed/simple;
	bh=1Sziv7AFwvheSAPK5KVZ0KLVMKzZh2gT7FByMNWYtEk=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=XZFJXEjTW6HIDT9+pDYjzmFDJYf2ZKjueLSgVplroJ+q2Kk0TtvX4NHYUStHJuJwXKsMnClXq1nmfa/YGPm93k/R011GrJxWm2dFrOXXM8ELWY+yX76egXdVmDovClIIBbiJCo5dZKtOtheIVtaoS2cDby0Wz/w2tlukoZl3cQE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZSUSYIsx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZSUSYIsx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 19D3D1F0089B;
	Sun, 11 Oct 2026 17:26:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739613;
	bh=1Sziv7AFwvheSAPK5KVZ0KLVMKzZh2gT7FByMNWYtEk=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=ZSUSYIsxXo+B6wCP12N7+dvVeFuV13Tcvio1Z3yX0YgjAwKzJjZIWMes7mOev8QY4
	 bPT1NqQ47AKGks44OpNCuVPTktClmIZMbg23xouEAMe74gstpNP8DwzOp0IwCNx9ZR
	 G1GR8lal3Dem8gksS3KpXw/cZpqHQeXktgwljJ4uI/6/uQs76Ti/OCNtRTmGkGtaWR
	 KQtLrfD3WReqXv9p6EHCJvHRfeS1AqESEYvQoax3fyme5RyNEx5Vb1BizadWZmjnwH
	 6FCm2tvEo8wcJQ5N+VuV144CDyogT4rszMJ3wpVUVp4xsTGnfFlCUW9HU7/3W8H21W
	 3fALYz6Mr6ohA==
Message-ID: <sashiko-outbox-167349@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 01/13] ext4: refuse encryption when block size > page
 size
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-2-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-2-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:26:52 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> From: Alberto Garcia <berto@igalia.com>
>=20
> Encryption is not supported when a filesystem's block size is larger
> than the page size, and commit 709f0f1f1bf5 ("ext4: add checks for
> large folio incompatibilities when BS > PS") added a check to refuse
> mounting such a filesystem.
>=20
> However, it is also possible to enable the "encrypt" feature on a
> filesystem that is already mounted (with tune2fs -O encrypt). Once
> that happens it won't be possible to mount the filesystem again in
> the future, but there is nothing preventing the user from setting an
> encryption policy while the filesystem is still mounted.
>=20
> Fix this by refusing to set an fscrypt context in ext4_set_context()
> when the block size is larger than the page size.
>=20
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities =
when BS > PS")
> Cc: stable@vger.kernel.org # v6.19+
> Signed-off-by: Alberto Garcia <berto@igalia.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D1

