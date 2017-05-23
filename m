Return-Path: <jack@suse.cz>
Date: Tue, 23 May 2017 10:24:10 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] ext4: remove redundant check for encrypted file on dio
 write path
Message-ID: <20170523082410.GD1230@quack2.suse.cz>
References: <20170523005316.18996-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523005316.18996-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon 22-05-17 17:53:16, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Currently we don't allow direct I/O on encrypted regular files, so in
> such cases we return 0 early in ext4_direct_IO().  There was also an
> additional BUG_ON() check in ext4_direct_IO_write(), but it can never be
> hit because of the earlier check for the exact same condition in
> ext4_direct_IO().  There was also no matching check on the read path,
> which made the write path specific check seem very ad-hoc.
> 
> Just remove the unnecessary BUG_ON().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Yeah, the check is rather before the BUG_ON so I guess that there's no big
point in the BUG_ON. When looking at this code I have one question though:

So when you mount the filesystem with 'dioread_nolock', do overwriting
direct write to the file, and just after we do inode_unlock() in
ext4_direct_IO_write() someone calls EXT4_IOC_SET_ENCRYPTION_POLICY ioctl
on the file, the BUG_ON could actually trigger. So I think you need 
to wait for outstanding direct IO for the file when setting encryption
policy. Likely in ext4_set_context() or maybe in the generic fscrypt code
(you need to wait after acquiring inode_lock), I'm not sure how other
filesystems using fscrypt handle this and whether it would make more sense
in the generic code or in ext4 specific one.

								Honza

> ---
>  fs/ext4/inode.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 1bd0bfa547f6..7c6e715b4d2e 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3629,9 +3629,6 @@ static ssize_t ext4_direct_IO_write(struct kiocb *iocb, struct iov_iter *iter)
>  		get_block_func = ext4_dio_get_block_unwritten_async;
>  		dio_flags = DIO_LOCKING;
>  	}
> -#ifdef CONFIG_EXT4_FS_ENCRYPTION
> -	BUG_ON(ext4_encrypted_inode(inode) && S_ISREG(inode->i_mode));
> -#endif
>  	ret = __blockdev_direct_IO(iocb, inode, inode->i_sb->s_bdev, iter,
>  				   get_block_func, ext4_end_io_dio, NULL,
>  				   dio_flags);
> -- 
> 2.13.0.303.g4ebf302169-goog
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
