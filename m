Return-Path: <SRS0=har8=S2=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V1 12/14] ext4: Compute logical block and the page range to be encrypted
Date: Wed, 24 Apr 2019 10:07:28 +0530
In-Reply-To: <20190424043730.13683-1-chandan@linux.ibm.com>
References: <20190424043730.13683-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190424043730.13683-13-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

For subpage-sized blocks, the initial logical block number mapped by a
page can be different from page->index. Hence this commit adds code to
compute the first logical block mapped by the page and also the page
range to be encrypted.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/ext4/page-io.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 3e9298e6a705..75485ee9e800 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -418,6 +418,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 {
 	struct page *data_page = NULL;
 	struct inode *inode = page->mapping->host;
+	u64 page_blk;
 	unsigned block_start;
 	struct buffer_head *bh, *head;
 	int ret = 0;
@@ -478,10 +479,14 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 
 	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) && nr_to_submit) {
 		gfp_t gfp_flags = GFP_NOFS;
+		unsigned int page_bytes;
+
+		page_bytes = round_up(len, i_blocksize(inode));
+		page_blk = page->index << (PAGE_SHIFT - inode->i_blkbits);
 
 	retry_encrypt:
-		data_page = fscrypt_encrypt_page(inode, page, PAGE_SIZE, 0,
-						page->index, gfp_flags);
+		data_page = fscrypt_encrypt_page(inode, page, page_bytes, 0,
+						page_blk, gfp_flags);
 		if (IS_ERR(data_page)) {
 			ret = PTR_ERR(data_page);
 			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
-- 
2.19.1
