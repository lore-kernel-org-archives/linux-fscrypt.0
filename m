Return-Path: <SRS0=d/SI=TK=asrmicro.com=hongjiefang@kernel.org>
From: Hongjie Fang <hongjiefang@asrmicro.com>
Subject: [PATCH V3] fscrypt: don't set policy for a dead directory
Date: Fri, 10 May 2019 10:05:23 +0800
Message-ID: <1557453923-5286-1-git-send-email-hongjiefang@asrmicro.com>
MIME-Version: 1.0
Content-Type: text/plain
To: tytso@mit.edu, jaegeuk@kernel.org, ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org, Hongjie Fang <hongjiefang@asrmicro.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

the directory maybe has been removed when enter fscrypt_ioctl_set_policy().
it this case, the empty_dir() check will return error for ext4 file system.

ext4_rmdir() sets i_size = 0, then ext4_empty_dir() reports an error
because 'inode->i_size < EXT4_DIR_REC_LEN(1) + EXT4_DIR_REC_LEN(2)'.
if the fs is mounted with errors=panic, it will trigger a panic issue.

add the check IS_DEADDIR() to fix this problem.

Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
Cc: <stable@vger.kernel.org> # v4.1+
Signed-off-by: Hongjie Fang <hongjiefang@asrmicro.com>
---
 fs/crypto/policy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index bd7eaf9..a4eca6e 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -81,6 +81,8 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 	if (ret == -ENODATA) {
 		if (!S_ISDIR(inode->i_mode))
 			ret = -ENOTDIR;
+		else if (IS_DEADDIR(inode))
+			ret = -ENOENT;
 		else if (!inode->i_sb->s_cop->empty_dir(inode))
 			ret = -ENOTEMPTY;
 		else
-- 
1.9.1
