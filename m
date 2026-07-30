Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E2BF37CD3D;
	Thu, 30 Jul 2026 02:40:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785379252; cv=none; b=cMmCZUdA80YCH/eMc7DHuTbElAXJi7Dh1y9LWUjM2R123ERFv7dxV9o2bg2O+/GdBRJHFM8LuPLnPt/sBpTbN2Bc/y6vy0wtzCdRBbX0e6nWtBTqXSBfNTt8kABY1KQ8MyQFfj95ogoYtlzr1Dg0mwGXJ9Cseyl+rsr5oATnvuo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785379252; c=relaxed/simple;
	bh=G2SRGJ0uHJQPHFnt58Iw1ZCttgLrjMzxJnqMT/ZAptM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tFDdk2d8wPf+01nxTjNy6jsOlbuhtBCu2Wc2HhfopM0+Nymi4Km+SMlx29cVQbjSh9fpxhcjr7iUf5nbdkMBtGTuWFHrCHniZgBge1vdZFxV27ZxFHNRUeIPOV6jllzh1+xIVY7D0JcCZDG60b98HLE4WFcrCD828flW6kxOeFw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M9+xhoiS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M9+xhoiS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98C9B1F00A3A;
	Thu, 30 Jul 2026 02:40:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785379251;
	bh=3EqODoI/vfXaEcbRz5tjhLuRmz5P6DhFL1Bj4v+bvGo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=M9+xhoiSMYHo/OBtz3AZqVOlhu/gJJPXi7IauLNkPhDEZQlhVfEHMZs0WBq/g3QPA
	 dwDXaXTK2kPd1Z/MrEkSCIu0MxIL91GkZXFjSIlLsv4q0x8lU2lUsgGzgBZefhSAqt
	 pMbf+CyvkHjuvc+ykkRYeyBltTxXrPpa3eNJ9GeQjpaIWRpsZbJCdlq/zbJ54hEUz5
	 GqsBzQVPHp5YW1sqszCEVMtXTWwvJW0Kk/+HUupYNYOqXcACy+h9JVaU96qMp18UOf
	 pYhmklGXkRBLcSEcUuv6nu/wXHrNvln1q+EO15DAKhYDjC0WCTWTlxMQRGgORWdJ0u
	 3fBbsYTRBliKQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 6.1] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()
Date: Wed, 29 Jul 2026 22:40:17 -0400
Message-ID: <20260729223316.stable-0021@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260729152655.28111-1-ebiggers@kernel.org>
References: <20260729152655.28111-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [PATCH 6.1] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()

Queued for 6.1, thanks.

-- 
Thanks,
Sasha
