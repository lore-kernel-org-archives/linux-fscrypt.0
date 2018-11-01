Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Thu,  1 Nov 2018 15:52:22 -0700
Message-Id: <20181101225230.88058-5-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 04/12] fs-verity: add data verification hooks
 for ->readpages()
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add functions that verify data pages that have been read from a
fs-verity file, against that file's Merkle tree.  These will be called
from filesystems' ->readpage() and ->readpages() methods.

Since data verification can block, a workqueue is provided for these
methods to enqueue verification work from their bio completion callback.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/Makefile           |   2 +-
 fs/verity/fsverity_private.h |   3 +
 fs/verity/setup.c            |  26 ++-
 fs/verity/verify.c           | 298 +++++++++++++++++++++++++++++++++++
 include/linux/fsverity.h     |  33 ++++
 5 files changed, 360 insertions(+), 2 deletions(-)
 create mode 100644 fs/verity/verify.c

diff --git a/fs/verity/Makefile b/fs/verity/Makefile
index 39e123805c827..a6c7cefb61ab7 100644
--- a/fs/verity/Makefile
+++ b/fs/verity/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_FS_VERITY)	+= fsverity.o
 
-fsverity-y := hash_algs.o setup.o
+fsverity-y := hash_algs.o setup.o verify.o
diff --git a/fs/verity/fsverity_private.h b/fs/verity/fsverity_private.h
index acc29825a0ed7..dfdbac3874d74 100644
--- a/fs/verity/fsverity_private.h
+++ b/fs/verity/fsverity_private.h
@@ -95,4 +95,7 @@ static inline bool set_fsverity_info(struct inode *inode,
 	return cmpxchg_release(&inode->i_verity_info, NULL, vi) == NULL;
 }
 
+/* verify.c */
+extern struct workqueue_struct *fsverity_read_workqueue;
+
 #endif /* _FSVERITY_PRIVATE_H */
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
index 925970fbe084d..184bdc96abe51 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -801,18 +801,42 @@ EXPORT_SYMBOL_GPL(fsverity_full_i_size);
 
 static int __init fsverity_module_init(void)
 {
+	int err;
+
+	/*
+	 * Use an unbound workqueue to allow bios to be verified in parallel
+	 * even when they happen to complete on the same CPU.  This sacrifices
+	 * locality, but it's worthwhile since hashing is CPU-intensive.
+	 *
+	 * Also use a high-priority workqueue to prioritize verification work,
+	 * which blocks reads from completing, over regular application tasks.
+	 */
+	err = -ENOMEM;
+	fsverity_read_workqueue = alloc_workqueue("fsverity_read_queue",
+						  WQ_UNBOUND | WQ_HIGHPRI,
+						  num_online_cpus());
+	if (!fsverity_read_workqueue)
+		goto error;
+
+	err = -ENOMEM;
 	fsverity_info_cachep = KMEM_CACHE(fsverity_info, SLAB_RECLAIM_ACCOUNT);
 	if (!fsverity_info_cachep)
-		return -ENOMEM;
+		goto error_free_workqueue;
 
 	fsverity_check_hash_algs();
 
 	pr_debug("Initialized fs-verity\n");
 	return 0;
+
+error_free_workqueue:
+	destroy_workqueue(fsverity_read_workqueue);
+error:
+	return err;
 }
 
 static void __exit fsverity_module_exit(void)
 {
+	destroy_workqueue(fsverity_read_workqueue);
 	kmem_cache_destroy(fsverity_info_cachep);
 	fsverity_exit_hash_algs();
 }
