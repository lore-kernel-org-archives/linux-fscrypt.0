Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794977814;
	b=Jg89GL4clCCuHAiIsWdlbBqZ88vZXrM5VsBL+ZE20jhPPsG9qusOwcqmYHGsOu+TtjFz
	 CcnUoBqk16T4rF0eSJ7kjhapePs3X+Fu6qRgRHw1cxHNYRGNrhr8lGhKysZys0v3hvDZQ
	 VO7EFXKSrnI7oF2zVe441F6ZfVdtuEepTLKBn/1rOANJWBQqsT1cFPB3caKvr2/SHUCa5
	 CelnB9Q4x09vmwBhi/nQ8aGE5MDjwdX+KTUIoRKUhDD9/Wqd4h6hIqW6a5jSV+Dtcjtx5
	 JIiarVmgp+dCGoDVBGMHlzf+H62PubR8btsaJ+bmz6Xi8u3Ky0pyPmWCaJOn1CaBO0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794977814;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition;
	bh=vBJwOopXChuf+WSraUW68GSu98Ya2otWx9eT1uHGC8o=;
	b=qfuRXotlL+H/IGFedDAO051uJDbybkxDLCJbuSTzxByNbCI2cS10SL5scZeaBCLbLdTf
	 kwvBp6XhByRcKeGkKzpT0L6hW1dXcZ0cVzRxTyujbaP+FjecBYgJwCVGgfks53UVQRqeC
	 e7+SWYSrF5UpVEJPf49H7G/24PwARntf0017boiOKpkCDJcJiFRy4ziP54V2XItX/EGY1
	 zmheZfMDvblNUol+x5UplFeFnSxRPaVKm+RSOyqMnlhx9LbJ9JdQ3nIsEGtpDlDwv1Lsd
	 UriD68zujq1lo9fZdYmSL+L8WE8G8OFkAqBt8X9WFYb8/xK9RsKa0plEffzpcPggwbg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ivrfh1a7;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F25D606A31C;
	Wed, 18 Nov 2026 04:56:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ivrfh1a7
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C51DF1F000C4;
	Wed, 18 Nov 2026 04:56:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794977814;
	bh=vBJwOopXChuf+WSraUW68GSu98Ya2otWx9eT1uHGC8o=;
	h=Date:From:To:Cc:Subject;
	b=Ivrfh1a7ae0NxHhBEJO8qi2xDzuc8cIcCveh758Q3Iy/XDgDXCD0A+xOT6Uc9O54T
	 ClkzIIzfl7ZWqkjnmLMI5vwuZ4yuSZblSJYhLEcBnqm5Uy0zv1ZDbsbpLlSoDEps7a
	 cawu/M/OCoI2wz3i95NEQRbTND9qjyAhacDzLR/pKDQHAZjDHlDzEPH28dwGA4Ozb3
	 rPxd+mZk1/Ifw7E0QBsYS3sl1297OjpMkhCNpHS7nEB4bLvdvOGLpOzz4eGgSRaQDq
	 51oZWz+wCQFoi+JDdwZ0B+XSlY4GrqYhzi7aU1NxUJJc29mRhNuiFYTiSloIdBBSuV
	 DGuED0UIv1aFQ==
Date: Tue, 17 Nov 2026 20:56:52 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Ada Smith <adasmithgt@gmail.com>
Subject: [GIT PULL] fscrypt fix for v7.4-rc4
Message-ID: <20261118045652.GB3400@sol>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit 7475ea8b58616b33c04afb976cf0fbaad9dd63fb:

  Linux 7.4-rc2 (2026-11-08 16:22:20 -0800)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to 2de253924266eeedb798fb662173726c90b0cf04:

  fscrypt: Initialize ->ci_master_key before publication (2026-11-10 14:19:21 -0800)

----------------------------------------------------------------

Fix a NULL dereference that was theoretically possible if
FS_IOC_SETFLAGS was called to set the casefold flag on an encrypted
directory concurrently with its encryption key being set up.

----------------------------------------------------------------
Eric Biggers (1):
      fscrypt: Initialize ->ci_master_key before publication

 fs/crypto/keysetup.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)
