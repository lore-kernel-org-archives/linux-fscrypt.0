Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C8F12C21D8;
	Fri, 17 Jul 2026 04:46:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784263612; cv=none; b=SxK+3GMPu9blYORZvWtL5HjA7cNK0aExbgIxNC10ASfOWTbyQYKIwkK5AdKqP75bHTKl3LCc6MAH1HJ60v3A6EgqHucYVvLBAwcFtsNbQayzxVhN8KXPaJX6SH1PeF+Gul0v9TMfa84+g+TXWTcsv29HiMjUCkaerN3VQef2eD8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784263612; c=relaxed/simple;
	bh=hXsFOam8Xv+IxgYVz6xy9dS5bRdfZppW46HywK0P/rY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Iis9bv2Ua9ZdB7+JQA/sLlfPhdhTV+6Qex+2qslrh/Y8OeqVJKlo17j2CMQA0Wpa4YlDhl2NfkFUOrGOlHVYfPlBVaWrIp+aJRRsIV5vuPC7l3bDC6+asVq793sus2pvRSCUWkifcnYBI5wLAbaCCMtJgA2dR+e4eMAh97cV6NU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DRyc6GTM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DRyc6GTM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 776171F000E9;
	Fri, 17 Jul 2026 04:46:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784263610;
	bh=SGlpMM/Yh7siYQw8mCl9Pl+Jgm5XrJBdfZVRoJkWnLo=;
	h=From:To:Cc:Subject:Date;
	b=DRyc6GTMKCUV7U2Wu32VKKb1nE/+p3syx1VXnb6bLyt4Gh//Ahw45YAMqjvOOM4gS
	 /6bcz8Kv8Woh98vUv1f085G2SRy3TPNZvW0MCXZut0REiPUCUm/jg1dY6kQddhGkd4
	 nZZl7LV4u4Ar1Qow10eeBfUO99NqK4x45rdB27KcUKaQ3oDPVzNawNPfURAkn3cQnT
	 7eKod/GZYGVjvFmrd56r+bFdVerjNFSPcNqwG7g2NH/hfFMe3bqbcktbWXHN0Ux1iv
	 84ofxCZb0RdO945IayjR8TJvRhSGyXJtWSGllgd9YPXMay1sPpBVQk0vNE6el+CUba
	 S3LZYKz25pPiA==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.12 0/7] Backport object allocation APIs and two fscrypt fixes
Date: Thu, 16 Jul 2026 21:42:56 -0700
Message-ID: <20260717044303.425265-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Like I did in an earlier series for 6.18
(https://lore.kernel.org/linux-hardening/20260709043301.142931-1-ebiggers@kernel.org/),
this series backports kmalloc_obj() et al to 6.12 so that more upstream
commits will cherry-pick cleanly.  As in 6.18, the flex counter
integration isn't included.

Patches 6-7 then backport two fscrypt fixes (which, like lots of other
kernel code, happen to use kzalloc_obj()).  Patch 7 is a clean
cherry-pick, while patch 6 required resolving some other conflicts.

Eric Biggers (2):
  fscrypt: Fix key setup in edge case with multiple data unit sizes
  fscrypt: Replace mk_users keyring with simple list

Kees Cook (2):
  slab: Introduce kmalloc_obj() and family
  slab: Introduce kmalloc_flex() and family

Linus Torvalds (2):
  add default_gfp() helper macro and use it in the new *alloc_obj()
    helpers
  default_gfp(): avoid using the "newfangled" __VA_OPT__ trick

Randy Dunlap (1):
  slab: recognize @GFP parameter as optional in kernel-doc

 Documentation/process/deprecated.rst |  31 ++++
 fs/crypto/fscrypt_private.h          |  87 ++++++----
 fs/crypto/inline_crypt.c             |   8 +-
 fs/crypto/keyring.c                  | 239 ++++++++++++---------------
 fs/crypto/keysetup.c                 | 119 ++++++++-----
 include/linux/gfp.h                  |   4 +
 include/linux/slab.h                 | 100 +++++++++++
 7 files changed, 373 insertions(+), 215 deletions(-)


base-commit: 296aabce459470a4c1b68ffd0c0c0920e563aaad
-- 
2.55.0

