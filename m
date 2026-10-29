Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793293577;
	b=MtoDQYvAYAfTD2SS++MqUN5Xp62ZSXW//9H4lDuABihJ9JgTCG+OGdpQsuEfojkAqfTR
	 haqTv9LqKFcZVsOWY2X+YCGmXfUxlc679IZRv4INdAseDMcXaKk8fyWnb0Slw5QRKbrai
	 shLLGWvFmoQPTxqrP/Z31TaariZN26hy18Jc7O5ydR4Oo8s+NnmV1fsMw0VJ2xCyw1Z5I
	 /0dVNpQtT5FCFFM30x/XyAqyhGwllSUbNKxL0FGZbrBs3RB/iMYt+/yfrB1KH5ORMrop8
	 b1kxyZySQtD3qggT+VXUySRJ+H2Gct3sDh9qNn0NyadXy0wpRO7G7hzKxNRwr4+5jZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793293577;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition;
	bh=Q/e95YXjZPLi1Alp8MrVdFWbAjpPBFcZYJssjltrBmM=;
	b=LDYmtL5iocZ9CexuDVo2xPt1hHIbDOLW97sNbSpb8+s8NkBWjnbll/9z4dXkyck2ub+4
	 ROIkMtHg4a35/w7fEbEbu0WQEgLPQwkTXU8FB4lhbT8BzpSwkWI9l1Dl62laltOTNzCT2
	 cFlPSuwHmmZ+aOlHOxnGlcif6VQxNOkNxJD/IFDcuKsE6yC0K7FikmGODKosXeDMlPe5T
	 UFjDlmRLRRS1ir73vw/7OXy2B9r1yZVW3xPtVv+ZG35t7xTwuQJz+F1oMM9kAjHgBP1LZ
	 OKcqgi2lOvtz+RAIj5mi25XE1PxkPAgqeCaBiy98zofCxsw2gRZiXK5wrkcateqAlZg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="i+Ea/T2t";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F709606A335;
	Thu, 29 Oct 2026 17:06:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i+Ea/T2t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B47C81F01816;
	Thu, 29 Oct 2026 17:06:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793293577;
	bh=Q/e95YXjZPLi1Alp8MrVdFWbAjpPBFcZYJssjltrBmM=;
	h=Date:From:To:Cc:Subject;
	b=i+Ea/T2t764DpYOvybMnC/jnHT/C6QaI6sdhqkkNTELzVpfloGy6XM3iBkeL4r+8M
	 oW8q7D0DmBPP9Cy7Gzp5OUH5tv71bbshk7kIzPt+EUDCNRa/Vl6XehD9chVOCfe+Q3
	 6fgpGZLqsvpzKXgHakR9xF1z71MCvi2nNm0FuiLlQMGMtgFVIw5gtpycvtHLyeSBP0
	 FSS5c9ZLc5Tlyh+H1/GVX4Gsh7dIHkV+LTTfj5gcXqQQePac6dCwWfNY2fkuFQms/u
	 /rIZuDVrc0s8Y6eG+h6WrqD84xcFifPgRRPT/RRCSZC7fJAlBeBmrdjA1WXs3VVQ4i
	 yi0KrT1Xf80Lw==
Date: Thu, 29 Oct 2026 10:06:15 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Alberto Garcia <berto@igalia.com>,
	Baokun Li <libaokun@linux.alibaba.com>
Subject: [GIT PULL] fscrypt fixes for v7.4-rc1
Message-ID: <20261029170615.GA1862@quark>
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

The following changes since commit 5b0764a53235d3c77e1ed674e836e1b3fe1a4b1f:

  Merge tag 'drm-next-2026-10-21' of https://gitlab.freedesktop.org/drm/kernel (2026-10-23 18:29:02 -1000)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to a5e894bc87b76fd980075892ba77e6bdeeb5e4d0:

  ext4: reject encrypted inodes when block size > page size (2026-10-24 12:58:37 -0700)

----------------------------------------------------------------

- Add more checks to prevent encryption on "large block size" ext4
  filesystems (s_blocksize > PAGE_SIZE), which isn't supported yet.
  There was already a mount-time check, but it wasn't enough.

- Add missing memory barrier to fscrypt_find_mode_key()

- Add missing zeroization in an error path

----------------------------------------------------------------
Alberto Garcia (2):
      ext4: refuse encryption when block size > page size
      ext4: reject encrypted inodes when block size > page size

Baokun Li (1):
      fscrypt: Fix missing barrier in fscrypt_find_mode_key()

Eric Biggers (1):
      fscrypt: Explicitly zeroize sw_secret in error path

 fs/crypto/keyring.c  | 4 +++-
 fs/crypto/keysetup.c | 8 +++++++-
 fs/ext4/crypto.c     | 9 +++++++++
 fs/ext4/inode.c      | 6 ++++++
 4 files changed, 25 insertions(+), 2 deletions(-)
