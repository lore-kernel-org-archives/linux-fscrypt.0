Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C73C30FF30;
	Mon,  3 Aug 2026 18:27:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785781623; cv=none; b=n9usb6XiXe4VuaitYeZ0eoXsfywnaRcoZUH4HtH6mgmmyhmuNIN1R6qTVlx6s7OTyxl00er4SGHIcEAnm+tG5quJR6okMClkIairAuMBk7gmAeNsbDuTJGkKj2DYqbiZ0782yRSrg0Ui4jfhrKwQJHWwOH68ZdU2oSZpJ8vhgF0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785781623; c=relaxed/simple;
	bh=qbbP/iq578Xc8yLtoKnU2cClP8JsdyZ7I5DUa4DxgpA=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=RmU5XUn82l2HzWCwq3/9xDoKEEleyaG5Z+s5n+IMv2jh/vZUYt7hPgSJNCjmmURs3ki5Kd+M8t7mvcGTjf0jLG1jbS98ZSmGna4aTbgn5CyrO7zFL5OBq7IdUJ5cez19Pm4ZKyZ0UifY7AlnbKk7PVi7v1owAXspdintyh0I1Ro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TCthhabI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TCthhabI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BEA841F000E9;
	Mon,  3 Aug 2026 18:27:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785781622;
	bh=ryjYomR3KLMF6BsgoIe8L2xWFC0aTvTQxgnPQfI+tkk=;
	h=Date:From:To:Cc:Subject;
	b=TCthhabI9jWMzxlk3qAkpgLz2E6/cbCWajDB3Iq3lHNCDEGoBqiyH6vUdMyA3CX11
	 abEw/oiOIslxYbX7KxGxM98z/Mk+f+oK9x/ay+mfwKI04N5gVGdk3Szxsy7vH2vwKA
	 Pt6fRtMhZVika44uXqVYPfM0jb3jiQj6Mz/JD5uD8HDRKHv+Aq4JKZaJYU8zKk2SXs
	 AZb+l5hGYr6o9Fv6L2/hlERVfwNh7lbHXsplVUT53dUHrGE7zCPCUb5Fnx7dT6dhv+
	 7FOIgri/1xw+bhZjxyjHBQsDOoV5POZBQmVzLzkTm/zYG9xFOnydP4zPPyluOSwTdz
	 n/YSAQz4UO/Pg==
Date: Mon, 3 Aug 2026 11:27:00 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Zhan Xusheng <zhanxusheng@xiaomi.com>
Subject: [GIT PULL] fscrypt fix for v7.2-rc7
Message-ID: <20260803182700.GA2062@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit f5098b6bae761e346ebcd9da7f95622c04733cff:

  Linux 7.2-rc5 (2026-07-26 14:45:48 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to cf6c993c0feca7984797e634deba3c80342e199a:

  fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy() (2026-07-28 21:19:44 -0700)

----------------------------------------------------------------

Fix a bug where FS_IOC_SET_ENCRYPTION_POLICY checked the original uid
rather than the idmapped one.

----------------------------------------------------------------
Zhan Xusheng (1):
      fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()

 fs/crypto/policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
