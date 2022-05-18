Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7F54C433FE
	for <linux-fscrypt@archiver.kernel.org>; Wed, 18 May 2022 09:42:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234510AbiERJmJ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 18 May 2022 05:42:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44148 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234615AbiERJke (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 18 May 2022 05:40:34 -0400
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com [45.249.212.188])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 984D714A27A;
        Wed, 18 May 2022 02:40:01 -0700 (PDT)
Received: from canpemm500005.china.huawei.com (unknown [172.30.72.54])
        by szxga02-in.huawei.com (SkyGuard) with ESMTP id 4L37H213JpzhZHF;
        Wed, 18 May 2022 17:39:10 +0800 (CST)
Received: from huawei.com (10.67.174.96) by canpemm500005.china.huawei.com
 (7.192.104.229) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.2375.24; Wed, 18 May
 2022 17:39:59 +0800
From:   Zhang Jianhua <chris.zjh@huawei.com>
To:     <ebiggers@kernel.org>, <tytso@mit.edu>
CC:     <linux-fscrypt@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH -next] fs-verity: Use struct_size() helper in fsverity_ioctl_measure()
Date:   Wed, 18 May 2022 17:38:29 +0800
Message-ID: <20220518093829.2248801-1-chris.zjh@huawei.com>
X-Mailer: git-send-email 2.31.0
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Content-Type:   text/plain; charset=US-ASCII
X-Originating-IP: [10.67.174.96]
X-ClientProxiedBy: dggems703-chm.china.huawei.com (10.3.19.180) To
 canpemm500005.china.huawei.com (7.192.104.229)
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Make use of the struct_size() helper instead of an open-coded version,
in order to avoid any potential type mistakes or integer overflows that,
in the worst scenario, could lead to heap overflows.

Also, address the following sparse warnings:
fs/verity/measure.c:48:9: warning: using sizeof on a flexible structure
fs/verity/measure.c:52:38: warning: using sizeof on a flexible structure

Signed-off-by: Zhang Jianhua <chris.zjh@huawei.com>
---
 fs/verity/measure.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/verity/measure.c b/fs/verity/measure.c
index e99c00350c28..4a388116d0de 100644
--- a/fs/verity/measure.c
+++ b/fs/verity/measure.c
@@ -27,6 +27,7 @@ int fsverity_ioctl_measure(struct file *filp, void __user *_uarg)
 	const struct fsverity_info *vi;
 	const struct fsverity_hash_alg *hash_alg;
 	struct fsverity_digest arg;
+	size_t arg_size = struct_size(&arg, digest, 0);
 
 	vi = fsverity_get_info(inode);
 	if (!vi)
@@ -44,11 +45,11 @@ int fsverity_ioctl_measure(struct file *filp, void __user *_uarg)
 	if (arg.digest_size < hash_alg->digest_size)
 		return -EOVERFLOW;
 
-	memset(&arg, 0, sizeof(arg));
+	memset(&arg, 0, arg_size);
 	arg.digest_algorithm = hash_alg - fsverity_hash_algs;
 	arg.digest_size = hash_alg->digest_size;
 
-	if (copy_to_user(uarg, &arg, sizeof(arg)))
+	if (copy_to_user(uarg, &arg, arg_size))
 		return -EFAULT;
 
 	if (copy_to_user(uarg->digest, vi->file_digest, hash_alg->digest_size))
-- 
2.31.0

