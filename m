Return-Path: <SRS0=c04+=WI=mit.edu=tytso@kernel.org>
Date: Mon, 12 Aug 2019 18:38:22 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v8 06/20] fscrypt: refactor key setup code in preparation
 for v2 policies
Message-ID: <20190812223822.GE28705@mit.edu>
References: <20190805162521.90882-1-ebiggers@kernel.org>
 <20190805162521.90882-7-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805162521.90882-7-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, keyrings@vger.kernel.org, linux-api@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 05, 2019 at 09:25:07AM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Do some more refactoring of the key setup code, in preparation for
> introducing a filesystem-level keyring and v2 encryption policies:
> 
> - Now that ci_inode exists, don't pass around the inode unnecessarily.
> 
> - Define a function setup_file_encryption_key() which handles the crypto
>   key setup given an under-construction fscrypt_info.  Don't pass the
>   fscrypt_context, since everything is in the fscrypt_info.
>   [This will be extended for v2 policies and the fs-level keyring.]
> 
> - Define a function fscrypt_set_derived_key() which sets the per-file
>   key, without depending on anything specific to v1 policies.
>   [This will also be used for v2 policies.]
> 
> - Define a function fscrypt_setup_v1_file_key() which takes the raw
>   master key, thus separating finding the key from using it.
>   [This will also be used if the key is found in the fs-level keyring.]
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Looks good, you can add:

Reviewed-by: Theodore Ts'o <tytso@mit.edu>

						- Ted
