Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 10/12] ext4: Fix block number passed to fscrypt_encrypt_page
Date: Tue, 22 May 2018 21:31:08 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-11-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

For the case of Block size < Page size, this commit computes the block
number of the first block mapped by the page. This is required by
fscrypt_encrypt_page() for encrypting the blocks mapped by the page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/page-io.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index db75901..52f9218 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -480,10 +480,14 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
 	    nr_to_submit) {
 		gfp_t gfp_flags = GFP_NOFS;
+		u64 blk_nr;
+
+		blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
 
 	retry_encrypt:
-		data_page = fscrypt_encrypt_page(inode, page, PAGE_SIZE, 0,
-						page->index, gfp_flags);
+		len = roundup(len, i_blocksize(inode));
+		data_page = fscrypt_encrypt_page(inode, page, len, 0, blk_nr,
+						gfp_flags);
 		if (IS_ERR(data_page)) {
 			ret = PTR_ERR(data_page);
 			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
@@ -520,7 +524,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	/* Error stopped previous loop? Clean up buffers... */
 	if (ret) {
 	out:
-		if (data_page)
+		if (data_page && bh == head)
 			fscrypt_restore_control_page(data_page);
 		printk_ratelimited(KERN_ERR "%s: ret = %d\n", __func__, ret);
 		redirty_page_for_writepage(wbc, page);
-- 
2.9.5
