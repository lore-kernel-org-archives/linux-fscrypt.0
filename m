Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44808 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727456AbeK0LbM (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 27 Nov 2018 06:31:12 -0500
Date: Mon, 26 Nov 2018 16:35:11 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 1/7] ext4: use IS_ENCRYPTED() to check encryption status
Message-ID: <20181127003510.GD11663@gmail.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-2-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119052324.31456-2-chandan@linux.vnet.ibm.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Mon, Nov 19, 2018 at 10:53:18AM +0530, Chandan Rajendra wrote:
> @@ -4724,7 +4724,7 @@ static bool ext4_should_use_dax(struct inode *inode)
>  		return false;
>  	if (ext4_has_inline_data(inode))
>  		return false;
> -	if (ext4_encrypted_inode(inode))
> +	if (IS_ENCRYPTED(inode))
>  		return false;
>  	if (ext4_verity_inode(inode))
>  		return false;

I think this part is wrong.  See how ext4_should_use_dax() is called from
ext4_set_inode_flags(), from ext4_set_context().  In this case,
ext4_set_inode_flags() should set S_ENCRYPTED and clear S_DAX.  However, you've
changed ext4_should_use_dax() to check S_ENCRYPTED instead of EXT4_ENCRYPT_FL;
but S_ENCRYPTED isn't set until later in ext4_set_inode_flags(), so S_DAX won't
be cleared anymore.

So I think you need to use ext4_test_inode_flag() here instead.

Similarly for the verity check.

- Eric
