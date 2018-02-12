Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 03/11] fs/crypto/: Rename functions to indicate that they operate on FS blocks
Date: Mon, 12 Feb 2018 15:13:39 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-4-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

The functions in fs/crypto/ actually operate on FS blocks. Hence this
commit renames the functions to represent this fact.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/bio.c                 |  8 ++++----
 fs/crypto/crypto.c              | 22 +++++++++++-----------
 fs/crypto/fscrypt_private.h     |  2 +-
 fs/ext4/inode.c                 |  4 ++--
 fs/ext4/page-io.c               |  2 +-
 fs/ext4/readpage.c              |  2 +-
 include/linux/fscrypt_notsupp.h |  4 ++--
 include/linux/fscrypt_supp.h    |  6 +++---
 8 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0d5e6a5..efb0734 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -40,7 +40,7 @@ static void completion_pages(struct work_struct *work)
 
 	bio_for_each_segment_all(bv, bio, i) {
 		struct page *page = bv->bv_page;
-		int ret = fscrypt_decrypt_page(page->mapping->host, page,
+		int ret = fscrypt_decrypt_block(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
 
 		if (ret) {
@@ -55,13 +55,13 @@ static void completion_pages(struct work_struct *work)
 	bio_put(bio);
 }
 
-void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx, struct bio *bio)
+void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx, struct bio *bio)
 {
 	INIT_WORK(&ctx->r.work, completion_pages);
 	ctx->r.bio = bio;
 	queue_work(fscrypt_read_workqueue, &ctx->r.work);
 }
-EXPORT_SYMBOL(fscrypt_decrypt_bio_pages);
+EXPORT_SYMBOL(fscrypt_decrypt_bio_blocks);
 
 void fscrypt_pullback_bio_page(struct page **page, bool restore)
 {
@@ -105,7 +105,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
 	}
 
 	while (len--) {
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk,
+		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk,
 					     ZERO_PAGE(0), ciphertext_page,
 					     PAGE_SIZE, 0, GFP_NOFS);
 		if (err)
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 732a786..24e3796 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -126,10 +126,10 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
 }
 EXPORT_SYMBOL(fscrypt_get_ctx);
 
