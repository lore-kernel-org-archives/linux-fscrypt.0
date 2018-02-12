Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 04/11] completion_pages: Decrypt all contiguous blocks in a page
Date: Mon, 12 Feb 2018 15:13:40 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-5-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

With blocksize < pagesize, a page can contain more than one block. Hence
this commit changes completion_pages() to invoke fscrypt_decrypt_block()
for all the contiguous blocks mapped by the page.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/bio.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index efb0734..378df08 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -40,8 +40,23 @@ static void completion_pages(struct work_struct *work)
 
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
-		int ret = fscrypt_decrypt_block(page->mapping->host, page,
-				PAGE_SIZE, 0, page->index);
+		struct inode *inode = page->mapping->host;
+		const unsigned long blocksize = inode->i_sb->s_blocksize;
+		const unsigned int blkbits = inode->i_blkbits;
+		u64 page_blk = page->index << (PAGE_SHIFT - blkbits);
+		u64 blk = page_blk + (bv->bv_offset >> blkbits);
+		int nr_blks = bv->bv_len >> blkbits;
+		int ret = 0;
+		int j;
+
+		for (j = 0; j < nr_blks; j++, blk++) {
+			ret = fscrypt_decrypt_block(page->mapping->host,
+						page, blocksize,
+						bv->bv_offset + (j << blkbits),
+						blk);
+			if (ret)
+				break;
+		}
 
 		if (ret) {
 			WARN_ON_ONCE(1);
-- 
2.9.5
