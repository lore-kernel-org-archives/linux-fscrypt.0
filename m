Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: [PATCH 8/9] fs: ext4: support diskcipher
Date: Wed, 21 Aug 2019 15:42:41 +0900
Message-ID: <004401d557eb$a1989480$e4c9bd80$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821064241epcas2p2bf71ad8055188f8b47870b06480c8368@epcas2p2.samsung.com>
To: 'Theodore Ts'o' <tytso@mit.edu>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Eric Biggers' <ebiggers@kernel.org>, "'Theodore Y. Ts'o'  <tytso@mit.edu>,  'Chao Yu'  <chao@kernel.org>,  'Jaegeuk Kim' " <jaegeuk@kernel.org>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, linux-fscrypt@vger.kernel.org, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc, linux-arm-kernel@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Ext4 checks the crypto properties of the inode,
and if it is a diskcipher, sets it to BIO before submitting the BIO.
When using diskcipher, Ext4 does not encrypt the data before submitting
the BIO and decrypt the data on complete of the BIO.

Cc: Theodore Ts'o <tytso@mit.edu>
Cc: Andreas Dilger <adilger.kernel@dilger.ca>
Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
---
 fs/ext4/inode.c    | 39 +++++++++++++++++++++++++++++++++------
 fs/ext4/page-io.c  |  8 +++++++-
 fs/ext4/readpage.c |  7 +++++++
 3 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5bcc96f..7f9e1fa 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1223,7 +1223,14 @@ static int ext4_block_write_begin(struct page *page,
loff_t pos, unsigned len,
 		if (!buffer_uptodate(bh) && !buffer_delay(bh) &&
 		    !buffer_unwritten(bh) &&
 		    (block_start < from || block_end > to)) {
-			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
+			if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode)
+					&&
fscrypt_has_encryption_key(inode)) {
+				bh->b_private =
fscrypt_get_diskcipher(inode);
+				ll_rw_block(REQ_OP_READ,
+					bh->b_private ? REQ_CRYPT : 0, 1,
&bh);
+			} else {
+				ll_rw_block(REQ_OP_READ, 0, 1, &bh);
+			}
 			wait[nr_wait++] = bh;
 		}
 	}
@@ -1237,7 +1244,8 @@ static int ext4_block_write_begin(struct page *page,
loff_t pos, unsigned len,
 	}
 	if (unlikely(err)) {
 		page_zero_new_buffers(page, from, to);
-	} else if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
+	} else if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) &&
+			!bh->b_private) {
 		for (i = 0; i < nr_wait; i++) {
 			int err2;
 
@@ -3670,6 +3678,13 @@ const struct iomap_ops ext4_iomap_ops = {
 	.iomap_end		= ext4_iomap_end,
 };
 
+static void ext4_submit_dio(struct bio *bio, struct inode *inode,
+							loff_t file_offset)
+{
+	fscrypt_set_bio(inode, bio, 0);
+	submit_bio(bio);
+}
+
 static int ext4_end_io_dio(struct kiocb *iocb, loff_t offset,
 			    ssize_t size, void *private)
 {
@@ -3801,7 +3816,9 @@ static ssize_t ext4_direct_IO_write(struct kiocb
*iocb, struct iov_iter *iter)
 		dio_flags = DIO_LOCKING;
 	}
 	ret = __blockdev_direct_IO(iocb, inode, inode->i_sb->s_bdev, iter,
-				   get_block_func, ext4_end_io_dio, NULL,
+				   get_block_func, ext4_end_io_dio,
+				   !fscrypt_disk_encrypted(inode) ?
+				   NULL : ext4_submit_dio,
 				   dio_flags);
 
 	if (ret > 0 && !overwrite && ext4_test_inode_state(inode,
@@ -3909,7 +3926,8 @@ static ssize_t ext4_direct_IO(struct kiocb *iocb,
struct iov_iter *iter)
 	ssize_t ret;
 
 #ifdef CONFIG_FS_ENCRYPTION
-	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)
+		&& !fscrypt_disk_encrypted(inode))
 		return 0;
 #endif
 	if (fsverity_active(inode))
@@ -4090,7 +4108,15 @@ static int __ext4_block_zero_page_range(handle_t
*handle,
 
 	if (!buffer_uptodate(bh)) {
 		err = -EIO;
-		ll_rw_block(REQ_OP_READ, 0, 1, &bh);
+		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode)
+				&& fscrypt_has_encryption_key(inode)) {
+			bh->b_private = fscrypt_get_diskcipher(inode);
+			ll_rw_block(REQ_OP_READ, bh->b_private ? REQ_CRYPT :
0,
+					1, &bh);
+		} else {
+			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
+		}
+
 		wait_on_buffer(bh);
 		/* Uhhuh. Read error. Complain and punt. */
 		if (!buffer_uptodate(bh))
@@ -4098,7 +4124,8 @@ static int __ext4_block_zero_page_range(handle_t
*handle,
 		if (S_ISREG(inode->i_mode) && IS_ENCRYPTED(inode)) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
-			WARN_ON_ONCE(fscrypt_decrypt_pagecache_blocks(
+			if (!bh->b_private)
+
WARN_ON_ONCE(fscrypt_decrypt_pagecache_blocks(
 					page, blocksize, bh_offset(bh)));
 		}
 	}
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 12ceadef..3e41788 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -345,6 +345,11 @@ void ext4_io_submit(struct ext4_io_submit *io)
 				  REQ_SYNC : 0;
 		io->io_bio->bi_write_hint = io->io_end->inode->i_write_hint;
 		bio_set_op_attrs(io->io_bio, REQ_OP_WRITE, io_op_flags);
+#if defined(CONFIG_FS_ENCRYPTION) && defined(CONFIG_CRYPTO_DISKCIPHER)
+		if (IS_ENCRYPTED(io->io_end->inode) &&
+				S_ISREG(io->io_end->inode->i_mode))
+			fscrypt_set_bio(io->io_end->inode, io->io_bio, 0);
+#endif
 		submit_bio(io->io_bio);
 	}
 	io->io_bio = NULL;
@@ -474,7 +479,8 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	 * (e.g. holes) to be unnecessarily encrypted, but this is rare and
 	 * can't happen in the common case of blocksize == PAGE_SIZE.
 	 */
-	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) && nr_to_submit) {
+	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) && nr_to_submit &&
+			!fscrypt_disk_encrypted(inode)) {
 		gfp_t gfp_flags = GFP_NOFS;
 		unsigned int enc_bytes = round_up(len, i_blocksize(inode));
 
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index a30b203..aab2cf7c 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -183,6 +183,9 @@ static struct bio_post_read_ctx
*get_bio_post_read_ctx(struct inode *inode,
 	unsigned int post_read_steps = 0;
 	struct bio_post_read_ctx *ctx = NULL;
 
+	if (fscrypt_disk_encrypted(inode))
+		return NULL;
+
 	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
 		post_read_steps |= 1 << STEP_DECRYPT;
 
@@ -376,6 +379,10 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			bio->bi_private = ctx;
 			bio_set_op_attrs(bio, REQ_OP_READ,
 						is_readahead ? REQ_RAHEAD :
0);
+#if defined(CONFIG_FS_ENCRYPTION) && defined(CONFIG_CRYPTO_DISKCIPHER)
+			if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
+				fscrypt_set_bio(inode, bio, 0);
+#endif
 		}
 
 		length = first_hole << blkbits;
-- 
2.7.4
