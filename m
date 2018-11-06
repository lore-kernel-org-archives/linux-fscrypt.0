Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Gao Xiang <gaoxiang25@huawei.com>
Subject: [RFC PATCH v2 1/2] fscrypt: remove d_lock on reading DCACHE_ENCRYPTED_WITH_KEY
Date: Tue, 6 Nov 2018 20:20:51 +0800
Message-ID: <20181106122052.18507-1-gaoxiang25@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chao Yu <yuchao0@huawei.com>, Miao Xie <miaoxie@huawei.com>, weidu.du@huawei.com, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

It seems there is no need to take d_lock when accessing
dentry->d_flags & DCACHE_ENCRYPTED_WITH_KEY in
fscrypt_d_revalidate. It only needs to be serialized for updating.

Signed-off-by: Gao Xiang <gaoxiang25@huawei.com>
---

Change log v2:
 - Fix negative dentry (NULL d_inode) issue as Eric pointed out;
 - Fix to use '__lockref_is_dead()' as Eric pointed out before;

[original message]
Hi,
 At glance, I have no idea why fscrypt_d_revalidate disables
RCU-lookup. Therefore I made patches to raise a question and
do some test (eg. fsstress w/ and w/o drop_caches) and it
seems to work.

Thanks,
Gao Xiang

 fs/crypto/crypto.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 0f46cf550907..b38c574f70ac 100644
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
2.14.4
