Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1DAB37E2F9;
	Mon, 13 Jul 2026 02:39:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783910396; cv=none; b=CtEG14dtuZ6hAAk3PFduTwba/ZikJsGan1JKmgUlAS1wBiTw7c6Iis0rqCyLvdJzOQ5A5JnjV7ulR1PF5PeKtQoAvbiX1gg2cdZqofbLIRjrz+Bq7f+sIg3lMrDYJRa1Rbx4x8GY3uIscJhg2P5C8ike4ohS1oXTg4EwheBAMsY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783910396; c=relaxed/simple;
	bh=IdGBKYqjPjbOf1UGVMk+BcK86QodDlIfrKYdL4n1Akc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GzrC3vnFYW0LP1H6fH0bIf2eIayNkeqNOIEUYYmTFkL/aOCa51i5SXq4F3KsUGAytDbhGsOieO5kgckQiNpCBagr7OLP2Jy4i5q8W+E1360UE2trtUitLcCyEcqEghcDNi3sQrjneHXK0zLCaCwApReXt3Nfiyvlrj+RCBODp1U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=deORRl5j; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="deORRl5j"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 177391F00A3D;
	Mon, 13 Jul 2026 02:39:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783910394;
	bh=BMAIOIoPLRG3X17cKZ1TRIpYWgnIKVg8nbkYwoXEk4M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=deORRl5jOuxzi5FNTOJyFeSMft4mkPBl655PGc905s4Y0NaqrB6MgqPaZTjz+ytIq
	 ThmP27RpJb2dUMqZ5kI0X1deSLsyS2ndmU1IcMooTxxO/02Tf2pK+0+K5R5Yl7/ewG
	 f/LxTtjJ6tkM7GobLsGWnbxJphrMHEC+s530rx6Q1XYnDFWtuhmhU8RJlu632LMMC0
	 KYGYB+Wu/PfRqLO75Uxrxz/Iiduc3J2HKDAjS02DMASksrhwIdQat1fZYnZrny9cNY
	 iFLqmHbwuoCaxODta0nzkHApFn2DnjUPATMlKLGpDBAebRMqNcQ1r+WjXXBMwV9fCB
	 9YokIkM5X8zIA==
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
Subject: [PATCH v3 15/17] fscrypt: Remove unused functions and workqueue
Date: Sun, 12 Jul 2026 22:37:06 -0400
Message-ID: <20260713023708.9245-16-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260713023708.9245-1-ebiggers@kernel.org>
References: <20260713023708.9245-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Remove functions that are no longer used:

- fscrypt_decrypt_bio()
- fscrypt_decrypt_pagecache_blocks()
- fscrypt_inode_uses_fs_layer_crypto()
- fscrypt_inode_uses_inline_crypto()
- fscrypt_enqueue_decrypt_work()

This makes the decryption workqueue unused, so remove it too.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/bio.c         | 32 --------------------
 fs/crypto/crypto.c      | 65 -----------------------------------------
 include/linux/fscrypt.h | 47 -----------------------------
 3 files changed, 144 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 58b6b13eeedd..db095258cfca 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -15,38 +15,6 @@
 
 #include "fscrypt_private.h"
 
