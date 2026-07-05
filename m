Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81DA03A7D9E;
	Sun,  5 Jul 2026 19:48:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783280886; cv=none; b=QrvWG1/Kir3sE2nruasqxulIh+iBXpPv/8ah4764IEEKjz68OsHr3e5qESZrrqMsrZ4cnA9CvJjktety6XcMX7hyqKKBhAFhSeJCpIHTzBi5Ng6MI9h6yYyOA0/EunEYVmj8ABA2Sb+JTnRFmvwTmn/WNjok6vGAVo49rrFSf3U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783280886; c=relaxed/simple;
	bh=EC0Aakh1yWKRSTNuCMSYnpOLzzW5YERw936bH6JO5AI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eFVVvhnPvsnGVYCGnDnNA0/WlnCYFogsx62YL5Oh+DmxF3RZWU5vxlq1vambCW6UiH7gRmd/my531Ih99jFjtgX/gGpwV2s6foq+edyzWQ2akosA0gfQl+nETHbdISTLaHAsd8Ssv4ioyOAWorz1kkZ5rCKh5+IuEKpAxH/pORg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sql50m2Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sql50m2Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51B5B1F000E9;
	Sun,  5 Jul 2026 19:48:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783280885;
	bh=nkvnJ8oJZh+bVhSs7wFscRTKd8Hvl3yWkKR6CSgRjsI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Sql50m2YoWn05Cg7wPf1fFKcFvnf2Z+Cb2umzXzfPdHtOGGypQ4uJ8Be3EHbscblk
	 1AqJVYf5SqLdErhfaN6w9RP1ctnnvaaICPJ0o/gioTHrqH9xGm+FZfqHMq6hWCsjjI
	 gs1bPjbtZjwFRyH0AfMjxZ20vN26wf/wuP3Zg/30wbELS2kZJCiCY8MkAWMy1097Ow
	 TT4Be0P2uDP80E38VagZYnuXZCszC0U4dNFp8lt3dlMtDhvzOnfujBKA1CUxf5seIL
	 WtymsXUaH76KZ3GhLbJ/HPs1UfG8m97UcoohoFQwnJ4EzS71SBVGyD9um25RMl35O0
	 VNmkMTgVuTUhg==
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
Subject: [PATCH v2 12/17] fscrypt: Replace calls to fscrypt_inode_uses_inline_crypto()
Date: Sun,  5 Jul 2026 12:45:49 -0700
Message-ID: <20260705194555.75030-13-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260705194555.75030-1-ebiggers@kernel.org>
References: <20260705194555.75030-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Now that fscrypt's file contents en/decryption is always implemented
using blk-crypto when the filesystem is block-based, the calls to
fscrypt_inode_uses_inline_crypto() in fs/crypto/inline_crypt.c (which
contains functions that are called only from block-based filesystems)
are equivalent to checking whether the file is an encrypted regular
file, i.e. fscrypt_needs_contents_encryption().  Use that instead.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/inline_crypt.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index 3a92bd57e3eb..685815fa71a6 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -228,8 +228,8 @@ static void fscrypt_generate_dun(const struct fscrypt_inode_info *ci,
  * @gfp_mask: memory allocation flags - these must be a waiting mask so that
  *					bio_crypt_set_ctx can't fail.
  *
- * If the contents of the file should be encrypted (or decrypted) with inline
- * encryption, then assign the appropriate encryption context to the bio.
+ * If the contents of the file should be encrypted (or decrypted), then assign
+ * the appropriate encryption context to the bio.
  *
  * Normally the bio should be newly allocated (i.e. no pages added yet), as
  * otherwise fscrypt_mergeable_bio() won't work as intended.
@@ -242,7 +242,7 @@ void fscrypt_set_bio_crypt_ctx(struct bio *bio, const struct inode *inode,
 	const struct fscrypt_inode_info *ci;
 	u64 dun[BLK_CRYPTO_DUN_ARRAY_SIZE];
 
-	if (!fscrypt_inode_uses_inline_crypto(inode))
+	if (!fscrypt_needs_contents_encryption(inode))
 		return;
 	ci = fscrypt_get_inode_info_raw(inode);
 
@@ -257,12 +257,12 @@ EXPORT_SYMBOL_GPL(fscrypt_set_bio_crypt_ctx);
  * @inode: the inode for the next part of the I/O
  * @pos: the next file position (in bytes) in the I/O
  *
- * When building a bio which may contain data which should undergo inline
- * encryption (or decryption) via fscrypt, filesystems should call this function
- * to ensure that the resulting bio contains only contiguous data unit numbers.
- * This will return false if the next part of the I/O cannot be merged with the
- * bio because either the encryption key would be different or the encryption
- * data unit numbers would be discontiguous.
+ * When building a bio which may contain data which should undergo encryption
+ * (or decryption) via fscrypt, filesystems should call this function to ensure
+ * that the resulting bio contains only contiguous data unit numbers.  This will
+ * return false if the next part of the I/O cannot be merged with the bio
+ * because either the encryption key would be different or the encryption data
+ * unit numbers would be discontiguous.
  *
  * fscrypt_set_bio_crypt_ctx() must have already been called on the bio.
  *
@@ -279,7 +279,7 @@ bool fscrypt_mergeable_bio(struct bio *bio, const struct inode *inode,
 	const struct fscrypt_inode_info *ci;
 	u64 next_dun[BLK_CRYPTO_DUN_ARRAY_SIZE];
 
-	if (!!bc != fscrypt_inode_uses_inline_crypto(inode))
+	if (!!bc != fscrypt_needs_contents_encryption(inode))
 		return false;
 	if (!bc)
 		return true;
@@ -337,7 +337,7 @@ bool fscrypt_dio_supported(struct inode *inode)
 		 */
 		return false;
 	}
-	return fscrypt_inode_uses_inline_crypto(inode);
+	return true;
 }
 EXPORT_SYMBOL_GPL(fscrypt_dio_supported);
 
@@ -366,7 +366,7 @@ u64 fscrypt_limit_io_blocks(const struct inode *inode, u64 lblk, u64 nr_blocks)
 	const struct fscrypt_inode_info *ci;
 	u32 dun;
 
-	if (!fscrypt_inode_uses_inline_crypto(inode))
+	if (!fscrypt_needs_contents_encryption(inode))
 		return nr_blocks;
 
 	if (nr_blocks <= 1)
-- 
2.54.0

