Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36492 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726438AbfEGPzf (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 May 2019 11:55:35 -0400
Date: Tue, 7 May 2019 08:55:32 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: don't set policy for a dead directory
Message-ID: <20190507155531.GA1399@sol.localdomain>
References: <1557204108-29048-1-git-send-email-hongjiefang@asrmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557204108-29048-1-git-send-email-hongjiefang@asrmicro.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: hongjiefang <hongjiefang@asrmicro.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On Tue, May 07, 2019 at 12:41:48PM +0800, hongjiefang wrote:
> if the directory had been removed, should not set policy for it.
> 
> Signed-off-by: hongjiefang <hongjiefang@asrmicro.com>

Can you explain the motivation for this change?  It makes some sense, but I
don't see why it's really needed.  If you look at all the other IS_DEADDIR()
checks in the kernel, they're not for operations on the directory inode itself,
but rather for creating/finding/listing entries in the directory.  I think
FS_IOC_SET_ENCRYPTION_POLICY is more like the former (though it does have to
check whether the directory is empty).

> ---
>  fs/crypto/policy.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index bd7eaf9..82900a4 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -77,6 +77,12 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  
>  	inode_lock(inode);
>  
> +	/* don't set policy for a dead directory */
> +	if (IS_DEADDIR(inode)) {
> +		ret = -ENOENT;
> +		goto deaddir_out;
> +	}
> +
>  	ret = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
>  	if (ret == -ENODATA) {
>  		if (!S_ISDIR(inode->i_mode))
> @@ -96,6 +102,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  		ret = -EEXIST;
>  	}
>  
> +deaddir_out:
>  	inode_unlock(inode);

Call this label 'out_unlock' instead?

>  
>  	mnt_drop_write_file(filp);
> -- 
> 1.9.1
> 

Thanks,

- Eric
