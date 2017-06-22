Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: make ->dummy_context() return bool
Date: Thu, 22 Jun 2017 12:14:40 -0700
Message-Id: <20170622191440.82025-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This makes it consistent with ->is_encrypted(), ->empty_dir(), and
fscrypt_dummy_context_enabled().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/super.c                | 2 +-
 include/linux/fscrypt_common.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d46766a7c33e..8ca7e0f03596 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1219,7 +1219,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	return res;
 }
 
-static int ext4_dummy_context(struct inode *inode)
+static bool ext4_dummy_context(struct inode *inode)
 {
 	return DUMMY_ENCRYPTION_ENABLED(EXT4_SB(inode->i_sb));
 }
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 4022c61f7e9b..e3e1208e0f54 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -77,7 +77,7 @@ struct fscrypt_operations {
 	const char *key_prefix;
 	int (*get_context)(struct inode *, void *, size_t);
 	int (*set_context)(struct inode *, const void *, size_t, void *);
-	int (*dummy_context)(struct inode *);
+	bool (*dummy_context)(struct inode *);
 	bool (*is_encrypted)(struct inode *);
 	bool (*empty_dir)(struct inode *);
 	unsigned (*max_namelen)(struct inode *);
-- 
2.13.1.611.g7e3b11ae1-goog
