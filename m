Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37214 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726211AbeLLCmZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 11 Dec 2018 21:42:25 -0500
Date: Tue, 11 Dec 2018 18:42:22 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 0/2] fs-verity: fix !CONFIG_FS_VERITY case
Message-ID: <20181212024221.GA722@sol.localdomain>
References: <20181211224651.112510-1-ebiggers@kernel.org>
 <20181212023018.GD4464@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212023018.GD4464@thunk.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ted,

On Tue, Dec 11, 2018 at 09:30:18PM -0500, Theodore Y. Ts'o wrote:
> On Tue, Dec 11, 2018 at 02:46:49PM -0800, Eric Biggers wrote:
> > Replace the two patches that broken the !CONFIG_FS_VERITY case with
> > fixed verisons.
> 
> I had fixed this by simply adding the conditional to the
> !CONFIG_FS_VERITY versions of fsverity_file_open() and
> fsverity_prepare_setattr(), before I found your patch in my inbox.  I
> think my version is simpler (and results in a fewer lines of code :-),
> so I think I'm going to stick with it.
> 
> The net diff of my changes from the previous version was:
> 
> diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
> index ea8c418bd7d5..6684bb72bbfc 100644
> --- a/include/linux/fsverity.h
> +++ b/include/linux/fsverity.h
> @@ -60,13 +60,13 @@ static inline int fsverity_ioctl_measure(struct file *filp, void __user *arg)
>  
>  static inline int fsverity_file_open(struct inode *inode, struct file *filp)
>  {
> -	return -EOPNOTSUPP;
> +	return IS_VERITY(inode) ? -ENOTSUPP : 0;
>  }
>  
>  static inline int fsverity_prepare_setattr(struct dentry *dentry,
>  					   struct iattr *attr)
>  {
> -	return -EOPNOTSUPP;
> +	return IS_VERITY(d_inode(dentry)) ? -ENOTSUPP : 0;
>  }
>  
>  static inline int fsverity_prepare_getattr(struct inode *inode)
> 
>        	   				   	 - Ted

Either works, but I slightly prefer my version since it minimizes the overhead
on non-verity files when the kconfig option is enabled: it's just an i_flags
check, rather than a function call plus an i_flags check.  The same approach is
used in the fscrypt hooks.  Also shouldn't it be EOPNOTSUPP, not ENOTSUPP?

- Eric
