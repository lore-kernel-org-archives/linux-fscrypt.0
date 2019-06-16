Return-Path: <SRS0=94sN=UP=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V3 3/7] fscrypt: remove struct fscrypt_ctx
Date: Sun, 16 Jun 2019 21:38:09 +0530
In-Reply-To: <20190616160813.24464-1-chandan@linux.ibm.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190616160813.24464-4-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Commit "fscrypt: remove the 'write' part of struct fscrypt_ctx" reduced
"struct fscrypt_ctx" to be used only for decryption. With "read
callbacks" being integrated into Ext4 and F2FS, we don't use "struct
fscrypt_ctx" anymore. Hence this commit removes the structure and the
associated code.

Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
---
 fs/crypto/crypto.c      | 89 +----------------------------------------
 include/linux/fscrypt.h | 25 ------------
 2 files changed, 2 insertions(+), 112 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index e0aa20cfcaa7..18c6b664b042 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -32,24 +32,16 @@
 #include "fscrypt_private.h"
 
 static unsigned int num_prealloc_crypto_pages = 32;
-static unsigned int num_prealloc_crypto_ctxs = 128;
 
 module_param(num_prealloc_crypto_pages, uint, 0444);
 MODULE_PARM_DESC(num_prealloc_crypto_pages,
 		"Number of crypto pages to preallocate");
-module_param(num_prealloc_crypto_ctxs, uint, 0444);
-MODULE_PARM_DESC(num_prealloc_crypto_ctxs,
-		"Number of crypto contexts to preallocate");
 
 static mempool_t *fscrypt_bounce_page_pool = NULL;
 
-static LIST_HEAD(fscrypt_free_ctxs);
-static DEFINE_SPINLOCK(fscrypt_ctx_lock);
-
 static struct workqueue_struct *fscrypt_read_workqueue;
 static DEFINE_MUTEX(fscrypt_init_mutex);
 
-static struct kmem_cache *fscrypt_ctx_cachep;
 struct kmem_cache *fscrypt_info_cachep;
 
 void fscrypt_enqueue_decrypt_work(struct work_struct *work)
@@ -59,62 +51,6 @@ void fscrypt_enqueue_decrypt_work(struct work_struct *work)
 }
 EXPORT_SYMBOL(fscrypt_enqueue_decrypt_work);
 
