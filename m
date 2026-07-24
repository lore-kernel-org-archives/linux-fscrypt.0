Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D1263C8C46;
	Fri, 24 Jul 2026 21:04:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784927063; cv=none; b=ipv0GZSsLy9N1Gu6oqBt3wSSSYfTE9qrc6MJw6Rl8rQ1VvafVlBOStzHazQ3V6vVSKi0tIaMfdIHsQH7/hwHKpwv2aFh9xX72b+XgfbfEGdoGldIek/+hb52UkF5Uva6jFpi9XTb+k2BUkOAYYV9YqkaFib0+1uxiTi54rPD3F8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784927063; c=relaxed/simple;
	bh=C/KgQkQgDooOFwHOI0kco/XuivUjmHOnHDk8awpR4U8=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=oZocrLlEJyUQxVeRHRVWSLOHPXkNfJKy6/Nog8pZhgslN4cRYfIFkPtyS7aECFaWN8PW1t+oyB9ZRDdjs68IG01NVeWln/DoiW3nZol8XypvnGh7CmYqGPVboOy6TFfVsDbzIchScH8t1hHU3TSw8wD/6hYi48TaKrxzkl79Kkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E6ixflVe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E6ixflVe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9C371F000E9;
	Fri, 24 Jul 2026 21:04:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784927062;
	bh=VPZkQmDLSH7ETDX6B51oW9a8XzrsYq9lKUuOQ48NL3I=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=E6ixflVeLUGPaMe0z0n3tSAy6cYCTwTxI3KOhPpbEvDkq8hsWp5xCAWxDpMQGKFSL
	 cr36Er7pGfIwsWAZf3+pPMpnMF6ybH5P9nokHdOYsQb1HLgDEuotXE00r5grPCVnqz
	 hHplIFSw6sPRZJuvVdanFNmmXBmsh+D+xj4QwDl04PfS5nckxs6moY3ujTQGVkHvZ2
	 8UWkY3RwXXWf7d0ksKpcsQPlefykivuhlbVWsGDG+v+INNn1Y7rDdPly7uytTHvxqb
	 DV6x1bldDJCdzpI740U6iP+MIkZbmA+C55uu9j0OpfkT3j0dLQ36rwrLBVHlC8H3DW
	 4HBeTxqKMKuyA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 56A8938111D2;
	Fri, 24 Jul 2026 21:03:50 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt fixes for v7.2-rc5
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260724195941.GA122270@quark>
References: <20260724195941.GA122270@quark>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260724195941.GA122270@quark>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: 6fe4e4b8259e1330945b5f3c9476e08473b8e0e8
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 981f4a2baaf15a15fd4a22d311f15d066e28833b
Message-Id: <178492702892.3306475.4881154415120662320.pr-tracker-bot@kernel.org>
Date: Fri, 24 Jul 2026 21:03:48 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

The pull request you sent on Fri, 24 Jul 2026 12:59:41 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/981f4a2baaf15a15fd4a22d311f15d066e28833b

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