diff --git a/fs/verity/verify.c b/fs/verity/verify.c
new file mode 100644
index 0000000000000..e308f22475e8d
--- /dev/null
+++ b/fs/verity/verify.c
@@ -0,0 +1,298 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * fs/verity/verify.c: fs-verity data verification functions,
+ *		       i.e. hooks for ->readpages()
+ *
+ * Copyright 2018 Google LLC
+ *
+ * Originally written by Jaegeuk Kim and Michael Halcrow;
+ * heavily rewritten by Eric Biggers.
+ */
+
+#include "fsverity_private.h"
+
+#include <crypto/hash.h>
+#include <linux/bio.h>
+#include <linux/pagemap.h>
+#include <linux/ratelimit.h>
+#include <linux/scatterlist.h>
+
+struct workqueue_struct *fsverity_read_workqueue;
+
+/**
+ * hash_at_level() - compute the location of the block's hash at the given level
+ *
+ * @vi:		(in) the file's verity info
+ * @dindex:	(in) the index of the data block being verified
+ * @level:	(in) the level of hash we want (0 is leaf level)
+ * @hindex:	(out) the index of the hash block containing the wanted hash
+ * @hoffset:	(out) the byte offset to the wanted hash within the hash block
+ */
+static void hash_at_level(const struct fsverity_info *vi, pgoff_t dindex,
+			  unsigned int level, pgoff_t *hindex,
+			  unsigned int *hoffset)
+{
+	pgoff_t position;
+
+	/* Offset of the hash within the level's region, in hashes */
+	position = dindex >> (level * vi->log_arity);
+
+	/* Index of the hash block in the tree overall */
+	*hindex = vi->hash_lvl_region_idx[level] + (position >> vi->log_arity);
+
+	/* Offset of the wanted hash (in bytes) within the hash block */
+	*hoffset = (position & ((1 << vi->log_arity) - 1)) <<
+		   (vi->block_bits - vi->log_arity);
+}
+
+/* Extract a hash from a hash page */
+static void extract_hash(struct page *hpage, unsigned int hoffset,
+			 unsigned int hsize, u8 *out)
+{
+	void *virt = kmap_atomic(hpage);
+
+	memcpy(out, virt + hoffset, hsize);
+	kunmap_atomic(virt);
+}
+
+static int fsverity_hash_page(const struct fsverity_info *vi,
+			      struct ahash_request *req,
+			      struct page *page, u8 *out)
+{
+	struct scatterlist sg;
+	DECLARE_CRYPTO_WAIT(wait);
+	int err;
+
+	sg_init_table(&sg, 1);
+	sg_set_page(&sg, page, PAGE_SIZE, 0);
+
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP |
+				   CRYPTO_TFM_REQ_MAY_BACKLOG,
+				   crypto_req_done, &wait);
+	ahash_request_set_crypt(req, &sg, out, PAGE_SIZE);
+
+	err = crypto_ahash_import(req, vi->hashstate);
+	if (err)
+		return err;
+
+	return crypto_wait_req(crypto_ahash_finup(req), &wait);
+}
+
+static inline int compare_hashes(const u8 *want_hash, const u8 *real_hash,
+				 int digest_size, struct inode *inode,
+				 pgoff_t index, int level, const char *algname)
+{
+	if (memcmp(want_hash, real_hash, digest_size) == 0)
+		return 0;
+
+	pr_warn_ratelimited("VERIFICATION FAILURE!  ino=%lu, index=%lu, level=%d, want_hash=%s:%*phN, real_hash=%s:%*phN\n",
+			    inode->i_ino, index, level,
+			    algname, digest_size, want_hash,
+			    algname, digest_size, real_hash);
+	return -EBADMSG;
+}
+
+/*
+ * Verify a single data page against the file's Merkle tree.
+ *
+ * In principle, we need to verify the entire path to the root node.  But as an
+ * optimization, we cache the hash pages in the file's page cache, similar to
+ * data pages.  Therefore, we can stop verifying as soon as a verified hash page
+ * is seen while ascending the tree.
+ *
+ * Note that unlike data pages, hash pages are marked Uptodate *before* they are
+ * verified; instead, the Checked bit is set on hash pages that have been
+ * verified.  Multiple tasks may race to verify a hash page and mark it Checked,
+ * but it doesn't matter.  The use of the Checked bit also implies that the hash
+ * block size must equal PAGE_SIZE (for now).
+ */
+static bool verify_page(struct inode *inode, const struct fsverity_info *vi,
+			struct ahash_request *req, struct page *data_page)
+{
+	pgoff_t index = data_page->index;
+	int level = 0;
+	u8 _want_hash[FS_VERITY_MAX_DIGEST_SIZE];
+	const u8 *want_hash = NULL;
+	u8 real_hash[FS_VERITY_MAX_DIGEST_SIZE];
+	struct page *hpages[FS_VERITY_MAX_LEVELS];
+	unsigned int hoffsets[FS_VERITY_MAX_LEVELS];
+	int err;
+
+	/* The page must not be unlocked until verification has completed. */
+	if (WARN_ON_ONCE(!PageLocked(data_page)))
+		return false;
+
+	/*
+	 * Filesystems shouldn't ask to verify pages beyond the end of the
+	 * original data (e.g. pages of the Merkle tree itself, if it's stored
+	 * beyond EOF), but to be safe check for it here too.
+	 */
+	if (index >= (vi->data_i_size + PAGE_SIZE - 1) >> PAGE_SHIFT) {
+		pr_debug("Page %lu is beyond data region\n", index);
+		return true;
+	}
+
+	pr_debug_ratelimited("Verifying data page %lu...\n", index);
+
+	/*
+	 * Starting at the leaves, ascend the tree saving hash pages along the
+	 * way until we find a verified hash page, indicated by PageChecked; or
+	 * until we reach the root.
+	 */
+	for (level = 0; level < vi->depth; level++) {
+		pgoff_t hindex;
+		unsigned int hoffset;
+		struct page *hpage;
+
+		hash_at_level(vi, index, level, &hindex, &hoffset);
+
+		pr_debug_ratelimited("Level %d: hindex=%lu, hoffset=%u\n",
+				     level, hindex, hoffset);
+
+		hpage = fsverity_read_metadata_page(inode, hindex);
+		if (IS_ERR(hpage)) {
+			err = PTR_ERR(hpage);
+			goto out;
+		}
+
+		if (PageChecked(hpage)) {
+			extract_hash(hpage, hoffset, vi->hash_alg->digest_size,
+				     _want_hash);
+			want_hash = _want_hash;
+			put_page(hpage);
+			pr_debug_ratelimited("Hash page already checked, want %s:%*phN\n",
+					     vi->hash_alg->name,
+					     vi->hash_alg->digest_size,
+					     want_hash);
+			break;
+		}
+		pr_debug_ratelimited("Hash page not yet checked\n");
+		hpages[level] = hpage;
+		hoffsets[level] = hoffset;
+	}
+
+	if (!want_hash) {
+		want_hash = vi->root_hash;
+		pr_debug("Want root hash: %s:%*phN\n", vi->hash_alg->name,
+			 vi->hash_alg->digest_size, want_hash);
+	}
+
+	/* Descend the tree verifying hash pages */
+	for (; level > 0; level--) {
+		struct page *hpage = hpages[level - 1];
+		unsigned int hoffset = hoffsets[level - 1];
+
+		err = fsverity_hash_page(vi, req, hpage, real_hash);
+		if (err)
+			goto out;
+		err = compare_hashes(want_hash, real_hash,
+				     vi->hash_alg->digest_size,
+				     inode, index, level - 1,
+				     vi->hash_alg->name);
+		if (err)
+			goto out;
+		SetPageChecked(hpage);
+		extract_hash(hpage, hoffset, vi->hash_alg->digest_size,
+			     _want_hash);
+		want_hash = _want_hash;
+		put_page(hpage);
+		pr_debug("Verified hash page at level %d, now want %s:%*phN\n",
+			 level - 1, vi->hash_alg->name,
+			 vi->hash_alg->digest_size, want_hash);
+	}
+
+	/* Finally, verify the data page */
+	err = fsverity_hash_page(vi, req, data_page, real_hash);
+	if (err)
+		goto out;
+	err = compare_hashes(want_hash, real_hash, vi->hash_alg->digest_size,
+			     inode, index, -1, vi->hash_alg->name);
+out:
+	for (; level > 0; level--)
+		put_page(hpages[level - 1]);
+	if (err) {
+		pr_warn_ratelimited("Error verifying page; ino=%lu, index=%lu (err=%d)\n",
+				    inode->i_ino, data_page->index, err);
+		return false;
+	}
+	return true;
+}
+
+/**
+ * fsverity_verify_page - verify a data page
+ *
+ * Verify a page that has just been read from a file against that file's Merkle
+ * tree.  The page is assumed to be a pagecache page.
+ *
+ * Return: true if the page is valid, else false.
+ */
+bool fsverity_verify_page(struct page *data_page)
+{
+	struct inode *inode = data_page->mapping->host;
+	const struct fsverity_info *vi = get_fsverity_info(inode);
+	struct ahash_request *req;
+	bool valid;
+
+	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
+	if (unlikely(!req))
+		return false;
+
+	valid = verify_page(inode, vi, req, data_page);
+
+	ahash_request_free(req);
+
+	return valid;
+}
+EXPORT_SYMBOL_GPL(fsverity_verify_page);
+
+#ifdef CONFIG_BLOCK
+/**
+ * fsverity_verify_bio - verify a 'read' bio that has just completed
+ *
+ * Verify a set of pages that have just been read from a file against that
+ * file's Merkle tree.  The pages are assumed to be pagecache pages.  Pages that
+ * fail verification are set to the Error state.  Verification is skipped for
+ * pages already in the Error state, e.g. due to fscrypt decryption failure.
+ *
+ * This is a helper function for filesystems that issue bios to read data
+ * directly into the page cache.  Filesystems that work differently should call
+ * fsverity_verify_page() on each page instead.  fsverity_verify_page() is also
+ * needed on holes!
+ */
+void fsverity_verify_bio(struct bio *bio)
+{
+	struct inode *inode = bio_first_page_all(bio)->mapping->host;
+	const struct fsverity_info *vi = get_fsverity_info(inode);
+	struct ahash_request *req;
+	struct bio_vec *bv;
+	int i;
+
+	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
+	if (unlikely(!req)) {
+		bio_for_each_segment_all(bv, bio, i)
+			SetPageError(bv->bv_page);
+		return;
+	}
+
+	bio_for_each_segment_all(bv, bio, i) {
+		struct page *page = bv->bv_page;
+
+		if (!PageError(page) && !verify_page(inode, vi, req, page))
+			SetPageError(page);
+	}
+
+	ahash_request_free(req);
+}
+EXPORT_SYMBOL_GPL(fsverity_verify_bio);
+#endif /* CONFIG_BLOCK */
+
+/**
+ * fsverity_enqueue_verify_work - enqueue work on the fs-verity workqueue
+ *
+ * Enqueue verification work for asynchronous processing.
+ */
+void fsverity_enqueue_verify_work(struct work_struct *work)
+{
+	queue_work(fsverity_read_workqueue, work);
+}
+EXPORT_SYMBOL_GPL(fsverity_enqueue_verify_work);
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index c9422a579c160..15478fe7d55aa 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -28,6 +28,16 @@ extern int fsverity_prepare_getattr(struct inode *inode);
 extern void fsverity_cleanup_inode(struct inode *inode);
 extern loff_t fsverity_full_i_size(const struct inode *inode);
 
