Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33520 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726055AbfHKVhO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 11 Aug 2019 17:37:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6/6] f2fs: use EFSCORRUPTED in f2fs_get_verity_descriptor()
Date: Sun, 11 Aug 2019 14:35:57 -0700
Message-Id: <20190811213557.1970-7-ebiggers@kernel.org>
In-Reply-To: <20190811213557.1970-1-ebiggers@kernel.org>
References: <20190811213557.1970-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

EFSCORRUPTED is now defined in f2fs.h, so use it instead of EUCLEAN.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/verity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/f2fs/verity.c b/fs/f2fs/verity.c
index 6bc3470d99d00..a401ef72bc821 100644
--- a/fs/f2fs/verity.c
+++ b/fs/f2fs/verity.c
@@ -210,7 +210,7 @@ static int f2fs_get_verity_descriptor(struct inode *inode, void *buf,
 	if (pos + size < pos || pos + size > inode->i_sb->s_maxbytes ||
 	    pos < f2fs_verity_metadata_pos(inode) || size > INT_MAX) {
 		f2fs_warn(F2FS_I_SB(inode), "invalid verity xattr");
-		return -EUCLEAN; /* EFSCORRUPTED */
+		return -EFSCORRUPTED;
 	}
 	if (buf_size) {
 		if (size > buf_size)
-- 
2.22.0
