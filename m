Return-Path: <tytso@thunk.org>
Date: Tue, 27 Mar 2018 15:40:56 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed
 out blocks of a page
Message-ID: <20180327194056.GD15608@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <5846743.5xSkMaRmik@localhost.localdomain>
 <20180326060533.GC15608@thunk.org>
 <18565695.50sL0kI9m1@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18565695.50sL0kI9m1@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Mar 26, 2018 at 01:52:54PM +0530, Chandan Rajendra wrote:
> > Also, it looks like when you renamed the *_page fscrypt functions to
> > *_blocks, on the write side, a bounce page is still being used for
> > each block.  So so an an architecture which has 64k pages, and we are
> > writing to a file sytem with 4k blocks, to write a 64k page, the
> > fscrypt layer will have to allocate 16 64k bounce pages to write a
> > single 64k page to an encrypted file.  Am I missing something?
> > 
> 
> ext4_bio_write_page() invokes the new fscrypt_encrypt_block() function for
> each block of the page that has been marked with "Async write". For all blocks
> of the page that needs to be written to the disk, we pass the same bounce page
> as an argument to fscrypt_encrypt_block().

Thanks for the explanation.  I do wonder if the proper thing to export
from the fscrypt layer is fscrypt_encrypt_page(), since for all file
systems, the only thing which really makes sense is to read and write
a full page at a time, since we cache things at the page cache a full
page a time.  So instead of teaching each file system how to use
fscrypt_{encrypt,decrypt}_block, maybe push that into the fscrypt
layer, and implement a new fscrypt_encrypt_page() which calls
fs_encrypt_block()?

							- Ted