+/* verify.c */
+extern bool fsverity_verify_page(struct page *page);
+extern void fsverity_verify_bio(struct bio *bio);
+extern void fsverity_enqueue_verify_work(struct work_struct *work);
+
+static inline bool fsverity_check_hole(struct inode *inode, struct page *page)
+{
+	return inode->i_verity_info == NULL || fsverity_verify_page(page);
+}
+
 #else /* !__FS_HAS_VERITY */
 
 /* setup.c */
@@ -57,6 +67,29 @@ static inline loff_t fsverity_full_i_size(const struct inode *inode)
 	return i_size_read(inode);
 }
 
+/* verify.c */
+
+static inline bool fsverity_verify_page(struct page *page)
+{
+	WARN_ON(1);
+	return false;
+}
+
+static inline void fsverity_verify_bio(struct bio *bio)
+{
+	WARN_ON(1);
+}
+
+static inline void fsverity_enqueue_verify_work(struct work_struct *work)
+{
+	WARN_ON(1);
+}
+
+static inline bool fsverity_check_hole(struct inode *inode, struct page *page)
+{
+	return true;
+}
+
 #endif	/* !__FS_HAS_VERITY */
 
 #endif	/* _LINUX_FSVERITY_H */
-- 
2.19.1.568.g152ad8e336-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
