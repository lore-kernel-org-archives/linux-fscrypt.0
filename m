Return-Path: <SRS0=RJsC=SS=mit.edu=tytso@kernel.org>
Date: Tue, 16 Apr 2019 19:08:40 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 1/5] fscrypt: clean up and improve dentry revalidation
Message-ID: <20190416230840.GB14623@mit.edu>
References: <20190320183913.12686-1-ebiggers@kernel.org>
 <20190320183913.12686-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320183913.12686-2-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-unionfs@vger.kernel.org, Sarthak Kukreti <sarthakkukreti@chromium.org>, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Mar 20, 2019 at 11:39:09AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Make various improvements to fscrypt dentry revalidation:
> 
> - Don't try to handle the case where the per-directory key is removed,
>   as this can't happen without the inode (and dentries) being evicted.
> 
> - Flag ciphertext dentries rather than plaintext dentries, since it's
>   ciphertext dentries that need the special handling.
> 
> - Avoid doing unnecessary work for non-ciphertext dentries.
> 
> - When revalidating ciphertext dentries, try to set up the directory's
>   i_crypt_info to make sure the key is really still absent, rather than
>   invalidating all negative dentries as the previous code did.  An old
>   comment suggested we can't do this for locking reasons, but AFAICT
>   this comment was outdated and it actually works fine.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
