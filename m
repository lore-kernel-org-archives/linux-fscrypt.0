Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42626 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727956AbfGKQmc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 11 Jul 2019 12:42:32 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 4.9] fscrypt: don't set policy for a dead directory
Date: Thu, 11 Jul 2019 09:41:48 -0700
Message-Id: <20190711164148.230281-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: stable@vger.kernel.org, gregkh@linuxfoundation.org
Cc: linux-fscrypt@vger.kernel.org, Hongjie Fang <hongjiefang@asrmicro.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Hongjie Fang <hongjiefang@asrmicro.com>

commit 5858bdad4d0d0fc18bf29f34c3ac836e0b59441f upstream.
[Please apply to 4.9-stable.]

The directory may have been removed when entering
fscrypt_ioctl_set_policy().  If so, the empty_dir() check will return
error for ext4 file system.

ext4_rmdir() sets i_size = 0, then ext4_empty_dir() reports an error
because 'inode->i_size < EXT4_DIR_REC_LEN(1) + EXT4_DIR_REC_LEN(2)'.  If
the fs is mounted with errors=panic, it will trigger a panic issue.

Add the check IS_DEADDIR() to fix this problem.

Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
Cc: <stable@vger.kernel.org> # v4.1+
Signed-off-by: Hongjie Fang <hongjiefang@asrmicro.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/policy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index c160d2d0e18d77..57a97b38a2fa2c 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -114,6 +114,8 @@ int fscrypt_process_policy(struct file *filp,
 	if (!inode_has_encryption_context(inode)) {
 		if (!S_ISDIR(inode->i_mode))
 			ret = -ENOTDIR;
+		else if (IS_DEADDIR(inode))
+			ret = -ENOENT;
 		else if (!inode->i_sb->s_cop->empty_dir)
 			ret = -EOPNOTSUPP;
 		else if (!inode->i_sb->s_cop->empty_dir(inode))
-- 
2.22.0.410.gd8fdbe21b5-goog
