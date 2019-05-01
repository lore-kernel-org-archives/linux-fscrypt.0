Return-Path: <SRS0=+nDJ=TB=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V2 03/13] fsverity: Add call back to decide if verity check has to be performed
Date: Wed, 01 May 2019 18:03:56 +0530
In-Reply-To: <20190430211037.GA30337@azazel.net>
References: <20190428043121.30925-1-chandan@linux.ibm.com> <20190428043121.30925-4-chandan@linux.ibm.com> <20190430211037.GA30337@azazel.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1679959.ODoryAfBfi@localhost.localdomain>
To: Jeremy Sowden <jeremy@azazel.net>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, May 1, 2019 2:40:38 AM IST Jeremy Sowden wrote:
> On 2019-04-28, at 10:01:11 +0530, Chandan Rajendra wrote:
> > Ext4 and F2FS store verity metadata in data extents (beyond
> > inode->i_size) associated with a file. But other filesystems might
> > choose alternative means to store verity metadata. Hence this commit
> > adds a callback function pointer to 'struct fsverity_operations' to
> > help in deciding if verity operation needs to performed against a
> > page-cache page holding file data.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/ext4/super.c          | 6 ++++++
> >  fs/f2fs/super.c          | 6 ++++++
> >  fs/read_callbacks.c      | 4 +++-
> >  include/linux/fsverity.h | 1 +
> >  4 files changed, 16 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> > index aba724f82cc3..63d73b360f1d 100644
> > --- a/fs/ext4/super.c
> > +++ b/fs/ext4/super.c
> > @@ -1428,10 +1428,16 @@ static struct page *ext4_read_verity_metadata_page(struct inode *inode,
> >  	return read_mapping_page(inode->i_mapping, index, NULL);
> >  }
> >  
> > +static bool ext4_verity_required(struct inode *inode, pgoff_t index)
> > +{
> > +	return index < (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +}
> > +
> >  static const struct fsverity_operations ext4_verityops = {
> >  	.set_verity		= ext4_set_verity,
> >  	.get_metadata_end	= ext4_get_verity_metadata_end,
> >  	.read_metadata_page	= ext4_read_verity_metadata_page,
> > +	.verity_required	= ext4_verity_required,
> >  };
> >  #endif /* CONFIG_FS_VERITY */
> >  
> > diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
> > index 2f75f06c784a..cd1299e1f92d 100644
> > --- a/fs/f2fs/super.c
> > +++ b/fs/f2fs/super.c
> > @@ -2257,10 +2257,16 @@ static struct page *f2fs_read_verity_metadata_page(struct inode *inode,
> >  	return read_mapping_page(inode->i_mapping, index, NULL);
> >  }
> >  
> > +static bool f2fs_verity_required(struct inode *inode, pgoff_t index)
> > +{
> > +	return index < (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +}
> > +
> >  static const struct fsverity_operations f2fs_verityops = {
> >  	.set_verity		= f2fs_set_verity,
> >  	.get_metadata_end	= f2fs_get_verity_metadata_end,
> >  	.read_metadata_page	= f2fs_read_verity_metadata_page,
> > +	.verity_required	= f2fs_verity_required,
> >  };
> >  #endif /* CONFIG_FS_VERITY */
> >  
> > diff --git a/fs/read_callbacks.c b/fs/read_callbacks.c
> > index b6d5b95e67d7..6dea54b0baa9 100644
> > --- a/fs/read_callbacks.c
> > +++ b/fs/read_callbacks.c
> > @@ -86,7 +86,9 @@ struct read_callbacks_ctx *get_read_callbacks_ctx(struct inode *inode,
> >  		read_callbacks_steps |= 1 << STEP_DECRYPT;
> >  #ifdef CONFIG_FS_VERITY
> >  	if (inode->i_verity_info != NULL &&
> > -		(index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
> > +		((inode->i_sb->s_vop->verity_required
> > +			&& inode->i_sb->s_vop->verity_required(inode, index))
> > +			|| (inode->i_sb->s_vop->verity_required == NULL)))
> 
> I think this is a bit easier to follow:
> 
> 		(inode->i_sb->s_vop->verity_required == NULL || 
> 			inode->i_sb->s_vop->verity_required(inode, index)))

Yes, you are right. I will implement the changes suggested by you.

-- 
chandan
