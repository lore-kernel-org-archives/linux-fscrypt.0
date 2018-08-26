Return-Path: <SRS0=3FIm=LJ=gmail.com=chucklever@kernel.org>
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC PATCH 02/10] fs-verity: add data verification hooks for
 ->readpages()
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20180824161642.1144-3-ebiggers@kernel.org>
Date: Sun, 26 Aug 2018 11:55:57 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <C86750D6-CA95-4A7F-9204-51345C497EC2@gmail.com>
References: <20180824161642.1144-1-ebiggers@kernel.org>
 <20180824161642.1144-3-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>



> On Aug 24, 2018, at 12:16 PM, Eric Biggers <ebiggers@kernel.org> =
wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> Add functions that verify data pages that have been read from a
> fs-verity file, against that file's Merkle tree.  These will be called
> from filesystems' ->readpage() and ->readpages() methods.
>=20
> Since data verification can block, a workqueue is provided for these
> methods to enqueue verification work from their bio completion =
callback.
>=20
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
> fs/verity/Makefile           |   2 +-
> fs/verity/fsverity_private.h |   3 +
> fs/verity/setup.c            |  26 ++-
> fs/verity/verify.c           | 310 +++++++++++++++++++++++++++++++++++
> include/linux/fsverity.h     |  23 +++
> 5 files changed, 362 insertions(+), 2 deletions(-)
> create mode 100644 fs/verity/verify.c
>=20
> diff --git a/fs/verity/Makefile b/fs/verity/Makefile
> index 39e123805c827..a6c7cefb61ab7 100644
> --- a/fs/verity/Makefile
> +++ b/fs/verity/Makefile
> @@ -1,3 +1,3 @@
> obj-$(CONFIG_FS_VERITY)	+=3D fsverity.o
>=20
> -fsverity-y :=3D hash_algs.o setup.o
> +fsverity-y :=3D hash_algs.o setup.o verify.o
> diff --git a/fs/verity/fsverity_private.h =
b/fs/verity/fsverity_private.h
> index a18ff645695f4..c553f99dc4973 100644
> --- a/fs/verity/fsverity_private.h
> +++ b/fs/verity/fsverity_private.h
> @@ -96,4 +96,7 @@ static inline bool set_fsverity_info(struct inode =
*inode,
> 	return true;
> }
>=20
> +/* verify.c */
> +extern struct workqueue_struct *fsverity_read_workqueue;
> +
> #endif /* _FSVERITY_PRIVATE_H */
> diff --git a/fs/verity/setup.c b/fs/verity/setup.c
> index e675c52898d5b..84cc2edeca25b 100644
> --- a/fs/verity/setup.c
> +++ b/fs/verity/setup.c
> @@ -824,18 +824,42 @@ EXPORT_SYMBOL_GPL(fsverity_full_i_size);
>=20
> static int __init fsverity_module_init(void)
> {
> +	int err;
> +
> +	/*
> +	 * Use an unbound workqueue to allow bios to be verified in =
parallel
> +	 * even when they happen to complete on the same CPU.  This =
sacrifices
> +	 * locality, but it's worthwhile since hashing is CPU-intensive.
> +	 *
> +	 * Also use a high-priority workqueue to prioritize verification =
work,
> +	 * which blocks reads from completing, over regular application =
tasks.
> +	 */
> +	err =3D -ENOMEM;
> +	fsverity_read_workqueue =3D =
alloc_workqueue("fsverity_read_queue",
> +						  WQ_UNBOUND | =
WQ_HIGHPRI,
> +						  num_online_cpus());
> +	if (!fsverity_read_workqueue)
> +		goto error;
> +
> +	err =3D -ENOMEM;
> 	fsverity_info_cachep =3D KMEM_CACHE(fsverity_info, =
SLAB_RECLAIM_ACCOUNT);
> 	if (!fsverity_info_cachep)
> -		return -ENOMEM;
> +		goto error_free_workqueue;
>=20
> 	fsverity_check_hash_algs();
>=20
> 	pr_debug("Initialized fs-verity\n");
> 	return 0;
> +
> +error_free_workqueue:
> +	destroy_workqueue(fsverity_read_workqueue);
> +error:
> +	return err;
> }
>=20
> static void __exit fsverity_module_exit(void)
> {
> +	destroy_workqueue(fsverity_read_workqueue);
> 	kmem_cache_destroy(fsverity_info_cachep);
> 	fsverity_exit_hash_algs();
> }
> diff --git a/fs/verity/verify.c b/fs/verity/verify.c
> new file mode 100644
> index 0000000000000..1452dd05f75d3
> --- /dev/null
> +++ b/fs/verity/verify.c
> @@ -0,0 +1,310 @@
> +// SPDX-License-Identifier: GPL-2.0
> +/*
> + * fs/verity/verify.c: fs-verity data verification functions,
> + *		       i.e. hooks for ->readpages()
> + *
> + * Copyright (C) 2018 Google LLC
> + *
> + * Originally written by Jaegeuk Kim and Michael Halcrow;
> + * heavily rewritten by Eric Biggers.
> + */
> +
> +#include "fsverity_private.h"
> +
> +#include <crypto/hash.h>
> +#include <linux/bio.h>
> +#include <linux/pagemap.h>
> +#include <linux/ratelimit.h>
> +#include <linux/scatterlist.h>
> +
> +struct workqueue_struct *fsverity_read_workqueue;
> +
> +/**
> + * hash_at_level() - compute the location of the block's hash at the =
given level
> + *
> + * @vi:		(in) the file's verity info
> + * @dindex:	(in) the index of the data block being verified
> + * @level:	(in) the level of hash we want
> + * @hindex:	(out) the index of the hash block containing the wanted =
hash
> + * @hoffset:	(out) the byte offset to the wanted hash within the hash =
block
> + */
> +static void hash_at_level(const struct fsverity_info *vi, pgoff_t =
dindex,
> +			  unsigned int level, pgoff_t *hindex,
> +			  unsigned int *hoffset)
> +{
> +	pgoff_t hoffset_in_lvl;
> +
> +	/*
> +	 * Compute the offset of the hash within the level's region, in =
hashes.
> +	 * For example, with 4096-byte blocks and 32-byte hashes, there =
are
> +	 * 4096/32 =3D 128 =3D 2^7 hashes per hash block, i.e. log_arity =
=3D 7.  Then,
> +	 * if the data block index is 65668 and we want the level 1 =
hash, it is
> +	 * located at 65668 >> 7 =3D 513 hashes into the level 1 region.
> +	 */
> +	hoffset_in_lvl =3D dindex >> (level * vi->log_arity);
> +
> +	/*
> +	 * Compute the index of the hash block containing the wanted =
hash.
> +	 * Continuing the above example, the block would be at index 513 =
>> 7 =3D
> +	 * 4 within the level 1 region.  To this we'd add the index at =
which the
> +	 * level 1 region starts.
> +	 */
> +	*hindex =3D vi->hash_lvl_region_idx[level] +
> +		  (hoffset_in_lvl >> vi->log_arity);
> +
> +	/*
> +	 * Finally, compute the index of the hash within the block =
rather than
> +	 * the region, and multiply by the hash size to turn it into a =
byte
> +	 * offset.  Continuing the above example, the hash would be at =
byte
> +	 * offset (513 & ((1 << 7) - 1)) * 32 =3D 32 within the block.
> +	 */
> +	*hoffset =3D (hoffset_in_lvl & ((1 << vi->log_arity) - 1)) *
> +		   vi->hash_alg->digest_size;
> +}
> +
> +/* Extract a hash from a hash page */
> +static void extract_hash(struct page *hpage, unsigned int hoffset,
> +			 unsigned int hsize, u8 *out)
> +{
> +	void *virt =3D kmap_atomic(hpage);
> +
> +	memcpy(out, virt + hoffset, hsize);
> +	kunmap_atomic(virt);
> +}
> +
> +static int hash_page(const struct fsverity_info *vi, struct =
ahash_request *req,
> +		     struct page *page, u8 *out)
> +{
> +	struct scatterlist sg[3];
> +	DECLARE_CRYPTO_WAIT(wait);
> +	int err;
> +
> +	sg_init_table(sg, 1);
> +	sg_set_page(&sg[0], page, PAGE_SIZE, 0);
> +
> +	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP |
> +				   CRYPTO_TFM_REQ_MAY_BACKLOG,
> +				   crypto_req_done, &wait);
> +	ahash_request_set_crypt(req, sg, out, PAGE_SIZE);
> +
> +	err =3D crypto_ahash_import(req, vi->hashstate);
> +	if (err)
> +		return err;
> +
> +	return crypto_wait_req(crypto_ahash_finup(req), &wait);
> +}
> +
> +static inline int compare_hashes(const u8 *want_hash, const u8 =
*real_hash,
> +				 int digest_size, struct inode *inode,
> +				 pgoff_t index, int level, const char =
*algname)
> +{
> +	if (memcmp(want_hash, real_hash, digest_size) =3D=3D 0)
> +		return 0;
> +
> +	pr_warn_ratelimited("VERIFICATION FAILURE!  ino=3D%lu, =
index=3D%lu, level=3D%d, want_hash=3D%s:%*phN, real_hash=3D%s:%*phN\n",
> +			    inode->i_ino, index, level,
> +			    algname, digest_size, want_hash,
> +			    algname, digest_size, real_hash);
> +	return -EBADMSG;
> +}
> +
> +/*
> + * Verify a single data page against the file's Merkle tree.
> + *
> + * In principle, we need to verify the entire path to the root node.  =
But as an
> + * optimization, we cache the hash pages in the file's page cache, =
similar to
> + * data pages.  Therefore, we can stop verifying as soon as a =
verified hash page
> + * is seen while ascending the tree.
> + *
> + * Note that unlike data pages, hash pages are marked Uptodate =
*before* they are
> + * verified; instead, the Checked bit is set on hash pages that have =
been
> + * verified.  Multiple tasks may race to verify a hash page and mark =
it Checked,
> + * but it doesn't matter.  The use of the Checked bit also implies =
that the hash
> + * block size must equal PAGE_SIZE (for now).
> + */
> +static bool verify_page(struct inode *inode, const struct =
fsverity_info *vi,
> +			struct ahash_request *req, struct page =
*data_page)
> +{
> +	pgoff_t index =3D data_page->index;
> +	int level =3D 0;
> +	u8 _want_hash[FS_VERITY_MAX_DIGEST_SIZE];
> +	const u8 *want_hash =3D NULL;
> +	u8 real_hash[FS_VERITY_MAX_DIGEST_SIZE];
> +	struct page *hpages[FS_VERITY_MAX_LEVELS];
> +	unsigned int hoffsets[FS_VERITY_MAX_LEVELS];
> +	int err;
> +
> +	/* The page must not be unlocked until verification has =
completed. */
> +	if (WARN_ON_ONCE(!PageLocked(data_page)))
> +		return false;
> +
> +	/*
> +	 * Since ->i_size is overridden with ->data_i_size, and =
fs-verity avoids
> +	 * recursing into itself when reading hash pages, we shouldn't =
normally
> +	 * get here with a page beyond ->data_i_size.  But, it can =
happen if a
> +	 * read is issued at or beyond EOF since the VFS doesn't check =
i_size
> +	 * before calling ->readpage().  Thus, just skip verification if =
the
> +	 * page is beyond ->data_i_size.
> +	 */
> +	if (index >=3D (vi->data_i_size + PAGE_SIZE - 1) >> PAGE_SHIFT) =
{
> +		pr_debug("Page %lu is in metadata region\n", index);
> +		return true;
> +	}
> +
> +	pr_debug_ratelimited("Verifying data page %lu...\n", index);
> +
> +	/*
> +	 * Starting at the leaves, ascend the tree saving hash pages =
along the
> +	 * way until we find a verified hash page, indicated by =
PageChecked; or
> +	 * until we reach the root.
> +	 */
> +	for (level =3D 0; level < vi->depth; level++) {
> +		pgoff_t hindex;
> +		unsigned int hoffset;
> +		struct page *hpage;
> +
> +		hash_at_level(vi, index, level, &hindex, &hoffset);
> +
> +		pr_debug_ratelimited("Level %d: hindex=3D%lu, =
hoffset=3D%u\n",
> +				     level, hindex, hoffset);
> +
> +		hpage =3D read_mapping_page(inode->i_mapping, hindex, =
NULL);
> +		if (IS_ERR(hpage)) {
> +			err =3D PTR_ERR(hpage);
> +			goto out;
> +		}
> +
> +		if (PageChecked(hpage)) {
> +			extract_hash(hpage, hoffset, =
vi->hash_alg->digest_size,
> +				     _want_hash);
> +			want_hash =3D _want_hash;
> +			put_page(hpage);
> +			pr_debug_ratelimited("Hash page already checked, =
want %s:%*phN\n",
> +					     vi->hash_alg->name,
> +					     vi->hash_alg->digest_size,
> +					     want_hash);
> +			break;
> +		}
> +		pr_debug_ratelimited("Hash page not yet checked\n");
> +		hpages[level] =3D hpage;
> +		hoffsets[level] =3D hoffset;
> +	}
> +
> +	if (!want_hash) {
> +		want_hash =3D vi->root_hash;
> +		pr_debug("Want root hash: %s:%*phN\n", =
vi->hash_alg->name,
> +			 vi->hash_alg->digest_size, want_hash);
> +	}
> +
> +	/* Descend the tree verifying hash pages */
> +	for (; level > 0; level--) {
> +		struct page *hpage =3D hpages[level - 1];
> +		unsigned int hoffset =3D hoffsets[level - 1];
> +
> +		err =3D hash_page(vi, req, hpage, real_hash);
> +		if (err)
> +			goto out;
> +		err =3D compare_hashes(want_hash, real_hash,
> +				     vi->hash_alg->digest_size,
> +				     inode, index, level - 1,
> +				     vi->hash_alg->name);
> +		if (err)
> +			goto out;
> +		SetPageChecked(hpage);
> +		extract_hash(hpage, hoffset, vi->hash_alg->digest_size,
> +			     _want_hash);
> +		want_hash =3D _want_hash;
> +		put_page(hpage);
> +		pr_debug("Verified hash page at level %d, now want =
%s:%*phN\n",
> +			 level - 1, vi->hash_alg->name,
> +			 vi->hash_alg->digest_size, want_hash);
> +	}
> +
> +	/* Finally, verify the data page */
> +	err =3D hash_page(vi, req, data_page, real_hash);
> +	if (err)
> +		goto out;
> +	err =3D compare_hashes(want_hash, real_hash, =
vi->hash_alg->digest_size,
> +			     inode, index, -1, vi->hash_alg->name);
> +out:
> +	for (; level > 0; level--)
> +		put_page(hpages[level - 1]);
> +	if (err) {
> +		pr_warn_ratelimited("Error verifying page; ino=3D%lu, =
index=3D%lu (err=3D%d)\n",
> +				    inode->i_ino, data_page->index, =
err);
> +		return false;
> +	}
> +	return true;
> +}
> +
> +/**
> + * fsverity_verify_page - verify a data page
> + *
> + * Verify a page that has just been read from a file against that =
file's Merkle
> + * tree.  The page is assumed to be a pagecache page.
> + *
> + * Return: true if the page is valid, else false.
> + */
> +bool fsverity_verify_page(struct page *data_page)
> +{
> +	struct inode *inode =3D data_page->mapping->host;
> +	const struct fsverity_info *vi =3D get_fsverity_info(inode);
> +	struct ahash_request *req;
> +	bool valid;
> +
> +	req =3D ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> +	if (unlikely(!req))
> +		return false;
> +
> +	valid =3D verify_page(inode, vi, req, data_page);
> +
> +	ahash_request_free(req);
> +
> +	return valid;
> +}
> +EXPORT_SYMBOL_GPL(fsverity_verify_page);
> +
> +/**
> + * fsverity_verify_bio - verify a 'read' bio that has just completed
> + *
> + * Verify a set of pages that have just been read from a file against =
that
> + * file's Merkle tree.  The pages are assumed to be pagecache pages.  =
Pages that
> + * fail verification are set to the Error state.  Verification is =
skipped for
> + * pages already in the Error state, e.g. due to fscrypt decryption =
failure.
> + */
> +void fsverity_verify_bio(struct bio *bio)

