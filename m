Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B00E3815FB;
	Wed, 24 Jun 2026 05:06:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782277567; cv=none; b=N+4sLpZb1gti9LmleVhSFzDFA+fxc4OKqCcGClHvxOI3MGq8ebN82adJtC2RLbH+1fAhH/i7US+XM1/IpWpZSud6qNAIMFYwhLjw0KHDZ+VaA6f2DNQ8yY4pFDdKK5qBky0zVOu2qYkkeFB5Lj70lrgHPQzUP+CY9Y8yGJyI7M0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782277567; c=relaxed/simple;
	bh=A5hN6c0GQfbbl/WeZ0hce1sNen9tn+svuDMzpl7ISOA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lfHdsIyo0psxYrYxmsVZV1/GIdGKqCGwjlg+2ipfr4zwGqHRIBOR28mS2mC24EQ062NFpjpNRGodY6eVycskYHbhi9X8Jdaxb8Ak6C4kutEEJ9jkVysXCaEWxgOTnSnE4416QXBRwvPDsI/BW3bpQ4vpSJu8XClUi7mmtJt+nEM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=deOzfmmE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="deOzfmmE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16E7B1F00A3D;
	Wed, 24 Jun 2026 05:06:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782277565;
	bh=Mn6lr6qCjRwiUrSp6jfp28uOZlKSNZU4XGVuJV9dOYg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=deOzfmmEUqdYcKN2dPmZMd6/fcExt4/EhjfALy+7ri425ZGTchaHzk4OzqvrqGg+k
	 MLuz6EshZhYz7N0KtGl6k1DqvgrSaz4/6uynrxAyuWWdKLM4SHRPw1bnAxiN5fKxmv
	 NL0nZUpbGAQ0UIu3HGZswNGC3VU49e3o5sV8Hz/h6PSJ/cGXoYLN134rAwqRsYlgrT
	 yqhaAZm45fbskswrhptzFLZRBD6aRaozUR94JWx9e86AaT7gVikJAIr6vyEiUF93kB
	 KV26bcPITKbb9NJM5He03oSv+m/obJADyAX3IOqZ9m6A/7EKGSj3PlF4KNEpCnjclk
	 4bUJdBA6JHRow==
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
Subject: [PATCH 11/16] fscrypt: Replace calls to fscrypt_inode_uses_inline_crypto()
Date: Tue, 23 Jun 2026 22:03:29 -0700
Message-ID: <20260624050334.124606-12-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260624050334.124606-1-ebiggers@kernel.org>
References: <20260624050334.124606-1-ebiggers@kernel.org>
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

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/inline_crypt.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index caf706215621..111ea45732f0 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -225,12 +225,12 @@ static void fscrypt_generate_dun(const struct fscrypt_inode_info *ci,
  * @inode: the file's inode
  * @pos: the first file position (in bytes) in the I/O
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
  *
  * The encryption context will be freed automatically when the bio is freed.
@@ -239,11 +239,11 @@ void fscrypt_set_bio_crypt_ctx(struct bio *bio, const struct inode *inode,
 			       loff_t pos, gfp_t gfp_mask)
 {
 	const struct fscrypt_inode_info *ci;
 	u64 dun[BLK_CRYPTO_DUN_ARRAY_SIZE];
 
-	if (!fscrypt_inode_uses_inline_crypto(inode))
+	if (!fscrypt_needs_contents_encryption(inode))
 		return;
 	ci = fscrypt_get_inode_info_raw(inode);
 
 	fscrypt_generate_dun(ci, pos, dun);
 	bio_crypt_set_ctx(bio, ci->ci_enc_key.blk_key, dun, gfp_mask);
@@ -254,16 +254,16 @@ EXPORT_SYMBOL_GPL(fscrypt_set_bio_crypt_ctx);
  * fscrypt_mergeable_bio() - test whether data can be added to a bio
  * @bio: the bio being built up
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
  * This function isn't required in cases where crypto-mergeability is ensured in
  * another way, such as I/O targeting only a single file (and thus a single key)
@@ -276,11 +276,11 @@ bool fscrypt_mergeable_bio(struct bio *bio, const struct inode *inode,
 {
 	const struct bio_crypt_ctx *bc = bio->bi_crypt_context;
 	const struct fscrypt_inode_info *ci;
 	u64 next_dun[BLK_CRYPTO_DUN_ARRAY_SIZE];
 
-	if (!!bc != fscrypt_inode_uses_inline_crypto(inode))
+	if (!!bc != fscrypt_needs_contents_encryption(inode))
 		return false;
 	if (!bc)
 		return true;
 	ci = fscrypt_get_inode_info_raw(inode);
 
@@ -334,11 +334,11 @@ bool fscrypt_dio_supported(struct inode *inode)
 		 * Key unavailable or couldn't be set up.  This edge case isn't
 		 * worth worrying about; just report that DIO is unsupported.
 		 */
 		return false;
 	}
-	return fscrypt_inode_uses_inline_crypto(inode);
+	return true;
 }
 EXPORT_SYMBOL_GPL(fscrypt_dio_supported);
 
 /**
  * fscrypt_limit_io_blocks() - limit I/O blocks to avoid discontiguous DUNs
@@ -363,11 +363,11 @@ EXPORT_SYMBOL_GPL(fscrypt_dio_supported);
 u64 fscrypt_limit_io_blocks(const struct inode *inode, u64 lblk, u64 nr_blocks)
 {
 	const struct fscrypt_inode_info *ci;
 	u32 dun;
 
-	if (!fscrypt_inode_uses_inline_crypto(inode))
+	if (!fscrypt_needs_contents_encryption(inode))
 		return nr_blocks;
 
 	if (nr_blocks <= 1)
 		return nr_blocks;
 
-- 
2.54.0

