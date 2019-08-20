Return-Path: <SRS0=skfi=WQ=mit.edu=tytso@kernel.org>
Date: Tue, 20 Aug 2019 12:25:10 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Message-ID: <20190820162510.GC10232@mit.edu>
References: <20190816061804.14840-1-chandan@linux.ibm.com>
 <20190816061804.14840-6-chandan@linux.ibm.com>
 <1652707.8YmLLlegLt@localhost.localdomain>
 <20190820051236.GE159846@architecture4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820051236.GE159846@architecture4>
To: Gao Xiang <gaoxiang25@huawei.com>
Cc: Chandan Rajendra <chandan@linux.ibm.com>, ebiggers@kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, chandanrmail@gmail.com, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 20, 2019 at 01:12:36PM +0800, Gao Xiang wrote:
> Add a word, I have some little concern about post read procession order
> a bit as I mentioned before, because I'd like to move common EROFS
> decompression code out in the future as well for other fses to use
> after we think it's mature enough.
> 
> It seems the current code mainly addresses eliminating duplicated code,
> therefore I have no idea about that...

Actually, we should chat.  I was actually thinking about "borrowing"
code from erofs to provide ext4-specific compression.  I was really
impressed with the efficiency goals in the erofs design[1] when I
reviewed the Usenix ATC paper, and as the saying goes, the best
artists know how to steal from the best.  :-)

[1] https://www.usenix.org/conference/atc19/presentation/gao

My original specific thinking was to do code reuse by copy and paste,
simply because it was simpler, and I have limited time to work on it.
But if you are interested in making the erofs pipeline reusable by
other file systems, and have the time to do the necessary code
refactoring, I'd love to work with you on that.

It should be noted that the f2fs developers have been working on their
own compression scheme that was going to be f2fs-specific, unlike the
file system generic approach used with fsverity and fscrypt.

My expectation is that we will need to modify the read pipeling code
to support compression.  That's true whether we are looking at the
existing file system-specific code used by ext4 and f2fs or in some
combined work such as what Chandan has proposed.

Cheers,

					- Ted
