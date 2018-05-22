Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 03/12] fscrypt_decrypt_page: Decrypt all blocks in a page
Date: Tue, 22 May 2018 21:31:01 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-4-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On BLOCKSIZE < PAGE SIZE systems, a page maps more than one filesystem
block. This commit changes fscrypt_decrypt_page() to iterate across and
decrypt all the blocks mapped by a page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/crypto.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index fac445d..27509b1 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -305,11 +305,24 @@ EXPORT_SYMBOL(fscrypt_encrypt_page);
 int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
 			unsigned int len, unsigned int offs, u64 lblk_num)
 {
+	unsigned long blocksize = inode->i_sb->s_blocksize;
+	unsigned int last = offs + len;
+	int ret;
+
 	if (!(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES))
 		BUG_ON(!PageLocked(page));
 
-	return fscrypt_do_block_crypto(inode, FS_DECRYPT, lblk_num, page, page,
-				      len, offs, GFP_NOFS);
+	while (offs < last) {
+		ret = fscrypt_do_block_crypto(inode, FS_DECRYPT, lblk_num, page,
+					page, blocksize, offs, GFP_NOFS);
+		if (ret)
+			return ret;
+
+		offs += blocksize;
+		++lblk_num;
+	}
+
+	return 0;
 }
 EXPORT_SYMBOL(fscrypt_decrypt_page);
 
-- 
2.9.5
