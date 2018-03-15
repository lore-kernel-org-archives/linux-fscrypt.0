Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga07-in.huawei.com ([45.249.212.35]:60875 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751585AbeCOKv4 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 15 Mar 2018 06:51:56 -0400
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v5 3/3] ext4: do not allow mount with test_dummy_encryption if encrypt not set
Date: Thu, 15 Mar 2018 18:51:43 +0800
Message-ID: <20180315105143.133050-4-shengyong1@huawei.com>
In-Reply-To: <20180315105143.133050-1-shengyong1@huawei.com>
References: <20180315105143.133050-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

When mounting with test_dummy_encryption option, if encrypt feature
is not set, return fail instead of setting encrypt feature forcely.

Cc: linux-ext4@vger.kernel.org
Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 fs/ext4/super.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 39bf464c35f1..1a253342b09e 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4149,10 +4149,9 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		goto failed_mount_wq;
 	}
 
-	if (DUMMY_ENCRYPTION_ENABLED(sbi) && !sb_rdonly(sb) &&
-	    !ext4_has_feature_encrypt(sb)) {
-		ext4_set_feature_encrypt(sb);
-		ext4_commit_super(sb, 1);
+	if (DUMMY_ENCRYPTION_ENABLED(sbi) && !ext4_has_feature_encrypt(sb)) {
+		ext4_msg(sb, KERN_ERR, "Encrypt does not support");
+		goto failed_mount_wq;
 	}
 
 	/*
-- 
2.16.2

