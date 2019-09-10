Return-Path: <SRS0=mAtp=XF=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH RESEND V5 3/7] fs/mpage.c: Integrate read callbacks
Date: Tue, 10 Sep 2019 21:21:11 +0530
Message-Id: <20190910155115.28550-4-chandan@linux.ibm.com>
In-Reply-To: <20190910155115.28550-1-chandan@linux.ibm.com>
References: <20190910155115.28550-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
To: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, hch@infradead.org, chandanrlinux@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

This commit adds code to make do_mpage_readpage() to be "read callbacks"
aware i.e. for files requiring decryption, do_mpage_readpage() now
sets up the read callbacks state machine when allocating a bio and later
starts execution of the state machine after file data is read from the
underlying disk.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/mpage.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 3f19da75178b..65e7165644e2 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -30,6 +30,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#include <linux/read_callbacks.h>
 #include "internal.h"
 
 /*
@@ -44,7 +45,7 @@
  * status of that page is hard.  See end_buffer_async_read() for the details.
  * There is no point in duplicating all that complexity.
  */
-static void mpage_end_io(struct bio *bio)
+static void end_bio(struct bio *bio)
 {
 	struct bio_vec *bv;
 	int i;
@@ -52,13 +53,24 @@ static void mpage_end_io(struct bio *bio)
 
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
 		struct page *page = bv->bv_page;
-		page_endio(page, bio_op(bio),
-			   blk_status_to_errno(bio->bi_status));
+		int err;
+
+		err = blk_status_to_errno(bio->bi_status);
+
+		if (!err && read_callbacks_failed(page))
+			err = -EIO;
+
+		page_endio(page, bio_op(bio), err);
 	}
 
 	bio_put(bio);
 }
 
+static void mpage_end_io(struct bio *bio)
+{
+	read_callbacks_endio_bio(bio, end_bio);
+}
+
 static struct bio *mpage_bio_submit(int op, int op_flags, struct bio *bio)
 {
 	bio->bi_end_io = mpage_end_io;
@@ -310,6 +322,12 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 					gfp);
 		if (args->bio == NULL)
 			goto confused;
+
+		if (read_callbacks_setup_bio(inode, args->bio)) {
+			bio_put(args->bio);
+			args->bio = NULL;
+			goto confused;
+		}
 	}
 
 	length = first_hole << blkbits;
-- 
2.19.1
