Return-Path: <SRS0=LT3F=WT=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V5 4/7] fs/buffer.c: add decryption support via read_callbacks
Date: Fri, 23 Aug 2019 18:55:39 +0530
Message-Id: <20190823132542.13434-5-chandan@linux.ibm.com>
In-Reply-To: <20190823132542.13434-1-chandan@linux.ibm.com>
References: <20190823132542.13434-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, hch@infradead.org, chandanrlinux@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

This commit sets up read_callbacks context for buffer heads whose
contents need to be decrypted on endio.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/buffer.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index ce357602f471..96c4c9840746 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -45,6 +45,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/pagevec.h>
 #include <linux/sched/mm.h>
+#include <linux/read_callbacks.h>
 #include <trace/events/block.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
@@ -245,11 +246,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	return ret;
 }
 
-/*
- * I/O completion handler for block_read_full_page() - pages
- * which come unlocked at the end of I/O.
- */
-static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
+void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
 	struct buffer_head *first;
@@ -257,8 +254,6 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	struct page *page;
 	int page_uptodate = 1;
 
-	BUG_ON(!buffer_async_read(bh));
-
 	page = bh->b_page;
 	if (uptodate) {
 		set_buffer_uptodate(bh);
@@ -306,6 +301,17 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	return;
 }
 
+/*
+ * I/O completion handler for block_read_full_page().  Pages are unlocked
+ * after the I/O completes and the read callbacks (if any) have executed.
+ */
+static void __end_buffer_async_read(struct buffer_head *bh, int uptodate)
+{
+	BUG_ON(!buffer_async_read(bh));
+
+	read_callbacks_endio_bh(bh, uptodate, end_buffer_async_read);
+}
+
 /*
  * Completion handler for block_write_full_page() - pages which are unlocked
  * during I/O, and which have PageWriteback cleared upon I/O completion.
@@ -378,7 +384,7 @@ EXPORT_SYMBOL(end_buffer_async_write);
  */
 static void mark_buffer_async_read(struct buffer_head *bh)
 {
-	bh->b_end_io = end_buffer_async_read;
+	bh->b_end_io = __end_buffer_async_read;
 	set_buffer_async_read(bh);
 }
 
@@ -2293,10 +2299,15 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	 */
 	for (i = 0; i < nr; i++) {
 		bh = arr[i];
-		if (buffer_uptodate(bh))
-			end_buffer_async_read(bh, 1);
-		else
+		if (buffer_uptodate(bh)) {
+			__end_buffer_async_read(bh, 1);
+		} else {
+			if (WARN_ON(read_callbacks_setup_bh(inode, bh))) {
+				__end_buffer_async_read(bh, 0);
+				continue;
+			}
 			submit_bh(REQ_OP_READ, 0, bh);
+		}
 	}
 	return 0;
 }
-- 
2.19.1
