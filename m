Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C55D8433E8C;
	Sun,  5 Jul 2026 19:47:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783280858; cv=none; b=npLjKJ2uMq7Yd21g1EqiGF12/eyBuGy9GEq3k1GQ0qZmfofKmgP+M0CMEv9ldg8Rnk/a2+mXfwkgfm4VQrtAWDP2i5hAxqO1f/eAcdYX9nng5p/DLIw0Gx09beg8bwU5Lrdbyp69SUchylKtFW3jCzt4NwrJlI+0hguWx48dHLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783280858; c=relaxed/simple;
	bh=nGQIqMgEXiLXD0x1G5Zf+14Q+SCTlORmX1fo1uhpclg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dJFQrZoudHqPJRkx4x1B3bnGCbw4NIzJAIF/sB5xqaEGiOsZz1z0c3rZb8Vl90rxF8Wh2biY6nPipagVQxeo7q47uhE+NnlfP+s3x24LdY29y7vaPlVv+AKuF5laIvGXTWjZplTd8lq6raW+heUUCHin51bnKJBq9/51L8aIRJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=e0XOG7yN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="e0XOG7yN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9454F1F000E9;
	Sun,  5 Jul 2026 19:47:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783280856;
	bh=qcRkO0YeM29chatD/XAiCFByzOxWthm1N/Hu3jDnoeA=;
	h=From:To:Cc:Subject:Date;
	b=e0XOG7yNL/Rqj+p+NKjWV/AXtgtIHh3XHecNxTP5SSIsFWPEsFHEHvYDHZcXB9uP3
	 3qaSSZ4njfdXc7fkks8KTQqkSwG0zzFYDjJnUte4YFXbD/3RSqMNupM+ZvStSNKzdx
	 tg6zaAwKPDxIsgNdWsJVuFJsmH1fCWpN5FUExhqXr0QE8SCwloiVT1ND8n0yzIF0yA
	 i3qPB401mnQunNtg+zsdHEIdXnLTETGdRFjRyBXUrNhhXBnwMNEv0r40xvU0PWhuPN
	 G3EUDw+6JO73Mtk8itYDkvx7Zo3pqDg2TpS/XpT52OjS7DfVdgwAssz5Uc8/mxOu/e
	 5eG0Npy2nx7Dg==
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
Subject: [PATCH v2 00/17] fscrypt: Standardize on blk-crypto
Date: Sun,  5 Jul 2026 12:45:37 -0700
Message-ID: <20260705194555.75030-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This series applies to commit 2d0afaac9137e9 of
https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next
It can also be retrieved from:

    git fetch https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/ fscrypt-blk-crypto-v2

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

Changed in v2:

  - Replaced the allow_hw bool with a flags argument.

  - Added patch "Documentation: fscrypt: Update docs for inlinecrypt"
    which updates the documentation more completely by updating not just
    fscrypt.rst (which was previously part of another patch), but also
    the documentation for inlinecrypt in ext4.rst and f2fs.rst.  

  - Removed extern from declarations of ext4_init_verity_caches() and
    ext4_exit_verity_caches()
 
  - Remove unused 'inode' argument from ext4_set_verity_work()

  - Added Reviewed-by tags

Eric Biggers (17):
  blk-crypto: Simplify check for fallback support
  blk-crypto: Fold __blk_crypto_cfg_supported() into its caller
  blk-crypto: Allow control over whether hardware is used
  fscrypt: Fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE
  fscrypt: Always use blk-crypto for contents on block-based filesystems
  Documentation: fscrypt: Update docs for inlinecrypt
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

 Documentation/admin-guide/ext4.rst          |   8 +-
 Documentation/filesystems/f2fs.rst          |  10 +-
 Documentation/filesystems/fscrypt.rst       |  39 ++-
 arch/loongarch/configs/loongson32_defconfig |   1 -
 arch/loongarch/configs/loongson64_defconfig |   1 -
 block/blk-crypto-fallback.c                 |   3 +-
 block/blk-crypto-profile.c                  |  22 --
 block/blk-crypto.c                          |  34 ++-
 drivers/md/dm-inlinecrypt.c                 |   3 +-
 fs/buffer.c                                 |  45 +---
 fs/crypto/Kconfig                           |   8 +-
 fs/crypto/Makefile                          |   3 +-
 fs/crypto/bio.c                             | 216 ---------------
 fs/crypto/{inline_crypt.c => block.c}       | 284 ++++++++++----------
 fs/crypto/crypto.c                          | 140 ++++------
 fs/crypto/fscrypt_private.h                 |  28 +-
 fs/crypto/keysetup.c                        |  31 +--
 fs/crypto/policy.c                          |  17 ++
 fs/ext4/crypto.c                            |   2 +-
 fs/ext4/ext4.h                              |   6 +-
 fs/ext4/inode.c                             |  64 +----
 fs/ext4/page-io.c                           |  74 +----
 fs/ext4/readpage.c                          | 139 +++-------
 fs/ext4/super.c                             |   6 +-
 fs/f2fs/compress.c                          |  31 +--
 fs/f2fs/data.c                              |  93 +------
 fs/f2fs/f2fs.h                              |   2 -
 fs/f2fs/file.c                              |   2 -
 fs/f2fs/segment.c                           |   2 -
 fs/f2fs/super.c                             |   2 +-
 include/linux/blk-crypto.h                  |  14 +-
 include/linux/fscrypt.h                     |  96 ++-----
 32 files changed, 375 insertions(+), 1051 deletions(-)
 delete mode 100644 fs/crypto/bio.c
 rename fs/crypto/{inline_crypt.c => block.c} (61%)


base-commit: 2d0afaac9137e95e504bd3ad3512a9044745536b
-- 
2.54.0

