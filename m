Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF6F6313531;
	Wed, 24 Jun 2026 05:05:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782277559; cv=none; b=oioVrLgs7oZe3sYYfLeOQHUQmh6uxNz0QqaarzxZlJe+SceZXcGedTLswGz+TaJFWChzfI73opKCFgYi1HPEyn5tMIU1i3YixH7OX40Z7bZM4FZ5m2P/keT2N3BFlaPIekRz8q6gXR/bi/YSx7L0MsVMAwfqnrXTQ3AuAS00/kE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782277559; c=relaxed/simple;
	bh=DLHjuuRPPX+LfcpEI/kiEoQD4w3kTds9F8lhqWhadg8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=gnGtXR7Z8cDLrEJ+8A9DZyhlrNeWfBgP9czNbTmwURkfVvXOKQgfJCpX5Q90EDu4Jr5uz61tPT1///3Nij3N895HWBkpnByCflK387AEt1ZRFbo3ipcHaKkbUh2QIvO1YfoMka5I+P5nsAE019J3m/MhNhtWGCrx5ns0QoAY9yg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NOuLezmi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NOuLezmi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F1D671F000E9;
	Wed, 24 Jun 2026 05:05:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782277558;
	bh=5YUFiQzd3x6NdgG13Jlp3OxISfEg5s3ydgP/rBYymgE=;
	h=From:To:Cc:Subject:Date;
	b=NOuLezmi2eOEpFm/ujP3KKp7Mf/QYbSot3vazQzNUfFL4RdsoccRpH1Nc3YEL9sap
	 8ifvgBWM0Wj0i2A8GvP1F/AlmhReHt7cWNBMUZEciigC+zE6dLFGJGVzDMxyPjyFba
	 ioi8E31xFczqydIbYqsSPXVX+P20m01Zk5kB7EPZQPerF/25+qEUF4ChpZaX/nELmm
	 nAxLs8w5kJx8iIz7wkFCOcjtRDc8o3d1nlqjtmG8rQogXn0A9+p/LGEKU+EbzdBzQM
	 f865DBkEvtdQ2zLYpLICfem6GaarfyIsSjAIMyEGZr/TjWaCC52QIFTsu5BJpWpJRQ
	 3KBYNue/QasHw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 00/16] fscrypt: Standardize on blk-crypto
Date: Tue, 23 Jun 2026 22:03:18 -0700
Message-ID: <20260624050334.124606-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series can also be retrieved from:

    git fetch https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/ fscrypt-blk-crypto-v1

Currently, ext4 and f2fs (i.e., the block-based filesystems with fscrypt
support) have two file contents encryption implementations:

 - Filesystem-layer, where code in fs/crypto/ directly invokes
   crypto_skcipher to en/decrypt data using the CPU.  This
   implementation requires the management of bounce pages at the
   filesystem level.  It doesn't support direct I/O or large folios.

 - blk-crypto (also known as inline encryption), where the filesystem
   assigns bio_crypt_ctxs to bios, which are then processed either by
   the CPU using blk-crypto-fallback.c or by inline encryption hardware.
   This supports direct I/O and is compatible with large folios.

Currently, the latter implementation is enabled only when the
"inlinecrypt" mount option is given.

The persistence of the fs-layer implementation is mainly for historical
reasons, as it came first.  It's becoming increasingly hard to maintain,
especially as the filesystems get refactored to use iomap, large folios,
etc.  It's time to remove it and just rely on the similar code in
blk-crypto-fallback.  This series does that.

Some fs-layer encryption support remains in fs/crypto/ for non-block
based filesystems (UBIFS and CephFS), as well as directories and
symlinks.  So it's not entirely gone, but it's reduced.

To be clear, this just changes an internal implementation detail.  ext4
and f2fs continue to fully support encryption (fscrypt), regardless of
the presence of inline encryption hardware on the system.

Eric Biggers (16):
  blk-crypto: Simplify check for fallback support
  blk-crypto: Fold __blk_crypto_cfg_supported() into its caller
  blk-crypto: Allow control over whether hardware is used
  fscrypt: Fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE
  fscrypt: Always use blk-crypto for contents on block-based filesystems
  ext4: Remove fs-layer file contents en/decryption code
  ext4: Make ext4_bio_write_folio() return void
  ext4: Further de-generalize the bio postprocessing code
  f2fs: Remove fs-layer file contents en/decryption code
  fs/buffer: Remove fs-layer decryption code
  fscrypt: Replace calls to fscrypt_inode_uses_inline_crypto()
  fscrypt: Remove fscrypt_dio_supported()
  fscrypt: Remove fs-layer zeroout code
  fscrypt: Remove unused functions and workqueue
  fscrypt: Merge bio.c and inline_crypt.c into block.c
  fscrypt: Add safety checks to non-block-based en/decryption

 Documentation/filesystems/fscrypt.rst       |  39 ++-
 arch/loongarch/configs/loongson32_defconfig |   1 -
 arch/loongarch/configs/loongson64_defconfig |   1 -
 block/blk-crypto-fallback.c                 |   3 +-
 block/blk-crypto-profile.c                  |  22 --
 block/blk-crypto.c                          |  31 ++-
 drivers/md/dm-inlinecrypt.c                 |   2 +-
 fs/buffer.c                                 |  45 +---
 fs/crypto/Kconfig                           |   8 +-
 fs/crypto/Makefile                          |   3 +-
 fs/crypto/bio.c                             | 216 ---------------
 fs/crypto/{inline_crypt.c => block.c}       | 283 +++++++++-----------
 fs/crypto/crypto.c                          | 140 ++++------
 fs/crypto/fscrypt_private.h                 |  28 +-
 fs/crypto/keysetup.c                        |  31 +--
 fs/crypto/policy.c                          |  17 ++
 fs/ext4/crypto.c                            |   2 +-
 fs/ext4/ext4.h                              |   6 +-
 fs/ext4/inode.c                             |  64 +----
 fs/ext4/page-io.c                           |  74 +----
 fs/ext4/readpage.c                          | 140 +++-------
 fs/ext4/super.c                             |   6 +-
 fs/f2fs/compress.c                          |  28 +-
 fs/f2fs/data.c                              |  93 +------
 fs/f2fs/f2fs.h                              |   2 -
 fs/f2fs/file.c                              |   2 -
 fs/f2fs/segment.c                           |   2 -
 fs/f2fs/super.c                             |   2 +-
 include/linux/blk-crypto.h                  |   6 +-
 include/linux/fscrypt.h                     |  96 ++-----
 30 files changed, 357 insertions(+), 1036 deletions(-)
 delete mode 100644 fs/crypto/bio.c
 rename fs/crypto/{inline_crypt.c => block.c} (61%)


base-commit: 1dc18801be29bc54709aa355b8acd80e183b03cd
prerequisite-patch-id: 319d2891e88c7df1ebb5ebf434d18b68f770399f
prerequisite-patch-id: f6157c86deab0ff5ec953ae3ed6b0e84f37741bf
prerequisite-patch-id: 5330c9e4b65644baae81bd177a46be6223d2b494
prerequisite-patch-id: 073cb85332cc58e4b5066bf8f7ac948c0d9a2bac
prerequisite-patch-id: 4b1b7521df7ce7157156dbbc373c699060b21e3f
prerequisite-patch-id: edfd2a34a97697517828f233e478e5b7f8cf85c2
-- 
2.54.0

