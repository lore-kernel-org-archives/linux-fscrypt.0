Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6AA2C4334D2;
	Mon,  3 Aug 2026 19:29:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785785371; cv=none; b=PalbDQp6Sq233BbOtgo2Uc2F7gF1WJAcogOP+9VAM2cu3yRtDp4Sj9JVJfHsM6EEFv7G1dYqZXv/eWy28H77iyRMmm/jGUs48lFuusayWZY4nQsr6SC6OjkrC9Wlp2hKOgC0kyk6j3Sra22TWMYUISCaANDOA1I5fY6NkDrV6YA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785785371; c=relaxed/simple;
	bh=xlSNyzyqGwDKYaCdplKq8CsvQ2nzTHporOuoZbUcSUU=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=pyhj8jt450V6luhhDgNB0djp5DdduvO2EbM3N+xHlldBgMI2Zt59KUQTw0qSTFRxch5moH91g4bkUeZbBPIAyojoruf4tplbTii6UqC2yMYs6oWGEF+890JSy4wSrFa6OH+Qboi0iy9TpKoAu4rUQTKTSCdZW8qRj586MHNpCFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jNcVypi2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jNcVypi2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5103D1F000E9;
	Mon,  3 Aug 2026 19:29:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785785370;
	bh=4mj5sUXPlCJFOQfJ8fWbYrAS0ETD9ITLdiEDoihG5LQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=jNcVypi2ywABr67SXmzrg08ZDgVH/JPLglLdhNzOl774zmvwhfKnFulw0RlxyE3//
	 hwMAEoBqPVzIgHAaQT+T06I3fPecyl+QUcinfklzS+7sNYOkdDZA8sGreixrz5LNHt
	 JyyUWkMWAi0+Rp2mMZqr318jPaWMUlXn7eLM9pI9aS2Sm2+73t06xZzCA1OvK7z2Ar
	 9vhO3kv3XVNlUdWOYCVW1t5RYvrS8JPSTSELywFpDnYDfFBQYOSgT/rzBvQt20nwJB
	 x5fPzss4r9MCspqCgypQVCrS7HX+cXChMlYw2B8oXTeWW3zTptlM026nf3MuguN0Qy
	 atnFKdL0whCgg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 93B1E380A957;
	Mon,  3 Aug 2026 19:28:52 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt fix for v7.2-rc7
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260803182700.GA2062@quark>
References: <20260803182700.GA2062@quark>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260803182700.GA2062@quark>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: cf6c993c0feca7984797e634deba3c80342e199a
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 2e718c88315af1c0a04fd9c295d605944a7949af
Message-Id: <178578533107.2798434.2955022558171294064.pr-tracker-bot@kernel.org>
Date: Mon, 03 Aug 2026 19:28:51 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Zhan Xusheng <zhanxusheng@xiaomi.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

The pull request you sent on Mon, 3 Aug 2026 11:27:00 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/2e718c88315af1c0a04fd9c295d605944a7949af

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
