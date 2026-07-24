Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 644CB37A83F;
	Fri, 24 Jul 2026 19:59:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784923183; cv=none; b=gLQ8UikoL8Jn2ey5w+cMQT4ENnEAXvrduEiRk+kTIAQNqcyIHree0gYcR3Sl+6//St2gGJ4SVpfLzp4xtViN7ATMM36Ty8rAukHFrnaztFxIyJ/umBcDPoKfC0YC1rQRMr4cxAq5lWodfy/XuvzH8RobogIKY7L1tkUbOzsMVnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784923183; c=relaxed/simple;
	bh=oUGYR5yB8eMQKmQtv1x6auo091+nSy6jOQCKojzAoEY=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=qso48BUIicm4NMUwBwEowOJv2ObkN5V3av2ETeSS5zyiyK9sNN3Eq6qGa4gSIEaDAZzZnlhefla0Agk1pPfeW9z15oMXKJRPxkzsRiEm0n4bFMr2e4mpo11WN+36SWv6syYmLfzC22OsBucr1CzMVz/vfjo5yKwEfKGgr91mJ8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m2wLJmJb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m2wLJmJb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDA571F000E9;
	Fri, 24 Jul 2026 19:59:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784923182;
	bh=EsF7sMcqAQ7ZtXvVxF2Rya+42uJX7f4xU+wGkXj3LTw=;
	h=Date:From:To:Cc:Subject;
	b=m2wLJmJbFYsplu8h4QTbq1UdFO6vYB8ULzOJP5iRCiaVv8xScRX4vjdq1r8W3u+tz
	 GUDkSxiaOapOb/L1JD/iQX6JN+PXbLdM8EAI71J20QiwMEpaco+WzkPaWCNC0YRsRM
	 L+NPO7ASHC5sxwdelHx5Rb0bIZ0bNgpSxlOsextLWcldvwVPwIBQCT/HpN1X+E/sz6
	 G8J4/w2nMCQp/JnUU42alf/JNLxji0Gh5KE/sgdu9RsI5LJNmLjAoZZkkubu5SQON1
	 Sra/1gwef73uSTYq9dU0gcK7GDbAB+ejrEuxcCWNWaiSIePMcE04ai0Q4H810j6c7Q
	 XMs2Utdy+D6ng==
Date: Fri, 24 Jul 2026 12:59:41 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>
Subject: [GIT PULL] fscrypt fixes for v7.2-rc5
Message-ID: <20260724195941.GA122270@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit 1590cf0329716306e948a8fc29f1d3ee87d3989f:

  Linux 7.2-rc4 (2026-07-19 13:54:41 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to 6fe4e4b8259e1330945b5f3c9476e08473b8e0e8:

  fscrypt: Avoid dynamic allocation in fscrypt_get_devices() (2026-07-20 10:39:24 -0700)

----------------------------------------------------------------

A couple fixes for AI-detected bugs.

----------------------------------------------------------------
Eric Biggers (2):
      fscrypt: Add missing superblock check in find_or_insert_direct_key()
      fscrypt: Avoid dynamic allocation in fscrypt_get_devices()

 fs/crypto/inline_crypt.c | 57 +++++++++++++++++-------------------------------
 fs/crypto/keysetup_v1.c  |  8 ++++++-
 fs/f2fs/super.c          | 25 +++++++++++----------
 include/linux/fscrypt.h  | 18 ++++++++-------
 4 files changed, 51 insertions(+), 57 deletions(-)
