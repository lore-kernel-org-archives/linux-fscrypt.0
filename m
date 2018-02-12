Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 02/11] fs/buffer.c: Export end_buffer_async_read and create_page_buffers
Date: Mon, 12 Feb 2018 15:13:38 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-3-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

The functions end_buffer_async_read() and create_page_buffers() will be
required by the fscrypt module to implement decrypting encrypted blocks
that have been read from the filesystem.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/buffer.c                 | 6 ++++--
 include/linux/buffer_head.h | 3 +++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 551b781..663180d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -256,7 +256,7 @@ __find_get_block_slow(struct block_device *bdev, sector_t block)
  * I/O completion handler for block_read_full_page() - pages
  * which come unlocked at the end of I/O.
  */
-static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
+void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 {
 	unsigned long flags;
 	struct buffer_head *first;
@@ -312,6 +312,7 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
 	local_irq_restore(flags);
 	return;
 }
+EXPORT_SYMBOL(end_buffer_async_read);
 
 /*
  * Completion handler for block_write_full_page() - pages which are unlocked
@@ -1647,7 +1648,7 @@ static inline int block_size_bits(unsigned int blocksize)
 	return ilog2(blocksize);
 }
 
-static struct buffer_head *create_page_buffers(struct page *page, struct inode *inode, unsigned int b_state)
+struct buffer_head *create_page_buffers(struct page *page, struct inode *inode, unsigned int b_state)
 {
 	BUG_ON(!PageLocked(page));
 
@@ -1656,6 +1657,7 @@ static struct buffer_head *create_page_buffers(struct page *page, struct inode *
 				     b_state);
 	return page_buffers(page);
 }
+EXPORT_SYMBOL(create_page_buffers);
 
 /*
  * NOTE! All mapped/uptodate combinations are valid:
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index f1aed01..edc0983 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -161,7 +161,10 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 		bool retry);
 void create_empty_buffers(struct page *, unsigned long,
 			unsigned long b_state);
+struct buffer_head *create_page_buffers(struct page *page, struct inode *inode,
+					unsigned int b_state);
 void end_buffer_read_sync(struct buffer_head *bh, int uptodate);
+void end_buffer_async_read(struct buffer_head *bh, int uptodate);
 void end_buffer_write_sync(struct buffer_head *bh, int uptodate);
 void end_buffer_async_write(struct buffer_head *bh, int uptodate);
 
-- 
2.9.5
