Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Wed,  1 May 2019 15:45:09 -0700
Message-Id: <20190501224515.43059-8-ebiggers@kernel.org>
In-Reply-To: <20190501224515.43059-1-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH 07/13] fscrypt: handle blocksize < PAGE_SIZE in
 fscrypt_zeroout_range()
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Chandan Rajendra <chandan@linux.ibm.com>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Adjust fscrypt_zeroout_range() to encrypt a block at a time rather than
a page at a time, so that it works when blocksize < PAGE_SIZE.

This isn't optimized for performance, but then again this function
already wasn't optimized for performance.  As a future optimization, we
could submit much larger bios here.

This is in preparation for allowing encryption on ext4 filesystems with
blocksize != PAGE_SIZE.

This is based on work by Chandan Rajendra.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index bcab8822217b0..e67e9d4d342b3 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -73,12 +73,12 @@ EXPORT_SYMBOL(fscrypt_enqueue_decrypt_bio);
 int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 				sector_t pblk, unsigned int len)
 {
+	const unsigned int blockbits = inode->i_blkbits;
+	const unsigned int blocksize = 1 << blockbits;
 	struct page *ciphertext_page;
 	struct bio *bio;
 	int ret, err = 0;
 
-	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
-
 	ciphertext_page = fscrypt_alloc_bounce_page(GFP_NOWAIT);
 	if (!ciphertext_page)
 		return -ENOMEM;
@@ -86,7 +86,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 	while (len--) {
 		err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk,
 					  ZERO_PAGE(0), ciphertext_page,
-					  PAGE_SIZE, 0, GFP_NOFS);
+					  blocksize, 0, GFP_NOFS);
 		if (err)
 			goto errout;
 
@@ -96,14 +96,11 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 			goto errout;
 		}
 		bio_set_dev(bio, inode->i_sb->s_bdev);
-		bio->bi_iter.bi_sector =
-			pblk << (inode->i_sb->s_blocksize_bits - 9);
+		bio->bi_iter.bi_sector = pblk << (blockbits - 9);
 		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
-		ret = bio_add_page(bio, ciphertext_page,
-					inode->i_sb->s_blocksize, 0);
-		if (ret != inode->i_sb->s_blocksize) {
+		ret = bio_add_page(bio, ciphertext_page, blocksize, 0);
+		if (WARN_ON(ret != blocksize)) {
 			/* should never happen! */
-			WARN_ON(1);
 			bio_put(bio);
 			err = -EIO;
 			goto errout;
-- 
2.21.0.593.g511ec345e18-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
