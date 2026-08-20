Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7CEB215075;
	Thu, 20 Aug 2026 04:19:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787199573; cv=none; b=X8mk6W7lBlpUjopwp/wRQFc9Xy4kwaiXNDEDGmMlqt93tD9Pr2P4SBWUmF3dxfaIbtgYT0HTwaeyRVrHsLnBcIfn1uk4YTjThljfJAO/wtzDYAvDTNgNDNA/nTotan61MF+G3iQXA9IVLhfSjURHB5/ByOiPoD8JrKLMWhhkEa0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787199573; c=relaxed/simple;
	bh=+zEdKcdFV5hOUqxqQ+H0YXHTzHEfsJcEo3Xvz4vc4xI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rxSaCwLFVdetDD6UXWu25Afr/tONZxR6+IDVBgMi83MtcwjQ2lZEpIM+2FsjB4IXpWtEnzTR2gG4MS9qdytXPATDfga1Gdf/GpbHORVv2yhMHMLELVLjia5SwOa8lF3Xgw8oGmIQiUwWi1+/rHR/BId4WS4hSOMCaICKK8CpFHM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DOPN3EWH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DOPN3EWH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C3BD1F000E9;
	Thu, 20 Aug 2026 04:19:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787199572;
	bh=51lpfH0rR8sTn3GoVVHxtb1YdxF3rlY2WzMd44ux8mQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DOPN3EWHNxX55yMB2utflKf6ncRJEhRXo4oreHCdjxsmA0a2SAbMeyN3xPfv4oMYA
	 NUQ5/JXbD2P6AUrVgk3wwgD9dNPZCh7QOBBKucSjj9sho7mJlmEwraQmu2HLHHDzAK
	 7E6d+yuMi/7/vcJuMxLdyy0qb7CcnH/ubuYj7gssSJ8Wyep8GqXG74vjPdXgYu0HYd
	 xJxHDyNc7sqftqgw0dA2V+Lfqj1nEWhPCB1lX5a570gj+X165OQpn74y6g5I/JyflU
	 5qvuQL6H2PbdGciBxb5UR0ZnMcb3aKr4/JogFcOuMlzSEXYp+jEBLT+6Mcna6JRbkk
	 uQhdC8Bx3PpQw==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 5.15] fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()
Date: Thu, 20 Aug 2026 00:19:22 -0400
Message-ID: <20260820040907.1@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260818184052.80142-1-ebiggers@kernel.org>
References: <20260818184052.80142-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Tue, Aug 18, 2026 at 11:40:52AM -0700, Eric Biggers wrote:
> commit cf6c993c0feca7984797e634deba3c80342e199a upstream.

Queued for 5.15, thanks.

-- 
Thanks,
Sasha
