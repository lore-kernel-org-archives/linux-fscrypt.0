Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A505F3A6B70;
	Sun,  5 Jul 2026 19:48:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783280893; cv=none; b=M2l54n/3fztdezDzHKbHL6qkXe2XrJSKXbDAhZiR/wmwbB8l+vAu8pUc9RZl/Pdbb3lsLM9kux75XHTCedK4HuVr1kq1zjrHsVutkL9GhTvep0y6YxRACNE1JvLz+kW8O8BvhtedB5DLEkZ9Mr8gsULl6YQqsu0VeDQW826l9Ew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783280893; c=relaxed/simple;
	bh=ORNHwH2+A1QgJWZ5vqYcA+uoaLOgVvAGAYEn1kS0/OM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=u47Zc3EMfKPrn+H8E1exiiaoCaNZbFlNQauCLo2qsyhjceoLAO4wB+3dh3196ocxe7ht2KREHSruNb0T4Fvx664e7tWkvEUyIlADT+r3ahowowRzqlpmZUUZaJ7/J6H7qCB7pCv74VJ6rWeyqNBmUheBkupm833AQT5Dfu0jvM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SW287yyj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SW287yyj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 699B41F00A3A;
	Sun,  5 Jul 2026 19:48:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783280892;
	bh=htUAXJYIiw7QAOgR27oV+3eHKQdd5p6jbnsdVP1KIck=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SW287yyjVhn0pZnV2uEnSBjWk1jrrf3oUlJHzLBwmsa6yDlZZ4wCxcn4WUobtL8kd
	 b8zgfZEXjwsOG0hKzb4SNC1m5YG95araHg5WNV6r3PMpPpjoTkSKsCyrQ1sN6zGCFh
	 AwraNsPLJ9D/Yffq0KgVwTdHRu54f+ov2gm++CRKnmSel4cPKAUqCQwsYBH6C/9h2L
	 8l4ZBLWiVW25uhxJw698uAuf2s43hO9KOHaQIwWpMjfThbwHMTlkUDcU80iUWppQX2
	 wsjjLb5uAXiW43K89+fzREZnTBXdEOJlVigHM4zH9ZxgM3ZAvJkSjjdBScIymLKSVJ
	 8Kpx8EHYRWxQA==
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
Subject: [PATCH v2 17/17] fscrypt: Add safety checks to non-block-based en/decryption
Date: Sun,  5 Jul 2026 12:45:54 -0700
Message-ID: <20260705194555.75030-18-ebiggers@kernel.org>
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

