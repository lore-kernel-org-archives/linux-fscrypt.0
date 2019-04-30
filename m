Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 30 Apr 2019 10:11:35 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190430171133.GC48973@gmail.com>
References: <20190428043121.30925-1-chandan@linux.ibm.com>
 <20190428043121.30925-11-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190428043121.30925-11-chandan@linux.ibm.com>
Subject: Re: [f2fs-dev] [PATCH V2 10/13] fscrypt_encrypt_page: Loop across
 all blocks mapped by a page range
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
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: tytso@mit.edu, linux-f2fs-devel@lists.sourceforge.net, hch@infradead.org, linux-fscrypt@vger.kernel.org, adilger.kernel@dilger.ca, linux-fsdevel@vger.kernel.org, jaegeuk@kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Apr 28, 2019 at 10:01:18AM +0530, Chandan Rajendra wrote:
> For subpage-sized blocks, this commit now encrypts all blocks mapped by
> a page range.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> ---
>  fs/crypto/crypto.c | 37 +++++++++++++++++++++++++------------
>  1 file changed, 25 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
> index 4f0d832cae71..2d65b431563f 100644
> --- a/fs/crypto/crypto.c
> +++ b/fs/crypto/crypto.c
> @@ -242,18 +242,26 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,

Need to update the function comment to clearly explain what this function
actually does now.

>  {
>  	struct fscrypt_ctx *ctx;
>  	struct page *ciphertext_page = page;
> +	int i, page_nr_blks;
>  	int err;
>  
>  	BUG_ON(len % FS_CRYPTO_BLOCK_SIZE != 0);
>  

Make a 'blocksize' variable so you don't have to keep calling i_blocksize().

Also, you need to check whether 'len' and 'offs' are filesystem-block-aligned,
since the code now assumes it.

	const unsigned int blocksize = i_blocksize(inode);

        if (!IS_ALIGNED(len | offs, blocksize))
                return -EINVAL;

However, did you check whether that's always true for ubifs?  It looks like it
may expect to encrypt a prefix of a block, that is only padded to the next
16-byte boundary.
		
> +	page_nr_blks = len >> inode->i_blkbits;
> +
>  	if (inode->i_sb->s_cop->flags & FS_CFLG_OWN_PAGES) {
>  		/* with inplace-encryption we just encrypt the page */
> -		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num, page,
> -					     ciphertext_page, len, offs,
> -					     gfp_flags);
> -		if (err)
> -			return ERR_PTR(err);
> -
> +		for (i = 0; i < page_nr_blks; i++) {
> +			err = fscrypt_do_page_crypto(inode, FS_ENCRYPT,
> +						lblk_num, page,
> +						ciphertext_page,
> +						i_blocksize(inode), offs,
> +						gfp_flags);
> +			if (err)
> +				return ERR_PTR(err);
> +			++lblk_num;
> +			offs += i_blocksize(inode);
> +		}
>  		return ciphertext_page;
>  	}
>  
> @@ -269,12 +277,17 @@ struct page *fscrypt_encrypt_page(const struct inode *inode,
>  		goto errout;
>  
>  	ctx->control_page = page;
> -	err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
> -				     page, ciphertext_page, len, offs,
> -				     gfp_flags);
> -	if (err) {
> -		ciphertext_page = ERR_PTR(err);
> -		goto errout;
> +
> +	for (i = 0; i < page_nr_blks; i++) {
> +		err = fscrypt_do_page_crypto(inode, FS_ENCRYPT, lblk_num,
> +					page, ciphertext_page,
> +					i_blocksize(inode), offs, gfp_flags);

As I mentioned elsewhere, renaming fscrypt_do_page_crypto() to
fscrypt_crypt_block() would make more sense now.

> +		if (err) {
> +			ciphertext_page = ERR_PTR(err);
> +			goto errout;
> +		}
> +		++lblk_num;
> +		offs += i_blocksize(inode);
>  	}
>  	SetPagePrivate(ciphertext_page);
>  	set_page_private(ciphertext_page, (unsigned long)ctx);
> -- 
> 2.19.1
> 


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
