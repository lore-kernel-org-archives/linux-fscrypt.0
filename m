Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 10/11] Enable writing encrypted files in blocksize less than pagesize setup
Date: Mon, 12 Feb 2018 15:13:46 +0530
In-Reply-To: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180212094347.22071-11-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

This commit splits the functionality of fscrypt_encrypt_block(). The
allocation of fscrypt context and cipher text page is moved to a new
function fscrypt_prep_ciphertext_page().

ext4_bio_write_page() is modified to appropriately make use of the above
two functions.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 fs/crypto/crypto.c              | 71 +++++++++++++++++++++--------------------
 fs/ext4/page-io.c               | 34 +++++++++++++-------
 include/linux/fscrypt_notsupp.h | 16 +++++++---
 include/linux/fscrypt_supp.h    |  9 ++++--
 4 files changed, 75 insertions(+), 55 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 24e3796..8fb27ee 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -195,6 +195,35 @@ struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 	return ctx->w.bounce_page;
 }
 
+struct page *fscrypt_prep_ciphertext_page(struct inode *inode,
+					struct page *page,
+					gfp_t gfp_flags)
+{
+	struct page *ciphertext_page;
+	struct fscrypt_ctx *ctx;
+
+	BUG_ON(!PageLocked(page));
+
+	ctx = fscrypt_get_ctx(inode, gfp_flags);
+	if (IS_ERR(ctx))
+		return ERR_CAST(ctx);
+
+	ctx->w.control_page = page;
+
+	ciphertext_page = fscrypt_alloc_bounce_page(ctx, gfp_flags);
+	if (IS_ERR(ciphertext_page)) {
+		fscrypt_release_ctx(ctx);
+		return ERR_CAST(ciphertext_page);
+	}
+
+	SetPagePrivate(ciphertext_page);
+	set_page_private(ciphertext_page, (unsigned long)ctx);
+	lock_page(ciphertext_page);
+
+	return ciphertext_page;
+}
+EXPORT_SYMBOL(fscrypt_prep_ciphertext_page);
+
 /**
  * fscypt_encrypt_page() - Encrypts a page
  * @inode:     The inode for which the encryption should take place
@@ -226,15 +255,11 @@ struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
  * Return: A page with the encrypted content on success. Else, an
  * error value or NULL.
  */
-struct page *fscrypt_encrypt_block(const struct inode *inode,
-				struct page *page,
-				unsigned int len,
-				unsigned int offs,
-				u64 lblk_num, gfp_t gfp_flags)
-
+int fscrypt_encrypt_block(const struct inode *inode,
+			struct page *page, struct page *ciphertext_page,
+			unsigned int len, unsigned int offs,
+			u64 lblk_num, gfp_t gfp_flags)
 {
-	struct fscrypt_ctx *ctx;
-	struct page *ciphertext_page = page;
 	int err;
 
 	BUG_ON(len % FS_CRYPTO_BLOCK_SIZE != 0);
@@ -242,41 +267,17 @@ struct page *fscrypt_encrypt_block(const struct inode *inode,
 	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
 		/* with inplace-encryption we just encrypt the page */
 		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num, page,
-					     ciphertext_page, len, offs,
-					     gfp_flags);
-		if (err)
-			return ERR_PTR(err);
-
-		return ciphertext_page;
+					page, len, offs, gfp_flags);
+		return err;
 	}
 
 	BUG_ON(!PageLocked(page));
 
-	ctx = fscrypt_get_ctx(inode, gfp_flags);
-	if (IS_ERR(ctx))
-		return (struct page *)ctx;
-
-	/* The encryption operation will require a bounce page. */
-	ciphertext_page = fscrypt_alloc_bounce_page(ctx, gfp_flags);
-	if (IS_ERR(ciphertext_page))
-		goto errout;
-
-	ctx->w.control_page = page;
 	err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk_num,
 				     page, ciphertext_page, len, offs,
 				     gfp_flags);
-	if (err) {
-		ciphertext_page = ERR_PTR(err);
-		goto errout;
-	}
-	SetPagePrivate(ciphertext_page);
-	set_page_private(ciphertext_page, (unsigned long)ctx);
-	lock_page(ciphertext_page);
-	return ciphertext_page;
+	return err;
 
