Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D782137FF46;
	Sat, 27 Jun 2026 21:13:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782594801; cv=none; b=gnBHpab3mn/Jl3oEYrWoG1Gbh0aaa539PaAQY7YWKniCmA7ggy3FMMgPlxtUmIFxg9opttz+GwxlLUT+afGM9nUkWuS8P8PayxuIUmbJx3GLdPQQdeI54vObg10ssBtfQpd7GtA9diWE2PXYbVLci9uIkIk2aAWE28/YQYZm32w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782594801; c=relaxed/simple;
	bh=tFvNBQiZI6UzZK8AohNh5zELWhljVKkiMtsyGcDqHwU=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=Ew8n4lDnx1MHWQXNpvWNTwVFoXRq1eGc8eQhpUzC46RcIIEhW7Z5PhMvaak+s/3fYVpDVwQ6zDwuE+MizTkjyDBnp+jDMeu6xgl/T05fSmX+VrIW+8ga9ccogH6wR+vdt3a2ljDnSSJQb4Xm8vYNkrqTNLvN0CEpdXDfNUq7sH0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eFYDeZlv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eFYDeZlv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BCB711F000E9;
	Sat, 27 Jun 2026 21:13:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782594800;
	bh=EX5VmE3YSsvEq2Umd1hn19zoxghX3Y31VGqWDH4SHN0=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=eFYDeZlv5uuSrw6TJWzSqcwJQFhruz+ul1pICLmA/g0SkPtBLQJYUxlr1WUsmkYEg
	 ClE4OGURZJtm9krS4vwzBEmGTZnFzI6zQFw6nE/8wOJi4sPdGWhC2lw/S54rkvgCMD
	 fSxNMhmQb29BGs/LOBTmZK05uSgxWdSXmfRF3+F7EXZTJs34oS5DhkBil8KXrJ8YVD
	 zuhwQGTVP6pepTCaQ/pgqRIlGlFi0wT0ycbLgcIjg3bKui1arURogt1zchcmNoA+Sl
	 F2cnY2kR0TuQrF4zJ1/tQRqQvwfo4uX1SfqzqMlg51jzKSDlMgnPOky0wCbBDT0/bb
	 MbDkGtdfoyDyA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id D0BA53938452;
	Sat, 27 Jun 2026 21:13:07 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt fixes for 7.2
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260627004314.GA2075@quark>
References: <20260627004314.GA2075@quark>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260627004314.GA2075@quark>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: 696c030e1e3438955aba443b308ee8b6faa3983e
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 6ca693ea903df5748809f61b290831004036978d
Message-Id: <178259478645.1431938.819006475632242246.pr-tracker-bot@kernel.org>
Date: Sat, 27 Jun 2026 21:13:06 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Mohammed EL Kadiri <med08elkadiri@gmail.com>, Luis Henriques <luis@igalia.com>, syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

The pull request you sent on Fri, 26 Jun 2026 17:43:14 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/6ca693ea903df5748809f61b290831004036978d

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
