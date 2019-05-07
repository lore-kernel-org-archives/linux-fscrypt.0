Return-Path: <SRS0=//Tt=TH=asrmicro.com=hongjiefang@kernel.org>
From: hongjiefang <hongjiefang@asrmicro.com>
Subject: [PATCH] fscrypt: don't set policy for a dead directory
Date: Tue, 7 May 2019 12:41:48 +0800
Message-ID: <1557204108-29048-1-git-send-email-hongjiefang@asrmicro.com>
MIME-Version: 1.0
Content-Type: text/plain
To: tytso@mit.edu, jaegeuk@kernel.org, ebiggers@kernel.org
Cc: linux-fscrypt@vger.kernel.org, hongjiefang <hongjiefang@asrmicro.com>
List-ID: <linux-fscrypt@vger.kernel.org>

if the directory had been removed, should not set policy for it.

Signed-off-by: hongjiefang <hongjiefang@asrmicro.com>
---
 fs/crypto/policy.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index bd7eaf9..82900a4 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -77,6 +77,12 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 
 	inode_lock(inode);
 
+	/* don't set policy for a dead directory */
+	if (IS_DEADDIR(inode)) {
+		ret = -ENOENT;
+		goto deaddir_out;
+	}
+
 	ret = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
 	if (ret == -ENODATA) {
 		if (!S_ISDIR(inode->i_mode))
@@ -96,6 +102,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		ret = -EEXIST;
 	}
 
+deaddir_out:
 	inode_unlock(inode);
 
 	mnt_drop_write_file(filp);
-- 
1.9.1
