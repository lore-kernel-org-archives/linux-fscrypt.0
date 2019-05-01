Return-Path: <SRS0=+nDJ=TB=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V2 11/13] ext4: Compute logical block and the page range to be encrypted
Date: Wed, 01 May 2019 19:41:49 +0530
In-Reply-To: <20190430170151.GB48973@gmail.com>
References: <20190428043121.30925-1-chandan@linux.ibm.com> <20190428043121.30925-12-chandan@linux.ibm.com> <20190430170151.GB48973@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <12288535.bgPuNnGEdQ@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, April 30, 2019 10:31:51 PM IST Eric Biggers wrote:
> On Sun, Apr 28, 2019 at 10:01:19AM +0530, Chandan Rajendra wrote:
> > For subpage-sized blocks, the initial logical block number mapped by a
> > page can be different from page->index. Hence this commit adds code to
> > compute the first logical block mapped by the page and also the page
> > range to be encrypted.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/ext4/page-io.c | 9 +++++++--
> >  1 file changed, 7 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
> > index 3e9298e6a705..75485ee9e800 100644
> > --- a/fs/ext4/page-io.c
> > +++ b/fs/ext4/page-io.c
> > @@ -418,6 +418,7 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
> >  {
> >  	struct page *data_page = NULL;
> >  	struct inode *inode = page->mapping->host;
> > +	u64 page_blk;
> >  	unsigned block_start;
> >  	struct buffer_head *bh, *head;
> >  	int ret = 0;
> > @@ -478,10 +479,14 @@ int ext4_bio_write_page(struct ext4_io_submit *io,
> >  
> >  	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode) && nr_to_submit) {
> >  		gfp_t gfp_flags = GFP_NOFS;
> > +		unsigned int page_bytes;
> > +
> 
> page_blk should be declared here, just after page_bytes.
> 
> > +		page_bytes = round_up(len, i_blocksize(inode));
> > +		page_blk = page->index << (PAGE_SHIFT - inode->i_blkbits);
> 
> Although block numbers are 32-bit in ext4, if you're going to make 'page_blk' a
> u64 anyway, then for consistency page->index should be cast to u64 here.
> 
> >  
> >  	retry_encrypt:
> > -		data_page = fscrypt_encrypt_page(inode, page, PAGE_SIZE, 0,
> > -						page->index, gfp_flags);
> > +		data_page = fscrypt_encrypt_page(inode, page, page_bytes, 0,
> > +						page_blk, gfp_flags);
> >  		if (IS_ERR(data_page)) {
> >  			ret = PTR_ERR(data_page);
> >  			if (ret == -ENOMEM && wbc->sync_mode == WB_SYNC_ALL) {
> 
> 

I will implement the changes that have been suggested here.

-- 
chandan
