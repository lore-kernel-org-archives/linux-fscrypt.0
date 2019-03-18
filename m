Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44044 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726765AbfCRRXt (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 18 Mar 2019 13:23:49 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: drop inode argument from fscrypt_get_ctx()
Date: Mon, 18 Mar 2019 10:23:33 -0700
Message-Id: <20190318172333.239937-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The only reason the inode is being passed to fscrypt_get_ctx() is to
verify that the encryption key is available.  However, all callers
already ensure this because if we get as far as trying to do I/O to an
encrypted file without the key, there's already a bug.

Therefore, remove this unnecessary argument.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c         |  2 +-
 fs/crypto/crypto.c      | 16 +++++-----------
 fs/ext4/readpage.c      |  2 +-
 include/linux/fscrypt.h |  5 ++---
 4 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index d7ad74818b2b..41dde4578f3b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -102,7 +102,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 
 	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
 
-	ctx = fscrypt_get_ctx(inode, GFP_NOFS);
+	ctx = fscrypt_get_ctx(GFP_NOFS);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 4dc788e3bc96..5efc494a4e38 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -87,23 +87,17 @@ EXPORT_SYMBOL(fscrypt_release_ctx);
 
 /**
  * fscrypt_get_ctx() - Gets an encryption context
- * @inode:       The inode for which we are doing the crypto
  * @gfp_flags:   The gfp flag for memory allocation
  *
  * Allocates and initializes an encryption context.
  *
- * Return: An allocated and initialized encryption context on success; error
- * value or NULL otherwise.
+ * Return: A new encryption context on success; an ERR_PTR() otherwise.
  */
-struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
+struct fscrypt_ctx *fscrypt_get_ctx(gfp_t gfp_flags)
 {
-	struct fscrypt_ctx *ctx = NULL;
-	struct fscrypt_info *ci = inode->i_crypt_info;
+	struct fscrypt_ctx *ctx;
 	unsigned long flags;
 
-	if (ci == NULL)
-		return ERR_PTR(-ENOKEY);
-
 	/*
 	 * We first try getting the ctx from a free list because in
 	 * the common case the ctx will have an allocated and
@@ -258,9 +252,9 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 
 	BUG_ON(!PageLocked(page));
 
-	ctx = fscrypt_get_ctx(inode, gfp_flags);
+	ctx = fscrypt_get_ctx(gfp_flags);
 	if (IS_ERR(ctx))
-		return (struct page *)ctx;
+		return ERR_CAST(ctx);
 
 	/* The encryption operation will require a bounce page. */
 	ciphertext_page = fscrypt_alloc_bounce_page(ctx, gfp_flags);
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 3adadf461825..75cef6af6080 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -244,7 +244,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
 			struct fscrypt_ctx *ctx = NULL;
 
 			if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
-				ctx = fscrypt_get_ctx(inode, GFP_NOFS);
+				ctx = fscrypt_get_ctx(GFP_NOFS);
 				if (IS_ERR(ctx))
 					goto set_error_page;
 			}
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index e5194fc3983e..6cf8a34523ff 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -90,7 +90,7 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 
 /* crypto.c */
 extern void fscrypt_enqueue_decrypt_work(struct work_struct *);
-extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
+extern struct fscrypt_ctx *fscrypt_get_ctx(gfp_t);
 extern void fscrypt_release_ctx(struct fscrypt_ctx *);
 extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
 						unsigned int, unsigned int,
@@ -247,8 +247,7 @@ static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
 {
 }
 
-static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
-						  gfp_t gfp_flags)
+static inline struct fscrypt_ctx *fscrypt_get_ctx(gfp_t gfp_flags)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
-- 
2.21.0.225.g810b269d1ac-goog
