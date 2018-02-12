Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 06/11] ext4: Decrypt the block that needs to be partially zeroed
Date: Mon, 12 Feb 2018 15:13:42 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-7-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

__ext4_block_zero_page_range decrypts the entire page. This commit
changes the code to decrypt the block that needs to be partially zeroed
instead of the whole page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/inode.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 180dd2d..aac0e04 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4034,9 +4034,10 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 		    ext4_encrypted_inode(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
-			BUG_ON(blocksize != PAGE_SIZE);
 			WARN_ON_ONCE(fscrypt_decrypt_block(page->mapping->host,
-						page, PAGE_SIZE, 0, page->index));
+						page, blocksize,
+						round_down(offset, blocksize),
+						iblock));
 		}
 	}
 	if (ext4_should_journal_data(inode)) {
-- 
2.9.5