-int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
-			   u64 lblk_num, struct page *src_page,
-			   struct page *dest_page, unsigned int len,
-			   unsigned int offs, gfp_t gfp_flags)
+int fscrypt_do_block_crypto(const struct inode *inode, fscrypt_direction_t rw,
+			u64 lblk_num, struct page *src_page,
+			struct page *dest_page, unsigned int len,
+			unsigned int offs, gfp_t gfp_flags)
 {
 	struct {
 		__le64 index;
@@ -226,7 +226,7 @@ struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
  * Return: A page with the encrypted content on success. Else, an
  * error value or NULL.
  */
-struct page *fscrypt_encrypt_page(const struct inode *inode,
+struct page *fscrypt_encrypt_block(const struct inode *inode,
 				struct page *page,
 				unsigned int len,
 				unsigned int offs,
@@ -241,7 +241,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 
 	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
 		/* with inplace-encryption we just encrypt the page */
-		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num, page,
+		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num, page,
 					     ciphertext_page, len, offs,
 					     gfp_flags);
 		if (err)
@@ -262,7 +262,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 		goto errout;
 
 	ctx->w.control_page = page;
-	err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
+	err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num,
 				     page, ciphertext_page, len, offs,
 				     gfp_flags);
 	if (err) {
@@ -278,7 +278,7 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
 	fscrypt_release_ctx(ctx);
 	return ciphertext_page;
 }
-EXPORT_SYMBOL(fscrypt_encrypt_page);
+EXPORT_SYMBOL(fscrypt_encrypt_block);
 
 /**
  * fscrypt_decrypt_page() - Decrypts a page in-place
@@ -295,16 +295,16 @@ EXPORT_SYMBOL(fscrypt_encrypt_page);
  *
  * Return: Zero on success, non-zero otherwise.
  */
-int fscrypt_decrypt_page(const struct inode *inode, struct page *page,
+int fscrypt_decrypt_block(const struct inode *inode, struct page *page,
 			unsigned int len, unsigned int offs, u64 lblk_num)
 {
 	if (!(inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES))
 		BUG_ON(!PageLocked(page));
 
-	return fscrypt_do_page_crypto(inode, FS_DECRYPT, lblk_num, page, page,
+	return fscrypt_do_block_crypto(inode, FS_DECRYPT, lblk_num, page, page,
 				      len, offs, GFP_NOFS);
 }
-EXPORT_SYMBOL(fscrypt_decrypt_page);
+EXPORT_SYMBOL(fscrypt_decrypt_block);
 
 /*
  * Validate dentries for encrypted directories to make sure we aren't
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index c0b4f55..9821e97 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -74,7 +74,7 @@ typedef enum {
 /* crypto.c */
 extern int fscrypt_initialize(unsigned int cop_flags);
 extern struct workqueue_struct *fscrypt_read_workqueue;
-extern int fscrypt_do_page_crypto(const struct inode *inode,
+extern int fscrypt_do_block_crypto(const struct inode *inode,
 				  fscrypt_direction_t rw, u64 lblk_num,
 				  struct page *src_page,
 				  struct page *dest_page,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index e8ecf67..69a4fd6 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1232,7 +1232,7 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
 	if (unlikely(err))
 		page_zero_new_buffers(page, from, to);
 	else if (decrypt) {
-		err = fscrypt_decrypt_page(page->mapping->host, page,
+		err = fscrypt_decrypt_block(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
 		if (err)
 			clear_buffer_uptodate(*wait_bh);
@@ -4022,7 +4022,7 @@ static int __ext4_block_zero_page_range(handle_t *handle,
 			/* We expect the key to be set. */
 			BUG_ON(!fscrypt_has_encryption_key(inode));
 			BUG_ON(blocksize != PAGE_SIZE);
-			WARN_ON_ONCE(fscrypt_decrypt_page(page->mapping->host,
+			WARN_ON_ONCE(fscrypt_decrypt_block(page->mapping->host,
 						page, PAGE_SIZE, 0, page->index));
 		}
 	}
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index db75901..0a4a1e7 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -482,7 +482,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 		gfp_t gfp_flags = GFP_NOFS;
 
 	retry_encrypt:
-		data_page = fscrypt_encrypt_page(inode, page, PAGE_SIZE, 0,
+		data_page = fscrypt_encrypt_block(inode, page, PAGE_SIZE, 0,
 						page->index, gfp_flags);
 		if (IS_ERR(data_page)) {
 			ret = PTR_ERR(data_page);
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 9ffa6fa..8b2789f 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -77,7 +77,7 @@ static void mpage_end_io(struct bio *bio)
 		if (bio->bi_status) {
 			fscrypt_release_ctx(bio->bi_private);
 		} else {
-			fscrypt_decrypt_bio_pages(bio->bi_private, bio);
+			fscrypt_decrypt_bio_blocks(bio->bi_private, bio);
 			return;
 		}
 	}
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 63e5880..d726b53 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -35,7 +35,7 @@ static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
-static inline int fscrypt_decrypt_page(const struct inode *inode,
+static inline int fscrypt_decrypt_block(const struct inode *inode,
 				       struct page *page,
 				       unsigned int len, unsigned int offs,
 				       u64 lblk_num)
@@ -161,7 +161,7 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 }
 
 /* bio.c */
-static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
+static inline void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *ctx,
 					     struct bio *bio)
 {
 	return;
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index cf9e9fc..7720e4a 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -15,10 +15,10 @@
 extern struct kmem_cache *fscrypt_info_cachep;
 extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
 extern void fscrypt_release_ctx(struct fscrypt_ctx *);
-extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
+extern struct page *fscrypt_encrypt_block(const struct inode *, struct page *,
 						unsigned int, unsigned int,
 						u64, gfp_t);
-extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
+extern int fscrypt_decrypt_block(const struct inode *, struct page *, unsigned int,
 				unsigned int, u64);
 extern void fscrypt_restore_control_page(struct page *);
 
@@ -139,7 +139,7 @@ static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 }
 
 /* bio.c */
-extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
+extern void fscrypt_decrypt_bio_blocks(struct fscrypt_ctx *, struct bio *);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
 extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
 				 unsigned int);
-- 
2.9.5
