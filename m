Return-Path: <SRS0=R1kQ=WQ=aol.com=hsiangkao@kernel.org>
Date: Wed, 21 Aug 2019 01:07:43 +0800
From: Gao Xiang <hsiangkao@aol.com>
Subject: Re: [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Message-ID: <20190820170738.GA8402@hsiangkao-HP-ZHAN-66-Pro-G1>
References: <20190816061804.14840-1-chandan@linux.ibm.com>
 <20190816061804.14840-6-chandan@linux.ibm.com>
 <1652707.8YmLLlegLt@localhost.localdomain>
 <20190820051236.GE159846@architecture4>
 <20190820162510.GC10232@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820162510.GC10232@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Gao Xiang <gaoxiang25@huawei.com>, Chandan Rajendra <chandan@linux.ibm.com>, ebiggers@kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, chandanrmail@gmail.com, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ted,

On Tue, Aug 20, 2019 at 12:25:10PM -0400, Theodore Y. Ts'o wrote:
> On Tue, Aug 20, 2019 at 01:12:36PM +0800, Gao Xiang wrote:
> > Add a word, I have some little concern about post read procession order
> > a bit as I mentioned before, because I'd like to move common EROFS
> > decompression code out in the future as well for other fses to use
> > after we think it's mature enough.
> > 
> > It seems the current code mainly addresses eliminating duplicated code,
> > therefore I have no idea about that...
> 
> Actually, we should chat.  I was actually thinking about "borrowing"
> code from erofs to provide ext4-specific compression.  I was really
> impressed with the efficiency goals in the erofs design[1] when I
> reviewed the Usenix ATC paper, and as the saying goes, the best
> artists know how to steal from the best.  :-)
> 
> [1] https://www.usenix.org/conference/atc19/presentation/gao

I also guessed it's you reviewed our work as well from some written words :)
(even though it's analymous...) and I personally think there are some
useful stuffs in our EROFS effort.

> 
> My original specific thinking was to do code reuse by copy and paste,
> simply because it was simpler, and I have limited time to work on it.
> But if you are interested in making the erofs pipeline reusable by
> other file systems, and have the time to do the necessary code
> refactoring, I'd love to work with you on that.

Yes, I have interest in making the erofs pipeline for generic fses.
Now I'm still investigating sequential read on very high speed NVME
(like SAMSUNG 970pro, one thread seq read >3GB/s), it seems it still
has some optimization space.

And then I will do that work for generic fses as well... (but the first
thing I want to do is getting erofs out of staging, as Greg said [1])

Metadata should be designed for each fs like ext4, but maybe not flexible
and compacted as EROFS, therefore it could be some extra metadata
overhead than EROFS.

[1] https://lore.kernel.org/lkml/20190618064523.GA6015@kroah.com/

> 
> It should be noted that the f2fs developers have been working on their
> own compression scheme that was going to be f2fs-specific, unlike the
> file system generic approach used with fsverity and fscrypt.
> 
> My expectation is that we will need to modify the read pipeling code
> to support compression.  That's true whether we are looking at the
> existing file system-specific code used by ext4 and f2fs or in some
> combined work such as what Chandan has proposed.

I think either form is fine with me. :) But it seems that is some minor
which tree we will work on (Maybe Chandan's work will be merged then).

The first thing I need to do is to tidy up the code, and making it more
general, and then it will be very easy for fses to integrate :)

Thanks,
Gao Xiang


> 
> Cheers,
> 
> 					- Ted