-/**
- * fscrypt_release_ctx() - Release a decryption context
- * @ctx: The decryption context to release.
- *
- * If the decryption context was allocated from the pre-allocated pool, return
- * it to that pool.  Else, free it.
- */
-void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
-{
-	unsigned long flags;
-
-	if (ctx->flags & FS_CTX_REQUIRES_FREE_ENCRYPT_FL) {
-		kmem_cache_free(fscrypt_ctx_cachep, ctx);
-	} else {
-		spin_lock_irqsave(&fscrypt_ctx_lock, flags);
-		list_add(&ctx->free_list, &fscrypt_free_ctxs);
-		spin_unlock_irqrestore(&fscrypt_ctx_lock, flags);
-	}
-}
-EXPORT_SYMBOL(fscrypt_release_ctx);
-
-/**
- * fscrypt_get_ctx() - Get a decryption context
- * @gfp_flags:   The gfp flag for memory allocation
- *
- * Allocate and initialize a decryption context.
- *
- * Return: A new decryption context on success; an ERR_PTR() otherwise.
- */
-struct fscrypt_ctx *fscrypt_get_ctx(gfp_t gfp_flags)
-{
-	struct fscrypt_ctx *ctx;
-	unsigned long flags;
-
-	/*
-	 * First try getting a ctx from the free list so that we don't have to
-	 * call into the slab allocator.
-	 */
-	spin_lock_irqsave(&fscrypt_ctx_lock, flags);
-	ctx = list_first_entry_or_null(&fscrypt_free_ctxs,
-					struct fscrypt_ctx, free_list);
-	if (ctx)
-		list_del(&ctx->free_list);
-	spin_unlock_irqrestore(&fscrypt_ctx_lock, flags);
-	if (!ctx) {
-		ctx = kmem_cache_zalloc(fscrypt_ctx_cachep, gfp_flags);
-		if (!ctx)
-			return ERR_PTR(-ENOMEM);
-		ctx->flags |= FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
-	} else {
-		ctx->flags &= ~FS_CTX_REQUIRES_FREE_ENCRYPT_FL;
-	}
-	return ctx;
-}
-EXPORT_SYMBOL(fscrypt_get_ctx);
-
 struct page *fscrypt_alloc_bounce_page(gfp_t gfp_flags)
 {
 	return mempool_alloc(fscrypt_bounce_page_pool, gfp_flags);
@@ -401,11 +337,6 @@ const struct dentry_operations fscrypt_d_ops = {
 
 static void fscrypt_destroy(void)
 {
-	struct fscrypt_ctx *pos, *n;
-
-	list_for_each_entry_safe(pos, n, &fscrypt_free_ctxs, free_list)
-		kmem_cache_free(fscrypt_ctx_cachep, pos);
-	INIT_LIST_HEAD(&fscrypt_free_ctxs);
 	mempool_destroy(fscrypt_bounce_page_pool);
 	fscrypt_bounce_page_pool = NULL;
 }
@@ -421,7 +352,7 @@ static void fscrypt_destroy(void)
  */
 int fscrypt_initialize(unsigned int cop_flags)
 {
-	int i, res = -ENOMEM;
+	int res = -ENOMEM;
 
 	/* No need to allocate a bounce page pool if this FS won't use it. */
 	if (cop_flags & FS_CFLG_OWN_PAGES)
@@ -431,15 +362,6 @@ int fscrypt_initialize(unsigned int cop_flags)
 	if (fscrypt_bounce_page_pool)
 		goto already_initialized;
 
-	for (i = 0; i < num_prealloc_crypto_ctxs; i++) {
-		struct fscrypt_ctx *ctx;
-
-		ctx = kmem_cache_zalloc(fscrypt_ctx_cachep, GFP_NOFS);
-		if (!ctx)
-			goto fail;
-		list_add(&ctx->free_list, &fscrypt_free_ctxs);
-	}
-
 	fscrypt_bounce_page_pool =
 		mempool_create_page_pool(num_prealloc_crypto_pages, 0);
 	if (!fscrypt_bounce_page_pool)
@@ -494,18 +416,12 @@ static int __init fscrypt_init(void)
 	if (!fscrypt_read_workqueue)
 		goto fail;
 
-	fscrypt_ctx_cachep = KMEM_CACHE(fscrypt_ctx, SLAB_RECLAIM_ACCOUNT);
-	if (!fscrypt_ctx_cachep)
-		goto fail_free_queue;
-
 	fscrypt_info_cachep = KMEM_CACHE(fscrypt_info, SLAB_RECLAIM_ACCOUNT);
 	if (!fscrypt_info_cachep)
-		goto fail_free_ctx;
+		goto fail_free_queue;
 
 	return 0;
 
-fail_free_ctx:
-	kmem_cache_destroy(fscrypt_ctx_cachep);
 fail_free_queue:
 	destroy_workqueue(fscrypt_read_workqueue);
 fail:
@@ -522,7 +438,6 @@ static void __exit fscrypt_exit(void)
 
 	if (fscrypt_read_workqueue)
 		destroy_workqueue(fscrypt_read_workqueue);
-	kmem_cache_destroy(fscrypt_ctx_cachep);
 	kmem_cache_destroy(fscrypt_info_cachep);
 
 	fscrypt_essiv_cleanup();
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 4ec0bd7cc0ba..13012c589aa3 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -19,7 +19,6 @@
 
 #define FS_CRYPTO_BLOCK_SIZE		16
 
-struct fscrypt_ctx;
 struct fscrypt_info;
 
 struct fscrypt_str {
@@ -63,18 +62,6 @@ struct fscrypt_operations {
 	unsigned int max_namelen;
 };
 
-/* Decryption work */
-struct fscrypt_ctx {
-	union {
-		struct {
-			struct bio *bio;
-			struct work_struct work;
-		};
-		struct list_head free_list;	/* Free list */
-	};
-	u8 flags;				/* Flags */
-};
-
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 {
 	/* pairs with cmpxchg_release() in fscrypt_get_encryption_info() */
@@ -101,8 +88,6 @@ static inline void fscrypt_handle_d_move(struct dentry *dentry)
 
 /* crypto.c */
 extern void fscrypt_enqueue_decrypt_work(struct work_struct *);
-extern struct fscrypt_ctx *fscrypt_get_ctx(gfp_t);
-extern void fscrypt_release_ctx(struct fscrypt_ctx *);
 
 extern struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 						     unsigned int len,
@@ -281,16 +266,6 @@ static inline void fscrypt_enqueue_decrypt_work(struct work_struct *work)
 {
 }
 
-static inline struct fscrypt_ctx *fscrypt_get_ctx(gfp_t gfp_flags)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
-{
-	return;
-}
-
 static inline struct page *fscrypt_encrypt_pagecache_blocks(struct page *page,
 							    unsigned int len,
 							    unsigned int offs,
-- 
2.19.1
