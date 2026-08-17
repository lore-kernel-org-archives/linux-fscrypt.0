Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7D772FDC28;
	Mon, 17 Aug 2026 03:25:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786937123; cv=none; b=c1cIkcjFU1nkT6FG1HaqY3v4MTdHbZkev+eaOWcl6/QqCIQbCqrFYQkTLvpt70t6QzzzWiK1XcmCpAg15GLvueWMuXMdBzLnZVF2Xbl4XYQ4mD2hjGEC2j3ci/SRaNXrjkVlBHEShH/JxtB6x8gb7Vud2X7mYgs4t6oczl4YXos=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786937123; c=relaxed/simple;
	bh=2DlhX5N6VdVhf7azZIpXl3c6wsXf/1UA+YlfKR4KyrI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Q510705P4di6KiiZIk18yE7UILx2XyQeSvJEyuM+pT/qFXegPvYEJiQfp7l8eRZ5QWCwFZxWFhEPSyRpnJraWKSbQ8jQqvO+Gb+j1gtEiNq/wOorEcYjLthCd1g3gwVJymFSKYy9eQbEt/GUlsF4n6d/igXvw1uikI2SArQP82A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ntWpAp0y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ntWpAp0y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 92FAA1F00A3D;
	Mon, 17 Aug 2026 03:25:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786937122;
	bh=kIyxsQRwXPYJMW69I/QC+zsCrse+OYL4jC6euAdFArc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ntWpAp0yOW0h/tmSpM2V7sq77+yUtmq4RD4TrncH1lWJOYkfYU/gt2zvS83kQXwIf
	 uAepRrsh5AVacHNIP6YhrENUt4ai6nDcmtDarMFVW2++EzYkV1Ao/Hl6RDKeo72+wu
	 ni9TaQMiRxwvPED/mUUxTVPk2QqpDvyWQ9+3mneqr/RAHMuJu4kxpn8dNERww/HwsJ
	 m5QBGHXDXmwCFTrBKZCrZm1kaCheKpXt04R89qk6Pcs0Rnznu89L2gQrYj32JjIjjd
	 jG+d+cXwj6Z8cSfwHtp7NG4p7u9v2HJnSG4AgyeHBrKjpGrwFaXIJi7kBQ8cW+mViG
	 oaU9Ec8vdxC8A==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>
Subject: Re: [PATCH 5.10] fscrypt: Replace mk_users keyring with simple list
Date: Sun, 16 Aug 2026 23:25:09 -0400
Message-ID: <20260816211000.3@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260815183141.101727-1-ebiggers@kernel.org>
References: <20260815183141.101727-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> commit 696c030e1e3438955aba443b308ee8b6faa3983e upstream.
>
> Change mk_users (the set of user claims to an fscrypt master key) from a
> 'struct key' keyring to a simple linked list.

Queued for 5.10, thanks.

-- 
Thanks,
Sasha
