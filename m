Return-Path: <SRS0=SM74=UY=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V3 2/7] Integrate read callbacks into Ext4 and F2FS
Date: Tue, 25 Jun 2019 11:35:06 +0530
In-Reply-To: <20190621210800.GB167064@gmail.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com> <20190616160813.24464-3-chandan@linux.ibm.com> <20190621210800.GB167064@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <4046659.6pHPRur4YB@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Saturday, June 22, 2019 2:38:01 AM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Sun, Jun 16, 2019 at 09:38:08PM +0530, Chandan Rajendra wrote:
> > This commit gets Ext4 and F2FS to make use of read callbacks API to
> > perform decryption of file data read from the disk.
> > ---
> >  fs/crypto/bio.c             |  30 +--------
> >  fs/crypto/crypto.c          |   1 +
> >  fs/crypto/fscrypt_private.h |   3 +
> >  fs/ext4/readpage.c          |  29 +++------
> >  fs/f2fs/data.c              | 124 +++++++-----------------------------
> >  fs/f2fs/super.c             |   9 +--
> >  fs/read_callbacks.c         |   1 -
> >  include/linux/fscrypt.h     |  18 ------
> >  8 files changed, 40 insertions(+), 175 deletions(-)
> > 
> 
> This patch changes many different components.  It would be much easier to
> review, and might get more attention from the other ext4 and f2fs developers, if
> it were split into 3 patches:
> 
> a. Convert ext4 to use read_callbacks.
> b. Convert f2fs to use read_callbacks.
> c. Remove the functions from fs/crypto/ that became unused as a result of
>    patches (a) and (b).  (Actually, this part probably should be merged with the
>    patch that removes the fscrypt_ctx, and the patch renamed to something like
>    "fscrypt: remove decryption I/O path helpers")
> 
> Any reason why this wouldn't work?  AFAICS, you couldn't do it only because you
> made this patch change fscrypt_enqueue_decrypt_work() to be responsible for
> initializing the work function.  But as per my comments on patch 1, I don't
> think we should do that, since it would make much more sense to put the work
> function in read_callbacks.c.

Yes, you are right about that. I will make the changes suggested by you.

> 
> However, since you're converting ext4 to use mpage_readpages() anyway, I don't
> think we should bother with the intermediate change to ext4_mpage_readpages().
> It's useless, and that intermediate state of the ext4 code inevitably won't get
> tested very well.  So perhaps order the whole series as:
> 
> - fs: introduce read_callbacks
> - fs/mpage.c: add decryption support via read_callbacks
> - fs/buffer.c: add decryption support via read_callbacks
> - f2fs: convert to use read_callbacks
> - ext4: convert to use mpage_readpages[s]
> - ext4: support encryption with subpage-sized blocks
> - fscrypt: remove decryption I/O path helpers
> 
> That order would also give the flexibility to possibly apply the fs/ changes
> first, without having to update both ext4 and f2fs simultaneously with them.
> 
> > @@ -557,8 +511,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
> >  {
> >  	struct f2fs_sb_info *sbi = F2FS_I_SB(inode);
> >  	struct bio *bio;
> > -	struct bio_post_read_ctx *ctx;
> > -	unsigned int post_read_steps = 0;
> > +	int ret;
> 
> Nit: 'err' rather than 'ret', since this is 0 or a -errno value.
> 
> > -int __init f2fs_init_post_read_processing(void)
> > -{
> > -	bio_post_read_ctx_cache = KMEM_CACHE(bio_post_read_ctx, 0);
> > -	if (!bio_post_read_ctx_cache)
> > -		goto fail;
> > -	bio_post_read_ctx_pool =
> > -		mempool_create_slab_pool(NUM_PREALLOC_POST_READ_CTXS,
> > -					 bio_post_read_ctx_cache);
> > -	if (!bio_post_read_ctx_pool)
> > -		goto fail_free_cache;
> > -	return 0;
> > -
> > -fail_free_cache:
> > -	kmem_cache_destroy(bio_post_read_ctx_cache);
> > -fail:
> > -	return -ENOMEM;
> > -}
> > -
> > -void __exit f2fs_destroy_post_read_processing(void)
> > -{
> > -	mempool_destroy(bio_post_read_ctx_pool);
> > -	kmem_cache_destroy(bio_post_read_ctx_cache);
> > -}
> 
> Need to remove the declarations of these functions from fs/f2fs/f2fs.h to.
> 
> > diff --git a/fs/read_callbacks.c b/fs/read_callbacks.c
> > index a4196e3de05f..4b7fc2a349cd 100644
> > --- a/fs/read_callbacks.c
> > +++ b/fs/read_callbacks.c
> > @@ -76,7 +76,6 @@ void read_callbacks(struct read_callbacks_ctx *ctx)
> >  	switch (++ctx->cur_step) {
> >  	case STEP_DECRYPT:
> >  		if (ctx->enabled_steps & (1 << STEP_DECRYPT)) {
> > -			INIT_WORK(&ctx->work, fscrypt_decrypt_work);
> >  			fscrypt_enqueue_decrypt_work(&ctx->work);
> >  			return;
> >  		}
> 
> Again, I think the work initialization should remain here as:
> 
> 	INIT_WORK(&ctx->work, decrypt_work);
> 
> rather than moving it to fs/crypto/.
> 
> Thanks!
> 
> - Eric
> 


-- 
chandan
