Return-Path: <SRS0=XRRt=SO=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 03/14] fsverity: Add call back to decide if verity check has to be performed
Date: Fri, 12 Apr 2019 22:40:30 +0530
In-Reply-To: <20190412171041.31995-1-chandan@linux.ibm.com>
References: <20190412171041.31995-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190412171041.31995-4-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

Ext4 and F2FS store verity metadata in data extents (beyond
inode->i_size) associated with a file. But other filesystems might
choose alternative means to store verity metadata. Hence this commit
adds a callback function pointer to 'struct fsverity_operations' to help
in deciding if verity operation needs to performed against a page-cache
page holding file data.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/ext4/super.c          | 6 ++++++
 fs/post_read_process.c   | 4 +++-
 include/linux/fsverity.h | 1 +
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index aba724f82cc3..63d73b360f1d 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1428,10 +1428,16 @@ static struct page *ext4_read_verity_metadata_page(struct inode *inode,
 	return read_mapping_page(inode->i_mapping, index, NULL);
 }
 
+static bool ext4_verity_required(struct inode *inode, pgoff_t index)
+{
+	return index < (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
+}
+
 static const struct fsverity_operations ext4_verityops = {
 	.set_verity		= ext4_set_verity,
 	.get_metadata_end	= ext4_get_verity_metadata_end,
 	.read_metadata_page	= ext4_read_verity_metadata_page,
+	.verity_required	= ext4_verity_required,
 };
 #endif /* CONFIG_FS_VERITY */
 
diff --git a/fs/post_read_process.c b/fs/post_read_process.c
index d203fc263091..c408184b671a 100644
--- a/fs/post_read_process.c
+++ b/fs/post_read_process.c
@@ -86,7 +86,9 @@ struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
 		post_read_steps |= 1 << STEP_DECRYPT;
 #ifdef CONFIG_FS_VERITY
 	if (inode->i_verity_info != NULL &&
-		(index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
+		((inode->i_sb->s_vop->verity_required
+			&& inode->i_sb->s_vop->verity_required(inode, index))
+			|| (inode->i_sb->s_vop->verity_required == NULL))
 		post_read_steps |= 1 << STEP_VERITY;
 #endif
 	if (post_read_steps) {
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index 7c33b42abf1b..b83712d6c79a 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -18,6 +18,7 @@ struct fsverity_operations {
 	int (*set_verity)(struct inode *inode, loff_t data_i_size);
 	int (*get_metadata_end)(struct inode *inode, loff_t *metadata_end_ret);
 	struct page *(*read_metadata_page)(struct inode *inode, pgoff_t index);
+	bool (*verity_required)(struct inode *inode, pgoff_t index);
 };
 
 #ifdef CONFIG_FS_VERITY
-- 
2.19.1
