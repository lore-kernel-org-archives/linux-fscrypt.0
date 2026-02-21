Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D59B10F1
	for <linux-fscrypt@vger.kernel.org>; Sat, 21 Feb 2026 20:13:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771704833; cv=none; b=EDdT8qBgs8ipsaGMtYXQ7YW2hRqXkW+1LrnopFB0ZDpWHf5jnssTdF64XYBCgoaKfU459xg2sx+cP81a0rJrFu09MIg4qIVzSeREBpFFHENiBnYZeSlB+BR0kncP/hhkcCfGTytZVMVHwIriZ8c2FbLt1QH0aX5zjHPkMTK/dQ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771704833; c=relaxed/simple;
	bh=XiSyrRdVNg5RaCKPxQSBaWFY6pxU+wD3GORpXVNtZPI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Am3qcnO3DzLvznDIy6mfmvC1Rm8NJxI7vr9mCozm+xoPr+pCHGNtg0HYzyFPjD5B5BGMMvlQcNxEwwc7lXQMLOqBHcsK+RVf3oVlcba9Lb2gop7xgitnYXvcEQgQ+FpR/qmKcOinofVbhROg79wu+QZJY0fgZlUG+cO48epnIO8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tpKpFZJf; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tpKpFZJf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6E64EC4CEF7;
	Sat, 21 Feb 2026 20:13:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771704832;
	bh=XiSyrRdVNg5RaCKPxQSBaWFY6pxU+wD3GORpXVNtZPI=;
	h=From:To:Cc:Subject:Date:From;
	b=tpKpFZJfY4gmoUoOOahFyx6ZeKQaK9Jpcx6A+86olHVTje9Iji+Dn/smneuw+IYzP
	 ACgeOZViJoWuR4aceGqxDWeVajBuBVtTkDwXLVK/BIxPbmt3L089CyierAgueJJmUL
	 jugtnhqFEQROcK3FpV0oxi478/9iwyy4Nm4Noxjclup2S4gzpMkaJUf0IivwKkQnEm
	 32jiiI0kp87649SSfNfUQISW73ZYRbCqe49B04xkNIQ7MP1WE8jCOQNoKGplnjPBM1
	 6NxW8PR8BtfDTKnMvmokGxAKUsPeq4ETUyIDOY9xF7iElzHCuiZ3u4IyD9NFzGTlyq
	 +aUA9XyMi5TgA==
From: Eric Biggers <ebiggers@kernel.org>
To: Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	linux-f2fs-devel@lists.sourceforge.net
Cc: linux-fscrypt@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Eric Biggers <ebiggers@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] f2fs: remove unreachable code in f2fs_encrypt_one_page()
Date: Sat, 21 Feb 2026 12:13:16 -0800
Message-ID: <20260221201316.22025-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since commit 52e7e0d88933 ("fscrypt: Switch to sync_skcipher and
on-stack requests") eliminated the dynamic allocation of crypto
requests, the only remaining dynamic memory allocation done by
fscrypt_encrypt_pagecache_blocks() is the bounce page allocation.

The bounce page is allocated from a mempool.  Mempool allocations with
GFP_NOFS never fail.  Therefore, fscrypt_encrypt_pagecache_blocks() can
no longer return -ENOMEM when passed GFP_NOFS.

Remove the now-unreachable code from f2fs_encrypt_one_page().

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Link: https://lore.kernel.org/all/d9dc2ee1-283d-4467-ad36-a6a4aa557589@suse.cz/
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/f2fs/data.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 338df7a2aea6..400f0400e13d 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -2785,33 +2785,23 @@ static void f2fs_readahead(struct readahead_control *rac)
 int f2fs_encrypt_one_page(struct f2fs_io_info *fio)
 {
 	struct inode *inode = fio_inode(fio);
 	struct folio *mfolio;
 	struct page *page;
-	gfp_t gfp_flags = GFP_NOFS;
 
 	if (!f2fs_encrypted_file(inode))
 		return 0;
 
 	page = fio->compressed_page ? fio->compressed_page : fio->page;
 
 	if (fscrypt_inode_uses_inline_crypto(inode))
 		return 0;
 
-retry_encrypt:
 	fio->encrypted_page = fscrypt_encrypt_pagecache_blocks(page_folio(page),
-					PAGE_SIZE, 0, gfp_flags);
-	if (IS_ERR(fio->encrypted_page)) {
-		/* flush pending IOs and wait for a while in the ENOMEM case */
-		if (PTR_ERR(fio->encrypted_page) == -ENOMEM) {
-			f2fs_flush_merged_writes(fio->sbi);
-			memalloc_retry_wait(GFP_NOFS);
-			gfp_flags |= __GFP_NOFAIL;
-			goto retry_encrypt;
-		}
+					PAGE_SIZE, 0, GFP_NOFS);
+	if (IS_ERR(fio->encrypted_page))
 		return PTR_ERR(fio->encrypted_page);
-	}
 
 	mfolio = filemap_lock_folio(META_MAPPING(fio->sbi), fio->old_blkaddr);
 	if (!IS_ERR(mfolio)) {
 		if (folio_test_uptodate(mfolio))
 			memcpy(folio_address(mfolio),

base-commit: 8934827db5403eae57d4537114a9ff88b0a8460f
-- 
2.53.0

