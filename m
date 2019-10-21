Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36774 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730069AbfJUXHY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Oct 2019 19:07:24 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 3/3] f2fs: add support for INLINE_CRYPT_OPTIMIZED encryption policies
Date: Mon, 21 Oct 2019 16:03:55 -0700
Message-Id: <20191021230355.23136-4-ebiggers@kernel.org>
In-Reply-To: <20191021230355.23136-1-ebiggers@kernel.org>
References: <20191021230355.23136-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Paul Lawrence <paullawrence@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

f2fs inode numbers are stable across filesystem resizing, and f2fs inode
and file logical block numbers are always 32-bit.  So f2fs can always
support INLINE_CRYPT_OPTIMIZED encryption policies.  Wire up the needed
fscrypt_operations to declare support.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/super.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 1443cee158633..851ac95229263 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -2308,13 +2308,27 @@ static bool f2fs_dummy_context(struct inode *inode)
 	return DUMMY_ENCRYPTION_ENABLED(F2FS_I_SB(inode));
 }
 
+static bool f2fs_has_stable_inodes(struct super_block *sb)
+{
+	return true;
+}
+
+static void f2fs_get_ino_and_lblk_bits(struct super_block *sb,
+				       int *ino_bits_ret, int *lblk_bits_ret)
+{
+	*ino_bits_ret = 8 * sizeof(nid_t);
+	*lblk_bits_ret = 8 * sizeof(block_t);
+}
+
 static const struct fscrypt_operations f2fs_cryptops = {
-	.key_prefix	= "f2fs:",
-	.get_context	= f2fs_get_context,
-	.set_context	= f2fs_set_context,
-	.dummy_context	= f2fs_dummy_context,
-	.empty_dir	= f2fs_empty_dir,
-	.max_namelen	= F2FS_NAME_LEN,
+	.key_prefix		= "f2fs:",
+	.get_context		= f2fs_get_context,
+	.set_context		= f2fs_set_context,
+	.dummy_context		= f2fs_dummy_context,
+	.empty_dir		= f2fs_empty_dir,
+	.max_namelen		= F2FS_NAME_LEN,
+	.has_stable_inodes	= f2fs_has_stable_inodes,
+	.get_ino_and_lblk_bits	= f2fs_get_ino_and_lblk_bits,
 };
 #endif
 
-- 
2.23.0.866.gb869b98d4c-goog