fscrypt_encrypt_pagecache_blocks(), fscrypt_encrypt_block_inplace(),
fscrypt_decrypt_block_inplace() would dereference a NULL
fscrypt_inode_info pointer if they were to be called on a file that
hasn't been opened yet or on a block-based filesystem.  Since they have
the ability to report errors anyway, add WARN_ON_ONCE checks for this.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/crypto.c | 61 +++++++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 22 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 27663f4d8705..c91eda62f9a4 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -105,12 +105,17 @@ static int fscrypt_crypt_data_unit(const struct fscrypt_inode_info *ci,
 				   struct page *dest_page, unsigned int len,
 				   unsigned int offs)
 {
-	struct crypto_sync_skcipher *tfm = ci->ci_enc_key.tfm;
-	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
+	struct crypto_sync_skcipher *tfm;
 	union fscrypt_iv iv;
 	struct scatterlist dst, src;
 	int err;
 
+	if (WARN_ON_ONCE(ci == NULL)) /* File hasn't been opened yet? */
+		return -ENOKEY;
+	tfm = ci->ci_enc_key.tfm;
+	if (WARN_ON_ONCE(tfm == NULL)) /* Called on block-based filesystem? */
+		return -ENOKEY;
+
 	if (WARN_ON_ONCE(len <= 0))
 		return -EINVAL;
 	if (WARN_ON_ONCE(len % FSCRYPT_CONTENTS_ALIGNMENT != 0))
@@ -118,18 +123,22 @@ static int fscrypt_crypt_data_unit(const struct fscrypt_inode_info *ci,
 
 	fscrypt_generate_iv(&iv, index, ci);
 
-	skcipher_request_set_callback(
-		req, CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
-		NULL, NULL);
-	sg_init_table(&dst, 1);
-	sg_set_page(&dst, dest_page, len, offs);
-	sg_init_table(&src, 1);
-	sg_set_page(&src, src_page, len, offs);
-	skcipher_request_set_crypt(req, &src, &dst, len, &iv);
-	if (rw == FS_DECRYPT)
-		err = crypto_skcipher_decrypt(req);
-	else
-		err = crypto_skcipher_encrypt(req);
+	{
+		SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
+		skcipher_request_set_callback(req,
+					      CRYPTO_TFM_REQ_MAY_BACKLOG |
+						      CRYPTO_TFM_REQ_MAY_SLEEP,
+					      NULL, NULL);
+		sg_init_table(&dst, 1);
+		sg_set_page(&dst, dest_page, len, offs);
+		sg_init_table(&src, 1);
+		sg_set_page(&src, src_page, len, offs);
+		skcipher_request_set_crypt(req, &src, &dst, len, &iv);
+		if (rw == FS_DECRYPT)
+			err = crypto_skcipher_decrypt(req);
+		else
+			err = crypto_skcipher_encrypt(req);
+	}
 	if (err)
 		fscrypt_err(ci->ci_inode,
 			    "%scryption failed for data unit %llu: %d",
@@ -153,7 +162,7 @@ static int fscrypt_crypt_data_unit(const struct fscrypt_inode_info *ci,
  * which the plaintext data was located in the source page.  Any other parts of
  * the bounce page will be left uninitialized.
  *
- * This is for use by the filesystem's ->writepages() method.
+ * This is for use by the ->writepages() method of non-block-based filesystems.
  *
  * The bounce page allocation is mempool-backed, so it will always succeed when
  * @gfp_flags includes __GFP_DIRECT_RECLAIM, e.g. when it's GFP_NOFS.  However,
@@ -167,14 +176,20 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct folio *folio,
 {
 	const struct inode *inode = folio->mapping->host;
 	const struct fscrypt_inode_info *ci = fscrypt_get_inode_info_raw(inode);
-	const unsigned int du_bits = ci->ci_data_unit_bits;
-	const unsigned int du_size = 1U << du_bits;
+	unsigned int du_bits;
+	unsigned int du_size;
 	struct page *ciphertext_page;
-	u64 index = ((u64)folio->index << (PAGE_SHIFT - du_bits)) +
-		    (offs >> du_bits);
+	u64 index;
 	unsigned int i;
 	int err;
 
+	if (WARN_ON_ONCE(ci == NULL)) /* File hasn't been opened yet? */
+		return ERR_PTR(-ENOKEY);
+
+	du_bits = ci->ci_data_unit_bits;
+	du_size = 1U << du_bits;
+	index = (folio_pos(folio) + offs) >> du_bits;
+
 	VM_BUG_ON_FOLIO(folio_test_large(folio), folio);
 	if (WARN_ON_ONCE(!folio_test_locked(folio)))
 		return ERR_PTR(-EINVAL);
@@ -215,7 +230,8 @@ EXPORT_SYMBOL(fscrypt_encrypt_pagecache_blocks);
  * arbitrary page, not necessarily in the original pagecache page.  The @inode
  * and @lblk_num must be specified, as they can't be determined from @page.
  *
- * This is not compatible with fscrypt_operations::supports_subblock_data_units.
+ * This function only supports non-block-based filesystems that don't support
+ * sub-block data units (as indicated by the fscrypt_operations fields).
  *
  * Return: 0 on success; -errno on failure
  */
@@ -245,7 +261,8 @@ EXPORT_SYMBOL(fscrypt_encrypt_block_inplace);
  * arbitrary page, not necessarily in the original pagecache page.  The @inode
  * and @lblk_num must be specified, as they can't be determined from @page.
  *
- * This is not compatible with fscrypt_operations::supports_subblock_data_units.
+ * This function only supports non-block-based filesystems that don't support
+ * sub-block data units (as indicated by the fscrypt_operations fields).
  *
  * Return: 0 on success; -errno on failure
  */
@@ -275,7 +292,7 @@ int fscrypt_initialize(struct super_block *sb)
 	mempool_t *pool;
 
 	/* pairs with smp_store_release() below */
-	if (likely(smp_load_acquire(&fscrypt_bounce_page_pool)))
+	if (smp_load_acquire(&fscrypt_bounce_page_pool))
 		return 0;
 
 	/* No need to allocate a bounce page pool if this FS won't use it. */
-- 
2.54.0

