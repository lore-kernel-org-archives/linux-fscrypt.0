Return-Path: <SRS0=Hy9y=Q4=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [f2fs-dev] [RFC PATCH 05/10] fsverity: Add call back to decide if verity check has to be performed
Date: Thu, 21 Feb 2019 18:24:52 +0530
In-Reply-To: <20190219232649.GF12177@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com> <20190218100433.20048-6-chandan@linux.ibm.com> <20190219232649.GF12177@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3323472.mdDe8xBITV@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, February 20, 2019 4:56:49 AM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Mon, Feb 18, 2019 at 03:34:28PM +0530, Chandan Rajendra wrote:
> > Ext4 and F2FS store verity metadata in data extents (beyond
> > inode->i_size) associated with a file. But other filesystems might
> > choose alternative means to store verity metadata. Hence this commit
> > adds a callback function pointer to 'struct fsverity_operations' to help
> > in deciding if verity operation needs to performed against a page-cache
> > page holding file data.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/ext4/super.c          | 9 +++++++++
> >  fs/post_read_process.c   | 5 +++--
> >  include/linux/fsverity.h | 1 +
> >  3 files changed, 13 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> > index 9314dddfbf34..2d7781ab6824 100644
> > --- a/fs/ext4/super.c
> > +++ b/fs/ext4/super.c
> > @@ -1428,10 +1428,19 @@ static struct page *ext4_read_verity_metadata_page(struct inode *inode,
> >  	return read_mapping_page(inode->i_mapping, index, NULL);
> >  }
> >  
> > +static bool ext4_verity_required(struct inode *inode, pgoff_t index)
> > +{
> > +	if (index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT))
> > +		return true;
> > +	else
> > +		return false;
> > +}
> 
> This can be simplified to:
> 
> 	return index < (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
>

You are right.

> > +
> >  static const struct fsverity_operations ext4_verityops = {
> >  	.set_verity		= ext4_set_verity,
> >  	.get_metadata_end	= ext4_get_verity_metadata_end,
> >  	.read_metadata_page	= ext4_read_verity_metadata_page,
> > +	.verity_required	= ext4_verity_required,
> >  };
> >  #endif /* CONFIG_FS_VERITY */
> 
> Doesn't f2fs need this too?  This patch only changes ext4.

Yes, My plan was to get review comments about the current approach and then
make corresponding changes in F2FS.

> 
> >  
> > diff --git a/fs/post_read_process.c b/fs/post_read_process.c
> > index 9720eeff0160..1f8663d70247 100644
> > --- a/fs/post_read_process.c
> > +++ b/fs/post_read_process.c
> > @@ -79,8 +79,9 @@ struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
> >  	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
> >  		post_read_steps |= 1 << STEP_DECRYPT;
> >  #ifdef CONFIG_FS_VERITY
> > -	if (inode->i_verity_info != NULL &&
> > -		(index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
> > +	if (inode->i_verity_info != NULL
> > +		&& inode->i_sb->s_vop->verity_required
> > +		&& inode->i_sb->s_vop->verity_required(inode, index))
> >  		post_read_steps |= 1 << STEP_VERITY;
> 
> If ->verity_required is NULL, shouldn't that be equivalent to
> ->verity_required() returning true?
>

Yes, you are right about that. I will fix it in the next iteration of the
patchset.

> >  #endif
> >  	if (post_read_steps) {
> > diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
> > index 7c33b42abf1b..b83712d6c79a 100644
> > --- a/include/linux/fsverity.h
> > +++ b/include/linux/fsverity.h
> > @@ -18,6 +18,7 @@ struct fsverity_operations {
> >  	int (*set_verity)(struct inode *inode, loff_t data_i_size);
> >  	int (*get_metadata_end)(struct inode *inode, loff_t *metadata_end_ret);
> >  	struct page *(*read_metadata_page)(struct inode *inode, pgoff_t index);
> > +	bool (*verity_required)(struct inode *inode, pgoff_t index);
> >  };
> >  
> >  #ifdef CONFIG_FS_VERITY
> 
> - Eric
> 
> 


-- 
chandan
