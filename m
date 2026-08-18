Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C7553D567E;
	Tue, 18 Aug 2026 03:58:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787025488; cv=none; b=RLZrt8OWCRdLsX5oyWxth1WKtRDhgsx3C2DWY2SUuGAmqd0DadvWQvNozQuKU/ZqpBm9Tu1EgEyFO2Eadp73Gf9kHJ7ItKRylDq19K4EO5JDFCv+COEmUQYxTRUMtOoHds8WuXM39CQivMPdSDb3edYRDTS337jVDuAkw5s72c8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787025488; c=relaxed/simple;
	bh=HlJJjeOiX8CH+43ws5Hu0UtmJvn55gBePPiu7D7Q/i4=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=bLvU06EB/Sr+6/XKwo0oZz8hKLHB685C85sr65vDE9RqY+1iU/kE9vC0M+SMB7Grs0b35PA4A4XjikCMOxL5Pyqv3QJNgOvnHelw+0jIXTPUU3tTvlxSeXBMaai0hHxulcKjNmr1t6pjj5VYhm3ItzyiVww0IJvGfWtcTDBd/cw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Hs0z7ei/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Hs0z7ei/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 73D111F000E9;
	Tue, 18 Aug 2026 03:58:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787025487;
	bh=gklsedvwg/1RBEAFZOJaRdv25Q5XetfTjtahYKt3FGY=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=Hs0z7ei/yI5eRfjNBvWmtqktBzf6/Yt+m7WF/z66EHe/dV4TVgEIh99vkwyOSVEkm
	 wL8CPLEUL+8pXlU7v8G9F+DLFt5wvRk7dS3u+mY9S6IWuyu755v+f1+xbZD7Phpuwf
	 LoNMnQvpssVBrLMLx0hOYgBSwYtrOQYjsHgV5hA3ymy+ndwzEgkH6u9b8lPCNYwdIH
	 U+fXGSBvKgl872L4FXmUBAPAfdcwTK/wLiVxuPBZ2AAmRSW3sbz+eCjfbpyGRUxCyI
	 0LidkTntVEnUu1XcCyI9K7QaF0uemtr5rJawcgm5tLpYX6pIP+4YnwFPOYzcCD5MTS
	 LmAnTSCx0lbVg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 93B193926381;
	Tue, 18 Aug 2026 03:57:20 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt updates for 7.3
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260817173311.GB8327@quark>
References: <20260817173311.GB8327@quark>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260817173311.GB8327@quark>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: 7dd38d9dd7a05329825fe2324d4d8e27ad4b3cec
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 1d7443e4dca1e8637930f3baf64e2fe82033e669
Message-Id: <178702543910.1862718.5095788167656687707.pr-tracker-bot@kernel.org>
Date: Tue, 18 Aug 2026 03:57:19 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

The pull request you sent on Mon, 17 Aug 2026 10:33:11 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/1d7443e4dca1e8637930f3baf64e2fe82033e669

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
