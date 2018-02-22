Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: clean up after fscrypt_prepare_lookup() conversions
Date: Thu, 22 Feb 2018 15:56:01 -0800
Message-Id: <20180222235601.105764-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now that all filesystems have been converted to use
fscrypt_prepare_lookup(), we can remove the fscrypt_set_d_op() and
fscrypt_set_encrypted_dentry() functions as well as un-export
fscrypt_d_ops.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c              |  1 -
 fs/crypto/fscrypt_private.h     |  1 +
 include/linux/fscrypt_notsupp.h | 10 ----------
 include/linux/fscrypt_supp.h    | 14 --------------
 4 files changed, 1 insertion(+), 25 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index ce654526c0fb..f2b2d8408a01 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -353,7 +353,6 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 const struct dentry_operations fscrypt_d_ops = {
 	.d_revalidate = fscrypt_d_revalidate,
 };
-EXPORT_SYMBOL(fscrypt_d_ops);
 
 void fscrypt_restore_control_page(struct page *page)
 {
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index ad6722bae8b7..fb96e493167b 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -106,6 +106,7 @@ extern int fscrypt_do_page_crypto(const struct inode *inode,
 				  gfp_t gfp_flags);
 extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
+extern const struct dentry_operations fscrypt_d_ops;
 
 /* fname.c */
 extern int fname_encrypt(struct inode *inode, const struct qstr *iname,
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 44b50c04bae9..25b6492de6e5 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -64,16 +64,6 @@ static inline void fscrypt_restore_control_page(struct page *page)
 	return;
 }
 
-static inline void fscrypt_set_d_op(struct dentry *dentry)
-{
-	return;
-}
-
-static inline void fscrypt_set_encrypted_dentry(struct dentry *dentry)
-{
-	return;
-}
-
 /* policy.c */
 static inline int fscrypt_ioctl_set_policy(struct file *filp,
 					   const void __user *arg)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 477a7a6504d2..c9c2cc26bc62 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -74,20 +74,6 @@ static inline struct page *fscrypt_control_page(struct page *page)
 
 extern void fscrypt_restore_control_page(struct page *);
 
-extern const struct dentry_operations fscrypt_d_ops;
-
-static inline void fscrypt_set_d_op(struct dentry *dentry)
-{
-	d_set_d_op(dentry, &fscrypt_d_ops);
-}
-
-static inline void fscrypt_set_encrypted_dentry(struct dentry *dentry)
-{
-	spin_lock(&dentry->d_lock);
-	dentry->d_flags |= DCACHE_ENCRYPTED_WITH_KEY;
-	spin_unlock(&dentry->d_lock);
-}
-
 /* policy.c */
 extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
 extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
-- 
2.16.1.291.g4437f3f132-goog
