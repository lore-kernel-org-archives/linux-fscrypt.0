Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 04/14] fscrypt: remove stale comment from fscrypt_d_revalidate()
Date: Fri, 23 Mar 2018 12:23:48 -0700
Message-Id: <20180323192358.95691-5-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 58761d816751..d22887f689ad 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -322,7 +322,6 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 		return 0;
 	}
 
-	/* this should eventually be an flag in d_flags */
 	spin_lock(&dentry->d_lock);
 	cached_with_key = dentry->d_flags & DCACHE_ENCRYPTED_WITH_KEY;
 	spin_unlock(&dentry->d_lock);
-- 
2.17.0.rc0.231.g781580f067-goog
