Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 08/14] fscrypt: drop empty name check from fname_decrypt()
Date: Fri, 23 Mar 2018 12:23:52 -0700
Message-Id: <20180323192358.95691-9-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fname_decrypt() is validating that the encrypted filename is nonempty.
However, earlier a stronger precondition was already enforced: the
encrypted filename must be at least 16 (FS_CRYPTO_BLOCK_SIZE) bytes.

Drop the redundant check for an empty filename.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index cc9590b5f371..c4eb3a235ae4 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -97,9 +97,6 @@ static int fname_decrypt(struct inode *inode,
 	int res = 0;
 	char iv[FS_CRYPTO_BLOCK_SIZE];
 
-	if (iname->len <= 0)
-		return -EIO;
-
 	/* Allocate request */
 	req = skcipher_request_alloc(tfm, GFP_NOFS);
 	if (!req)
-- 
2.17.0.rc0.231.g781580f067-goog
