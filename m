Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCBCA46C4C5;
	Mon, 17 Aug 2026 17:33:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786988000; cv=none; b=hSD0vfYXLzRxJQ7tAPFs5jK84vZmTbH70kUcEferzm8hJS5x8oToD0vFZd3HmXnccT4Re1MTV01eh9pVryZQHohm8h7C6prupstH6AT5qjpY2xPXPLgnai69qQeQ0Tg+n5MQaJu0x1TdT6XsZAaiidK9gWwkAP8YZNv3KgCNgZ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786988000; c=relaxed/simple;
	bh=DNrgx7RPzmX362il76PIMdQkIiYBm4+v9LhzABok7EE=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=Xn4szuGBVMTmHeCKuCgPCkNKqVTC8VUecfeo4SQGauxg/lecS9itCgxyY01aYPRqpchhy5rAmXKLTjQIIYseqbUCQ1KMWntcNUAc1kl98TwVAMxxg0MyGdNccxEeoHwsK0fIlBwBXwTE9YNRWZPIUzPUugXTt36pkfUrWneUPc0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DkCH1N9L; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DkCH1N9L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E5EB1F00A3A;
	Mon, 17 Aug 2026 17:33:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786987993;
	bh=EmyV7xbzNpKPMsgyi7dD1KtLhUmJvpKWR0aS98Q0COk=;
	h=Date:From:To:Cc:Subject;
	b=DkCH1N9Lskx1xfHS9tQKoXIYa9ECtWkT0PFiAorHAT9gTDyb5YmdOGUImCvXbr9ZP
	 7UnJf8n6ye5OGeTaQb2nwqy725T7QcTe3N2amXGBn9H8w6a+iM4O1YHntanFRDUgTP
	 ITM8/ZjVTuPS8gM2EuV9ekbbLRTXSLqf1pGMvQGozgvtdeB/6QpaoIK0sVSNKPsLbD
	 U2sbbw6+uxxEqOeEe0jxiZnm59+AueHzXLp/vGg9kxoGmk3MXZIRys8GkG1/x+oE8i
	 hJmrJhEtomWzI/myHBmI9FKStCNCCnUQWYLJkuzm0/vzr5ngZz3kpVJrfhZLJsZ1Am
	 50UpOyClxFn3w==
Date: Mon, 17 Aug 2026 10:33:11 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Subject: [GIT PULL] fscrypt updates for 7.3
Message-ID: <20260817173311.GB8327@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The following changes since commit 6fe4e4b8259e1330945b5f3c9476e08473b8e0e8:

  fscrypt: Avoid dynamic allocation in fscrypt_get_devices() (2026-07-20 10:39:24 -0700)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/linux.git tags/fscrypt-for-linus

for you to fetch changes up to 7dd38d9dd7a05329825fe2324d4d8e27ad4b3cec:

  blk-crypto: Update docs for blk-crypto-fallback motivation (2026-07-20 10:39:26 -0700)

----------------------------------------------------------------

The main change this cycle is a significant simplification that's been
overdue for a while now: standardizing on a single file contents
encryption implementation in ext4 and f2fs, instead of having two.

Specifically, the original filesystem-layer file contents encryption
implementation is removed, and the blk-crypto implementation is now
used unconditionally. blk-crypto delegates either to inline crypto
hardware or to the CPU via blk-crypto-fallback. The latter is
functionally equivalent to the original filesystem-layer code.

The blk-crypto implementation already existed, but previously it was
used only when the filesystem was mounted with "-o inlinecrypt". Now,
"-o inlinecrypt" just selects whether inline crypto hardware is used.

To allow maintaining that user control over hardware use, the
blk-crypto API is extended with a new flag BLK_CRYPTO_CFG_ALLOW_HW.

Overall, this removes quite a bit of redundant code from ext4, f2fs,
and fs/crypto/. It should make things easier for ongoing filesystem
efforts such as iomap support, large folios, and btrfs encryption.
(btrfs had already been planning to use blk-crypto exclusively.)

There are two small behavior changes of note:

