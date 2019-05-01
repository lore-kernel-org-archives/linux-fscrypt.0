Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Wed,  1 May 2019 15:45:12 -0700
Message-Id: <20190501224515.43059-11-ebiggers@kernel.org>
In-Reply-To: <20190501224515.43059-1-ebiggers@kernel.org>
References: <20190501224515.43059-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH 10/13] ext4: clear BH_Uptodate flag on decryption
 error
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

From: Chandan Rajendra <chandan@linux.ibm.com>

If decryption fails, ext4_block_write_begin() can return with the page's
buffer_head marked with the BH_Uptodate flag.  This commit clears the
BH_Uptodate flag in such cases.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 1ef5d791834fc..9382e1bcefe49 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1225,10 +1225,14 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 		if (!buffer_uptodate(*wait_bh))
 			err = -EIO;
 	}
-	if (unlikely(err))
+	if (unlikely(err)) {
 		page_zero_new_buffers(page, from, to);
-	else if (decrypt)
+	} else if (decrypt) {
 		err = fscrypt_decrypt_pagecache_blocks(page, PAGE_SIZE, 0);
+		if (err)
+			clear_buffer_uptodate(*wait_bh);
+	}
+
 	return err;
 }
 #endif
-- 
2.21.0.593.g511ec345e18-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
