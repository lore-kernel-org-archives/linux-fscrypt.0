Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 07/15] fscrypt: don't special-case EOPNOTSUPP from fscrypt_get_encryption_info()
Date: Mon, 30 Apr 2018 15:51:41 -0700
Message-Id: <20180430225149.183514-8-ebiggers3@gmail.com>
In-Reply-To: <20180430225149.183514-1-ebiggers3@gmail.com>
References: <20180430225149.183514-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In fscrypt_setup_filename(), remove the unnecessary check for
fscrypt_get_encryption_info() returning EOPNOTSUPP.  There's no reason
to handle this error differently from any other.  I think there may have
been some confusion because the "notsupp" version of
fscrypt_get_encryption_info() returns EOPNOTSUPP -- but that's not
applicable from inside fs/crypto/.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 3b5164b159cb..8088a606c0aa 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -335,7 +335,7 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 		return 0;
 	}
 	ret = fscrypt_get_encryption_info(dir);
-	if (ret && ret != -EOPNOTSUPP)
+	if (ret)
 		return ret;
 
 	if (dir->i_crypt_info) {
-- 
2.17.0.441.gb46fe60e1d-goog