- Direct I/O now works on encrypted files even without
  "-o inlinecrypt", rather than falling back to buffered I/O. This is
  effectively a bugfix, though I'll continue to keep an eye out for
  any user that may have been depending on the buffered I/O fallback.

- IV_INO_LBLK_32 policies are no longer supported in certain cases
  that didn't make sense and have no known uses.

This has been in linux-next since July 22 with no reported issues.
All encryption xfstests pass on ext4 and f2fs. As usual I've also been
using it on a system with an fscrypt-encrypted home directory. Of
course, the blk-crypto code paths also aren't new and were already
being used on many systems via the inlinecrypt mount option.

In addition to the main change described above, there are a few other
cleanups such as using lock guards for mutexes, improving
documentation, and removing a workaround for outdated gcc versions.

----------------------------------------------------------------
Eric Biggers (29):
      fscrypt: Use lock guards for mutexes
      fscrypt: Remove FSCRYPT_MODE_MAX
      fscrypt: Simplify handling of errors during initcall
      fscrypt: Remove workaround for bug in gcc 7 and earlier
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
      fscrypt: Replace some variable-size memsets with fixed-size
      fscrypt: Update encryption policy version docs
      fs: Update outdated comment for SB_INLINECRYPT
      f2fs: Update outdated comment in f2fs_write_begin()
      fscrypt: Remove unused function fscrypt_finalize_bounce_page()
      fscrypt: Update docs for data path
      blk-crypto: Remove unused function blk_crypto_config_supported()
      blk-crypto: Update docs for blk-crypto-fallback motivation

 Documentation/admin-guide/ext4.rst          |   8 +-
 Documentation/block/inline-encryption.rst   |  43 ++---
 Documentation/filesystems/f2fs.rst          |  10 +-
 Documentation/filesystems/fscrypt.rst       | 154 +++++++--------
 arch/loongarch/configs/loongson32_defconfig |   1 -
 arch/loongarch/configs/loongson64_defconfig |   1 -
 block/blk-crypto-fallback.c                 |   3 +-
 block/blk-crypto-internal.h                 |   3 -
 block/blk-crypto-profile.c                  |  22 ---
 block/blk-crypto.c                          |  46 +++--
 drivers/md/dm-inlinecrypt.c                 |   3 +-
 fs/buffer.c                                 |  45 +----
 fs/crypto/Kconfig                           |   8 +-
 fs/crypto/Makefile                          |   3 +-
 fs/crypto/bio.c                             | 216 ---------------------
 fs/crypto/{inline_crypt.c => block.c}       | 279 ++++++++++++++--------------
 fs/crypto/crypto.c                          | 180 ++++++------------
 fs/crypto/fscrypt_private.h                 |  33 +---
 fs/crypto/keyring.c                         |  21 +--
 fs/crypto/keysetup.c                        |  63 ++-----
 fs/crypto/keysetup_v1.c                     |   2 +-
 fs/crypto/policy.c                          |  34 ++--
 fs/ext4/crypto.c                            |   2 +-
 fs/ext4/ext4.h                              |   6 +-
 fs/ext4/inode.c                             |  71 ++-----
 fs/ext4/page-io.c                           |  74 +-------
 fs/ext4/readpage.c                          | 139 ++++----------
 fs/ext4/super.c                             |   6 +-
 fs/f2fs/compress.c                          |  31 +---
 fs/f2fs/data.c                              |  95 +---------
 fs/f2fs/f2fs.h                              |   2 -
 fs/f2fs/file.c                              |   6 +-
 fs/f2fs/segment.c                           |   2 -
 fs/f2fs/super.c                             |   2 +-
 include/linux/blk-crypto.h                  |  15 +-
 include/linux/fs/super_types.h              |   2 +-
 include/linux/fscrypt.h                     | 107 ++---------
 include/uapi/linux/fscrypt.h                |   1 -
 tools/include/uapi/linux/fscrypt.h          |   1 -
 39 files changed, 494 insertions(+), 1246 deletions(-)
 delete mode 100644 fs/crypto/bio.c
 rename fs/crypto/{inline_crypt.c => block.c} (61%)
