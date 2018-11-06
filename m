Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:14179 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2387612AbeKFVcI (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 6 Nov 2018 16:32:08 -0500
From: Gao Xiang <gaoxiang25@huawei.com>
Subject: [RFC PATCH v2 2/2] fscrypt: enable RCU-walk path for .d_revalidate
Date: Tue, 6 Nov 2018 20:20:52 +0800
Message-ID: <20181106122052.18507-2-gaoxiang25@huawei.com>
In-Reply-To: <20181106122052.18507-1-gaoxiang25@huawei.com>
References: <20181106122052.18507-1-gaoxiang25@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chao Yu <yuchao0@huawei.com>, Miao Xie <miaoxie@huawei.com>, weidu.du@huawei.com, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

This patch attempts to enable RCU-walk for fscrypt.
It looks harmless at glance and could have better
performance than do ref-walk only.

Signed-off-by: Gao Xiang <gaoxiang25@huawei.com>
---

p.s.
  In my opinion, it is better to retry for the case of
  READ_ONCE(dentry->d_parent) != dir rather than just
  return 0; and then do real lookup for ref-walk path...
  It behaves much like a seqlock and I tend to avoid
  taking d_lock as well..
  Please kindly correct me if I am wrong... Thanks in advance.

Thanks,
Gao Xiang

 fs/crypto/crypto.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index b38c574f70ac..2cc26fe9c43d 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -319,20 +319,29 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct dentry *dir;
 	int dir_has_key, cached_with_key;
+	struct inode *dir_inode;
 
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
+repeat:
+	rcu_read_lock();
+	dir = READ_ONCE(dentry->d_parent);
 
-	dir = dget_parent(dentry);
-	if (!IS_ENCRYPTED(d_inode(dir))) {
-		dput(dir);
+	dir_inode = d_inode_rcu(dir);
+	if (!dir_inode || !IS_ENCRYPTED(dir_inode)) {
+		rcu_read_unlock();
 		return 0;
 	}
+	dir_has_key = (dir_inode->i_crypt_info != NULL);
+
+	/* original dir becomes invalid after sampling all? */
+	if (unlikely(__lockref_is_dead(&dir->d_lockref) ||
+		     READ_ONCE(dentry->d_parent) != dir)) {
+		rcu_read_unlock();
+		goto repeat;
+	}
+	rcu_read_unlock();
 
 	cached_with_key = READ_ONCE(dentry->d_flags) &
 		DCACHE_ENCRYPTED_WITH_KEY;
-	dir_has_key = (d_inode(dir)->i_crypt_info != NULL);
-	dput(dir);
 
 	/*
 	 * If the dentry was cached without the key, and it is a
-- 
2.14.4
