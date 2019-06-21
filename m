Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Fri, 21 Jun 2019 14:14:55 -0700
From: Eric Biggers <ebiggers@kernel.org>
Message-ID: <20190621211454.GC167064@gmail.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com>
 <20190616160813.24464-5-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20190616160813.24464-5-chandan@linux.ibm.com>
Subject: Re: [f2fs-dev] [PATCH V3 4/7] fs/mpage.c: Integrate read callbacks
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

On Sun, Jun 16, 2019 at 09:38:10PM +0530, Chandan Rajendra wrote:
> This commit adds code to make do_mpage_readpage() to be "read callbacks"
> aware i.e. for files requiring decryption, do_mpage_readpage() now
> sets up the read callbacks state machine when allocating a bio and later
> starts execution of the state machine after file data is read from the
> underlying disk.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> ---
>  fs/mpage.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/mpage.c b/fs/mpage.c
> index 436a85260394..611ad122fc92 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -30,6 +30,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/pagevec.h>
>  #include <linux/cleancache.h>
> +#include <linux/read_callbacks.h>
>  #include "internal.h"
>  
>  /*
> @@ -49,6 +50,8 @@ static void mpage_end_io(struct bio *bio)
>  	struct bio_vec *bv;
>  	struct bvec_iter_all iter_all;
>  
> +	if (read_callbacks_end_bio(bio))
> +		return;
>  	bio_for_each_segment_all(bv, bio, iter_all) {
>  		struct page *page = bv->bv_page;
>  		page_endio(page, bio_op(bio),
> @@ -309,6 +312,12 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
>  					gfp);
>  		if (args->bio == NULL)
>  			goto confused;
> +
> +		if (read_callbacks_setup(inode, args->bio, NULL)) {
> +			bio_put(args->bio);
> +			args->bio = NULL;
> +			goto confused;
> +		}
>  	}
>  
>  	length = first_hole << blkbits;
> @@ -330,7 +339,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
>  confused:
>  	if (args->bio)
>  		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
> -	if (!PageUptodate(page))
> +	if (!PageUptodate(page) && !PageError(page))
>  		block_read_full_page(page, args->get_block);
>  	else
>  		unlock_page(page);
> -- 
> 2.19.1

Why is the !PageError() check needed here?

- Eric


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
