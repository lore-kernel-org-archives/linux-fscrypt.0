Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga07-in.huawei.com ([45.249.212.35]:50823 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751284AbeCIHx1 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 9 Mar 2018 02:53:27 -0500
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH 3/3] ext4: do not allow mount with test_dummy_encryption if encrypt not set
Date: Fri, 9 Mar 2018 15:53:12 +0800
Message-ID: <20180309075312.62357-4-shengyong1@huawei.com>
In-Reply-To: <20180309075312.62357-1-shengyong1@huawei.com>
References: <20180309075312.62357-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

When mounting with test_dummy_encryption option, if encrypt feature
is not set, return fail instead of setting encrypt feature forcely.

CC: linux-ext4@vger.kernel.org
Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 fs/ext4/super.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 39bf464c35f1..c424af0ccda9 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4151,8 +4151,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 
 	if (DUMMY_ENCRYPTION_ENABLED(sbi) && !sb_rdonly(sb) &&
 	    !ext4_has_feature_encrypt(sb)) {
-		ext4_set_feature_encrypt(sb);
-		ext4_commit_super(sb, 1);
+		ext4_msg(sb, KERN_ERR,
+			 "Encrypt does not support or filesystem is read-only");
+		goto failed_mount_wq;
 	}
 
 	/*
-- 
2.14.1

