Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33498 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726055AbfHKVhN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Aug 2019 17:37:13 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 1/6] fs-verity: fix crash on read error in build_merkle_tree_level()
Date: Sun, 11 Aug 2019 14:35:52 -0700
Message-Id: <20190811213557.1970-2-ebiggers@kernel.org>
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In build_merkle_tree_level(), use a separate fsverity_err() statement
when failing to read a data page, rather than incorrectly reusing the
one for failure to read a Merkle tree page and accessing level_start[]
out of bounds due to 'params->level_start[level - 1]' when level == 0.

Fixes: 248676649d53 ("fs-verity: implement FS_IOC_ENABLE_VERITY ioctl")
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/enable.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/verity/enable.c b/fs/verity/enable.c
index 3371d51563962..eabc6ac199064 100644
--- a/fs/verity/enable.c
+++ b/fs/verity/enable.c
@@ -43,19 +43,27 @@ static int build_merkle_tree_level(struct inode *inode, unsigned int level,
 			pr_debug("Hashing block %llu of %llu for level %u\n",
 				 i + 1, num_blocks_to_hash, level);
 
-		if (level == 0)
+		if (level == 0) {
 			/* Leaf: hashing a data block */
 			src_page = read_mapping_page(inode->i_mapping, i, NULL);
-		else
+			if (IS_ERR(src_page)) {
+				err = PTR_ERR(src_page);
+				fsverity_err(inode,
+					     "Error %d reading data page %llu",
+					     err, i);
+				return err;
+			}
+		} else {
 			/* Non-leaf: hashing hash block from level below */
 			src_page = vops->read_merkle_tree_page(inode,
 					params->level_start[level - 1] + i);
-		if (IS_ERR(src_page)) {
-			err = PTR_ERR(src_page);
-			fsverity_err(inode,
-				     "Error %d reading Merkle tree page %llu",
-				     err, params->level_start[level - 1] + i);
-			return err;
+			if (IS_ERR(src_page)) {
+				err = PTR_ERR(src_page);
+				fsverity_err(inode,
+					     "Error %d reading Merkle tree page %llu",
+					     err, params->level_start[level - 1] + i);
+				return err;
+			}
 		}
 
 		err = fsverity_hash_page(params, inode, req, src_page,
-- 
2.22.0
