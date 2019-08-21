Return-Path: <SRS0=AKvp=WR=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V4 5/8] f2fs: Use read_callbacks for decrypting file data
Date: Wed, 21 Aug 2019 07:34:10 +0530
In-Reply-To: <20190820173116.GA58214@jaegeuk-macbookpro.roam.corp.google.com>
References: <20190816061804.14840-1-chandan@linux.ibm.com> <20190820163837.GD10232@mit.edu> <20190820173116.GA58214@jaegeuk-macbookpro.roam.corp.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2592782.4KYYplS4oi@localhost.localdomain>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, ebiggers@kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, chandanrmail@gmail.com, adilger.kernel@dilger.ca, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, August 20, 2019 11:01 PM Jaegeuk Kim wrote:
> Hi Chandan,
> 
> On 08/20, Theodore Y. Ts'o wrote:
> > On Tue, Aug 20, 2019 at 10:35:29AM +0530, Chandan Rajendra wrote:
> > > Looks like F2FS requires a lot more flexiblity than what can be offered by
> > > read callbacks i.e.
> > > 
> > > 1. F2FS wants to make use of its own workqueue for decryption, verity and
> > >    decompression.
> > > 2. F2FS' decompression code is not an FS independent entity like fscrypt and
> > >    fsverity. Hence they would need Filesystem specific callback functions to
> > >    be invoked from "read callbacks". 
> > > 
> > > Hence I would suggest that we should drop F2FS changes made in this
> > > patchset. Please let me know your thoughts on this.
> > 
> > That's probably the best way to go for now.  My one concern is that it
> > means that only ext4 will be using your framework.  I could imagine
> > that some people might argue that should just move the callback scheme
> > into ext4 code as opposed to leaving it in fscrypt --- at least until
> > we can find other file systems where we can show that it will be
> > useful for those other file systems.
> 
> I also have to raise a flag on this. Doesn't this patch series try to get rid
> of redundant work? What'd be the rationale, if it only supports ext4?

This patchset gets encryption working with subpage blocksize by making
relevant changes in the generic code (i.e. do_mpage_readpage() and
block_read_full_page()) and removing duplicate code from ext4
(i.e. ext4_readpage() and friends). Without these changes the only way to get
subpage blocksize support was to add more duplicate code into Ext4 i.e. import
a copy of block_read_full_page() into Ext4 and make necessary edits to support
encryption.

So this patchset actually does help in removing exiting duplicate code in Ext4
and also prevents addition of more such code.

> 
> How about generalizing the framework to support generic_post_read and per-fs
> post_read for fscrypt/fsverity/... selectively?

Quoting what I had said earlier,
> > > 1. F2FS wants to make use of its own workqueue for decryption, verity and
> > >    decompression.
> > > 2. F2FS' decompression code is not an FS independent entity like fscrypt and
> > >    fsverity. Hence they would need Filesystem specific callback functions to
> > >    be invoked from "read callbacks". 

I am not sure if read callbacks can be made flexible enough to support the
above use cases. fscrypt and fsverity already provide workqueues and any new
post processing code added should follow the same convention. I see
that F2FS use case is special since,
1. It uses its own workqueues.
2. Decompression code inside F2FS isn't written as an FS independent subsystem
   like how fscrypt and fsverity are implemented.

To summarize, I believe the users of read callbacks should follow the
conventions set by fscrypt/fsverity and new post processing code that needs to
be plugged into read callbacks should provide APIs similar to
fscrypt/fsverity. Otherwise the state machine logic implemented by read
callbacks will get complex/convoluted.

> 
> Thanks,
> 
> > 
> > (Perhaps a useful experiment would be to have someone implement patches
> > to support fscrypt and fsverity in ext2 --- the patch might or might
> > not be accepted for upstream inclusion, but it would be useful to
> > demonstrate how easy it is to add fscrypt and fsverity.)
> > 
> > The other thing to consider is that there has been some discussion
> > about adding generalized support for I/O submission to the iomap
> > library.  It might be that if that work is accepted, support for
> > fscrypt and fsverity would be a requirement for ext4 to use that
> > portion of iomap's functionality.  So in that eventuality, it might be
> > that we'll want to move your read callbacks code into iomap, or we'll
> > need to rework the read callbacks code so it can work with iomap.
> > 
> > But this is all work for the future.  I'm a firm believe that the
> > perfect should not be the enemy of the good, and that none of this
> > should be a fundamental obstacle in having your code upstream.
> > 
> > Cheers,
> > 
> > 					- Ted
> > 
> 

-- 
chandan
