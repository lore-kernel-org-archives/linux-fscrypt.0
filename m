Return-Path: <ebiggers3@gmail.com>
Date: Tue, 20 Feb 2018 16:54:54 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [RFC PATCH V2 10/11] Enable writing encrypted files in blocksize
 less than pagesize setup
Message-ID: <20180221005454.GB252219@gmail.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <20180212094347.22071-11-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180212094347.22071-11-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Feb 12, 2018 at 03:13:46PM +0530, Chandan Rajendra wrote:
> This commit splits the functionality of fscrypt_encrypt_block(). The
> allocation of fscrypt context and cipher text page is moved to a new
> function fscrypt_prep_ciphertext_page().
> 
> ext4_bio_write_page() is modified to appropriately make use of the above
> two functions.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Well, this patch also modifies ext4_bio_write_page() to support the blocksize <
pagesize case.  The commit message makes it sound like it's just refactoring.

> diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
> index 0a4a1e7..1e869d5 100644
> --- a/fs/ext4/page-io.c
> +++ b/fs/ext4/page-io.c
> @@ -419,9 +419,12 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
>  	struct inode *inode = page->mapping->host;
>  	unsigned block_start;
>  	struct buffer_head *bh, *head;
> +	u64 blk_nr;
> +	gfp_t gfp_flags = GFP_NOFS;
>  	int ret = 0;
>  	int nr_submitted = 0;
>  	int nr_to_submit = 0;
> +	int blocksize = (1 << inode->i_blkbits);
>  
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(PageWriteback(page));
> @@ -475,15 +478,11 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
>  		nr_to_submit++;
>  	} while ((bh = bh->b_this_page) != head);
>  
> -	bh = head = page_buffers(page);
> -
> -	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode) &&
> -	    nr_to_submit) {
> -		gfp_t gfp_flags = GFP_NOFS;
> -
> -	retry_encrypt:
> -		data_page = fscrypt_encrypt_block(inode, page, PAGE_SIZE, 0,
> -						page->index, gfp_flags);
> +	if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode)
> +		&& nr_to_submit) {
> +	retry_prep_ciphertext_page:
> +		data_page = fscrypt_prep_ciphertext_page(inode, page,
> +							gfp_flags);
>  		if (IS_ERR(data_page)) {
>  			ret = PTR_ERR(data_page);
>  			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
> @@ -492,17 +491,28 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
>  					congestion_wait(BLK_RW_ASYNC, HZ/50);
>  				}
>  				gfp_flags |= __GFP_NOFAIL;
> -				goto retry_encrypt;
> +				goto retry_prep_ciphertext_page;
>  			}
>  			data_page = NULL;
>  			goto out;
>  		}
>  	}
>  
> +	blk_nr = page->index << (PAGE_SHIFT - inode->i_blkbits);
> +
>  	/* Now submit buffers to write */
> +	bh = head = page_buffers(page);
>  	do {
>  		if (!buffer_async_write(bh))
>  			continue;
> +
> +		if (ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode)) {
> +			ret = fscrypt_encrypt_block(inode, page, data_page, blocksize,
> +						bh_offset(bh), blk_nr, gfp_flags);
> +			if (ret)
> +				break;
> +		}
> +
>  		ret = io_submit_add_bh(io, inode,
>  				       data_page ? data_page : page, bh);
>  		if (ret) {
> @@ -515,12 +525,12 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
>  		}
>  		nr_submitted++;
>  		clear_buffer_dirty(bh);
> -	} while ((bh = bh->b_this_page) != head);
> +	} while (++blk_nr, (bh = bh->b_this_page) != head);
>  
>  	/* Error stopped previous loop? Clean up buffers... */
>  	if (ret) {
>  	out:
> -		if (data_page)
> +		if (data_page && bh == head)
>  			fscrypt_restore_control_page(data_page);
>  		printk_ratelimited(KERN_ERR "%s: ret = %d\n", __func__, ret);
>  		redirty_page_for_writepage(wbc, page);

I'm wondering why you didn't move the crypto stuff in ext4_bio_write_page() into
a separate function like I had suggested?  It's true we don't have to encrypt
all the blocks in the page at once, but it would make the crypto stuff more
self-contained.

- Eric
