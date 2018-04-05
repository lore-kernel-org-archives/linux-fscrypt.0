Return-Path: <tytso@thunk.org>
Date: Thu, 5 Apr 2018 08:47:45 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed
 out blocks of a page
Message-ID: <20180405124745.GA20556@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <18565695.50sL0kI9m1@localhost.localdomain>
 <20180327194056.GD15608@thunk.org>
 <3388885.zk0F4oSU7q@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3388885.zk0F4oSU7q@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Apr 05, 2018 at 12:33:26PM +0530, Chandan Rajendra wrote:
> 
> I encountered a problem when refactoring the code to get fscrypt layer to
> encrypt all the blocks of a page by internally calling
> fscrypt_encrypt_block().
> 
> It is the filesystem which knows which subset of blocks mapped by a page that
> needs to be encrypted.

That's not quite correct.  All blocks in a file are either always
encrypted, or not.  So that's not really the problem.

> For example, ext4_bio_write_page() marks such blocks
> with "Async Write" flag and later in another pass, it encrypts and also adds
> these blocks to a bio.

The tricky bits with ext4_bio_write_page() all are in handling the
case where page_size > block_size.  In that case, where there are multiple
file system blocks covering a page, we need to know the on-disk
block numbers are for the blocks covering the page, and the encryption
is intertwined with the I/O submission path, which is file system
specific -- mainly because how the completion callback and the
parameters which need to be passed *into* the the callback function is
file system specific.

However, none of that is needed or relevant to the encryption
operation.  It's an accident of code development history that
fscrypt_encrypt_page was placed where it was.

That is, none of work done in the first pass (starting with the
comment "In the first loop we prepare and mark buffers to submit....")
is needed to be done before we call fscrypt_encrypt_page().  That call:

	data_page = fscrypt_encrypt_page(inode, page, PAGE_SIZE, 0,
					page->index, gfp_flags);

... could easily be moved to the beginning of ext4_bio_write_page().

I can do that to make the function easier to understand, but that
particular cleanup is merely cosmetic.  It doesn't what you would need
to do order to make fscrypt_encrypt_page() iterate over the page as it
calls fscrypt_encrypt_buffer().

Regards,

						- Ted
