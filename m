Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 04/12] __fscrypt_decrypt_bio: Fix page offset and len args to fscrypt_decrypt_page
Date: Tue, 22 May 2018 21:31:02 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-5-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

For block size < page size scenario, the block to be decrypted can be
mapped at a non-zero page offset and the length of the block is less
than page size. Hence this commit fixes the corresponding arguments sent
to fscrypt_decrypt_page().

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/bio.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 778b826..32288c3 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -33,9 +33,15 @@ static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
 
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
-		int ret = fscrypt_decrypt_page(page->mapping->host, page,
-				PAGE_SIZE, 0, page->index);
+		struct inode *inode = page->mapping->host;
+		u64 blk;
+		int ret;
 
+		blk = page->index << (PAGE_SHIFT - inode->i_blkbits);
+		blk += bv->bv_offset >> inode->i_blkbits;
+
+		ret = fscrypt_decrypt_page(page->mapping->host, page,
+					bv->bv_len, bv->bv_offset, blk);
 		if (ret) {
 			WARN_ON_ONCE(1);
 			SetPageError(page);
-- 
2.9.5
