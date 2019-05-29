Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37154 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726121AbfE2Uuc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 29 May 2019 16:50:32 -0400
Date: Wed, 29 May 2019 13:50:29 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH V3] fscrypt: don't set policy for a dead directory
Message-ID: <20190529205028.GC141639@gmail.com>
References: <1558490573-21562-1-git-send-email-hongjiefang@asrmicro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1558490573-21562-1-git-send-email-hongjiefang@asrmicro.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Hongjie Fang <hongjiefang@asrmicro.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, May 22, 2019 at 10:02:53AM +0800, Hongjie Fang wrote:
> the directory maybe has been removed when enter fscrypt_ioctl_set_policy().
> if so, the empty_dir() check will return error for ext4 file system.
> 
> ext4_rmdir() sets i_size = 0, then ext4_empty_dir() reports an error
> because 'inode->i_size < EXT4_DIR_REC_LEN(1) + EXT4_DIR_REC_LEN(2)'.
> if the fs is mounted with errors=panic, it will trigger a panic issue.
> 
> add the check IS_DEADDIR() to fix this problem.
> 
> Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> Cc: <stable@vger.kernel.org> # v4.1+
> Signed-off-by: Hongjie Fang <hongjiefang@asrmicro.com>
> ---
>  fs/crypto/policy.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index d536889..4941fe8 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -81,6 +81,8 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  	if (ret == -ENODATA) {
>  		if (!S_ISDIR(inode->i_mode))
>  			ret = -ENOTDIR;
> +		else if (IS_DEADDIR(inode))
> +			ret = -ENOENT;
>  		else if (!inode->i_sb->s_cop->empty_dir(inode))
>  			ret = -ENOTEMPTY;
>  		else
> -- 
> 1.9.1
> 

Applied to fscrypt.git for v5.3.

- Eric
