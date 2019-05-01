Return-Path: <SRS0=+nDJ=TB=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V2 12/13] fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
Date: Wed, 01 May 2019 19:52:02 +0530
In-Reply-To: <20190430165114.GA48973@gmail.com>
References: <20190428043121.30925-1-chandan@linux.ibm.com> <20190428043121.30925-13-chandan@linux.ibm.com> <20190430165114.GA48973@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <5118219.DRdbvtsWY3@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, April 30, 2019 10:21:15 PM IST Eric Biggers wrote:
> On Sun, Apr 28, 2019 at 10:01:20AM +0530, Chandan Rajendra wrote:
> > For subpage-sized blocks, this commit adds code to encrypt all zeroed
> > out blocks mapped by a page.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/crypto/bio.c | 40 ++++++++++++++++++----------------------
> >  1 file changed, 18 insertions(+), 22 deletions(-)
> > 
> > diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
> > index 856f4694902d..46dd2ec50c7d 100644
> > --- a/fs/crypto/bio.c
> > +++ b/fs/crypto/bio.c
> > @@ -108,29 +108,23 @@ EXPORT_SYMBOL(fscrypt_pullback_bio_page);
> >  int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
> >  				sector_t pblk, unsigned int len)
> >  {
> > -	struct fscrypt_ctx *ctx;
> >  	struct page *ciphertext_page = NULL;
> >  	struct bio *bio;
> > +	u64 total_bytes, page_bytes;
> 
> page_bytes should be 'unsigned int', since it's <= PAGE_SIZE.
> 
> >  	int ret, err = 0;
> >  
> > -	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
> > -
> > -	ctx = fscrypt_get_ctx(inode, GFP_NOFS);
> > -	if (IS_ERR(ctx))
> > -		return PTR_ERR(ctx);
> > +	total_bytes = len << inode->i_blkbits;
> 
> Should cast len to 'u64' here, in case it's greater than UINT_MAX / blocksize.
> 
> >  
> > -	ciphertext_page = fscrypt_alloc_bounce_page(ctx, GFP_NOWAIT);
> > -	if (IS_ERR(ciphertext_page)) {
> > -		err = PTR_ERR(ciphertext_page);
> > -		goto errout;
> > -	}
> > +	while (total_bytes) {
> > +		page_bytes = min_t(u64, total_bytes, PAGE_SIZE);
> >  
> > -	while (len--) {
> > -		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk,
> > -					     ZERO_PAGE(0), ciphertext_page,
> > -					     PAGE_SIZE, 0, GFP_NOFS);
> > -		if (err)
> > +		ciphertext_page = fscrypt_encrypt_page(inode, ZERO_PAGE(0),
> > +						page_bytes, 0, lblk, GFP_NOFS);
> > +		if (IS_ERR(ciphertext_page)) {
> > +			err = PTR_ERR(ciphertext_page);
> > +			ciphertext_page = NULL;
> >  			goto errout;
> > +		}
> 
> 'ciphertext_page' is leaked after each loop iteration.  Did you mean to free it,
> or did you mean to reuse it for subsequent iterations?

Thanks for pointing this out. I actually meant to free it. I will see if I can
reuse ciphertext_page in my next patchset rather than freeing and allocating
it each time the loop is executed.

> 
> >  
> >  		bio = bio_alloc(GFP_NOWAIT, 1);
> >  		if (!bio) {
> > @@ -141,9 +135,8 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
> >  		bio->bi_iter.bi_sector =
> >  			pblk << (inode->i_sb->s_blocksize_bits - 9);
> 
> This line uses ->s_blocksize_bits, but your new code uses ->i_blkbits.  AFAIK
> they'll always be the same, but please pick one or the other to use.

I will fix this.

> 
> >  		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
> > -		ret = bio_add_page(bio, ciphertext_page,
> > -					inode->i_sb->s_blocksize, 0);
> > -		if (ret != inode->i_sb->s_blocksize) {
> > +		ret = bio_add_page(bio, ciphertext_page, page_bytes, 0);
> > +		if (ret != page_bytes) {
> >  			/* should never happen! */
> >  			WARN_ON(1);
> >  			bio_put(bio);
> > @@ -156,12 +149,15 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
> >  		bio_put(bio);
> >  		if (err)
> >  			goto errout;
> > -		lblk++;
> > -		pblk++;
> > +
> > +		lblk += page_bytes >> inode->i_blkbits;
> > +		pblk += page_bytes >> inode->i_blkbits;
> > +		total_bytes -= page_bytes;
> >  	}
> >  	err = 0;
> >  errout:
> > -	fscrypt_release_ctx(ctx);
> > +	if (!IS_ERR_OR_NULL(ciphertext_page))
> > +		fscrypt_restore_control_page(ciphertext_page);
> >  	return err;
> >  }
> >  EXPORT_SYMBOL(fscrypt_zeroout_range);
> 
> 


-- 
chandan
