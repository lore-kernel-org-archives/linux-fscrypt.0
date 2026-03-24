Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE2AF408221;
	Tue, 24 Mar 2026 17:32:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774373548; cv=none; b=gYU+PmC366fg6dNM6bIXbFvJX7z1pyYeXxw69hZvVRy15X6HAmE4/5BYfdTZgjhPdI/obIylWWGHjfcqRdMQq4LAoyHkcylpcA4ulw5FDrw4NdtY+XRZjrix1czIILvg6hJDXh2Pn6Nvec8XFq9SYqKD348O5L2GP63cJ0m+iKk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774373548; c=relaxed/simple;
	bh=6PvabfWqgV6Mk2o8Mrspk5xNPAhygV5RC4LIJoudYN8=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=PMpKcYeQgwbfinuCLYS/X5BRTB5dpeKGQzQt24GZ0fSv8tQNBGy20DhMAJiQtnB5+Chf/6jw9YvN6VaRhoha/3ucNwpy17FOzRSrWTiqgyPGkpF2c+eFgAjrlu0pmnWBsgxXXUA2cgNXXGZ1KaJv6GH3dZsTgGx0vMqZlgSMEiw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Zo8h9UkR; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zo8h9UkR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1C9DC2BC87;
	Tue, 24 Mar 2026 17:32:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774373547;
	bh=6PvabfWqgV6Mk2o8Mrspk5xNPAhygV5RC4LIJoudYN8=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=Zo8h9UkR3EFZ5X+t7pfglF358HIzZfkYCEPXbzgvSpn1932RytFLUmxbaM7vvtb+8
	 jOc+954Byl6hn4EPrsHfGfcxTsXE+uJ/91AD9cpiFU6fQFUnqTIZOUCz3jiKp9Lt/y
	 fP9agQ5q5IpglKVONQ2rdOMbIopiphjj96iDiDCdLhsIg4j6oOgV7iv4UPtrAChvwo
	 Lf11yj5JD7NSZtLROFPsdSkSE5aVMD/liTgqh0NDhuTdaGleJaQf9azubnWFNzP4Uo
	 AztXkDjv+clCATZJstRL/ReX0kcwsokdxAQqf0P4yOrlBxTSfcE3G2EgYulRsJROWY
	 I9c7LivQUYhng==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 7D0D83808203;
	Tue, 24 Mar 2026 17:32:16 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [f2fs-dev] [GIT PULL] fsverity updates for 6.3
From: patchwork-bot+f2fs@kernel.org
Message-Id: 
 <177437353528.1223048.9746825008977248948.git-patchwork-notify@kernel.org>
Date: Tue, 24 Mar 2026 17:32:15 +0000
References: <Y/KLHT3zaA0QFhVJ@sol.localdomain>
In-Reply-To: <Y/KLHT3zaA0QFhVJ@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: torvalds@linux-foundation.org, fsverity@lists.linux.dev, tytso@mit.edu,
 linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
 linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org

Hello:

This pull request was applied to jaegeuk/f2fs.git (dev)
by Linus Torvalds <torvalds@linux-foundation.org>:

On Sun, 19 Feb 2023 12:48:29 -0800 you wrote:
> The following changes since commit 88603b6dc419445847923fcb7fe5080067a30f98:
> 
>   Linux 6.2-rc2 (2023-01-01 13:53:16 -0800)
> 
> are available in the Git repository at:
> 
>   https://git.kernel.org/pub/scm/fs/fsverity/linux.git tags/fsverity-for-linus
> 
> [...]

Here is the summary with links:
  - [f2fs-dev,GIT,PULL] fsverity updates for 6.3
    https://git.kernel.org/jaegeuk/f2fs/c/5ee8dbf54602

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


