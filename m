Return-Path: <SRS0=Zw4/=ST=mit.edu=tytso@kernel.org>
Date: Wed, 17 Apr 2019 09:50:15 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 1/5] fscrypt: clean up and improve dentry revalidation
Message-ID: <20190417135015.GA4686@mit.edu>
References: <20190320183913.12686-1-ebiggers@kernel.org>
 <20190320183913.12686-2-ebiggers@kernel.org>
 <20190416230840.GB14623@mit.edu>
 <20190417001041.GA18090@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417001041.GA18090@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-unionfs@vger.kernel.org, Sarthak Kukreti <sarthakkukreti@chromium.org>, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Apr 16, 2019 at 05:10:42PM -0700, Eric Biggers wrote:
> 
> Hi Ted, I assumed you resolved the conflict with "fscrypt: use READ_ONCE() to
> access ->i_crypt_info"?  The code in fscrypt_d_revalidate() should be:
> 
>         dir = dget_parent(dentry);
>         err = fscrypt_get_encryption_info(d_inode(dir));
>         valid = !fscrypt_has_encryption_key(d_inode(dir));
>         dput(dir);

Yes, I did notice the patch conflict.  Thanks for confirming the
correct resolution!

						- Ted
