Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795024570;
	b=rlvrLivkUV8kmM39/TY7e0DfQEp1l9FCM1Nw8ScndU1wq4a0aeQ/4p9ywFNC+egtgTqQ
	 k668XUH2ciRNt5P0taGKUNfPHsw6jNnz3wsFz1dcFZPJ5av24+M3BScLHwzy5QNo1v/2I
	 Eqegod/NbN2Y0XrxprwkAtBXTt6M9mPfoYM9awU95VgG1undhevhUlHuFij7K+rnR0kkC
	 j9MfYL9bCLm4Ra84JfBe9cs6ImpIwz7LxOkfclOH1EprwUqE7mt6sENwzdotqGdi68kww
	 5rrtFl+4LT9vrZKzgdGPZ0KTR0gLEv8bfX/AhzFZ+mVtkihDdrtZeFQb/xIEvf70Cog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795024570;
	h=Received:DKIM-Signature:Received:Subject:From:In-Reply-To:References:
	 X-PR-Tracked-List-Id:X-PR-Tracked-Message-Id:X-PR-Tracked-Remote:
	 X-PR-Tracked-Commit-Id:X-PR-Merge-Tree:X-PR-Merge-Refname:
	 X-PR-Merge-Commit-Id:Message-Id:Date:To:Cc;
	bh=lYN6ixomx7WxT/HbsQHDXbqojgu1W2HFsZEBmRDQ3qQ=;
	b=TC+Kqj9U7adWzTsCZErbIlIyGGtjbO5X+eO/dvFWSRr/7f/Iz0QtAxQVA8qS+0m+42EA
	 CKLWnnhrkYmI88yc/Z+lekwaSAKjMi0dal8wCSM85+VLlex7uGBkV918t+Cvksgklojmz
	 /4FgV18gGj3qbc/cbJHuEL9KGIU/8859PcMdj4PVtFnQI1yZBOeF4DsVSK2gOo+dVd7Vu
	 NPzp10uvZYWHZCplUheUrIH6sKYypCnDiR2bRmMKYUHutSUpsSdMCMC9KkjUe09H8NUlu
	 e1r6jVrCSkzbmyMqHN87QZ8wfMVYsTRY3X7dMYteQOPOHGZw9xuozzovoe6yUk6BkFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m1IpZNIR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3F8D606A32C;
	Wed, 18 Nov 2026 17:56:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=m1IpZNIR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 809211F000C5;
	Wed, 18 Nov 2026 17:56:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795024570;
	bh=lYN6ixomx7WxT/HbsQHDXbqojgu1W2HFsZEBmRDQ3qQ=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc;
	b=m1IpZNIRvQQAPBusr77ChBeXUIAUgJPj1O5Ftxxlai688ECTwmq9WY6beBHnu4RcQ
	 7shfm9/tHl2xTclHscBQTtAFbTTfQzHXris2dFjELpbhANta+uNIrnOkMYFanYif9L
	 v15iwTH7TUZsJ0RZ2mW0Ym81L4+NJarMqZrSItS+3QO9rZQ6hr6FMUdBiw6LCgR+l9
	 dMdYm0Yu0c0lX56O3fDDr5rAGxfy0ajXjX24Cn01f8lAGZQkCucdiUFVDLYnKDW3iC
	 MKV+mCqHasAKnESMEUc9OM+dpVX5gNS1VYOjDZiY1ebyyGiu2+Qd832QGpZ9+GRiKZ
	 mC4Y13wD/Ddvg==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 776043808210;
	Wed, 18 Nov 2026 17:56:10 +0000 (UTC)
Subject: Re: [GIT PULL] fscrypt fix for v7.4-rc4
From: pr-tracker-bot@kernel.org
In-Reply-To: <20261118045652.GB3400@sol>
References: <20261118045652.GB3400@sol>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20261118045652.GB3400@sol>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: 2de253924266eeedb798fb662173726c90b0cf04
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: fb52ae0e9afb44d5f06bcf855b490584dad66687
Message-Id: <179502456910.1929586.2555396455066463564.pr-tracker-bot@kernel.org>
Date: Wed, 18 Nov 2026 17:56:09 +0000
To: Eric Biggers <ebiggers@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Ada Smith <adasmithgt@gmail.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

The pull request you sent on Tue, 17 Nov 2026 20:56:52 -0800:

> https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/fb52ae0e9afb44d5f06bcf855b490584dad66687

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
