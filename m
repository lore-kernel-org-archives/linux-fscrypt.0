Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 4/4] f2fs: don't bother checking for encryption key in ->write_iter()
Date: Mon, 22 May 2017 17:39:45 -0700
Message-Id: <20170523003945.14279-5-ebiggers3@gmail.com>
In-Reply-To: <20170523003945.14279-1-ebiggers3@gmail.com>
References: <20170523003945.14279-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Since only an open file can be written to, and we only allow open()ing
an encrypted file when its key is available, there is no need to check
for the key again before permitting each ->write_iter().

This code was also broken in that it wouldn't actually have failed if
the key was in fact unavailable.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/file.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index ff4db3efc0ac..3ccc63089a47 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -2318,11 +2318,6 @@ static ssize_t f2fs_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	struct blk_plug plug;
 	ssize_t ret;
 
-	if (f2fs_encrypted_inode(inode) &&
-				!fscrypt_has_encryption_key(inode) &&
-				fscrypt_get_encryption_info(inode))
-		return -EACCES;
-
 	inode_lock(inode);
 	ret = generic_write_checks(iocb, from);
 	if (ret > 0) {
-- 
2.13.0.303.g4ebf302169-goog
