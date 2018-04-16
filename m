Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:43197 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752934AbeDPTdc (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 16 Apr 2018 15:33:32 -0400
Received: by mail-pl0-f65.google.com with SMTP id a39-v6so10580806pla.10
        for <linux-fscrypt@vger.kernel.org>; Mon, 16 Apr 2018 12:33:31 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH 2/2] f2fs: refactor read path to allow multiple postprocessing steps
Date: Mon, 16 Apr 2018 12:31:47 -0700
Message-Id: <20180416193147.104555-3-ebiggers@google.com>
In-Reply-To: <20180416193147.104555-1-ebiggers@google.com>
References: <20180416193147.104555-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Currently f2fs's ->readpage() and ->readpages() assume that either the
data undergoes no postprocessing, or decryption only.  But with
fs-verity, there will be an additional authenticity verification step,
and it may be needed either by itself, or combined with decryption.

To support this, store a 'struct bio_post_read_ctx' in ->bi_private
which contains a work struct, a bitmask of postprocessing steps that are
enabled, and an indicator of the current step.  The bio completion
routine, if there was no I/O error, enqueues the first postprocessing
step.  When that completes, it continues to the next step.  Pages that
fail any postprocessing step have PageError set.  Once all steps have
completed, pages without PageError set are set Uptodate, and all pages
are unlocked.

Also replace f2fs_encrypted_file() with a new function
f2fs_post_read_required() in places like direct I/O and garbage
collection that really should be testing whether the file needs special
I/O processing, not whether it is encrypted specifically.

This may also be useful for other future f2fs features such as
compression.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/data.c   | 163 +++++++++++++++++++++++++++++++++++------------
 fs/f2fs/f2fs.h   |  12 +++-
 fs/f2fs/file.c   |   4 +-
 fs/f2fs/gc.c     |   6 +-
 fs/f2fs/inline.c |   2 +-
 fs/f2fs/super.c  |   6 ++
 6 files changed, 144 insertions(+), 49 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 39225519de1c..ec70de0cd1d5 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -30,6 +30,9 @@
 #include "trace.h"
 #include <trace/events/f2fs.h>
 
+static struct kmem_cache *bio_post_read_ctx_cache;
+static mempool_t *bio_post_read_ctx_pool;
+
 static bool __is_cp_guaranteed(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
@@ -50,11 +53,77 @@ static bool __is_cp_guaranteed(struct page *page)
 	return false;
 }
 
