Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V3 07/12] mpage_readpage[s]: Introduce post process callback parameters
Date: Wed, 13 Jun 2018 18:46:25 +0530
In-Reply-To: <2529815.jLScNpfAQz@localhost.localdomain>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com> <2124971.L8asKzUlzJ@localhost.localdomain> <2529815.jLScNpfAQz@localhost.localdomain>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1910532.EO49V71jrB@localhost.localdomain>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Monday, June 11, 2018 7:12:24 PM IST Chandan Rajendra wrote:
> On Monday, June 4, 2018 6:54:36 PM IST Chandan Rajendra wrote:
> > On Monday, June 4, 2018 3:39:40 PM IST Chandan Rajendra wrote:
> > > On Wednesday, May 30, 2018 10:36:42 AM IST Theodore Y. Ts'o wrote:
> > > > Note: we may want to move this thread so that it's on linux-fscrypt
> > > > exclusively.  I'm thinking that we should consider using linux-fscrypt
> > > > for fscrypt and fsverity discussions.  That way we can avoid adding
> > > > extra noise to the linux-fsdevel and linux-ext4 lists.  Comments?
> > > > 
> > > > On Wed, May 30, 2018 at 08:39:11AM +0530, Chandan Rajendra wrote:
> > > > > 
> > > > > I had misunderstood the requirement. Sorry about that. I had written the
> > > > > patchset in its current form with the understanding that fs/buffer.c and
> > > > > fs/ext4/*.c would need to get compiled even when fscrypt code isn't compiled
> > > > > at all. When the fscrypt module isn't selected for build in the kernel config,
> > > > > calls to fscrypt_*() functions would end up calling the equivalent nop
> > > > > functions in fscrypt_notsupp.h file.
> > > > > 
> > > > > For the generic code to be completely unaware of several stages of "post
> > > > > processinhg" functionality, I would most likely have to add more callback
> > > > > pointers into the newly introduced "struct post_process_read" structure. 
> > > > 
> > > > It's still a work in progress, but I have an initial integration of
> > > > ext4 with fsverity.  See the fsverity branch on ext4.git, and in
> > > > particular, the changes made to fs/ext4/readpage.c.
> > > > 
> > > > Let's be clear that neither Eric and I are completely happy with how
> > > > the fsveirty post-read processing is being done.  What's there right
> > > > now is a place-holder so we can continue to development/debug the
> > > > other aspects of fsverity.  In particular, we're aware that there is
> > > > code duplication between code in fs/f2fs/data.c and fs/ext4/readpage.c
> > > > 
> > > > One of the things which is a bit tricky right now is that fscrypt and
> > > > fsverity can be enabled on a per-file system basis.  That is, there are
> > > > separate CONFIG options:
> > > > 
> > > >    * CONFIG_EXT4_FS_ENCRYPTION
> > > >    * CONFIG_F2FS_FS_ENCRYPTION
> > > >    * CONFIG_EXT4_FS_VERITY
> > > >    * CONFIG_F2FS_FS_VERITY
> > > > 
> > > > And in each file system, you have to do this before including the header files:
> > > > 
> > > > #define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
> > > > #include <linux/fscrypt.h>
> > > > 
> > > > #define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
> > > > #include <linux/fsverity.ha>
> > > > 
> > > > That's because whether you get the function prototype or an inline
> > > > function which returns EOhPNOTSUPP for functions such as
> > > > fscrypt_decrypt_bio() depends on how __FS_HAS_ENCRYPTION is defined
> > > > before including linux/fscrypt.h.
> > > > 
> > > > I now think this was a mistake, and that we should handle this the
> > > > same way we handle CONFIG_QUOTA.  If we enable fscrypt or fsverity, it
> > > > should be enabled for all file sytems which support that feature.
> > > > Otherwise it becomes too hard to try to support this in a file system
> > > > independent way --- and we end up having code which is cut-and-pasted
> > > > for each file system (e.g., in fs/f2fs/data.c and fs/ext4/readpage.c)
> > > > but which may compile to something quite different thanks to the C
> > > > preprocessor magic which is going on at the moment.
> > > > 
> > > > > I will work on this and post the results in the next version of the patchset.
> > > > 
> > > > So in order to avoid your wasting time and energy, and perhaps getting
> > > > unnecessarily frustrated, I'd recommend that before you immediately
> > > > start diving into implementation, that we have a design discussion
> > > > about the best way to proceed.  And then when we have a common
> > > > agreement about how to proceed, let's get something upstream first
> > > > which changes the infrastructure used by the file systems and by
> > > > fscrypt first.  And let's get that working, *before* we start
> > > > integrating the changes for supporting fscrypt for 4k blocks for
> > > > systems with 32k pagesize, or before we start making final (e.g.,
> > > > non-prototype) changes to integrate fsverity.
> > > > 
> > > > I'll include my first attempt that I played around over the weekend
> > > > with in terms of generic infrastructure, before I realized that we
> > > > need to decide whether the current way we configure fscrypt and
> > > > fsverity makes sense or not.  It's an example of why we should have
> > > > design discussions first, and not just immediately start diving into
> > > > code.
> > > > 
> > > > Fortunately (perhaps because I've some experience with these sorts of
> > > > things) I only spent about an hour or so working on the prototype, and
> > > > none trying to integrate it and doing all of the testing and
> > > > debugging, before recognizing that we needed to have a meeting of the
> > > > minds about design and requirements first.  :-)
> > > > 
> > > > Cheers,
> > > > 
> > > > 						- Ted
> > > > 
> > > > ------------- include/linux/bio_post_read.h
> > > > 
> > > > #ifndef _LINUX_BIO_POST_READ_H
> > > > #define _LINUX_BIO_POST_READ_H
> > > > 
> > > > #include <linux/bio.h>
> > > > 
> > > > enum bio_post_read_step {
> > > > 	STEP_INITIAL = 0,
> > > > 	STEP_DECRYPT,
> > > > 	STEP_VERITY,
> > > > };
> > > > 
> > > > struct bio_post_read_ctx {
> > > > 	struct bio *bio;
> > > > 	struct work_struct work;
> > > > 	unsigned int cur_step;
> > > > 	unsigned int enabled_steps;
> > > > };
> > > > 
> > > > static inline bool bpr_required(struct bio *bio)
> > > > {
> > > > 	return bio->bi_private && !bio->bi_status;
> > > > }
> > > > 
> > > > extern void __bpr_read_end_io(struct bio *bio);
> > > > void bpr_do_processing(struct bio_post_read_ctx *ctx);
> > > > 
> > > > #endif /* _LINUX_BIO_POST_READ_H */
> > > > 
> > > > ------------- fs/bio_post_read.c
> > > > 
> > > > // SPDX-License-Identifier: GPL-2.0
> > > > /*
> > > >  * fs/bio_post_read.c
> > > >  *
> > > >  * Copyright (C) 2018, Google LLC
> > > >  *
> > > >  * Contains helper functions used by file systems which use fscrypt
> > > >  * and/or fsverity
> > > >  */
> > > > 
> > > > #include <linux/mempool.h>
> > > > #include <linux/module.h>
> > > > #include <linux/slab.h>
> > > > #include <linux/bio_post_read.h>
> > > > #include <linux/pagemap.h>
> > > > #include <linux/fscrypt.h>
> > > > #include <linux/fsverity.h>
> > > > 
> > > > static unsigned int num_prealloc_post_read_ctxs = 128;
> > > > 
> > > > module_param(num_prealloc_post_read_ctxs, uint, 0444);
> > > > MODULE_PARM_DESC(num_prealloc_post_read_ctxs,
> > > > 		"Number of bio_post_read contexts to preallocate");
> > > > 
> > > > static struct kmem_cache *bpr_ctx_cache;
> > > > static mempool_t *bpr_ctx_pool;
> > > > 
> > > > void __bpr_read_end_io(struct bio *bio)
> > > > {
> > > > 	struct page *page;
> > > > 	struct bio_vec *bv;
> > > > 	int i;
> > > > 
> > > > 	bio_for_each_segment_all(bv, bio, i) {
> > > > 		page = bv->bv_page;
> > > > 
> > > > 		/* PG_error was set if any post_read step failed */
> > > > 		if (bio->bi_status || PageError(page)) {
> > > > 			ClearPageUptodate(page);
> > > > 			SetPageError(page);
> > > > 		} else {
> > > > 			SetPageUptodate(page);
> > > > 		}
> > > > 		unlock_page(page);
> > > > 	}
> > > > 	if (bio->bi_private)
> > > > 		mempool_free(bio->bi_private, bpr_ctx_pool);
> > > > 	bio_put(bio);
> > > > }
> > > > 
> > > > static void decrypt_work(struct work_struct *work)
> > > > {
> > > > 	struct bio_post_read_ctx *ctx =
> > > > 		container_of(work, struct bio_post_read_ctx, work);
> > > > 
> > > > 	fscrypt_decrypt_bio(ctx->bio);
> > > > 
> > > > 	bpr_do_processing(ctx);
> > > > }
> > > > 
> > > > static void verity_work(struct work_struct *work)
> > > > {
> > > > 	struct bio_post_read_ctx *ctx =
> > > > 		container_of(work, struct bio_post_read_ctx, work);
> > > > 
> > > > 	fsverity_verify_bio(ctx->bio);
> > > > 
> > > > 	bpr_do_processing(ctx);
> > > > }
> > > > 
> > > > void bpr_do_processing(struct bio_post_read_ctx *ctx)
> > > > {
> > > > 	/*
> > > > 	 * We use different work queues for decryption and for verity because
> > > > 	 * verity may require reading metadata pages that need decryption, and
> > > > 	 * we shouldn't recurse to the same workqueue.
> > > > 	 */
> > > > 	switch (++ctx->cur_step) {
> > > > 	case STEP_DECRYPT:
> > > > 		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
> > > > 			INIT_WORK(&ctx->work, decrypt_work);
> > > > 			fscrypt_enqueue_decrypt_work(&ctx->work);
> > > > 			return;
> > > > 		}
> > > > 		ctx->cur_step++;
> > > > 		/* fall-through */
> > > > 	case STEP_VERITY:
> > > > 		if (ctx->enabled_steps & (1 << STEP_VERITY)) {
> > > > 			INIT_WORK(&ctx->work, verity_work);
> > > > 			fsverity_enqueue_verify_work(&ctx->work);
> > > > 			return;
> > > > 		}
> > > > 		ctx->cur_step++;
> > > > 		/* fall-through */
> > > > 	default:
> > > > 		__bpr_read_end_io(ctx->bio);
> > > > 	}
> > > > }
> > > 
> > > decrypt_work() and verity_work() can be defined in fscrypt and fsverity
> > > modules. inode->[i_crypt_info|i_verity_info] can hold the pointers to
> > > decrypt_work() and verity_work() functions. The newly introduced function
> > > pointers in inode->[i_crypt_info|i_verity_info] can be initialized in
> > > fscrypt_get_encryption_info() and create_fsverity_info() respectively.
> > > 
> > > 'struct bio_post_read_ctx' should have a new member to store a pointer to the
> > > bpr_do_processing() function. Once *_work() functions complete their job, they
> > > could invoke ctx->do_processing() to continue with the next stage of bio
> > > processing.
> > > 
> > 
> > Storing a pointer to the inode inside 'struct bio_post_read_ctx' can make
> > things much simpler. With this update, there is no need to store the
> > [decrypt|verity]_work() function pointers inside the 'struct
> > bpr_post_read_ctx'. We will be able to access the function via
> > inode->[i_crypt_info|i_verity_info]->[decrypt|verity]_work.
> > 
> > Along the same lines, inode->[i_crypt_info|i_verity_info] can store pointers
> > to functions which enqueue decrypt/verity work on respective work queues. With
> > this facility, we will be able to anonymously invoke
> > fscrypt_enqueue_decrypt_work() and fsverity_enqueue_verify_work() from
> > bpr_do_processing().
> 
> I noticed that 'struct fscrypt_info' (stored at inode->i_crypt_info) is a
> private structure i.e. the definition of this structure is not visible outside
> of the fscrypt code. Also, the [decrypt|verity]_work() functions will be
> common to all the inodes of a filesystem instance. Hence pointers to these
> functions need to be stored in 'struct superblock'.
> 
> The call to fscrypt/fsverity functions to initalize the pointers in 'struct
> superblock' can be put inside a "#if FS_ENCRYPTION ... #endif" block. For
> example,
> 
> #if defined(FS_ENCRYPTION)
> ret = fscrypt_init_bpr_cbs(&sb->fscrypt_cbs);
> if (ret) {
>         /* take corrective action */;
> }
> #endif
> 
> sb->fscrypt_cbs will have pointers to functions for,
> 1. Enqueuing the bio for decryption.
> 2. Decrypting the bio data.
> 
> 

