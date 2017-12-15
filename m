Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 03/24] fscrypt: move fscrypt_info_cachep declaration to fscrypt_private.h
Date: Fri, 15 Dec 2017 09:42:04 -0800
Message-Id: <20171215174225.31583-4-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The fscrypt_info kmem_cache is internal to fscrypt; filesystems don't
need to access it.  So move its declaration into fscrypt_private.h.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h  | 1 +
 include/linux/fscrypt_supp.h | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index c0b4f5597e1a..823c43a00bf7 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -72,6 +72,7 @@ typedef enum {
 #define FS_CTX_HAS_BOUNCE_BUFFER_FL		0x00000002
 
 /* crypto.c */
+extern struct kmem_cache *fscrypt_info_cachep;
 extern int fscrypt_initialize(unsigned int cop_flags);
 extern struct workqueue_struct *fscrypt_read_workqueue;
 extern int fscrypt_do_page_crypto(const struct inode *inode,
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index ad40780d4653..33d641e27c18 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -17,7 +17,6 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 }
 
 /* crypto.c */
-extern struct kmem_cache *fscrypt_info_cachep;
 extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
 extern void fscrypt_release_ctx(struct fscrypt_ctx *);
 extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
-- 
2.15.1
