Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35215 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752826AbdFNXk4 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 14 Jun 2017 19:40:56 -0400
Received: by mail-pf0-f181.google.com with SMTP id l89so7565541pfi.2
        for <linux-fscrypt@vger.kernel.org>; Wed, 14 Jun 2017 16:40:56 -0700 (PDT)
From: Michael Halcrow <mhalcrow@google.com>
Subject: [RFC PATCH 4/4] f2fs: Set the bio REQ_NOENCRYPT flag
Date: Wed, 14 Jun 2017 16:40:40 -0700
Message-Id: <20170614234040.4326-5-mhalcrow@google.com>
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
 fs/f2fs/data.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 7c0f6bdf817d..2a000c0ec7e1 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -359,6 +359,7 @@ int f2fs_submit_page_bio(struct f2fs_io_info *fio)
 		bio_put(bio);
 		return -EFAULT;
 	}
+	fio->op_flags |= fio->encrypted_page ? REQ_NOENCRYPT : 0;
 	bio_set_op_attrs(bio, fio->op, fio->op_flags);
 
 	__submit_bio(fio->sbi, bio, fio->type);
@@ -384,6 +385,7 @@ int f2fs_submit_page_mbio(struct f2fs_io_info *fio)
 	verify_block_addr(sbi, fio->new_blkaddr);
 
 	bio_page = fio->encrypted_page ? fio->encrypted_page : fio->page;
+	fio->op_flags |= fio->encrypted_page ? REQ_NOENCRYPT : 0;
 
 	/* set submitted = 1 as a return value */
 	fio->submitted = 1;
@@ -1242,7 +1244,10 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
 				bio = NULL;
 				goto set_error_page;
 			}
-			bio_set_op_attrs(bio, REQ_OP_READ, 0);
+			bio_set_op_attrs(bio, REQ_OP_READ,
+					 (f2fs_encrypted_inode(inode) ?
+					  REQ_NOENCRYPT :
+					  0));
 		}
 
 		if (bio_add_page(bio, page, blocksize, 0) < blocksize)
@@ -1914,7 +1919,8 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 			err = PTR_ERR(bio);
 			goto fail;
 		}
-		bio->bi_opf = REQ_OP_READ;
+		bio->bi_opf = REQ_OP_READ |
+			(f2fs_encrypted_inode(inode) ? REQ_NOENCRYPT : 0);
 		if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
 			bio_put(bio);
 			err = -EFAULT;
-- 
2.13.1.508.gb3defc5cc-goog

