Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FE0035839E;
	Mon, 13 Jul 2026 02:39:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783910391; cv=none; b=bRPdboPFnBC3fpKj7y9lwrt4EXn37jHNSgcP+WKW1t+FCJ0KdftfkvBU9j1/Xd/ufa7U6OUxDrRd5ER+OuMF7rsgrUDPqmO6+Ibbc4qQ5VIhAZvAgkVX6f9DwkC7IxDhwUhlEzUKGAczJWniJ47GfkKiFvbyPSlOPiHmLDW4amM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783910391; c=relaxed/simple;
	bh=V5ylNLGISd6RN32GFRjgf2V9Od+zjzW45KckiHs0O+E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pY2v8VQw3jLeHd7MpF5OpHMjxZeq7EShWL2BIRZyUYy+/3QwGi4BVIY7L9urydXshDLduPjMCk9p+XawGoZaBcR0yvC1hnSZP4BkHNC5fRMovkbQjY0vy9cyeWKhlWVVfOuG2m8PB78Dm6fcpClE79xSbiQEPBmpHBZRw3irvt0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BAgA1Vzn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BAgA1Vzn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA8741F00ACF;
	Mon, 13 Jul 2026 02:39:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783910389;
	bh=IBxqUGr7Rss79sXT9vNo3//Q1NQaBYMGBiCAhjoQZ0I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BAgA1VznRDskV8Yerp0cI9piB2ggl5brlvgitMZ19pnvbqSR/aGvFrRYLo9RIt22i
	 Z/sLVnAhszxfQgqPsiTpWz2ufgFDqJlRKmT5nDBrHrEKU/6eLcV/9eZPRcMVwrcZwp
	 HQKmSNHn1cz0VXCRFavfSrYo+opUPyGNKqGm4VycH/elQ7shIlThvyLWuKyJ9RcRhQ
	 5h1d62LoRl8kCHpMVQm8D7B3AL39n1H7G8KLWhVNNw6mVqh7H3NqdGPQqx90Iw6CLr
	 vRxBOS60Exspude/q+OcomLRpSzPMTqSLN4Oxc/7iLkMWCdJPHe0IS401MzriAdup/
	 LGiEaWKp2Rx0A==
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
	Eric Biggers <ebiggers@kernel.org>,
	"Christian Brauner (Amutable)" <brauner@kernel.org>
Subject: [PATCH v3 11/17] fs/buffer: Remove fs-layer decryption code
Date: Sun, 12 Jul 2026 22:37:02 -0400
Message-ID: <20260713023708.9245-12-ebiggers@kernel.org>
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

Now that fscrypt's file contents en/decryption is always implemented
using blk-crypto when the filesystem is block-based, the fs-layer
decryption code in fs/buffer.c is unused code.  Remove it.

Reviewed-by: Jan Kara <jack@suse.cz>
Reviewed-by: Christian Brauner (Amutable) <brauner@kernel.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/buffer.c | 45 ++++++++-------------------------------------
 1 file changed, 8 insertions(+), 37 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9af5f061a1f8..21dd9596a941 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -336,7 +336,7 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	spin_unlock_irqrestore(&first->b_uptodate_lock, flags);
 }
 
-struct postprocess_bh_ctx {
+struct verify_bh_ctx {
 	struct work_struct work;
 	struct buffer_head *bh;
 	struct fsverity_info *vi;
@@ -344,8 +344,8 @@ struct postprocess_bh_ctx {
 
 static void verify_bh(struct work_struct *work)
 {
-	struct postprocess_bh_ctx *ctx =
-		container_of(work, struct postprocess_bh_ctx, work);
+	struct verify_bh_ctx *ctx =
+		container_of(work, struct verify_bh_ctx, work);
 	struct buffer_head *bh = ctx->bh;
 	bool valid;
 
@@ -355,29 +355,6 @@ static void verify_bh(struct work_struct *work)
 	kfree(ctx);
 }
 
-static void decrypt_bh(struct work_struct *work)
-{
-	struct postprocess_bh_ctx *ctx =
-		container_of(work, struct postprocess_bh_ctx, work);
-	struct buffer_head *bh = ctx->bh;
-	int err;
-
-	err = fscrypt_decrypt_pagecache_blocks(bh->b_folio, bh->b_size,
-					       bh_offset(bh));
-	if (err == 0 && ctx->vi) {
-		/*
-		 * We use different work queues for decryption and for verity
-		 * because verity may require reading metadata pages that need
-		 * decryption, and we shouldn't recurse to the same workqueue.
-		 */
-		INIT_WORK(&ctx->work, verify_bh);
-		fsverity_enqueue_verify_work(&ctx->work);
-		return;
-	}
-	end_buffer_async_read(bh, err == 0);
-	kfree(ctx);
-}
-
 /*
  * I/O completion handler for block_read_full_folio() - folios
  * which come unlocked at the end of I/O.
@@ -387,27 +364,21 @@ static void bh_end_async_read(struct bio *bio)
 	struct buffer_head *bh;
 	bool uptodate = bio_endio_bh(bio, &bh);
 	struct inode *inode = bh->b_folio->mapping->host;
-	bool decrypt = fscrypt_inode_uses_fs_layer_crypto(inode);
 	struct fsverity_info *vi = NULL;
 
 	/* needed by ext4 */
 	if (bh->b_folio->index < DIV_ROUND_UP(inode->i_size, PAGE_SIZE))
 		vi = fsverity_get_info(inode);
 
-	/* Decrypt (with fscrypt) and/or verify (with fsverity) if needed. */
-	if (uptodate && (decrypt || vi)) {
-		struct postprocess_bh_ctx *ctx = kmalloc_obj(*ctx, GFP_ATOMIC);
+	/* Verify (with fsverity) if needed. */
+	if (vi && uptodate) {
+		struct verify_bh_ctx *ctx = kmalloc_obj(*ctx, GFP_ATOMIC);
 
 		if (ctx) {
 			ctx->bh = bh;
 			ctx->vi = vi;
-			if (decrypt) {
-				INIT_WORK(&ctx->work, decrypt_bh);
-				fscrypt_enqueue_decrypt_work(&ctx->work);
-			} else {
-				INIT_WORK(&ctx->work, verify_bh);
-				fsverity_enqueue_verify_work(&ctx->work);
-			}
+			INIT_WORK(&ctx->work, verify_bh);
+			fsverity_enqueue_verify_work(&ctx->work);
 			return;
 		}
 		uptodate = false;
-- 
2.55.0

