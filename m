Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 07/14] fscrypt: drop max_namelen check from fname_decrypt()
Date: Fri, 23 Mar 2018 12:23:51 -0700
Message-Id: <20180323192358.95691-8-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fname_decrypt() returns an error if the input filename is longer than
the inode's ->max_namelen() as given by the filesystem.  But, this
doesn't actually make sense because the filesystem provided the input
filename in the first place, where it was subject to the filesystem's
limits.  And fscrypt_decrypt() has no internal limit itself.

Thus, remove this unnecessary check.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 8088a606c0aa..cc9590b5f371 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -93,14 +93,11 @@ static int fname_decrypt(struct inode *inode,
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist src_sg, dst_sg;
-	struct fscrypt_info *ci = inode->i_crypt_info;
-	struct crypto_skcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = inode->i_crypt_info->ci_ctfm;
 	int res = 0;
 	char iv[FS_CRYPTO_BLOCK_SIZE];
-	unsigned lim;
 
-	lim = inode->i_sb->s_cop->max_namelen(inode);
-	if (iname->len <= 0 || iname->len > lim)
+	if (iname->len <= 0)
 		return -EIO;
 
 	/* Allocate request */
-- 
2.17.0.rc0.231.g781580f067-goog
