Return-Path: <SRS0=LT3F=WT=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V5 1/7] buffer_head: Introduce BH_Read_Cb flag
Date: Fri, 23 Aug 2019 18:55:36 +0530
Message-Id: <20190823132542.13434-2-chandan@linux.ibm.com>
In-Reply-To: <20190823132542.13434-1-chandan@linux.ibm.com>
References: <20190823132542.13434-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, hch@infradead.org, chandanrlinux@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

Decryption of file content encrypted using fscrypt relies on
bio->bi_private holding a pointer to an encryption context
i.e. Decryption operation is not performed for bios having a NULL value
at bio->bi_private.

The same logic cannot be used on buffer heads because,
1. In Btrfs, write_dev_supers() sets bh->b_private to 'struct
   btrfs_device' pointer and submits the buffer head for a write
   operation.
   1. In btrfs/146 test, the write operation fails and hence the
      endio function clears the BH_Uptodate flag.
   2. A read operation initiated later will submit the buffer head to
      the block layer. During endio processing, bh_>b_private would have a
      non-NULL value.

2. Another instance is when an Ext4 metadata block with BH_Uptodate set and
   also part of the in-memory JBD list undergoes the following,
   1. A sync() syscall is invoked by the userspace and the write
      operation on the metadata block is initiated.
   2. Due to an I/O failure, the BH_Uptodate flag is cleared by
      end_buffer_async_write(). The bh->b_private member would be
      pointing to a journal head structure.
   3. In such a case, a read operation invoked on the block mapped by the
      buffer head will initiate a read from the disk since the buffer head is
      missing the BH_Uptodate flag.
   4. After the read I/O request is submitted, end_buffer_async_read()
      will find a non-NULL value at bh->b_private.
   This scenario was observed when executing generic/475 test case.

Hence this commit introduces a new buffer head flag to reliably check for
decryption of a buffer head's contents after the block has been read
from the disk.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 include/linux/buffer_head.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 7b73ef7f902d..08f217ba8114 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -38,6 +38,7 @@ enum bh_state_bits {
 	BH_Meta,	/* Buffer contains metadata */
 	BH_Prio,	/* Buffer should be submitted with REQ_PRIO */
 	BH_Defer_Completion, /* Defer AIO completion to workqueue */
+	BH_Read_Cb,	     /* Block's contents needs to be decrypted */
 
 	BH_PrivateStart,/* not a state bit, but the first bit available
 			 * for private allocation by other entities
@@ -134,6 +135,7 @@ BUFFER_FNS(Unwritten, unwritten)
 BUFFER_FNS(Meta, meta)
 BUFFER_FNS(Prio, prio)
 BUFFER_FNS(Defer_Completion, defer_completion)
+BUFFER_FNS(Read_Cb, read_cb)
 
 #define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
 
-- 
2.19.1
