Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V2 07/11] fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
Date: Mon, 26 Mar 2018 13:52:54 +0530
In-Reply-To: <20180326060533.GC15608@thunk.org>
References: <20180212094347.22071-1-chandan@linux.vnet.ibm.com> <5846743.5xSkMaRmik@localhost.localdomain> <20180326060533.GC15608@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <18565695.50sL0kI9m1@localhost.localdomain>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Monday, March 26, 2018 11:35:33 AM IST Theodore Y. Ts'o wrote:
> On Wed, Feb 21, 2018 at 03:27:24PM +0530, Chandan Rajendra wrote:
> > 
> > You are right. I will fix that up in the next iteration of the patchset.
> >
> 
> Hi Chandan,
> 
> When were you planning on sending out the next iteration of the
> patchset?  The merge window will be opening soon, and I wasn't sure if
> I had missed a new iteration of your changes.ts
> 

Hi Ted,

I am sorry about the delay. I got pulled into various other things at
workplace. I have not posted V3 yet. I am still working on fixing 
test failures. I don't think the patches will be ready by the next
merge window.

> Also, it looks like when you renamed the *_page fscrypt functions to
> *_blocks, on the write side, a bounce page is still being used for
> each block.  So so an an architecture which has 64k pages, and we are
> writing to a file sytem with 4k blocks, to write a 64k page, the
> fscrypt layer will have to allocate 16 64k bounce pages to write a
> single 64k page to an encrypted file.  Am I missing something?
> 

ext4_bio_write_page() invokes the new fscrypt_encrypt_block() function for
each block of the page that has been marked with "Async write". For all blocks
of the page that needs to be written to the disk, we pass the same bounce page
as an argument to fscrypt_encrypt_block().

-- 
chandan
