Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 19:52:54 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Message-ID: <20170623235254.l5wyukjiy2mdms3m@thunk.org>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613234755.111167-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 13, 2017 at 04:47:53PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Currently, filesystems allow truncate(2) on an encrypted file without
> the encryption key.  However, it's impossible to correctly handle the
> case where the size being truncated to is not a multiple of the
> filesystem block size, because that would require decrypting the final
> block, zeroing the part beyond i_size, then encrypting the block.
> 
> As other modifications to encrypted file contents are prohibited without
> the key, just prohibit truncate(2) as well, making it fail with ENOKEY.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Thanks, applied.

					- Ted
