Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Sun, 11 Aug 2019 14:35:53 -0700
Message-Id: <20190811213557.1970-3-ebiggers@kernel.org>
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH 2/6] ext4: skip truncate when verity in progress
 in ->write_begin()
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
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

When an error (e.g. ENOSPC) occurs during ext4_write_begin() when called
from ext4_write_merkle_tree_block(), skip truncating the file.  i_size
is not meaningful in this case, and the truncation is handled by
ext4_end_enable_verity() instead.  Also, this was triggering the
WARN_ON(!inode_is_locked(inode)) in ext4_truncate().

Fixes: ea54d7e4c0f8 ("ext4: add basic fs-verity support")
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b2c8d09acf652..cf0fce1173a4c 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1340,6 +1340,9 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	if (ret) {
+		bool extended = (pos + len > inode->i_size) &&
+				!ext4_verity_in_progress(inode);
+
 		unlock_page(page);
 		/*
 		 * __block_write_begin may have instantiated a few blocks
@@ -1349,11 +1352,11 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 		 * Add inode to orphan list in case we crash before
 		 * truncate finishes
 		 */
-		if (pos + len > inode->i_size && ext4_can_truncate(inode))
+		if (extended && ext4_can_truncate(inode))
 			ext4_orphan_add(handle, inode);
 
 		ext4_journal_stop(handle);
-		if (pos + len > inode->i_size) {
+		if (extended) {
 			ext4_truncate_failed_write(inode);
 			/*
 			 * If truncate failed early the inode might
-- 
2.22.0



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
