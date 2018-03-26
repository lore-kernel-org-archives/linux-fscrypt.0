Return-Path: <tytso@thunk.org>
Date: Mon, 26 Mar 2018 02:05:33 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed
 out blocks of a page
Message-ID: <20180326060533.GC15608@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
 <20180212094347.22071-8-chandan@linux.vnet.ibm.com>
 <20180221011648.GD252219@gmail.com>
 <5846743.5xSkMaRmik@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5846743.5xSkMaRmik@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 21, 2018 at 03:27:24PM +0530, Chandan Rajendra wrote:
> 
> You are right. I will fix that up in the next iteration of the patchset.
>

Hi Chandan,

When were you planning on sending out the next iteration of the
patchset?  The merge window will be opening soon, and I wasn't sure if
I had missed a new iteration of your changes.ts

Also, it looks like when you renamed the *_page fscrypt functions to
*_blocks, on the write side, a bounce page is still being used for
each block.  So so an an architecture which has 64k pages, and we are
writing to a file sytem with 4k blocks, to write a 64k page, the
fscrypt layer will have to allocate 16 64k bounce pages to write a
single 64k page to an encrypted file.  Am I missing something?

Thanks,

					- Ted
