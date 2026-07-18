Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE32C339708;
	Sat, 18 Jul 2026 21:49:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411343; cv=none; b=Di0hvk/dj5d8y42gVeA+FYtVgmMgE/uewJ8DTgzK7fxWkDYgJBj+r9mdipJDUCIuOfExnn108u3SL42rd418aMlQRQw8/C89jFB4dzujOE5Ix9+7CSKGVtoK58PRb4dE1THw6qDtNoLHHbXLXUEqkZi/73Wvw+JvWzUGAsVYhn0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411343; c=relaxed/simple;
	bh=3Y4D9BU5+0B9iQI0k7XS96B5+vSEcYjOGHGaX6ZX43c=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=XQFVB+p3uB3Dae2kfMXSKYO8QXtpoHH4qipHAY7aki604oAGdwN8OaafH+tHqcLJAB4Vrk870JkrFAFjfycy1iDCfeYxCrEkoZPMnDcn94vOspQub5hn3Wlb5kFCO+BjPDWcXZPv448HpD0cDAkPw8Mo4unDv35pvFzQ1x82cPM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gJM7OV9v; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gJM7OV9v"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 587D91F000E9;
	Sat, 18 Jul 2026 21:49:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411342;
	bh=utFnArNBvhXi0tskwzedkcauorut7DvNltLjRLrRl94=;
	h=From:To:Cc:Subject:Date;
	b=gJM7OV9vS8RkGvdy8FXmYDuRyrrLXbUpYRKNNmTCWCICjXQ4nSIxlZoFiwYQzmMjN
	 Sgrws86276SHJPSsZh4ISyc0Z8hsdM0H4ZxC/6BySsYXivC5JBUk48zn6Zzt+ikGpl
	 9j3caqkmZviOWQRRMhB6g6Ie6/YV5VZX4Kl2GbQnIkBc6KqM+6GopvwKu1ys0S3HLG
	 zqo45K7feLUp5ceURQW83ryUd60pYvKMbY+WloS2r6j0tpvvA68IwIF+nqTM15OdM2
	 Rnmk8aGIU6xNeM06O+IH8QGOgteHHLJIHbpBcLkSuwmCQqQ9OW9ru64UxMGURbD+RT
	 VmYQayDmeJ3kw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/6] More fscrypt and blk-crypto doc updates and code removals
Date: Sat, 18 Jul 2026 14:46:49 -0700
Message-ID: <20260718214655.63186-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series applies on top of
"[PATCH v3 00/17] fscrypt: Standardize on blk-crypto"
(https://lore.kernel.org/linux-fscrypt/20260713023708.9245-1-ebiggers@kernel.org/).
It gets more documentation up to date, and it
removes a couple more functions that are no longer used.
I'm planning to take both series via the fscrypt tree.

Eric Biggers (6):
  fs: Update outdated comment for SB_INLINECRYPT
  f2fs: Update outdated comment in f2fs_write_begin()
  fscrypt: Remove unused function fscrypt_finalize_bounce_page()
  fscrypt: Update docs for data path
  blk-crypto: Remove unused function blk_crypto_config_supported()
  blk-crypto: Update docs for blk-crypto-fallback motivation

 Documentation/block/inline-encryption.rst | 43 +++++++----------
 Documentation/filesystems/fscrypt.rst     | 56 +++++++++++++++--------
 block/blk-crypto.c                        | 14 ------
 fs/f2fs/data.c                            |  2 +-
 include/linux/blk-crypto.h                |  2 -
 include/linux/fs/super_types.h            |  2 +-
 include/linux/fscrypt.h                   | 11 -----
 7 files changed, 56 insertions(+), 74 deletions(-)


base-commit: 185a45827da9459c4484ea60cfe1797c3e9966b3
-- 
2.55.0

