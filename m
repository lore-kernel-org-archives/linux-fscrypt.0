Return-Path: <SRS0=Zw4/=ST=mit.edu=tytso@kernel.org>
Date: Wed, 17 Apr 2019 10:07:01 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 4/5] fscrypt: only set dentry_operations on ciphertext
 dentries
Message-ID: <20190417140701.GD4686@mit.edu>
References: <20190320183913.12686-1-ebiggers@kernel.org>
 <20190320183913.12686-5-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320183913.12686-5-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-unionfs@vger.kernel.org, Sarthak Kukreti <sarthakkukreti@chromium.org>, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Mar 20, 2019 at 11:39:12AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Plaintext dentries are always valid, so only set fscrypt_d_ops on
> ciphertext dentries.
> 
> Besides marginally improved performance, this allows overlayfs to use an
> fscrypt-encrypted upperdir, provided that all the following are true:
> 
>     (1) The fscrypt encryption key is placed in the keyring before
> 	mounting overlayfs, and remains while the overlayfs is mounted.
> 
>     (2) The overlayfs workdir uses the same encryption policy.
> 
>     (3) No dentries for the ciphertext names of subdirectories have been
> 	created in the upperdir or workdir yet.  (Since otherwise
> 	d_splice_alias() will reuse the old dentry with ->d_op set.)
> 
> One potential use case is using an ephemeral encryption key to encrypt
> all files created or changed by a container, so that they can be
> securely erased ("crypto-shredded") after the container stops.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
