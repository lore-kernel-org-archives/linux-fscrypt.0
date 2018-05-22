Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 06/12] ext4: Decrypt the block that needs to be partially zeroed
Date: Tue, 22 May 2018 21:31:04 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-7-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

__ext4_block_zero_page_range decrypts the entire page. With block size <
page size this assumption is incorrect since the block to be decrypted
spans a sub-range of the page. This commit now passes the block's offset
within the page and also the length of the block as arguments to
fscrypt_decrypt_page().

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 736d209b..fbc89d9 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4050,9 +4050,10 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		    ext4_encrypted_inode(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
-			BUG_ON(blocksize != PAGE_SIZE);
 			WARN_ON_ONCE(fscrypt_decrypt_page(page->mapping->host,
-						page, PAGE_SIZE, 0, page->index));
+						page, blocksize,
+						round_down(offset, blocksize),
+						iblock));
 		}
 	}
 	if (ext4_should_journal_data(inode)) {
-- 
2.9.5
