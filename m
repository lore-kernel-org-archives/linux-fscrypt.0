Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f66.google.com ([209.85.160.66]:41270 "EHLO
        mail-pl0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753240AbeDPTd3 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 16 Apr 2018 15:33:29 -0400
Received: by mail-pl0-f66.google.com with SMTP id bj1-v6so10584265plb.8
        for <linux-fscrypt@vger.kernel.org>; Mon, 16 Apr 2018 12:33:29 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH 1/2] fscrypt: allow synchronous bio decryption
Date: Mon, 16 Apr 2018 12:31:46 -0700
Message-Id: <20180416193147.104555-2-ebiggers@google.com>
In-Reply-To: <20180416193147.104555-1-ebiggers@google.com>
References: <20180416193147.104555-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Currently, fscrypt provides fscrypt_decrypt_bio_pages() which decrypts a
bio's pages asynchronously, then unlocks them afterwards.  But, this
assumes that decryption is the last "postprocessing step" for the bio,
so it's incompatible with additional postprocessing steps such as
authenticity verification after decryption.

Therefore, rename the existing fscrypt_decrypt_bio_pages() to
fscrypt_enqueue_decrypt_bio().  Then, add fscrypt_decrypt_bio() which
decrypts the pages in the bio synchronously without unlocking the pages,
nor setting them Uptodate; and add fscrypt_enqueue_decrypt_work(), which
enqueues work on the fscrypt_read_workqueue.  The new functions will be
used by filesystems that support both fscrypt and fs-verity.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c                 | 35 +++++++++++++++++++++------------
 fs/crypto/crypto.c              |  8 +++++++-
 fs/crypto/fscrypt_private.h     |  1 -
 fs/ext4/readpage.c              |  2 +-
 fs/f2fs/data.c                  |  2 +-
 include/linux/fscrypt_notsupp.h | 13 +++++++++---
 include/linux/fscrypt_supp.h    |  5 ++++-
 7 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0d5e6a569d58..0959044c5cee 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -26,15 +26,8 @@
 #include <linux/namei.h>
 #include "fscrypt_private.h"
 
-/*
- * Call fscrypt_decrypt_page on every single page, reusing the encryption
- * context.
- */
-static void completion_pages(struct work_struct *work)
+static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
 {
-	struct fscrypt_ctx *ctx =
-		container_of(work, struct fscrypt_ctx, r.work);
-	struct bio *bio = ctx->r.bio;
 	struct bio_vec *bv;
 	int i;
 
@@ -46,22 +39,38 @@ static void completion_pages(struct work_struct *work)
 		if (ret) {
 			WARN_ON_ONCE(1);
 			SetPageError(page);
-		} else {
+		} else if (done) {
 			SetPageUptodate(page);
 		}
-		unlock_page(page);
+		if (done)
+			unlock_page(page);
 	}
+}
+
+void fscrypt_decrypt_bio(struct bio *bio)
+{
+	__fscrypt_decrypt_bio(bio, false);
+}
+EXPORT_SYMBOL(fscrypt_decrypt_bio);
+
+static void completion_pages(struct work_struct *work)
+{
+	struct fscrypt_ctx *ctx =
+		container_of(work, struct fscrypt_ctx, r.work);
+	struct bio *bio = ctx->r.bio;
+
+	__fscrypt_decrypt_bio(bio, true);
 	fscrypt_release_ctx(ctx);
 	bio_put(bio);
 }
 
-void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx, struct bio *bio)
+void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx, struct bio *bio)
 {
 	INIT_WORK(&ctx->r.work, completion_pages);
 	ctx->r.bio = bio;
-	queue_work(fscrypt_read_workqueue, &ctx->r.work);
+	fscrypt_enqueue_decrypt_work(&ctx->r.work);
 }
-EXPORT_SYMBOL(fscrypt_decrypt_bio_pages);
+EXPORT_SYMBOL(fscrypt_enqueue_decrypt_bio);
 
 void fscrypt_pullback_bio_page(struct page **page, bool restore)
 {
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index ce654526c0fb..0758d32ad01b 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -45,12 +45,18 @@ static mempool_t *fscrypt_bounce_page_pool = NULL;
 static LIST_HEAD(fscrypt_free_ctxs);
 static DEFINE_SPINLOCK(fscrypt_ctx_lock);
 
-struct workqueue_struct *fscrypt_read_workqueue;
+static struct workqueue_struct *fscrypt_read_workqueue;
 static DEFINE_MUTEX(fscrypt_init_mutex);
 
 static struct kmem_cache *fscrypt_ctx_cachep;
 struct kmem_cache *fscrypt_info_cachep;
 
+void fscrypt_enqueue_decrypt_work(struct work_struct *work)
+{
+	queue_work(fscrypt_read_workqueue, work);
+}
+EXPORT_SYMBOL(fscrypt_enqueue_decrypt_work);
+
 /**
  * fscrypt_release_ctx() - Releases an encryption context
  * @ctx: The encryption context to release.
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index ad6722bae8b7..4012558f6115 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -97,7 +97,6 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
 extern int fscrypt_initialize(unsigned int cop_flags);
-extern struct workqueue_struct *fscrypt_read_workqueue;
 extern int fscrypt_do_page_crypto(const struct inode *inode,
 				  fscrypt_direction_t rw, u64 lblk_num,
 				  struct page *src_page,
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 9ffa6fad18db..19b87a8de6ff 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -77,7 +77,7 @@ static void mpage_end_io(struct bio *bio)
 		if (bio->bi_status) {
 			fscrypt_release_ctx(bio->bi_private);
 		} else {
-			fscrypt_decrypt_bio_pages(bio->bi_private, bio);
+			fscrypt_enqueue_decrypt_bio(bio->bi_private, bio);
 			return;
 		}
 	}
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 02237d4d91f5..39225519de1c 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -66,7 +66,7 @@ static void f2fs_read_end_io(struct bio *bio)
 		if (bio->bi_status) {
 			fscrypt_release_ctx(bio->bi_private);
 		} else {
-			fscrypt_decrypt_bio_pages(bio->bi_private, bio);
+			fscrypt_enqueue_decrypt_bio(bio->bi_private, bio);
 			return;
 		}
 	}
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 44b50c04bae9..9770be37c9d4 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -25,6 +25,10 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 }
 
 /* crypto.c */
+static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
+{
+}
+
 static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
 						  gfp_t gfp_flags)
 {
@@ -160,10 +164,13 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 }
 
 /* bio.c */
-static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
-					     struct bio *bio)
+static inline void fscrypt_decrypt_bio(struct bio *bio)
+{
+}
+
+static inline void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
+					       struct bio *bio)
 {
-	return;
 }
 
 static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 477a7a6504d2..2c9a86ac5e83 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -59,6 +59,7 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 }
 
 /* crypto.c */
+extern void fscrypt_enqueue_decrypt_work(struct work_struct *);
 extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
 extern void fscrypt_release_ctx(struct fscrypt_ctx *);
 extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
@@ -188,7 +189,9 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 }
 
 /* bio.c */
-extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
+extern void fscrypt_decrypt_bio(struct bio *);
+extern void fscrypt_enqueue_decrypt_bio(struct fscrypt_ctx *ctx,
+					struct bio *bio);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
-- 
2.17.0.484.g0c8726318c-goog

