Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V2 05/11] ext4: Decrypt all boundary blocks when doing buffered write
Date: Wed, 21 Feb 2018 15:27:18 +0530
In-Reply-To: <20180221010155.GC252219@gmail.com>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com> <20180212094347.22071-6-chandan@linux.vnet.ibm.com> <20180221010155.GC252219@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <11341004.sBrkMnv4Fk@localhost.localdomain>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, February 21, 2018 6:31:55 AM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Mon, Feb 12, 2018 at 03:13:41PM +0530, Chandan Rajendra wrote:
> > With block size < page size, ext4_block_write_begin() can have up to two
> > blocks to decrypt. Hence this commit invokes fscrypt_decrypt_block() for
> > each of those blocks.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> > ---
> >  fs/ext4/inode.c | 33 +++++++++++++++++++++++----------
> >  1 file changed, 23 insertions(+), 10 deletions(-)
> > 
> > diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> > index 69a4fd6..180dd2d 100644
> > --- a/fs/ext4/inode.c
> > +++ b/fs/ext4/inode.c
> > @@ -1158,12 +1158,13 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
> >  	unsigned to = from + len;
> >  	struct inode *inode = page->mapping->host;
> >  	unsigned block_start, block_end;
> > -	sector_t block;
> > +	sector_t block, page_blk_nr;
> >  	int err = 0;
> >  	unsigned blocksize = inode->i_sb->s_blocksize;
> >  	unsigned bbits;
> >  	struct buffer_head *bh, *head, *wait[2], **wait_bh = wait;
> >  	bool decrypt = false;
> > +	int i;
> >  
> >  	BUG_ON(!PageLocked(page));
> >  	BUG_ON(from > PAGE_SIZE);
> > @@ -1224,18 +1225,30 @@ static int ext4_block_write_begin(struct page *page, loff_t pos, unsigned len,
> >  	/*
> >  	 * If we issued read requests, let them complete.
> >  	 */
> > -	while (wait_bh > wait) {
> > -		wait_on_buffer(*--wait_bh);
> > -		if (!buffer_uptodate(*wait_bh))
> > +	for (i = 0; &wait[i] < wait_bh; i++) {
> > +		wait_on_buffer(wait[i]);
> > +		if (!buffer_uptodate(wait[i]))
> >  			err = -EIO;
> > 	}
> 
> [...]
> 
> > +		for (i = 0; &wait[i] < wait_bh; i++) {
> > +			int err2;
> > +
> > +			--wait_bh;
> > +			block = page_blk_nr + (bh_offset(wait[i]) >> bbits);
> > +			err2 = fscrypt_decrypt_block(page->mapping->host, page,
> > +						wait[i]->b_size,
> > +						bh_offset(wait[i]),
> > +						block);
> > +			if (err2) {
> > +				clear_buffer_uptodate(wait[i]);
> > +				err = err2;
> > +			}
> > +		}
> 
> These are very confusing ways to iterate through an array, especially the second
> loop which is actually going in reverse order (why?).  Why not just use a
> variable like 'nr_wait' for the number of valid buffer_head's like I had
> suggested?  Then you can just do 'for (i = 0; i < nr_wait; i++)'.
> 

Sorry, the "--wait_bh;" part was a remanent from the "RFC PATCH V1". Without
that statement, we loop in increasing order of elements in wait[] array. I
will use the 'nr_wait' counter approach and post the next version of the
patchset.  I misunderstood your advice to mean that the code should use
similar looping order in both loops.

-- 
chandan