We only need the pointer to "enqueue work" function to be stored in the vfs
super block. The corresponding enqueue function can initialize
bio_post_read_ctx->work with the relevant "post read process" function . For
example, fscrypt_enqueue_decrypt_bio() initializes bio_post_read_ctx->work
with the pointer to completion_pages() function.

Pointers to "enqueue functions" corresponding to all the post read processing
functionality (currently limited to fscrypt and fsverity) can be
accumulated into a new structure called "struct bio_post_read_ops". The
structure itself will be stored inside the vfs super block.

So the code flow would be something along the lines of ...

1. Initialize "sb->bio_post_read_ops"
static int ext4_fill_super(struct super_block *sb, void *data, int silent)
{
	...
	...
#ifdef CONFIG_FS_ENCRYPTION
        sb->s_cop = &ext4_cryptops;
        sb->bpr_ops.enqueue_decrypt_work = fscrypt_enqueue_decrypt_bio;
#endif
#ifdef CONFIG_FS_VERITY
        sb->s_vop = &ext4_verityops;
        sb->bpr_ops.enqueue_verify_work = fsverity_enqueue_verify_bio;
#endif
	...
	...
}

2. Invoke "sb->bpr_ops->enqueue_decrypt_work()" to enqueue the work.
static void bpr_do_processing(struct bio_post_read_ctx *ctx)
{
        struct super_block *sb;
        /*
         * We use different work queues for decryption and for verity bec
         * verity may require reading metadata pages that need decryption
         * we shouldn't recurse to the same workqueue.
         */
        sb = ctx->inode->i_sb;

        switch (++ctx->cur_step) {
        case STEP_DECRYPT:
                if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
                        BUG_ON(!sb->bpr_ops->enqueue_decrypt_work);
                        sb->bpr_ops->enqueue_decrypt_work(ctx);
                        return;
                }
                ctx->cur_step++;
                /* fall-through */
        case STEP_VERITY:

	...
	...
}

void fscrypt_enqueue_decrypt_bio(struct bio_post_read_ctx *ctx)
{
        INIT_WORK(&ctx->work, completion_pages);
        fscrypt_enqueue_decrypt_work(&ctx->work);
}

3. After decryption, completion_pages() invokes ctx->do_processing() to
continue with the remaining steps i.e. fsverity.

static void completion_pages(struct work_struct *work)
{
        struct bio_post_read_ctx *ctx =
                container_of(work, struct bio_post_read_ctx, work);
        struct bio *bio = ctx->bio;

        fscrypt_decrypt_bio(bio, false);

        ctx->do_processing(ctx);
}


-- 
chandan
