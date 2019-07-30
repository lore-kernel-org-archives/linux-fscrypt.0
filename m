Return-Path: <SRS0=V8cj=V3=mit.edu=tytso@kernel.org>
Date: Mon, 29 Jul 2019 20:39:12 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v7 15/16] ubifs: wire up new fscrypt ioctls
Message-ID: <20190730003912.GB16445@mit.edu>
References: <20190726224141.14044-1-ebiggers@kernel.org>
 <20190726224141.14044-16-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726224141.14044-16-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-api@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Satya Tangirala <satyat@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jul 26, 2019 at 03:41:40PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Wire up the new ioctls for adding and removing fscrypt keys to/from the
> filesystem, and the new ioctl for retrieving v2 encryption policies.
> 
> FS_IOC_REMOVE_ENCRYPTION_KEY also required making UBIFS use
> fscrypt_drop_inode().
> 
> For more details see Documentation/filesystems/fscrypt.rst and the
> fscrypt patches that added the implementation of these ioctls.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

					- Ted
