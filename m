Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33510 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726307AbfHKVhO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Aug 2019 17:37:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 4/6] ext4: remove ext4_bio_encrypted()
Date: Sun, 11 Aug 2019 14:35:55 -0700
Message-Id: <20190811213557.1970-5-ebiggers@kernel.org>
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

ext4_bio_encrypted() is unused following commit 4e47a0d40dac
("ext4: add fs-verity read support"), so remove it.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/readpage.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index ec8aeab3af65a..a30b203fa461c 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -52,15 +52,6 @@
 static struct kmem_cache *bio_post_read_ctx_cache;
 static mempool_t *bio_post_read_ctx_pool;
 
-static inline bool ext4_bio_encrypted(struct bio *bio)
-{
-#ifdef CONFIG_FS_ENCRYPTION
-	return unlikely(bio->bi_private != NULL);
-#else
-	return false;
-#endif
-}
-
 /* postprocessing steps for read bios */
 enum bio_post_read_step {
 	STEP_INITIAL = 0,
-- 
2.22.0
