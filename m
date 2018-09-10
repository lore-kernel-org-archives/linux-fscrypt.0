Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:12092 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727269AbeIJRz3 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Sep 2018 13:55:29 -0400
From: Gao Xiang <gaoxiang25@huawei.com>
Subject: [RFC PATCH 1/2] fscrypt: remove d_lock on reading DCACHE_ENCRYPTED_WITH_KEY
Date: Mon, 10 Sep 2018 21:01:07 +0800
Message-ID: <1536584468-15695-1-git-send-email-gaoxiang25@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Chao Yu <yuchao0@huawei.com>, Miao Xie <miaoxie@huawei.com>, weidu.du@huawei.com, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

It seems there is no need to take d_lock when
accessing dentry->d_flags & DCACHE_ENCRYPTED_WITH_KEY
in fscrypt_d_revalidate. It only needs to be
serialized for updating.

Signed-off-by: Gao Xiang <gaoxiang25@huawei.com>
---
Hi,

At glance, I have no idea why fscrypt_d_revalidate disables
RCU-lookup. Therefore I made patches to raise a question and
do some basic test, and it seems to work.

Thanks,

 fs/crypto/crypto.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 0f46cf5..b38c574 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -329,9 +329,8 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 		return 0;
 	}
 
-	spin_lock(&dentry->d_lock);
-	cached_with_key = dentry->d_flags & DCACHE_ENCRYPTED_WITH_KEY;
-	spin_unlock(&dentry->d_lock);
+	cached_with_key = READ_ONCE(dentry->d_flags) &
+		DCACHE_ENCRYPTED_WITH_KEY;
 	dir_has_key = (d_inode(dir)->i_crypt_info != NULL);
 	dput(dir);
 
-- 
1.9.1
