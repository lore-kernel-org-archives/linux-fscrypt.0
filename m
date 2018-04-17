Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f68.google.com ([209.85.160.68]:34024 "EHLO
        mail-pl0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbeDQRm0 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 17 Apr 2018 13:42:26 -0400
Received: by mail-pl0-f68.google.com with SMTP id z12-v6so4918764plo.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 17 Apr 2018 10:42:26 -0700 (PDT)
Date: Tue, 17 Apr 2018 10:42:21 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [f2fs-dev] [PATCH 2/2] f2fs: refactor read path to allow
 multiple postprocessing steps
Message-ID: <20180417174221.GB7428@google.com>
References: <20180416193147.104555-1-ebiggers@google.com>
 <20180416193147.104555-3-ebiggers@google.com>
 <2ccf62e8-070a-7ddc-77a3-cb5ba9347bba@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ccf62e8-070a-7ddc-77a3-cb5ba9347bba@huawei.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chao Yu <yuchao0@huawei.com>
Cc: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chao,

On Tue, Apr 17, 2018 at 05:13:12PM +0800, Chao Yu wrote:
> > +
> > +static void bio_post_read_processing(struct bio_post_read_ctx *ctx);
> > +
> > +static void decrypt_work(struct work_struct *work)
> > +{
> > +	struct bio_post_read_ctx *ctx =
> > +		container_of(work, struct bio_post_read_ctx, work);
> > +
> > +	fscrypt_decrypt_bio(ctx->bio);
> > +
> > +	bio_post_read_processing(ctx);
> > +}
> > +
> > +static void bio_post_read_processing(struct bio_post_read_ctx *ctx)
> > +{
> > +	switch (++ctx->cur_step) {
> > +	case STEP_DECRYPT:
> > +		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
> > +			INIT_WORK(&ctx->work, decrypt_work);
> > +			fscrypt_enqueue_decrypt_work(&ctx->work);
> > +			return;
> > +		}
> > +		ctx->cur_step++;
> > +		/* fall-through */
> > +	default:
> > +		__read_end_io(ctx->bio);
> > +	}
> 
> How about introducing __bio_post_read_processing()
> 
> switch (step) {
> case STEP_DECRYPT:
> 	...
> 	break;
> case STEP_COMPRESS:
> 	...
> 	break;
> case STEP_GENERIC:
> 	__read_end_io;
> 	break;
> ...
> }
> 
> Then we can customize flexible read processes like:
> 
> bio_post_read_processing()
> {
> 	if (encrypt_enabled)
> 		__bio_post_read_processing(, STEP_DECRYPT);
> 	if (compress_enabled)
> 		__bio_post_read_processing(, STEP_COMPRESS);
> 	__bio_post_read_processing(, STEP_GENERIC);
> }
> 
> Or other flow.

If I understand correctly, you're suggesting that all the steps be done in a
single workqueue item?  The problem with that is that the verity work will
require I/O to the file to read hashes, which may need STEP_DECRYPT.  Hence,
decryption and verity will need separate workqueues.

> > @@ -481,29 +537,33 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
> >  							 unsigned nr_pages)
> >  {
> >  	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
> > -	struct fscrypt_ctx *ctx = NULL;
> >  	struct bio *bio;
> > -
> > -	if (f2fs_encrypted_file(inode)) {
> > -		ctx = fscrypt_get_ctx(inode, GFP_NOFS);
> > -		if (IS_ERR(ctx))
> > -			return ERR_CAST(ctx);
> > -
> > -		/* wait the page to be moved by cleaning */
> > -		f2fs_wait_on_block_writeback(sbi, blkaddr);
> > -	}
> > +	struct bio_post_read_ctx *ctx;
> > +	unsigned int post_read_steps = 0;
> >  
> >  	bio = f2fs_bio_alloc(sbi, min_t(int, nr_pages, BIO_MAX_PAGES), false);
> > -	if (!bio) {
> > -		if (ctx)
> > -			fscrypt_release_ctx(ctx);
> > +	if (!bio)
> >  		return ERR_PTR(-ENOMEM);
> > -	}
> >  	f2fs_target_device(sbi, blkaddr, bio);
> >  	bio->bi_end_io = f2fs_read_end_io;
> > -	bio->bi_private = ctx;
> 
> bio->bi_private = NULL;
> 

I don't see why.  ->bi_private is NULL by default.

> > +	bio_post_read_ctx_pool =
> > +		mempool_create_slab_pool(128, bio_post_read_ctx_cache);
> 
> #define MAX_POST_READ_CACHE_SIZE	128
> 

Yes, that makes sense.

- Eric
