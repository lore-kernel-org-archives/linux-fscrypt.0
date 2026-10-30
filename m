Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793318624;
	b=Sn7nA/zb0psNWNsYo/Y8oi6yvuEyyI+3SKLjrj36Pgyyfazf604VLcDlB7dq0XFk/GE/
	 f1W5BU6eayBaGRJ+ml4h7X8JLo1FQPTKktR3MKgarM3QgTArbOQsvuu3U0NRfPrkloDkF
	 XGieO31+SCq1ex+1l2zN8jkhcSy5cjimXgNQK42H31G9JSTfTnDNCJaSvJRgTK0WvHWNW
	 YCQ0yjhTF8ezf8CLh2yfv4QT7FRDHliUgTS7FfK29dFdfbh3jc0FEmfZChJSvYcSe9PAM
	 2+NQMScON7Q4JBKKSjPs5JWUF8hYcZ7/nNjlunK9ogylGm30rrwVpS9OPgoMZLhIA5A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793318624;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=OApn1EO3k9aspEjv7Ns/r728pKoPSDkmYJFKzLLVpzw=;
	b=CTVCpp6mcy7mzl28c2en+JRe70P8zc4qAn2TFGhn5BS5ueK5UfAnSJF2//JvvQLZEvKB
	 cH9cFKR6b00rZ2+ZEciVkV6eG4PCHFvg0y3H3sZZgrs1urFwYHeluNewNBMe6mZ+6k+id
	 Lgim2HYNFVgTbplT9c7kOksgbRRMOl+FvOsbxDhZ1uf3XbnEzU4f0lBFmVllJv2rL/7S3
	 ikYCqzVvXDmpnkbcSydiVIZTAJM7jFr9+lWE0F+LjszOAP3p8C8SSI4nx5MZIPQj7VJhD
	 2jt+DB5zYuSMZo9cJfu2hVMGOij/9+njZJL79nGPP2PxKCAr6Egl6KXj0fz4pk7ZoQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c1bcghQX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A99DC606A31A;
	Fri, 30 Oct 2026 00:03:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c1bcghQX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 84FA91F000C1;
	Fri, 30 Oct 2026 00:03:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793318623;
	bh=OApn1EO3k9aspEjv7Ns/r728pKoPSDkmYJFKzLLVpzw=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=c1bcghQXlX+21n2PhRRsjasOsgtJtUy1p5f+TpyVm/GmegD8tOMyA2ES5XDmhZPka
	 Wd6D52PTwBqJEGNH86OGoMzVIeHJsT2k/fYOsNWRpaaSkUpuHcekliNGBHks/9ctLe
	 kwPhct/Mqy+qJ8vIVs2Zlb1C6HtrViRS12tgY94Ymp48wmyZnW9ZAD5H9CpvFduSpo
	 DMG8Zc6DSuaDB3qMHthJhmGjkNbSjcjOsg6zDv5P2LfYvL3cVpqI6NtbYZnegi0zTC
	 Pix2+Orl4pxXD8t2oVqeN26ZZMxPhdOl5YJc2Hhd9b3Ncw/fdf2tG2zjSOZiprF+PN
	 6HWgZAcSuYXlA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 7D1EA38007D3;
	Fri, 30 Oct 2026 00:03:43 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt fixes for v7.4-rc1
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261029170615.GA1862@quark>
References: <20261029170615.GA1862@quark>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261029170615.GA1862@quark>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: a5e894bc87b76fd980075892ba77e6bdeeb5e4d0
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: d89e1d186ec9271bf78e62771779e9fc03bf0fc3
Message-Id: <179331862219.761441.16425885320324096172.pr-tracker-bot@kernel.org>
Date: Fri, 30 Oct 2026 00:03:42 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alberto Garcia <berto@igalia.com>, Baokun Li <libaokun@linux.alibaba.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Thu, 29 Oct 2026 10:06:15 -0700:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/d89e1d186ec9271bf78e62771779e9fc03bf0fc3

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
