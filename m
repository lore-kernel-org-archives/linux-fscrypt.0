Return-Path: <SRS0=Zw4/=ST=mit.edu=tytso@kernel.org>
Date: Wed, 17 Apr 2019 09:53:19 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 2/5] fscrypt: fix race allowing rename() and link() of
 ciphertext dentries
Message-ID: <20190417135319.GB4686@mit.edu>
References: <20190320183913.12686-1-ebiggers@kernel.org>
 <20190320183913.12686-3-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320183913.12686-3-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-unionfs@vger.kernel.org, Sarthak Kukreti <sarthakkukreti@chromium.org>, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Mar 20, 2019 at 11:39:10AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Close some race conditions where fscrypt allowed rename() and link() on
> ciphertext dentries that had been looked up just prior to the key being
> concurrently added.  It's better to return -ENOKEY in this case.
> 
> This avoids doing the nonsensical thing of encrypting the names a second
> time when searching for the actual on-disk dir entries.  It also
> guarantees that DCACHE_ENCRYPTED_NAME dentries are never rename()d, so
> the dcache won't have support all possible combinations of moving
> DCACHE_ENCRYPTED_NAME around during __d_move().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, applied.

					- Ted