-static void f2fs_read_end_io(struct bio *bio)
+/* postprocessing steps for read bios */
+enum bio_post_read_step {
+	STEP_INITIAL = 0,
+	STEP_DECRYPT,
+};
+
+struct bio_post_read_ctx {
+	struct bio *bio;
+	struct work_struct work;
+	unsigned int cur_step;
+	unsigned int enabled_steps;
+};
+
+static void __read_end_io(struct bio *bio)
 {
-	struct bio_vec *bvec;
+	struct page *page;
+	struct bio_vec *bv;
 	int i;
 
+	bio_for_each_segment_all(bv, bio, i) {
+		page = bv->bv_page;
+
+		/* PG_error was set if any post_read step failed */
+		if (bio->bi_status || PageError(page)) {
+			ClearPageUptodate(page);
+			SetPageError(page);
+		} else {
+			SetPageUptodate(page);
+		}
+		unlock_page(page);
+	}
+	if (bio->bi_private)
+		mempool_free(bio->bi_private, bio_post_read_ctx_pool);
+	bio_put(bio);
+}
+
+static void bio_post_read_processing(struct bio_post_read_ctx *ctx);
+
+static void decrypt_work(struct work_struct *work)
+{
+	struct bio_post_read_ctx *ctx =
+		container_of(work, struct bio_post_read_ctx, work);
+
+	fscrypt_decrypt_bio(ctx->bio);
+
+	bio_post_read_processing(ctx);
+}
+
+static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
+{
+	switch (++ctx->cur_step) {
+	case STEP_DECRYPT:
+		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
+			INIT_WORK(&ctx->work, decrypt_work);
+			fscrypt_enqueue_decrypt_work(&ctx->work);
+			return;
+		}
+		ctx->cur_step++;
+		/* fall-through */
+	default:
+		__read_end_io(ctx->bio);
+	}
+}
+
+static bool f2fs_bio_post_read_required(struct bio *bio)
+{
+	return bio->bi_private && !bio->bi_status;
+}
+
+static void f2fs_read_end_io(struct bio *bio)
+{
 #ifdef CONFIG_F2FS_FAULT_INJECTION
 	if (time_to_inject(F2FS_P_SB(bio_first_page_all(bio)), FAULT_IO)) {
 		f2fs_show_injection_info(FAULT_IO);
@@ -62,28 +131,15 @@ static void f2fs_read_end_io(struct bio *bio)
 	}
 #endif
 
-	if (f2fs_bio_encrypted(bio)) {
-		if (bio->bi_status) {
-			fscrypt_release_ctx(bio->bi_private);
-		} else {
-			fscrypt_enqueue_decrypt_bio(bio->bi_private, bio);
-			return;
-		}
-	}
-
-	bio_for_each_segment_all(bvec, bio, i) {
-		struct page *page = bvec->bv_page;
+	if (f2fs_bio_post_read_required(bio)) {
+		struct bio_post_read_ctx *ctx = bio->bi_private;
 
-		if (!bio->bi_status) {
-			if (!PageUptodate(page))
-				SetPageUptodate(page);
-		} else {
-			ClearPageUptodate(page);
-			SetPageError(page);
-		}
-		unlock_page(page);
+		ctx->cur_step = STEP_INITIAL;
+		bio_post_read_processing(ctx);
+		return;
 	}
-	bio_put(bio);
+
+	__read_end_io(bio);
 }
 
 static void f2fs_write_end_io(struct bio *bio)
@@ -481,29 +537,33 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 							 unsigned nr_pages)
 {
 	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
-	struct fscrypt_ctx *ctx = NULL;
 	struct bio *bio;
-
-	if (f2fs_encrypted_file(inode)) {
-		ctx = fscrypt_get_ctx(inode, GFP_NOFS);
-		if (IS_ERR(ctx))
-			return ERR_CAST(ctx);
-
-		/* wait the page to be moved by cleaning */
-		f2fs_wait_on_block_writeback(sbi, blkaddr);
-	}
+	struct bio_post_read_ctx *ctx;
+	unsigned int post_read_steps = 0;
 
 	bio = f2fs_bio_alloc(sbi, min_t(int, nr_pages, BIO_MAX_PAGES), false);
-	if (!bio) {
-		if (ctx)
-			fscrypt_release_ctx(ctx);
+	if (!bio)
 		return ERR_PTR(-ENOMEM);
-	}
 	f2fs_target_device(sbi, blkaddr, bio);
 	bio->bi_end_io = f2fs_read_end_io;
-	bio->bi_private = ctx;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
 
+	if (f2fs_encrypted_file(inode))
+		post_read_steps |= 1 << STEP_DECRYPT;
+	if (post_read_steps) {
+		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
+		if (!ctx) {
+			bio_put(bio);
+			return ERR_PTR(-ENOMEM);
+		}
+		ctx->bio = bio;
+		ctx->enabled_steps = post_read_steps;
+		bio->bi_private = ctx;
+
+		/* wait the page to be moved by cleaning */
+		f2fs_wait_on_block_writeback(sbi, blkaddr);
+	}
+
 	return bio;
 }
 
@@ -1525,7 +1585,7 @@ static int encrypt_one_page(struct f2fs_io_info *fio)
 	if (!f2fs_encrypted_file(inode))
 		return 0;
 
-	/* wait for GCed encrypted page writeback */
+	/* wait for GCed page writeback via META_MAPPING */
 	f2fs_wait_on_block_writeback(fio->sbi, fio->old_blkaddr);
 
 retry_encrypt:
