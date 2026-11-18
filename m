Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961776;
	b=PCK1u2jUfS3xyzIxHDC3si0GectRg+hB1TDQUaZsOo59zO4Qla0LIE3pm+csydsIYwMJ
	 CCLRBIU47LbTpNbolLS/CgDd1aCmG+JZVzUmz43ccGksDEU8bE0lwluw7ga8UUTnTz++J
	 pyaDFHEJkEFygoZxT7JPALtHx9iXMnep5jS2l4hMzjDZ11152hMUGl8PNON9rYYSIIKHD
	 /TCau3/CGC4B1LpRRdcndzICJfmSZA4uknWui/aEuJcAowJHQ2OtxVI08kgBWxXJdCO0M
	 2pjc+D5HXSLU/X5bMJ9oFDEdYHeqcKJ1ug+yUH2eEbGiyQChqIslt+/J7NubO1oPAtw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961776;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-Developer-Signature:X-Developer-Key:
	 Content-Transfer-Encoding;
	bh=qNXt9CrtwBP/UShhCkJznTf/nidzDEjoR+gXc90tUlE=;
	b=HZUQ9YTiRTuO7Nmam/HVTlWDjTme3YaxCtLidZbXb3qCkRsC1jCOQGbVCBmk+cJGW+bZ
	 m+wSvr8e4d2x7ROoA7miNMc4rppeJKSwb20WXygmNyR1Qz8mCVfCsrU48C7+Ox8TDSmxp
	 2gpFl1fbfoIjJSAGRkzkSlCF4ZyNyFrBXS/ny5/eAv8xs4Xflzm2xerDiVFzIVW6+l6Ag
	 GTOcXHzYO7EFoselXxQd6H+h9vg7fj+Qy3Q0ZNP1D1UO4udXpqyH5Kelg30cyyybc07QC
	 pDrIXwFgefEWce39MlvbZuw8Rl3cfLKtZy0EswH1bRoTMZwRSlzUqaT9SJz3vJABkMg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R7oQLSyE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A982606A31C;
	Wed, 18 Nov 2026 00:29:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R7oQLSyE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D68D01F000C4;
	Wed, 18 Nov 2026 00:29:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794961776;
	bh=qNXt9CrtwBP/UShhCkJznTf/nidzDEjoR+gXc90tUlE=;
	h=From:To:Cc:Subject:Date;
	b=R7oQLSyEL2pcGI1LgWXqvBRuFvDXgrxHyqrzhhpooghQUP5mlr4xyynm7F8jbOMDD
	 PYH4i6YSAbmQVvYK0HyDYT6Zx5CzESmw5G+ROIhEgR+h6jiIdbMKuXnhCEjc/Lzy5L
	 exwybYXRrpf4lytvHpJunftrfDkcrGwG92v6V+pWBcbqFU3FkU9wl9CGA+l9UAhVAF
	 rKu/B4bKdKI7yJ7T36P1BMh6J+QlBj5OlZ7fZsgEczMYZHDwW4wzKRMlCpPTnymTXk
	 NsxWx0g64DaJxxDpf5y1jmIanBDipGhZK7GPyb7+TfL4K+eRCq5GeF9pF7Gj6BKzUf
	 6HeZK24C2Irmw==
From: Thorsten Blum <blum@kernel.org>
To: David Sterba <dsterba@suse.com>,
	Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org,
	linux-fscrypt@vger.kernel.org,
	Thorsten Blum <blum@kernel.org>
Subject: [PATCH 0/4] fscrypt: Add FSTR() helper macro and convert initializers
Date: Wed, 18 Nov 2026 01:28:46 +0100
Message-ID: <20261118002845.574426-6-blum@kernel.org>
X-Mailer: git-send-email 2.56.1
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=716; i=blum@kernel.org; h=from:subject; bh=wqbOfCuCbdUcemVKsc9HdxKwyAV8xTGLwFPgISLMeYE=; b=owGbwMvMwCUWt7pQ4caZUj3G02pJDFl/PtrOPPLOlNey+xjX9vwP7NPkJococ3yzDrV/Vf5Fb UGhytqFHaUsDGJcDLJiiiwPZv2Y4VtaU7nJJGInzBxWJpAhDFycAjCR7qkM/109FfZ8O2wdlXJg YnLU4vt5bx6kpHxW+TTt088oN+1jW4oZ/tnuPNNc0OU9y7Nf7F5uZ5103Yr3KsmdDgqRnjH3dzC Z8AAA
X-Developer-Key: i=blum@kernel.org; a=openpgp; fpr=1D60735E8AEF3BE473B69D84733678FD8DFEEAD4
Content-Transfer-Encoding: 8bit

Similar to QSTR(), add FSTR() to initialize struct fscrypt_str from a
NUL-terminated string without specifying its length.

Use the helper for 8 initializers in btrfs, F2FS, and UBIFS, replacing
hard-coded lengths and explicit strlen() calls.

Thorsten Blum (4):
  fscrypt: Add FSTR() helper macro
  btrfs: Use FSTR() for the "default" name
  f2fs: Use FSTR() in f2fs_do_make_empty_dir()
  ubifs: Use FSTR() in ubifs_xattr_{set,get,remove}()

 fs/btrfs/inode.c        | 3 +--
 fs/btrfs/ioctl.c        | 3 +--
 fs/btrfs/super.c        | 3 +--
 fs/f2fs/dir.c           | 7 ++-----
 fs/ubifs/xattr.c        | 6 +++---
 include/linux/fscrypt.h | 1 +
 6 files changed, 9 insertions(+), 14 deletions(-)