Hi Eric-

This kind of API won't work for remote filesystems, which do not use
"struct bio" to do their I/O. Could a remote filesystem solely use
fsverity_verify_page instead?


> +{
> +	struct inode *inode =3D bio_first_page_all(bio)->mapping->host;
> +	const struct fsverity_info *vi =3D get_fsverity_info(inode);
> +	struct ahash_request *req;
> +	struct bio_vec *bv;
> +	int i;
> +
> +	req =3D ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
> +	if (unlikely(!req)) {
> +		bio_for_each_segment_all(bv, bio, i)
> +			SetPageError(bv->bv_page);
> +		return;
> +	}
> +
> +	bio_for_each_segment_all(bv, bio, i) {
> +		struct page *page =3D bv->bv_page;
> +
> +		if (!PageError(page) && !verify_page(inode, vi, req, =
page))
> +			SetPageError(page);
> +	}
> +
> +	ahash_request_free(req);
> +}
> +EXPORT_SYMBOL_GPL(fsverity_verify_bio);
> +
> +/**
> + * fsverity_enqueue_verify_work - enqueue work on the fs-verity =
workqueue
> + *
> + * Enqueue verification work for asynchronous processing.
> + */
> +void fsverity_enqueue_verify_work(struct work_struct *work)
> +{
> +	queue_work(fsverity_read_workqueue, work);
> +}
> +EXPORT_SYMBOL_GPL(fsverity_enqueue_verify_work);
> diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
> index 3af55241046aa..56341f10aa965 100644
> --- a/include/linux/fsverity.h
> +++ b/include/linux/fsverity.h
> @@ -28,6 +28,11 @@ extern int fsverity_prepare_getattr(struct inode =
*inode);
> extern void fsverity_cleanup_inode(struct inode *inode);
> extern loff_t fsverity_full_i_size(const struct inode *inode);
>=20
> +/* verify.c */
> +extern bool fsverity_verify_page(struct page *page);
> +extern void fsverity_verify_bio(struct bio *bio);
> +extern void fsverity_enqueue_verify_work(struct work_struct *work);
> +
> #else /* !__FS_HAS_VERITY */
>=20
> /* setup.c */
> @@ -57,6 +62,24 @@ static inline loff_t fsverity_full_i_size(const =
struct inode *inode)
> 	return i_size_read(inode);
> }
>=20
> +/* verify.c */
> +
> +static inline bool fsverity_verify_page(struct page *page)
> +{
> +	WARN_ON(1);
> +	return false;
> +}
> +
> +static inline void fsverity_verify_bio(struct bio *bio)
> +{
> +	WARN_ON(1);
> +}
> +
> +static inline void fsverity_enqueue_verify_work(struct work_struct =
*work)
> +{
> +	WARN_ON(1);
> +}
> +
> #endif	/* !__FS_HAS_VERITY */
>=20
> #endif	/* _LINUX_FSVERITY_H */
> --=20
> 2.18.0
>=20

--
Chuck Lever
chucklever@gmail.com
