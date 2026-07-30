Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9419F2EEE76;
	Thu, 30 Jul 2026 02:40:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785379249; cv=none; b=WjTVENP7jeU6Thoynz7XDp3L7kj/mez6Nw9toOG4vVg+Cpm2HkZWkO5D/pHO2yjthBdGtvJPhmCXHxXCOv039uLPeXu/Hbx/ggVHiYbIVRnD7lgmSqmZcT+lY1bdchMW93Ihym3o/o1NoCn92Dfn+A7sUY1WeIkID+eAb8h7gGQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785379249; c=relaxed/simple;
	bh=zPzCbS7LYetWIsU9waQjU0M9xm2NMY/q1KICXl0w+lU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=mx3B/byBBEXKpizuiqVt7izxT06iQcV5lLAkfdzlapyfZwMxtsklnQejGe5A2+s/tcQwKE3iXRXTdXQN/v38r8fk+E9QRcLz4I4jNmBVTSkGWY6lSCyQekuVvUxBBqQLNWL+yZasqTMstscIEk8jSIehpAoaVgcatSW5qPpcM80=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C38+LAkk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C38+LAkk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CD1071F000E9;
	Thu, 30 Jul 2026 02:40:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785379248;
	bh=wWOaXmuyFqvGmfMPmTXpsA6I5Il6YtpMCom9kc1QjTM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=C38+LAkkMr9l2lFhxwNr+xn0l+6DtqqU2Wc6jY1CUmDJ4J9efzReT0CzvDUNAWBBF
	 pGvXP9om6Pzxws9fI16n03GYqVnR6hxuGmVJFTPvGQpeSmDVPjanw4GULAWpVpyZQo
	 vDWoGZdEDYx68J8hz1pt6I/4qFucdCZZqAoe63AP4XS7K1+Nrvn75+d4rKKz4MCmrc
	 EH130k51KO207YFegTAeAVZ2VIrT3fHhK12Wgdm9Nlg7oNmO8AdiYhIxZ1i67u+ymy
	 l0U4F/xnurJhHfiLzR29iqk+3KEg/hY5P5p2/48wYhhguFnMrCxvR7AOLrNL4bSq8a
	 ksuk9PHovbahg==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 6.18] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()
Date: Wed, 29 Jul 2026 22:40:14 -0400
Message-ID: <20260729223316.stable-0018@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260729151905.8303-1-ebiggers@kernel.org>
References: <20260729151905.8303-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [PATCH 6.18] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()

Queued for 6.18, thanks.

-- 
Thanks,
Sasha
