Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7BD8304BB3;
	Mon, 19 Oct 2026 02:35:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792377304; cv=none; b=dweLtjSZN6/kYWPPJeGJj2sOey2Kz/lvG7TCkO5IKuN4nOzC6SEpnNc5qPP79rClQapWtKsSf/BU0d6W6gcMHWxnTNprq1eVIPI+gdyUBPsupOkV+XsfiaBkdWQ9SVM9VWkz/t3lM7k2Y+2lzSL2I5X8GjdJoRIwYRNlrrFHESU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792377304; c=relaxed/simple;
	bh=PtLsAFIbzhXPEzoAZGQ1BkiLSRrh0SAf+OswsfDD1JQ=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=fbNkUIA1bt+IMODT60N9X3Y/eFnaEhzcfxN5+FdCsJJudoUyVSGBgK9wD86m9C9FzoFAO2hAvMq82y0wvRMmfxZGnLp2HvP/azBp5y3E5KjzbjPy7Jt4zB5/WARxRBuc5+uH9XczyYtNuwjLLL56dVuktmxmsdiUx2I8ZzkbezY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JYqXsM7+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JYqXsM7+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3116E1F000C4;
	Mon, 19 Oct 2026 02:35:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792377303;
	bh=nrGPZw+YS9GgLAct5o3md99BWmYfrWJMf0gQeeDtUrM=;
	h=Date:From:To:Cc:Subject;
	b=JYqXsM7+yoUQZLmmpofUjYnDYa8TzIVno0ipmuVAuiKRbWGAfl593Fc5A9SOpF5WZ
	 vaIUo2dFtHCs+XLR6k7bDiSrOys4HLG4NHx7LY3X2RfSwB5YPAMH+Ov+WgUN+Ea+Mo
	 J/SDRaXYkDdxP+EPJCIiAIxuTbc9NAYo/nCulUwQycWXBj0K2vbhh3Qh4ChEu03grz
	 +wDwUyyHk/KzocfzEE1xS900NYJQ9pewJ5kUwQONbbGUWCvPx9B2jV5Fv+WRQtLaUs
	 3zFuZ9aa5I6vNWVvCTOdrhObShbUFQAuDV1dm2J7rT9G+L8swSbLsAevnqEg0a/tsI
	 ZKmWIRPqUWwMw==
Date: Sun, 18 Oct 2026 19:35:01 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>
Subject: [GIT PULL] fscrypt updates for 7.4
Message-ID: <20261019023501.GB3270@sol>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit fd73f4a6659897191fa0d40695fe370925dd3780:

  Linux 7.3-rc3 (2026-09-13 14:38:02 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to a63883d2c3d47ce6d41918c2453a4513b921eaaa:

  MAINTAINERS: List the fscrypt branches (2026-09-25 13:40:21 -0700)

----------------------------------------------------------------

A few minor cleanups for fs/crypto/.

----------------------------------------------------------------
Eric Biggers (3):
      fscrypt: Use aes_ecb_encrypt() for v1 key derivation
      fscrypt: Move several items from fscrypt_private.h to .c files
      MAINTAINERS: List the fscrypt branches

 MAINTAINERS                 |  3 ++-
 fs/crypto/Kconfig           |  2 +-
 fs/crypto/crypto.c          |  5 +++++
 fs/crypto/fscrypt_private.h | 27 ---------------------------
 fs/crypto/hooks.c           |  9 +++++++++
 fs/crypto/keyring.c         | 13 +++++++++++++
 fs/crypto/keysetup_v1.c     |  5 ++---
 7 files changed, 32 insertions(+), 32 deletions(-)
