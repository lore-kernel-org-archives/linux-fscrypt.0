Return-Path: <ebiggers3@gmail.com>
Date: Wed, 14 Jun 2017 00:03:57 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Message-ID: <20170614070357.GB605@zzz>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
 <20170614065210.GA10411@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614065210.GA10411@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Christoph,

On Tue, Jun 13, 2017 at 11:52:10PM -0700, Christoph Hellwig wrote:
> On Tue, Jun 13, 2017 at 04:47:53PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently, filesystems allow truncate(2) on an encrypted file without
> > the encryption key.  However, it's impossible to correctly handle the
> > case where the size being truncated to is not a multiple of the
> > filesystem block size, because that would require decrypting the final
> > block, zeroing the part beyond i_size, then encrypting the block.
> > 
> > As other modifications to encrypted file contents are prohibited without
> > the key, just prohibit truncate(2) as well, making it fail with ENOKEY.
> 
> What about hole punches?  What about fallocate which just adds zeroes
> but still changes the content.  What about insert or collapse range?

None of those are allowed because fallocate() requires a file descriptor, and
open() fails with ENOKEY if the encryption key is not available.  truncate() is
different because it takes a path, not a file descriptor.

Eric