-errout:
-	fscrypt_release_ctx(ctx);
-	return ciphertext_page;
 }
 EXPORT_SYMBOL(fscrypt_encrypt_block);
 
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 0a4a1e7..1e869d5 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -419,9 +419,12 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 	struct inode *inode = page->mapping->host;
 	unsigned block_start;
 	struct buffer_head *bh, *head;
+	u64 blk_nr;
+	gfp_t gfp_flags = GFP_NOFS;
 	int ret = 0;
 	int nr_submitted = 0;
 	int nr_to_submit = 0;
+	int blocksize = (1 << inode->i_blkbits);
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageWriteback(page));
@@ -475,15 +478,11 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 		nr_to_submit++;
 	} while ((bh = bh->b_this_page) != head);
 
-	bh = head = page_buffers(page);
-
-	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
-	    nr_to_submit) {
-		gfp_t gfp_flags = GFP_NOFS;
-
-	retry_encrypt:
-		data_page = fscrypt_encrypt_block(inode, page, PAGE_SIZE, 0,
-						page->index, gfp_flags);
+	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode)
+		&& nr_to_submit) {
+	retry_prep_ciphertext_page:
+		data_page = fscrypt_prep_ciphertext_page(inode, page,
+							gfp_flags);
 		if (IS_ERR(data_page)) {
 			ret = PTR_ERR(data_page);
 			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
@@ -492,17 +491,28 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 					congestion_wait(BLK_RW_ASYNC, HZ/50);
 				}
 				gfp_flags |= __GFP_NOFAIL;
-				goto retry_encrypt;
+				goto retry_prep_ciphertext_page;
 			}
 			data_page = NULL;
 			goto out;
 		}
 	}
 
+	blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
+
 	/* Now submit buffers to write */
+	bh = head = page_buffers(page);
 	do {
 		if (!buffer_async_write(bh))
 			continue;
+
+		if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode)) {
+			ret = fscrypt_encrypt_block(inode, page, data_page, blocksize,
+						bh_offset(bh), blk_nr, gfp_flags);
+			if (ret)
+				break;
+		}
+
 		ret = io_submit_add_bh(io, inode,
 				       data_page ? data_page : page, bh);
 		if (ret) {
@@ -515,12 +525,12 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
 		}
 		nr_submitted++;
 		clear_buffer_dirty(bh);
-	} while ((bh = bh->b_this_page) != head);
+	} while (++blk_nr, (bh = bh->b_this_page) != head);
 
 	/* Error stopped previous loop? Clean up buffers... */
 	if (ret) {
 	out:
-		if (data_page)
+		if (data_page && bh == head)
 			fscrypt_restore_control_page(data_page);
 		printk_ratelimited(KERN_ERR "%s: ret = %d\n", __func__, ret);
 		redirty_page_for_writepage(wbc, page);
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index aeb6b6d..3b0a53b 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -26,15 +26,21 @@ static inline void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
 	return;
 }
 
-static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
-						struct page *page,
-						unsigned int len,
-						unsigned int offs,
-						u64 lblk_num, gfp_t gfp_flags)
+static inline struct page *fscrypt_prep_ciphertext_page(struct inode *inode,
+					struct page *page,
+					gfp_t gfp_flags)
 {
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline int fscrypt_encrypt_block(const struct inode *inode,
+			struct page *page, struct page *ciphertext_page,
+			unsigned int len, unsigned int offs,
+			u64 lblk_num, gfp_t gfp_flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static inline int fscrypt_decrypt_block(const struct inode *inode,
 				       struct page *page,
 				       unsigned int len, unsigned int offs,
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index b4c5231..68a5e91 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -15,9 +15,12 @@
 extern struct kmem_cache *fscrypt_info_cachep;
 extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
 extern void fscrypt_release_ctx(struct fscrypt_ctx *);
-extern struct page *fscrypt_encrypt_block(const struct inode *, struct page *,
-						unsigned int, unsigned int,
-						u64, gfp_t);
+extern struct page *fscrypt_prep_ciphertext_page(struct inode *, struct page *,
+						gfp_t);
+extern int fscrypt_encrypt_block(const struct inode *inode,
+				struct page *page, struct page *ciphertext_page,
+				unsigned int len, unsigned int offs,
+				u64 lblk_num, gfp_t gfp_flags);
 extern int fscrypt_decrypt_block(const struct inode *, struct page *, unsigned int,
 				unsigned int, u64);
 extern void fscrypt_restore_control_page(struct page *);
-- 
2.9.5
