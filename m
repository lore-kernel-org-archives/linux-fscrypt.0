Return-Path: <SRS0=94sN=UP=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V3 4/7] fs/mpage.c: Integrate read callbacks
Date: Sun, 16 Jun 2019 21:38:10 +0530
In-Reply-To: <20190616160813.24464-1-chandan@linux.ibm.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190616160813.24464-5-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

This commit adds code to make do_mpage_readpage() to be "read callbacks"
aware i.e. for files requiring decryption, do_mpage_readpage() now
sets up the read callbacks state machine when allocating a bio and later
starts execution of the state machine after file data is read from the
underlying disk.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/mpage.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 436a85260394..611ad122fc92 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -30,6 +30,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/cleancache.h>
+#include <linux/read_callbacks.h>
 #include "internal.h"
 
 /*
@@ -49,6 +50,8 @@ static void mpage_end_io(struct bio *bio)
 	struct bio_vec *bv;
 	struct bvec_iter_all iter_all;
 
+	if (read_callbacks_end_bio(bio))
+		return;
 	bio_for_each_segment_all(bv, bio, iter_all) {
 		struct page *page = bv->bv_page;
 		page_endio(page, bio_op(bio),
@@ -309,6 +312,12 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 					gfp);
 		if (args->bio == NULL)
 			goto confused;
+
+		if (read_callbacks_setup(inode, args->bio, NULL)) {
+			bio_put(args->bio);
+			args->bio = NULL;
+			goto confused;
+		}
 	}
 
 	length = first_hole << blkbits;
@@ -330,7 +339,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
 confused:
 	if (args->bio)
 		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
-	if (!PageUptodate(page))
+	if (!PageUptodate(page) && !PageError(page))
 		block_read_full_page(page, args->get_block);
 	else
 		unlock_page(page);
-- 
2.19.1
