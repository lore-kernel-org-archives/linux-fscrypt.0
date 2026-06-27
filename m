Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B77B015E8B;
	Sat, 27 Jun 2026 00:43:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782520997; cv=none; b=UlAuMgg74243aesEBG9yeGgs6HcoiHB35dS66NqN5uxiGMZl7AYYrvONZa1rWO2AWJQEy/vYZOupnRoN2gUxz00c9EJjYXF9nDtTiinY2bgrp1JzvOXJIpp2cH89axsqmXiezpJuE0LidPVn9X3uAx6wp3ZCGtUYzdsgY6ZJ4p0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782520997; c=relaxed/simple;
	bh=1erZvWAO8GPRGbyc75Uq33HBKs82JDiPBulHV7KhsYo=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=KSkPGuLn87TGh++Ymde0gZe7tB7ja2ceftUKg2REPXuk+0jwnZMJ6cV3DvB//3uIcL8psLz31AlGwirkRZuwdj4liluobzoVYNlmC433DPp9CYset0KM48xTPQ0cW/kkrB0qIDIMN02wHBD/auegJ4NaqENXrjE5la2O/y6fVqc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WDvyQJG9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WDvyQJG9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2AE6B1F000E9;
	Sat, 27 Jun 2026 00:43:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782520996;
	bh=aWCzpncU7+6ITCn+zmFtEweahB9AkfncfcsrB7kCr/o=;
	h=Date:From:To:Cc:Subject;
	b=WDvyQJG9u2RYz5DIfB3fBE88IREtRlLglshGDWwkFEW4Uf+RYGk3noucwzptp/B4L
	 Ips1w9iDBC6r186wkw2P3FYiZvTVByvyrYjERV5q8aglaGFslYT4JQFR1CFS1BVr6d
	 jRfzeS4GSLxHSZgvALzJvku6Y/IK2arg5Fou5QgQCU8zrzBcn1NzjSHGcTcWAK6+Xs
	 2PHPeAuPgzfF1izaFJ+EAxOxTmfObcd+DDpe3/H48I5DKQcWtd+8BlCs1UKZJtfqT4
	 ZGwkRRIk0uGC7pi2Y+HBlu5KIW7xTTuLXKC/qa6+hgYgrTixxr7itc7Pvy+BXEpaeZ
	 YUoJq5UyX2KvQ==
Date: Fri, 26 Jun 2026 17:43:14 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>,
	Luis Henriques <luis@igalia.com>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com
Subject: [GIT PULL] fscrypt fixes for 7.2
Message-ID: <20260627004314.GA2075@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit 1dc18801be29bc54709aa355b8acd80e183b03cd:

  Merge tag 'i2c-7.2-part2' of git://git.kernel.org/pub/scm/linux/kernel/git/andi.shyti/linux (2026-06-22 09:30:31 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to 696c030e1e3438955aba443b308ee8b6faa3983e:

  fscrypt: Replace mk_users keyring with simple list (2026-06-22 12:12:11 -0700)

----------------------------------------------------------------

- Fix a bug where in a specific edge case, file contents en/decryption
  could be done with the wrong data unit size.

- Fix the data structure used for keeping track of users that have added
  an fscrypt key to be a simple list instead of a 'struct key' keyring.

  This fixes issues such as a lockdep report found by syzbot and
  possible unintended interactions with the keyctl() system calls.

----------------------------------------------------------------
Eric Biggers (2):
      fscrypt: Fix key setup in edge case with multiple data unit sizes
      fscrypt: Replace mk_users keyring with simple list

 fs/crypto/fscrypt_private.h |  84 ++++++++++------
 fs/crypto/inline_crypt.c    |   8 +-
 fs/crypto/keyring.c         | 239 +++++++++++++++++++-------------------------
 fs/crypto/keysetup.c        | 118 ++++++++++++++--------
 4 files changed, 233 insertions(+), 216 deletions(-)
