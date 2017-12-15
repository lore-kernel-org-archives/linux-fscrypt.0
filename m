Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 02/24] fscrypt: move fscrypt_control_page() to supp/notsupp headers
Date: Fri, 15 Dec 2017 09:42:03 -0800
Message-Id: <20171215174225.31583-3-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_control_page() is already split into two versions depending on
whether the filesystem is being built with encryption support or not.
Move them into the appropriate headers.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt.h         | 18 ++----------------
 include/linux/fscrypt_notsupp.h |  5 +++++
 include/linux/fscrypt_supp.h    |  6 ++++++
 3 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index d1c891b5bd9c..c23b2f16129a 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -123,24 +123,10 @@ static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
 }
 
 #if __FS_HAS_ENCRYPTION
-
-static inline struct page *fscrypt_control_page(struct page *page)
-{
-	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
-}
-
 #include <linux/fscrypt_supp.h>
-
-#else /* !__FS_HAS_ENCRYPTION */
-
-static inline struct page *fscrypt_control_page(struct page *page)
-{
-	WARN_ON_ONCE(1);
-	return ERR_PTR(-EINVAL);
-}
-
+#else
 #include <linux/fscrypt_notsupp.h>
-#endif /* __FS_HAS_ENCRYPTION */
+#endif
 
 /**
  * fscrypt_require_key - require an inode's encryption key
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 52e330285457..812dc701a5b3 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -48,6 +48,11 @@ static inline int fscrypt_decrypt_page(const struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
+static inline struct page *fscrypt_control_page(struct page *page)
+{
+	WARN_ON_ONCE(1);
+	return ERR_PTR(-EINVAL);
+}
 
 static inline void fscrypt_restore_control_page(struct page *page)
 {
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 79bb8beae018..ad40780d4653 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -25,6 +25,12 @@ extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
 						u64, gfp_t);
 extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
 				unsigned int, u64);
+
+static inline struct page *fscrypt_control_page(struct page *page)
+{
+	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
+}
+
 extern void fscrypt_restore_control_page(struct page *);
 
 extern const struct dentry_operations fscrypt_d_ops;
-- 
2.15.1
