Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DA3C2D3733;
	Sun,  5 Jul 2026 19:47:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783280858; cv=none; b=b4mX+V20V/2RJkMzHonegywVnuiA/pybjx1+bhPP45twWNa8h3vHLT2Cw0VfnzJiQzfB9fXT/u2SUS/m2z9xl8+Dn7bD8ragisaLI8COdk4migKq7ekSuTf6Kb6OMVe2ndV95Ci2N8qhWceFaVPd8D0RqIkJU37Wrux2PeaOr7M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783280858; c=relaxed/simple;
	bh=5Jqu/Lh/HRoUXQpUYinD/KZGd0rWg8s5p++1r0e4zYg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kNmhPGO+T4iFgskMdnT9ofPzjz3wr7W/mWOzgWwSkIuyavlGrZp7kaqVYL0A/W3B6NseVFWZ/UfHMvQ3Yxn/qS6ImglMlD5Hnk3Rq7C41UAi7DCc3h/Fk/JiRwTACfKiMzn3REy1weh5kWSiO0xfW+myczf8OSildIfxgqo4Lus=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EVQP0AL6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EVQP0AL6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5500D1F00A3F;
	Sun,  5 Jul 2026 19:47:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783280857;
	bh=ccW1qV9UN5V52RLw/3xBnC+VL1s84LZKZzkFmXShJlU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EVQP0AL65F6G4DPoUlRU+C+e0GBHXoJUhnk5l8rldhiLdToO6OPqGZiUS9HmxNnLq
	 xulRs2Zl/a9FVOL13BouqsFVwTmNEzWasAnU6zg8J6u+eIUXqVxnHKJ3SjmssNvkXO
	 VmB8/kloOSXmq/cPKcM+YEnG995a8euwtm5IidEzGuD3XfgNKsjxBymyDwnqV29AwO
	 fIGUrndcXnLmDIRqZKXtv6/2Y0T8SfcJKrx5dmbygV2cHoA3Zh/Vjxowq3p+9ZyNpf
	 TFx8TDaCCs6IDtEW4Qj3gVPj0Vpr1oCNb61O/0gtnZjeeje2f5cOfXf1RDkVBg3B1n
	 FwRSy/5KUYnhg==
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
Subject: [PATCH v2 01/17] blk-crypto: Simplify check for fallback support
Date: Sun,  5 Jul 2026 12:45:38 -0700
Message-ID: <20260705194555.75030-2-ebiggers@kernel.org>
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

Since blk-crypto-fallback supports all blk_crypto_keys except wrapped
keys, just check for that condition directly instead of using
__blk_crypto_cfg_supported().  With this done,
__blk_crypto_cfg_supported() is now used only for the hardware support.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 block/blk-crypto-fallback.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
index 2a5c52ab74b4..2a8f40a65158 100644
--- a/block/blk-crypto-fallback.c
+++ b/block/blk-crypto-fallback.c
@@ -496,8 +496,7 @@ bool blk_crypto_fallback_bio_prep(struct bio *bio)
 		return false;
 	}
 
-	if (!__blk_crypto_cfg_supported(blk_crypto_fallback_profile,
-					&bc->bc_key->crypto_cfg)) {
+	if (bc->bc_key->crypto_cfg.key_type != BLK_CRYPTO_KEY_TYPE_RAW) {
 		bio_endio_status(bio, BLK_STS_NOTSUPP);
 		return false;
 	}
-- 
2.54.0

