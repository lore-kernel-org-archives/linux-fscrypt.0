Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 05/11] ext4: Decrypt all boundary blocks when doing buffered write
Date: Mon, 12 Feb 2018 15:13:41 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-6-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

With block size < page size, ext4_block_write_begin() can have up to two
blocks to decrypt. Hence this commit invokes fscrypt_decrypt_block() for
each of those blocks.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/ext4/inode.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 69a4fd6..180dd2d 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1158,12 +1158,13 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	unsigned to = from + len;
 	struct inode *inode = page->mapping->host;
 	unsigned block_start, block_end;
-	sector_t block;
+	sector_t block, page_blk_nr;
 	int err = 0;
 	unsigned blocksize = inode->i_sb->s_blocksize;
 	unsigned bbits;
 	struct buffer_head *bh, *head, *wait[2], **wait_bh = wait;
 	bool decrypt = false;
+	int i;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(from > PAGE_SIZE);
@@ -1224,18 +1225,30 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	/*
 	 * If we issued read requests, let them complete.
 	 */
-	while (wait_bh > wait) {
-		wait_on_buffer(*--wait_bh);
-		if (!buffer_uptodate(*wait_bh))
+	for (i = 0; &wait[i] < wait_bh; i++) {
+		wait_on_buffer(wait[i]);
+		if (!buffer_uptodate(wait[i]))
 			err = -EIO;
 	}
-	if (unlikely(err))
+	if (unlikely(err)) {
 		page_zero_new_buffers(page, from, to);
-	else if (decrypt) {
-		err = fscrypt_decrypt_block(page->mapping->host, page,
-				PAGE_SIZE, 0, page->index);
-		if (err)
-			clear_buffer_uptodate(*wait_bh);
+	} else if (decrypt) {
+		page_blk_nr = (sector_t)page->index << (PAGE_SHIFT - bbits);
+
+		for (i = 0; &wait[i] < wait_bh; i++) {
+			int err2;
+
+			--wait_bh;
+			block = page_blk_nr + (bh_offset(wait[i]) >> bbits);
+			err2 = fscrypt_decrypt_block(page->mapping->host, page,
+						wait[i]->b_size,
+						bh_offset(wait[i]),
+						block);
+			if (err2) {
+				clear_buffer_uptodate(wait[i]);
+				err = err2;
+			}
+		}
 	}
 
 	return err;
-- 
2.9.5
