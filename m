Return-Path: <prvs=062504bbde=chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
Date: Wed, 28 Mar 2018 19:06:12 +0530
In-Reply-To: <20180327194056.GD15608@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com> <18565695.50sL0kI9m1@localhost.localdomain> <20180327194056.GD15608@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3725467.1vlXAT8yQV@localhost.localdomain>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, March 28, 2018 1:10:56 AM IST Theodore Y. Ts'o wrote:
> On Mon, Mar 26, 2018 at 01:52:54PM +0530, Chandan Rajendra wrote:
> > > Also, it looks like when you renamed the *_page fscrypt functions to
> > > *_blocks, on the write side, a bounce page is still being used for
> > > each block.  So so an an architecture which has 64k pages, and we are
> > > writing to a file sytem with 4k blocks, to write a 64k page, the
> > > fscrypt layer will have to allocate 16 64k bounce pages to write a
> > > single 64k page to an encrypted file.  Am I missing something?
> > > 
> > 
> > ext4_bio_write_page() invokes the new fscrypt_encrypt_block() function for
> > each block of the page that has been marked with "Async write". For all blocks
> > of the page that needs to be written to the disk, we pass the same bounce page
> > as an argument to fscrypt_encrypt_block().
> 
> Thanks for the explanation.  I do wonder if the proper thing to export
> from the fscrypt layer is fscrypt_encrypt_page(), since for all file
> systems, the only thing which really makes sense is to read and write
> a full page at a time, since we cache things at the page cache a full
> page a time.  So instead of teaching each file system how to use
> fscrypt_{encrypt,decrypt}_block, maybe push that into the fscrypt
> layer, and implement a new fscrypt_encrypt_page() which calls
> fs_encrypt_block()?

I don't see any problems in doing that. I will implement that. Thanks for the 
suggestion.

-- 
chandan
