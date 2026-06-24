Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D2A636A367;
	Wed, 24 Jun 2026 05:05:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782277560; cv=none; b=izC5NUymVyCuqQHh9sJ7usuF5vcF80Nz121XCv9CAUpA3QmVB7Q2Un+PIYQ3P8U8fsTc7NMZx/T/A69u4eiTx+/ZAsSyyIBvzML36n8zlNlvM/qK7/rnis+l/SXL5HfdVrO4HjOrwbFI8/Rn2CU1KAnSZIg8LRGhsJOxPqDZWrc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782277560; c=relaxed/simple;
	bh=4Tr2aq/hAasBeHeEc5GkB9apHk1PUbm3CW7NQqQGARY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jT4egftqbGX4qszA3wjPPQ0TKwHcC2LMNfqirgsOhvu38P/K2iTAgPAij7QS4aH/p/FsKqWx3/vd5Gd+wAP+zsVAEfJcfkkLFfKdVDLMNcxfQ8UMR3gCkAxs9KknXoNewuyagrJWFzh5w/P0odmcav6pIft/HtZ1IeRMjhGHC6Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lVePk+nx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lVePk+nx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F1B41F00A3A;
	Wed, 24 Jun 2026 05:05:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782277559;
	bh=tnb0tfseVuJy6ztSSzQ0+AU1yHkyqxTSNK4Dw8VuZEw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lVePk+nxDYyyFQ3wSnWoDkOkUFBrt6ijaZFhOX3Rj+jDahxShF94zAsOaf+wBkwjp
	 F7AVuZSrGIKf0xcdx80rMqsafrmPXZ3OyFdCzmk2HXUz5ijAUnv4fah0iI6LLzoH/Q
	 s3K//h9bR8lzc490fuK+I85OA5e0d1b8LofOzXPBegYr0B67rYYFOM50rjY2HFIumX
	 CWaV+8s9UiV8j6JHl6nVYz+ukjExnsp9Ievqe828Zn8UZFdq3DlYjVFHfA7lBJ/HBV
	 2RTcQN+FMIFBdJgpKIJFm3wy3+uO1roUGQvbwP75FuVeQa9Wk6YrLpcGqoBfx0dUJp
	 1AgRT9CiV/I6w==
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
Subject: [PATCH 01/16] blk-crypto: Simplify check for fallback support
Date: Tue, 23 Jun 2026 22:03:19 -0700
Message-ID: <20260624050334.124606-2-ebiggers@kernel.org>
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

Since blk-crypto-fallback supports all blk_crypto_keys except wrapped
keys, just check for that condition directly instead of using
__blk_crypto_cfg_supported().  With this done,
__blk_crypto_cfg_supported() is now used only for the hardware support.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 block/blk-crypto-fallback.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
index 2a5c52ab74b4..2a8f40a65158 100644
--- a/block/blk-crypto-fallback.c
+++ b/block/blk-crypto-fallback.c
@@ -494,12 +494,11 @@ bool blk_crypto_fallback_bio_prep(struct bio *bio)
 		/* User didn't call blk_crypto_start_using_key() first */
 		bio_io_error(bio);
 		return false;
 	}
 
-	if (!__blk_crypto_cfg_supported(blk_crypto_fallback_profile,
-					&bc->bc_key->crypto_cfg)) {
+	if (bc->bc_key->crypto_cfg.key_type != BLK_CRYPTO_KEY_TYPE_RAW) {
 		bio_endio_status(bio, BLK_STS_NOTSUPP);
 		return false;
 	}
 
 	if (bio_data_dir(bio) == WRITE) {
-- 
2.54.0

