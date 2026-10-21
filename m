Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792547615;
	b=INvwG/p+efmC8nNAQwpbYAdX1lBYMmV8XfVDjfp6ac2U8pmmL5r0teIO5XYikmDS4wPe
	 XzEzZ2pLmdt4qQQwSrAyDy2ERgFHSIA0xEQXB8awBQuVzmWSoLQS9IWWAbNMNmyqWumMY
	 4pnD+bmaoPmkJ9q0YmfPOk+8yM4WvobyZ8+qzggL6VfeeIlfHwYCidA+t/hGqr0XNPeUa
	 FvGx69Z09joBkSnnIiW1il3nJumV+wJSlbKcq864Qquh7Ueay0JXF4qExFZBQ4d7gDvMM
	 DglBxpjAn+96Jlb82O7gzFyTMcxm8ifp83LharSaEF44yabJKk6sRUXvTNPphv57ECA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792547615;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=jMlbbqXoNTNtXO6gJwUpwq7MXwdLhlzFO6lIbcOi9yA=;
	b=bW4XdrGNNRR+9+rcPdJj8WeqcjT2kQvSRGACwiC0HU00Nn9k/nWzhVW8LUQLYxeg5ewb
	 LE8ImJys81MGRswhOwJ7uv3GGb0aGfSbYraACcFyM8rNwfIhFyvDfEq4d7NlsCukAoJcP
	 BdDuyNK/xbqrbAUBnnhlE/1eS09NKtV2AJ7xZJ00cHaILxHaR3QIzG0EQDvrknqInEqkf
	 G0NlmvhKDeAb7XRdTMiS3LtEUgeAiB5ats5vKXyzMZqk9cuTT8k4qoaWODUhmdzSHbM+c
	 GMaSfThvAFEVO4CbkVazqPLH4PZPvH+DKCMOaEZWMV+Zgh9smAMBmilgFMHNcf09bpA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LWftTZyf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68447606A319;
	Wed, 21 Oct 2026 01:53:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LWftTZyf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 44AD61F000C9;
	Wed, 21 Oct 2026 01:53:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792547615;
	bh=jMlbbqXoNTNtXO6gJwUpwq7MXwdLhlzFO6lIbcOi9yA=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=LWftTZyf5qFh651z62Q3085PCHrnh1U9pOC7Kagn6rioa6Um3Wr9+OqJqCjYbCk7y
	 8n62fvVCveeoa0iNMkpspwN7DhqUee5RtpAqC0gxkLyW3f5uout9sG2VuZ7lhgKl8f
	 VLHJjFAC6UQmk2x0LmlIgNq8yjFJogR1kdIcJ89jI8DrtfbCyw9lp32q1xQIQLlApS
	 RvInnD5UlFxAN95SUgAgk6TUxr8cTHTKpMlYt5rwSFUiwXu8r60Neipzsj3XCv5UgM
	 nuNzl9Hmy0jYYZGB5Nj41pd7ywDWohm0FgLj5iBY1DY9XZKe+8J1X3ORP9p/ZunTHV
	 SNW7cc4y+Gozg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 3A5CD3809A0D;
	Wed, 21 Oct 2026 01:53:35 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt updates for 7.4
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261019023501.GB3270@sol>
References: <20261019023501.GB3270@sol>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261019023501.GB3270@sol>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: a63883d2c3d47ce6d41918c2453a4513b921eaaa
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: fe178c26cae01b677a1fec59f9c276c7bf20517a
Message-Id: <179254761373.320300.1681376073211424401.pr-tracker-bot@kernel.org>
Date: Wed, 21 Oct 2026 01:53:33 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Sun, 18 Oct 2026 19:35:01 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/fe178c26cae01b677a1fec59f9c276c7bf20517a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
