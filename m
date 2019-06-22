Return-Path: <jaegeuk@kernel.org>
Date: Sat, 22 Jun 2019 15:28:58 -0700
From: Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH v5 08/16] fs-verity: add the hook for file ->setattr()
Message-ID: <20190622222858.GH19686@jaegeuk-macbookpro.roam.corp.google.com>
References: <20190620205043.64350-1-ebiggers@kernel.org>
 <20190620205043.64350-9-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620205043.64350-9-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, linux-integrity@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, "Darrick J . Wong" <darrick.wong@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On 06/20, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a function fsverity_prepare_setattr() which filesystems that support
> fs-verity must call to deny truncates of verity files.
> 
> Reviewed-by: Theodore Ts'o <tytso@mit.edu>

Reviewed-by: Jaegeuk Kim <jaegeuk@kernel.org>

> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/verity/open.c         | 21 +++++++++++++++++++++
>  include/linux/fsverity.h |  7 +++++++
>  2 files changed, 28 insertions(+)
> 
> diff --git a/fs/verity/open.c b/fs/verity/open.c
> index 3a3bb27e23f5e3..21ae0ef254a695 100644
> --- a/fs/verity/open.c
> +++ b/fs/verity/open.c
> @@ -296,6 +296,27 @@ int fsverity_file_open(struct inode *inode, struct file *filp)
>  }
>  EXPORT_SYMBOL_GPL(fsverity_file_open);
>  
> +/**
> + * fsverity_prepare_setattr - prepare to change a verity inode's attributes
> + * @dentry: dentry through which the inode is being changed
> + * @attr: attributes to change
> + *
> + * Verity files are immutable, so deny truncates.  This isn't covered by the
> + * open-time check because sys_truncate() takes a path, not a file descriptor.
> + *
> + * Return: 0 on success, -errno on failure
> + */
> +int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr)
> +{
> +	if (IS_VERITY(d_inode(dentry)) && (attr->ia_valid & ATTR_SIZE)) {
> +		pr_debug("Denying truncate of verity file (ino %lu)\n",
> +			 d_inode(dentry)->i_ino);
> +		return -EPERM;
> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(fsverity_prepare_setattr);
> +
>  /**
>   * fsverity_cleanup_inode - free the inode's verity info, if present
>   *
> diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
> index 1372c236c8770c..cbcc358d073652 100644
> --- a/include/linux/fsverity.h
> +++ b/include/linux/fsverity.h
> @@ -46,6 +46,7 @@ static inline struct fsverity_info *fsverity_get_info(const struct inode *inode)
>  /* open.c */
>  
>  extern int fsverity_file_open(struct inode *inode, struct file *filp);
> +extern int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr);
>  extern void fsverity_cleanup_inode(struct inode *inode);
>  
>  #else /* !CONFIG_FS_VERITY */
> @@ -62,6 +63,12 @@ static inline int fsverity_file_open(struct inode *inode, struct file *filp)
>  	return IS_VERITY(inode) ? -EOPNOTSUPP : 0;
>  }
>  
> +static inline int fsverity_prepare_setattr(struct dentry *dentry,
> +					   struct iattr *attr)
> +{
> +	return IS_VERITY(d_inode(dentry)) ? -EOPNOTSUPP : 0;
> +}
> +
>  static inline void fsverity_cleanup_inode(struct inode *inode)
>  {
>  }
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