-/**
- * fscrypt_decrypt_bio() - decrypt the contents of a bio
- * @bio: the bio to decrypt
- *
- * Decrypt the contents of a "read" bio following successful completion of the
- * underlying disk read.  The bio must be reading a whole number of blocks of an
- * encrypted file directly into the page cache.  If the bio is reading the
- * ciphertext into bounce pages instead of the page cache (for example, because
- * the file is also compressed, so decompression is required after decryption),
- * then this function isn't applicable.  This function may sleep, so it must be
- * called from a workqueue rather than from the bio's bi_end_io callback.
- *
- * Return: %true on success; %false on failure.  On failure, bio->bi_status is
- *	   also set to an error status.
- */
-bool fscrypt_decrypt_bio(struct bio *bio)
-{
-	struct folio_iter fi;
-
-	bio_for_each_folio_all(fi, bio) {
-		int err = fscrypt_decrypt_pagecache_blocks(fi.folio, fi.length,
-							   fi.offset);
-
-		if (err) {
-			bio->bi_status = errno_to_blk_status(err);
-			return false;
-		}
-	}
-	return true;
-}
-EXPORT_SYMBOL(fscrypt_decrypt_bio);
-
 struct fscrypt_zero_done {
 	atomic_t		pending;
 	blk_status_t		status;
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 8c4660429418..27663f4d8705 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -38,17 +38,10 @@ MODULE_PARM_DESC(num_prealloc_crypto_pages,
 
 static mempool_t *fscrypt_bounce_page_pool = NULL;
 
-static struct workqueue_struct *fscrypt_read_workqueue;
 static DEFINE_MUTEX(fscrypt_init_mutex);
 
 struct kmem_cache *fscrypt_inode_info_cachep;
 
-void fscrypt_enqueue_decrypt_work(struct work_struct *work)
-{
-	queue_work(fscrypt_read_workqueue, work);
-}
-EXPORT_SYMBOL(fscrypt_enqueue_decrypt_work);
-
 static struct page *fscrypt_alloc_bounce_page(gfp_t gfp_flags)
 {
 	if (WARN_ON_ONCE(!fscrypt_bounce_page_pool)) {
@@ -238,50 +231,6 @@ int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
 }
 EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
 
-/**
- * fscrypt_decrypt_pagecache_blocks() - Decrypt data from a pagecache folio
- * @folio: the pagecache folio containing the data to decrypt
- * @len: size of the data to decrypt, in bytes
- * @offs: offset within @folio of the data to decrypt, in bytes
- *
- * Decrypt data that has just been read from an encrypted file.  The data must
- * be located in a pagecache folio that is still locked and not yet uptodate.
- * The length and offset of the data must be aligned to the file's crypto data
- * unit size.  Alignment to the filesystem block size fulfills this requirement,
- * as the filesystem block size is always a multiple of the data unit size.
- *
- * Return: 0 on success; -errno on failure
- */
-int fscrypt_decrypt_pagecache_blocks(struct folio *folio, size_t len,
-				     size_t offs)
-{
-	const struct inode *inode = folio->mapping->host;
-	const struct fscrypt_inode_info *ci = fscrypt_get_inode_info_raw(inode);
-	const unsigned int du_bits = ci->ci_data_unit_bits;
-	const unsigned int du_size = 1U << du_bits;
-	u64 index = ((u64)folio->index << (PAGE_SHIFT - du_bits)) +
-		    (offs >> du_bits);
-	size_t i;
-	int err;
-
-	if (WARN_ON_ONCE(!folio_test_locked(folio)))
-		return -EINVAL;
-
-	if (WARN_ON_ONCE(len <= 0 || !IS_ALIGNED(len | offs, du_size)))
-		return -EINVAL;
-
-	for (i = offs; i < offs + len; i += du_size, index++) {
-		struct page *page = folio_page(folio, i >> PAGE_SHIFT);
-
-		err = fscrypt_crypt_data_unit(ci, FS_DECRYPT, index, page,
-					      page, du_size, i & ~PAGE_MASK);
-		if (err)
-			return err;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(fscrypt_decrypt_pagecache_blocks);
-
 /**
  * fscrypt_decrypt_block_inplace() - Decrypt a filesystem block in-place
  * @inode:     The inode to which this block belongs
@@ -371,20 +320,6 @@ void fscrypt_msg(const struct inode *inode, const char *level,
 
 static int __init fscrypt_init(void)
 {
-	/*
-	 * Use an unbound workqueue to allow bios to be decrypted in parallel
-	 * even when they happen to complete on the same CPU.  This sacrifices
-	 * locality, but it's worthwhile since decryption is CPU-intensive.
-	 *
-	 * Also use a high-priority workqueue to prioritize decryption work,
-	 * which blocks reads from completing, over regular application tasks.
-	 */
-	fscrypt_read_workqueue = alloc_workqueue("fscrypt_read_queue",
-						 WQ_UNBOUND | WQ_HIGHPRI,
-						 num_online_cpus());
-	if (!fscrypt_read_workqueue)
-		panic("failed to allocate fscrypt_read_queue");
-
 	fscrypt_inode_info_cachep = KMEM_CACHE(fscrypt_inode_info,
 					       SLAB_RECLAIM_ACCOUNT |
 					       SLAB_PANIC);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 43bafdd67dd7..acf5b28eb9d7 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -343,7 +343,6 @@ static inline void fscrypt_prepare_dentry(struct dentry *dentry,
 }
 
 /* crypto.c */
-void fscrypt_enqueue_decrypt_work(struct work_struct *);
 
 struct page *fscrypt_encrypt_pagecache_blocks(struct folio *folio,
 		size_t len, size_t offs, gfp_t gfp_flags);
@@ -351,8 +350,6 @@ int fscrypt_encrypt_block_inplace(const struct inode *inode, struct page *page,
 				  unsigned int len, unsigned int offs,
 				  u64 lblk_num);
 
-int fscrypt_decrypt_pagecache_blocks(struct folio *folio, size_t len,
-				     size_t offs);
 int fscrypt_decrypt_block_inplace(const struct inode *inode, struct page *page,
 				  unsigned int len, unsigned int offs,
 				  u64 lblk_num);
@@ -450,7 +447,6 @@ bool fscrypt_match_name(const struct fscrypt_name *fname,
 u64 fscrypt_fname_siphash(const struct inode *dir, const struct qstr *name);
 
 /* bio.c */
-bool fscrypt_decrypt_bio(struct bio *bio);
 int fscrypt_zeroout_range(const struct inode *inode, loff_t pos,
 			  sector_t sector, u64 len);
 
@@ -510,9 +506,6 @@ static inline void fscrypt_prepare_dentry(struct dentry *dentry,
 }
 
 /* crypto.c */
-static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
-{
-}
 
 static inline struct page *fscrypt_encrypt_pagecache_blocks(struct folio *folio,
 		size_t len, size_t offs, gfp_t gfp_flags)
@@ -528,12 +521,6 @@ static inline int fscrypt_encrypt_block_inplace(const struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
-static inline int fscrypt_decrypt_pagecache_blocks(struct folio *folio,
-						   size_t len, size_t offs)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int fscrypt_decrypt_block_inplace(const struct inode *inode,
 						struct page *page,
 						unsigned int len,
@@ -751,10 +738,6 @@ static inline int fscrypt_d_revalidate(struct inode *dir, const struct qstr *nam
 }
 
 /* bio.c */
-static inline bool fscrypt_decrypt_bio(struct bio *bio)
-{
-	return true;
-}
 
 static inline int fscrypt_zeroout_range(const struct inode *inode, loff_t pos,
 					sector_t sector, u64 len)
@@ -892,36 +875,6 @@ static inline u64 fscrypt_limit_io_blocks(const struct inode *inode, u64 lblk,
 }
 #endif /* !CONFIG_FS_ENCRYPTION_INLINE_CRYPT */
 
-/**
- * fscrypt_inode_uses_inline_crypto() - test whether an inode uses inline
- *					encryption
- * @inode: an inode. If encrypted, its key must be set up.
- *
- * Return: true if the inode requires file contents encryption and if the
- *	   encryption should be done in the block layer via blk-crypto rather
- *	   than in the filesystem layer.
- */
-static inline bool fscrypt_inode_uses_inline_crypto(const struct inode *inode)
-{
-	return fscrypt_needs_contents_encryption(inode) &&
-	       inode->i_sb->s_cop->is_block_based;
-}
-
-/**
- * fscrypt_inode_uses_fs_layer_crypto() - test whether an inode uses fs-layer
- *					  encryption
- * @inode: an inode. If encrypted, its key must be set up.
- *
- * Return: true if the inode requires file contents encryption and if the
- *	   encryption should be done in the filesystem layer rather than in the
- *	   block layer via blk-crypto.
- */
-static inline bool fscrypt_inode_uses_fs_layer_crypto(const struct inode *inode)
-{
-	return fscrypt_needs_contents_encryption(inode) &&
-	       !inode->i_sb->s_cop->is_block_based;
-}
-
 /**
  * fscrypt_has_encryption_key() - check whether an inode has had its key set up
  * @inode: the inode to check
-- 
2.55.0

