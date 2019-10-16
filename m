Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:38050 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2393062AbfJPWOq (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 16 Oct 2019 18:14:46 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 1/2] fs/buffer.c: support fscrypt in block_read_full_page()
Date: Wed, 16 Oct 2019 15:11:41 -0700
Message-Id: <20191016221142.298754-2-ebiggers@kernel.org>
In-Reply-To: <20191016221142.298754-1-ebiggers@kernel.org>
References: <20191016221142.298754-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-ext4@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

After each filesystem block (as represented by a buffer_head) has been
read from disk by block_read_full_page(), decrypt it if needed.  The
decryption is done on the fscrypt_read_workqueue.

This is the final change needed to support ext4 encryption with
blocksize != PAGE_SIZE, and it's a fairly small change now that
CONFIG_FS_ENCRYPTION is a bool and fs/crypto/ exposes functions to
decrypt individual blocks and to enqueue work on the fscrypt workqueue.

Don't try to add fs-verity support yet, as the fs/verity/ support layer
isn't ready for sub-page blocks yet.  Just add fscrypt support for now.

Almost all the new code is compiled away when CONFIG_FS_ENCRYPTION=n.

Cc: Chandan Rajendra <chandan@linux.ibm.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/buffer.c | 47 ++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 5 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 86a38b979323..f26f64655246 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -47,6 +47,7 @@
 #include <linux/pagevec.h>
 #include <linux/sched/mm.h>
 #include <trace/events/block.h>
+#include <linux/fscrypt.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 static int submit_bh_wbc(int op, int op_flags, struct buffer_head *bh,
@@ -246,10 +247,6 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
 	return ret;
 }
 
-/*
- * I/O completion handler for block_read_full_page() - pages
- * which come unlocked at the end of I/O.
- */
 static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
@@ -307,6 +304,46 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	return;
 }
 
+struct decrypt_bh_ctx {
+	struct work_struct work;
+	struct buffer_head *bh;
+};
+
+static void decrypt_bh(struct work_struct *work)
+{
+	struct decrypt_bh_ctx *ctx =
+		container_of(work, struct decrypt_bh_ctx, work);
+	struct buffer_head *bh = ctx->bh;
+	int err;
+
+	err = fscrypt_decrypt_pagecache_blocks(bh->b_page, bh->b_size,
+					       bh_offset(bh));
+	end_buffer_async_read(bh, err == 0);
+	kfree(ctx);
+}
+
+/*
+ * I/O completion handler for block_read_full_page() - pages
+ * which come unlocked at the end of I/O.
+ */
+static void end_buffer_async_read_io(struct buffer_head *bh, int uptodate)
+{
+	/* Decrypt if needed */
+	if (uptodate && IS_ENABLED(CONFIG_FS_ENCRYPTION) &&
+	    IS_ENCRYPTED(bh->b_page->mapping->host)) {
+		struct decrypt_bh_ctx *ctx = kmalloc(sizeof(*ctx), GFP_ATOMIC);
+
+		if (ctx) {
+			INIT_WORK(&ctx->work, decrypt_bh);
+			ctx->bh = bh;
+			fscrypt_enqueue_decrypt_work(&ctx->work);
+			return;
+		}
+		uptodate = 0;
+	}
+	end_buffer_async_read(bh, uptodate);
+}
+
 /*
  * Completion handler for block_write_full_page() - pages which are unlocked
  * during I/O, and which have PageWriteback cleared upon I/O completion.
@@ -379,7 +416,7 @@ EXPORT_SYMBOL(end_buffer_async_write);
  */
 static void mark_buffer_async_read(struct buffer_head *bh)
 {
-	bh->b_end_io = end_buffer_async_read;
+	bh->b_end_io = end_buffer_async_read_io;
 	set_buffer_async_read(bh);
 }
 
-- 
2.23.0
