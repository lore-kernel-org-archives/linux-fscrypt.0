Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33516 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726527AbfHKVhO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Aug 2019 17:37:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 5/6] ext4: fix comment in ext4_end_enable_verity()
Date: Sun, 11 Aug 2019 14:35:56 -0700
Message-Id: <20190811213557.1970-6-ebiggers@kernel.org>
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/verity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/ext4/verity.c b/fs/ext4/verity.c
index bb0a3b8e6ea71..d0d8a9795dd62 100644
--- a/fs/ext4/verity.c
+++ b/fs/ext4/verity.c
@@ -196,7 +196,7 @@ static int ext4_end_enable_verity(struct file *filp, const void *desc,
 				  size_t desc_size, u64 merkle_tree_size)
 {
 	struct inode *inode = file_inode(filp);
-	const int credits = 2; /* superblock and inode for ext4_orphan_add() */
+	const int credits = 2; /* superblock and inode for ext4_orphan_del() */
 	handle_t *handle;
 	int err = 0;
 	int err2;
-- 
2.22.0
