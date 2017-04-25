Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36041 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946907AbdDYRyq (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 25 Apr 2017 13:54:46 -0400
Received: by mail-pf0-f173.google.com with SMTP id 194so30059313pfv.3
        for <linux-fscrypt@vger.kernel.org>; Tue, 25 Apr 2017 10:54:46 -0700 (PDT)
Date: Tue, 25 Apr 2017 10:54:42 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH] ubifs: Return -ENOKEY from rename if encryption keys are
 missing
Message-ID: <20170425175442.GB41477@google.com>
References: <1493070381-20075-1-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493070381-20075-1-git-send-email-richard@nod.at>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Cc: linux-mtd@lists.infradead.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, david@sigma-star.at, David Oberhollenzer <david.oberhollenzer@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David and Richard,

On Mon, Apr 24, 2017 at 11:46:21PM +0200, Richard Weinberger wrote:
> From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
> 
> If either source or destination directory is encrypted and the
> encryption key is unknown, make sure we return -ENOKEY instead
> of -EPERM, similar to how this case is handled in ext4.
> 
> Signed-off-by: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
> Signed-off-by: Richard Weinberger <richard@nod.at>
> 
> diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
> index ff77a0aa2f2b..c342f23581d2 100644
> --- a/fs/ubifs/dir.c
> +++ b/fs/ubifs/dir.c
> @@ -1340,6 +1340,12 @@ static int do_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	if (unlink)
>  		ubifs_assert(inode_is_locked(new_inode));
>  
> +	if ((ubifs_crypt_is_encrypted(old_dir) &&
> +	     !fscrypt_has_encryption_key(old_dir)) ||
> +	    (ubifs_crypt_is_encrypted(new_dir) &&
> +	     !fscrypt_has_encryption_key(new_dir)))
> +		return -ENOKEY;
> +
>  	if (old_dir != new_dir) {
>  		if (ubifs_crypt_is_encrypted(new_dir) &&
>  		    !fscrypt_has_permitted_context(new_dir, old_inode))
> @@ -1564,6 +1570,12 @@ static int ubifs_xrename(struct inode *old_dir, struct dentry *old_dentry,
>  
>  	ubifs_assert(fst_inode && snd_inode);
>  
> +	if ((ubifs_crypt_is_encrypted(old_dir) &&
> +	     !fscrypt_has_encryption_key(old_dir)) ||
> +	    (ubifs_crypt_is_encrypted(new_dir) &&
> +	     !fscrypt_has_encryption_key(new_dir)))
> +		return -ENOKEY;
> +
>  	if ((ubifs_crypt_is_encrypted(old_dir) ||
>  	    ubifs_crypt_is_encrypted(new_dir)) &&
>  	    (old_dir != new_dir) &&
> -- 

Did you test that this change actually does anything?  Unlike ext4 and f2fs,
ubifs calls fscrypt_setup_filename() from its rename methods rather than through
a helper function ${FS}_find_entry().  Therefore it's able to pass in lookup=0,
which means that the key is required.  So it should already be failing with
ENOKEY.  You can verify this by running xfstests generic/419.

- Eric
