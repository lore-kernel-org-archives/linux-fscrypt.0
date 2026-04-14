Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77DFE1AA7A6;
	Tue, 14 Apr 2026 00:38:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776127107; cv=none; b=T/sEhUKkCXBYKk0aN6M+hJgCXI3041bBkOa0aYjiM6Lq1hGk0shLOTkNQvKw1FTJ0Xsx0UOuuw5m3htUn+/2bu9ZylnJ7YnB9PigNspBi3gQCPqRZS4PK0Z5aTCoQxeCn3E54ivboFMsAbPDthyzcSXgNLJmywbdtMPTX1J8J8s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776127107; c=relaxed/simple;
	bh=vquBGZDDcr8I+SrjnwzXt0aC2jgbidZkGZbvCyRf4qA=;
	h=Subject:From:In-Reply-To:References:Message-Id:Date:To:Cc; b=FffKRK8+HtM76oAWRpLA8Ab7HAqAQA1OtGWEzxKrXjFvbwM5NT63vtkHxW5B/La94ZsKvrcAYFZKvfd03wNoziVwhAir8LMWLt2bFWdjCnM/QqxBRsZ/usfDnV8ZAD26sfv6weEgkDaH7P6FEuA02H7fCn/fU35jzGAOBlaQgxA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=udqUjDCn; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="udqUjDCn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D29DC2BCAF;
	Tue, 14 Apr 2026 00:38:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776127107;
	bh=vquBGZDDcr8I+SrjnwzXt0aC2jgbidZkGZbvCyRf4qA=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
	b=udqUjDCn+brac9KkQOkdLq8i11o9y9VubW2FrefzlUql9YAE7RJ7fKVX4P1b7cN3n
	 ZZCZ62Dafiy5CJNf8tKibPenX2egRcv+2NDNv3+IlW+zXKbinUqscpIujxbxXr0cM+
	 7XOK+kbqizjLxAwRnqiQoqbpJp4LXxt/+1Oh6Qx3to7X5TIUkEaUXwLGCkoUaVcXE7
	 Ch7A/JseNF9qpzPOeZojvbsgS6GU2f/X+CJAqhOoI5U9CW+mfOS/pHWH+wJNsVLMrf
	 Y/I68HnQqVPtGhRfVTcHOfTwVdhv3H00dKZpRbHgRggqwpwwYmJCLIKkSgw8oUHAMr
	 8kdlrtwgCnxFA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id B9DAF3809A0B;
	Tue, 14 Apr 2026 00:37:59 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt updates for 7.1
From: pr-tracker-bot@kernel.org
In-Reply-To: <20260412001820.GA6632@sol>
References: <20260412001820.GA6632@sol>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20260412001820.GA6632@sol>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: 1546d3feb5e533fbee6710bd51b2847b2ec23623
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 9932f00bf40d281151de5694bc0f097cb9b5616c
Message-Id: <177612707834.625472.17166940906300633902.pr-tracker-bot@kernel.org>
Date: Tue, 14 Apr 2026 00:37:58 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Christoph Hellwig <hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

The pull request you sent on Sat, 11 Apr 2026 17:18:20 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/9932f00bf40d281151de5694bc0f097cb9b5616c

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