@@ -2222,8 +2282,8 @@ static int f2fs_write_begin(struct file *file, struct address_space *mapping,
 
 	f2fs_wait_on_page_writeback(page, DATA, false);
 
-	/* wait for GCed encrypted page writeback */
-	if (f2fs_encrypted_file(inode))
+	/* wait for GCed page writeback via META_MAPPING */
+	if (f2fs_post_read_required(inode))
 		f2fs_wait_on_block_writeback(sbi, blkaddr);
 
 	if (len == PAGE_SIZE || PageUptodate(page))
@@ -2555,3 +2615,26 @@ const struct address_space_operations f2fs_dblock_aops = {
 	.migratepage    = f2fs_migrate_page,
 #endif
 };
+
+int __init f2fs_init_post_read_processing(void)
+{
+	bio_post_read_ctx_cache = KMEM_CACHE(bio_post_read_ctx, 0);
+	if (!bio_post_read_ctx_cache)
+		goto fail;
+	bio_post_read_ctx_pool =
+		mempool_create_slab_pool(128, bio_post_read_ctx_cache);
+	if (!bio_post_read_ctx_pool)
+		goto fail_free_cache;
+	return 0;
+
+fail_free_cache:
+	kmem_cache_destroy(bio_post_read_ctx_cache);
+fail:
+	return -ENOMEM;
+}
+
+void __exit f2fs_destroy_post_read_processing(void)
+{
+	mempool_destroy(bio_post_read_ctx_pool);
+	kmem_cache_destroy(bio_post_read_ctx_cache);
+}
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 1df7f10476d6..ea92c18db624 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -2858,6 +2858,8 @@ void destroy_checkpoint_caches(void);
 /*
  * data.c
  */
+int f2fs_init_post_read_processing(void);
+void f2fs_destroy_post_read_processing(void);
 void f2fs_submit_merged_write(struct f2fs_sb_info *sbi, enum page_type type);
 void f2fs_submit_merged_write_cond(struct f2fs_sb_info *sbi,
 				struct inode *inode, nid_t ino, pgoff_t idx,
@@ -3218,9 +3220,13 @@ static inline void f2fs_set_encrypted_inode(struct inode *inode)
 #endif
 }
 
-static inline bool f2fs_bio_encrypted(struct bio *bio)
+/*
+ * Returns true if the reads of the inode's data need to undergo some
+ * postprocessing step, like decryption or authenticity verification.
+ */
+static inline bool f2fs_post_read_required(struct inode *inode)
 {
-	return bio->bi_private != NULL;
+	return f2fs_encrypted_file(inode);
 }
 
 #define F2FS_FEATURE_FUNCS(name, flagname) \
@@ -3288,7 +3294,7 @@ static inline bool f2fs_may_encrypt(struct inode *inode)
 
 static inline bool f2fs_force_buffered_io(struct inode *inode, int rw)
 {
-	return (f2fs_encrypted_file(inode) ||
+	return (f2fs_post_read_required(inode) ||
 			(rw == WRITE && test_opt(F2FS_I_SB(inode), LFS)) ||
 			F2FS_I_SB(inode)->s_ndevs);
 }
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index 6b94f19b3fa8..cc08956334a0 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -110,8 +110,8 @@ static int f2fs_vm_page_mkwrite(struct vm_fault *vmf)
 	/* fill the page */
 	f2fs_wait_on_page_writeback(page, DATA, false);
 
-	/* wait for GCed encrypted page writeback */
-	if (f2fs_encrypted_file(inode))
+	/* wait for GCed page writeback via META_MAPPING */
+	if (f2fs_post_read_required(inode))
 		f2fs_wait_on_block_writeback(sbi, dn.data_blkaddr);
 
 out_sem:
diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
index 9327411fd93b..70418b34c5f6 100644
--- a/fs/f2fs/gc.c
+++ b/fs/f2fs/gc.c
@@ -850,8 +850,8 @@ static void gc_data_segment(struct f2fs_sb_info *sbi, struct f2fs_summary *sum,
 			if (IS_ERR(inode) || is_bad_inode(inode))
 				continue;
 
-			/* if encrypted inode, let's go phase 3 */
-			if (f2fs_encrypted_file(inode)) {
+			/* if inode uses special I/O path, let's go phase 3 */
+			if (f2fs_post_read_required(inode)) {
 				add_gc_inode(gc_list, inode);
 				continue;
 			}
@@ -899,7 +899,7 @@ static void gc_data_segment(struct f2fs_sb_info *sbi, struct f2fs_summary *sum,
 
 			start_bidx = start_bidx_of_node(nofs, inode)
 								+ ofs_in_node;
-			if (f2fs_encrypted_file(inode))
+			if (f2fs_post_read_required(inode))
 				move_data_block(inode, start_bidx, segno, off);
 			else
 				move_data_page(inode, start_bidx, gc_type,
diff --git a/fs/f2fs/inline.c b/fs/f2fs/inline.c
index 265da200daa8..767e41d944c6 100644
--- a/fs/f2fs/inline.c
+++ b/fs/f2fs/inline.c
@@ -25,7 +25,7 @@ bool f2fs_may_inline_data(struct inode *inode)
 	if (i_size_read(inode) > MAX_INLINE_DATA(inode))
 		return false;
 
-	if (f2fs_encrypted_file(inode))
+	if (f2fs_post_read_required(inode))
 		return false;
 
 	return true;
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 42d564c5ccd0..f31643718c76 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -3092,8 +3092,13 @@ static int __init init_f2fs_fs(void)
 	err = f2fs_create_root_stats();
 	if (err)
 		goto free_filesystem;
+	err = f2fs_init_post_read_processing();
+	if (err)
+		goto free_root_stats;
 	return 0;
 
+free_root_stats:
+	f2fs_destroy_root_stats();
 free_filesystem:
 	unregister_filesystem(&f2fs_fs_type);
 free_shrinker:
@@ -3116,6 +3121,7 @@ static int __init init_f2fs_fs(void)
 
 static void __exit exit_f2fs_fs(void)
 {
+	f2fs_destroy_post_read_processing();
 	f2fs_destroy_root_stats();
 	unregister_filesystem(&f2fs_fs_type);
 	unregister_shrinker(&f2fs_shrinker_info);
-- 
2.17.0.484.g0c8726318c-goog

