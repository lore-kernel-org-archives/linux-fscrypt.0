Return-Path: <ebiggers3@gmail.com>
Date: Tue, 20 Feb 2018 17:16:48 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed
 out blocks of a page
Message-ID: <20180221011648.GD252219@gmail.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <20180212094347.22071-8-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180212094347.22071-8-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Feb 12, 2018 at 03:13:43PM +0530, Chandan Rajendra wrote:
> For block size < page size, This commit adds code to encrypt all zeroed
> out blocks of a page.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> ---
>  fs/crypto/bio.c | 38 +++++++++++++++++++++++++-------------
>  1 file changed, 25 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
> index 378df08..4d0d14f 100644
> --- a/fs/crypto/bio.c
> +++ b/fs/crypto/bio.c
> @@ -104,10 +104,12 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
>  {
>  	struct fscrypt_ctx *ctx;
>  	struct page *ciphertext_page = NULL;
> +	unsigned int page_nr_blks;
> +	unsigned int offset;
> +	unsigned int page_io_len;
>  	struct bio *bio;
>  	int ret, err = 0;
> -
> -	BUG_ON(inode->i_sb->s_blocksize != PAGE_SIZE);
> +	int i;
>  
>  	ctx = fscrypt_get_ctx(inode, GFP_NOFS);
>  	if (IS_ERR(ctx))
> @@ -119,12 +121,23 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
>  		goto errout;
>  	}
>  
> -	while (len--) {
> -		err = fscrypt_do_block_crypto(inode, FS_ENCRYPT, lblk,
> -					     ZERO_PAGE(0), ciphertext_page,
> -					     PAGE_SIZE, 0, GFP_NOFS);
> -		if (err)
> -			goto errout;
> +	page_nr_blks = 1 << (PAGE_SHIFT - inode->i_blkbits);
> +
> +	while (len) {
> +		page_nr_blks = min_t(unsigned int, page_nr_blks, len);
> +		page_io_len = page_nr_blks << inode->i_blkbits;
> +		offset = 0;

The 'page_io_len' variable isn't needed, since 'offset == page_io_len' after the
encryption loop.  You can do 'bio_add_page(bio, ciphertext_page, offset, 0);'.

Eric
