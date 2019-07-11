Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:46584 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726213AbfGKQry (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 11 Jul 2019 12:47:54 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 4.4] fscrypt: don't set policy for a dead directory
Date: Thu, 11 Jul 2019 09:47:19 -0700
Message-Id: <20190711164719.262030-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: stable@vger.kernel.org, gregkh@linuxfoundation.org
Cc: linux-fscrypt@vger.kernel.org, Hongjie Fang <hongjiefang@asrmicro.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Hongjie Fang <hongjiefang@asrmicro.com>

commit 5858bdad4d0d0fc18bf29f34c3ac836e0b59441f upstream.
[Please apply to 4.4-stable.]

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
 fs/ext4/crypto_policy.c | 2 ++
 fs/f2fs/crypto_policy.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/ext4/crypto_policy.c b/fs/ext4/crypto_policy.c
index e4f4fc4e56abee..77bd7bfb632913 100644
--- a/fs/ext4/crypto_policy.c
+++ b/fs/ext4/crypto_policy.c
@@ -111,6 +111,8 @@ int ext4_process_policy(const struct ext4_encryption_policy *policy,
 	if (!ext4_inode_has_encryption_context(inode)) {
 		if (!S_ISDIR(inode->i_mode))
 			return -EINVAL;
+		if (IS_DEADDIR(inode))
+			return -ENOENT;
 		if (!ext4_empty_dir(inode))
 			return -ENOTEMPTY;
 		return ext4_create_encryption_context_from_policy(inode,
diff --git a/fs/f2fs/crypto_policy.c b/fs/f2fs/crypto_policy.c
index 884f3f0fe29d32..613ca32ec24887 100644
--- a/fs/f2fs/crypto_policy.c
+++ b/fs/f2fs/crypto_policy.c
@@ -99,6 +99,8 @@ int f2fs_process_policy(const struct f2fs_encryption_policy *policy,
 		return -EINVAL;
 
 	if (!f2fs_inode_has_encryption_context(inode)) {
+		if (IS_DEADDIR(inode))
+			return -ENOENT;
 		if (!f2fs_empty_dir(inode))
 			return -ENOTEMPTY;
 		return f2fs_create_encryption_context_from_policy(inode,
-- 
2.22.0.410.gd8fdbe21b5-goog
