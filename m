Return-Path: <SRS0=TTB/=VZ=mit.edu=tytso@kernel.org>
Date: Sun, 28 Jul 2019 11:09:27 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 04/16] fscrypt: add ->ci_inode to fscrypt_info
Message-ID: <20190728150927.GD6088@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-5-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726224141.14044-5-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 26, 2019 at 03:41:29PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add an inode back-pointer to 'struct fscrypt_info', such that
> inode->i_crypt_info->ci_inode == inode.
> 
> This will be useful for:
> 
> 1. Evicting the inodes when a fscrypt key is removed, since we'll track
>    the inodes using a given key by linking their fscrypt_infos together,
>    rather than the inodes directly.  This avoids bloating 'struct inode'
>    with a new list_head.
> 
> 2. Simplifying the per-file key setup, since the inode pointer won't
>    have to be passed around everywhere just in case something goes wrong
>    and it's needed for fscrypt_warn().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, feel free to add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>
