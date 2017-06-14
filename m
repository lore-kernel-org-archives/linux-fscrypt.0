Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35212 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752809AbdFNXlA (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Jun 2017 19:41:00 -0400
Received: by mail-pf0-f177.google.com with SMTP id l89so7565359pfi.2
        for <linux-fscrypt@vger.kernel.org>; Wed, 14 Jun 2017 16:41:00 -0700 (PDT)
From: Michael Halcrow <mhalcrow@google.com>
Subject: [RFC PATCH 3/4] ext4: Set the bio REQ_NOENCRYPT flag
Date: Wed, 14 Jun 2017 16:40:39 -0700
Message-Id: <20170614234040.4326-4-mhalcrow@google.com>
In-Reply-To: <20170614234040.4326-1-mhalcrow@google.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>
List-ID: <linux-fscrypt@vger.kernel.org>

When lower layers such as dm-crypt observe the REQ_NOENCRYPT flag, it
helps the I/O stack avoid redundant encryption, improving performance
and power utilization.

Note that lower layers must be consistent in their observation of this
flag in order to avoid the possibility of data corruption.

Signed-off-by: Michael Halcrow <mhalcrow@google.com>
---
 fs/crypto/bio.c    |  2 +-
 fs/ext4/ext4.h     |  3 +++
 fs/ext4/inode.c    | 13 ++++++++-----
 fs/ext4/page-io.c  |  5 +++++
 fs/ext4/readpage.c |  3 ++-
 5 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index a409a84f1bca..9093a715d2be 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -118,7 +118,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 		bio->bi_bdev = inode->i_sb->s_bdev;
 		bio->bi_iter.bi_sector =
 			pblk << (inode->i_sb->s_blocksize_bits - 9);
-		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
+		bio_set_op_attrs(bio, REQ_OP_WRITE, REQ_NOENCRYPT);
 		ret = bio_add_page(bio, ciphertext_page,
 					inode->i_sb->s_blocksize, 0);
 		if (ret != inode->i_sb->s_blocksize) {
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 8e8046104f4d..48c2bc9f8688 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -206,7 +206,10 @@ typedef struct ext4_io_end {
 	ssize_t			size;		/* size of the extent */
 } ext4_io_end_t;
 
+#define EXT4_IO_ENCRYPTED	1
+
 struct ext4_io_submit {
+	unsigned int		io_flags;
 	struct writeback_control *io_wbc;
 	struct bio		*io_bio;
 	ext4_io_end_t		*io_end;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 1bd0bfa547f6..25a9b7265692 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1154,10 +1154,11 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 		if (!buffer_uptodate(bh) && !buffer_delay(bh) &&
 		    !buffer_unwritten(bh) &&
 		    (block_start < from || block_end > to)) {
-			ll_rw_block(REQ_OP_READ, 0, 1, &bh);
-			*wait_bh++ = bh;
 			decrypt = ext4_encrypted_inode(inode) &&
 				S_ISREG(inode->i_mode);
+			ll_rw_block(REQ_OP_READ, (decrypt ? REQ_NOENCRYPT : 0),
+				    1, &bh);
+			*wait_bh++ = bh;
 		}
 	}
 	/*
@@ -3863,6 +3864,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 	struct inode *inode = mapping->host;
 	struct buffer_head *bh;
 	struct page *page;
+	bool decrypt;
 	int err = 0;
 
 	page = find_or_create_page(mapping, from >> PAGE_SHIFT,
@@ -3905,13 +3907,14 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 
 	if (!buffer_uptodate(bh)) {
 		err = -EIO;
-		ll_rw_block(REQ_OP_READ, 0, 1, &bh);
+		decrypt = S_ISREG(inode->i_mode) &&
+			ext4_encrypted_inode(inode);
+		ll_rw_block(REQ_OP_READ, (decrypt ? REQ_NOENCRYPT : 0), 1, &bh);
 		wait_on_buffer(bh);
 		/* Uhhuh. Read error. Complain and punt. */
 		if (!buffer_uptodate(bh))
 			goto unlock;
-		if (S_ISREG(inode->i_mode) &&
-		    ext4_encrypted_inode(inode)) {
+		if (decrypt) {
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
 			BUG_ON(blocksize != PAGE_SIZE);
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 1a82138ba739..e25bf6cb216a 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -349,6 +349,8 @@ void ext4_io_submit(struct ext4_io_submit *io)
 	if (bio) {
 		int io_op_flags = io->io_wbc->sync_mode == WB_SYNC_ALL ?
 				  REQ_SYNC : 0;
+		if (io->io_flags & EXT4_IO_ENCRYPTED)
+			io_op_flags |= REQ_NOENCRYPT;
 		bio_set_op_attrs(io->io_bio, REQ_OP_WRITE, io_op_flags);
 		submit_bio(io->io_bio);
 	}
@@ -358,6 +360,7 @@ void ext4_io_submit(struct ext4_io_submit *io)
 void ext4_io_submit_init(struct ext4_io_submit *io,
 			 struct writeback_control *wbc)
 {
+	io->io_flags = 0;
 	io->io_wbc = wbc;
 	io->io_bio = NULL;
 	io->io_end = NULL;
@@ -499,6 +502,8 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	do {
 		if (!buffer_async_write(bh))
 			continue;
+		if (data_page)
+			io->io_flags |= EXT4_IO_ENCRYPTED;
 		ret = io_submit_add_bh(io, inode,
 				       data_page ? data_page : page, bh);
 		if (ret) {
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index a81b829d56de..008d14d74f33 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -258,7 +258,8 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			bio->bi_iter.bi_sector = blocks[0] << (blkbits - 9);
 			bio->bi_end_io = mpage_end_io;
 			bio->bi_private = ctx;
-			bio_set_op_attrs(bio, REQ_OP_READ, 0);
+			bio_set_op_attrs(bio, REQ_OP_READ,
+					 ctx ? REQ_NOENCRYPT : 0);
 		}
 
 		length = first_hole << blkbits;
-- 
2.13.1.508.gb3defc5cc-goog

