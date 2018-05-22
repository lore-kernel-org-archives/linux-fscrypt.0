Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 11/12] ext4: Move encryption code into its own function
Date: Tue, 22 May 2018 21:31:09 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-12-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This commit makes the encryption code in ext4 to be self-contained by
moving the invocation of fscrypt_encrypt_page() and the corresponding
"retry encryption on ENOMEM" code to a function of its own.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/page-io.c | 45 ++++++++++++++++++++++++++++-----------------
 1 file changed, 28 insertions(+), 17 deletions(-)

diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 52f9218..55e52d8 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -409,6 +409,33 @@ static int io_submit_add_bh(struct ext4_io_submit *io,
 	return 0;
 }
 
+static struct page *
+encrypt_page(struct ext4_io_submit *io, struct inode *inode,
+	struct page *page, int len, struct writeback_control *wbc)
+{
+	struct page *data_page;
+	gfp_t gfp_flags = GFP_NOFS;
+	u64 blk_nr;
+
+	blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
+
+retry_encrypt:
+	len = roundup(len, i_blocksize(inode));
+	data_page = fscrypt_encrypt_page(inode, page, len, 0, blk_nr,
+					gfp_flags);
+	if (IS_ERR(data_page) && PTR_ERR(data_page) == -ENOMEM
+		&& wbc->sync_mode == WB_SYNC_ALL) {
+		if (io->io_bio) {
+			ext4_io_submit(io);
+			congestion_wait(BLK_RW_ASYNC, HZ/50);
+		}
+		gfp_flags |= __GFP_NOFAIL;
+		goto retry_encrypt;
+	}
+
+	return data_page;
+}
+
 int ext4_bio_write_page(struct ext4_io_submit *io,
 			struct page *page,
 			int len,
@@ -479,25 +506,9 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
 	    nr_to_submit) {
-		gfp_t gfp_flags = GFP_NOFS;
-		u64 blk_nr;
-
-		blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
-
-	retry_encrypt:
-		len = roundup(len, i_blocksize(inode));
-		data_page = fscrypt_encrypt_page(inode, page, len, 0, blk_nr,
-						gfp_flags);
+		data_page = encrypt_page(io, inode, page, len, wbc);
 		if (IS_ERR(data_page)) {
 			ret = PTR_ERR(data_page);
-			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
-				if (io->io_bio) {
-					ext4_io_submit(io);
-					congestion_wait(BLK_RW_ASYNC, HZ/50);
-				}
-				gfp_flags |= __GFP_NOFAIL;
-				goto retry_encrypt;
-			}
 			data_page = NULL;
 			goto out;
 		}
-- 
2.9.5
