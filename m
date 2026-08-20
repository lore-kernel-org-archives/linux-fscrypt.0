Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 551BF2F7F02;
	Thu, 20 Aug 2026 04:19:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787199574; cv=none; b=TjxQiwuyVxO+s5bkYZ5Cx+vbVGi3Gk94LpMW0M1lT4frQB4wBofKZpFkMtdLRrUKqJ+xKw2wv/5QiBJPF48Z7nAJ05XfYj5YGxwYpnnoBiiVdC+f0/6YaZ6byI9+vlVB1KgjqfmV34J6JEKiiwK3GhyfUr+Eh87QVuLGMkA68Ik=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787199574; c=relaxed/simple;
	bh=yqRH8GtvVQTmDYhvaOflztAX31gudXro+8rxQP7OHLE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dgHUsCUfOotshS2Uhz+iVyYQf2YAlb/eOqTTlNsakUQGVObh9w70ZgTIpipw2BxDpEPWnDlnF2B6rLMUBzZ0uRTSG97FpOdST5HX0/dphSAATPDSBgN4ZpHVKfw1/nuAx2GDtwrmz4BBzuAV36xm+ciriBNQXKQ6nPKwz3PTuKc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KhecQZ7T; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KhecQZ7T"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7068E1F00A3E;
	Thu, 20 Aug 2026 04:19:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787199573;
	bh=SQy1E+wP+JlSVRSFLYABlcoVI3rDiJOmU2Cj7iYxmXg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KhecQZ7Tsq3QGKLfbgebBz2DuT9BYar1o2vMbRrW+z7jprZn2jemC9Y1d/cL6mavJ
	 FFFLiuwmj0uEeMKA7J3FjbbWuxBMDLo2gjR3EfaqEbJsWCAwPFPVXAVL+VqBOr8uAK
	 rK9ILvdlNbDQBKC0UwGD3mx56nJCUmXsxPNU6BjoUR14NAfRi9e3lHIqGlB7XqAylv
	 eSW7heBVAye9Neyuj+aki23ipdD6u39Z45+AkYRPbUbMRuL56LUBQWlKX/fXovHwhv
	 6F1a9Ew6EkY5kL7L//vAUcJwyxCuSwSQOkUqTXyM7Sl6B0rh4x8qnJ5z4QRjyaajER
	 GHhhq/wqfQG8Q==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 6.1] fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()
Date: Thu, 20 Aug 2026 00:19:23 -0400
Message-ID: <20260820040907.2@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260818183821.73242-1-ebiggers@kernel.org>
References: <20260818183821.73242-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Tue, Aug 18, 2026 at 11:38:21AM -0700, Eric Biggers wrote:
> commit cf6c993c0feca7984797e634deba3c80342e199a upstream.

Queued for 6.1, thanks.

-- 
Thanks,
Sasha
