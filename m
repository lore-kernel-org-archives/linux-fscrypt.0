Return-Path: <SRS0=THX2=QZ=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [RFC PATCH 08/10] fsverity: Add call back to verify file holes
Date: Mon, 18 Feb 2019 15:34:31 +0530
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190218100433.20048-9-chandan@linux.ibm.com>
To: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

readpage() implmentations zero out part of the page-cache page mapping a
file hole. This commit adds a call back to "struct fsverity_operations"
which readpage() can invoke to verify the file hole.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/ext4/super.c          | 1 +
 include/linux/fsverity.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 4493ddc357c6..94e0d4b56653 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1459,6 +1459,7 @@ static const struct fsverity_operations ext4_verityops = {
 	.read_metadata_page	= ext4_read_verity_metadata_page,
 	.verity_required	= ext4_verity_required,
 	.readpage_limit		= ext4_readpage_limit,
+	.check_hole		= fsverity_check_hole,
 };
 #endif /* CONFIG_FS_VERITY */
 
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index fc8113acbbfe..8bc28b07d550 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -20,6 +20,7 @@ struct fsverity_operations {
 	struct page *(*read_metadata_page)(struct inode *inode, pgoff_t index);
 	bool (*verity_required)(struct inode *inode, pgoff_t index);
 	loff_t (*readpage_limit)(struct inode *inode);
+	bool (*check_hole)(struct inode *inode, struct page *page);
 };
 
 #ifdef CONFIG_FS_VERITY
-- 
2.19.1
