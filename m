Return-Path: <SRS0=k/KS=Q5=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [RFC PATCH 00/10] Consolidate Post read processing code
Date: Fri, 22 Feb 2019 09:59:31 +0530
In-Reply-To: <20190221183827.GA140206@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com> <2420837.hecoV8S9Z6@localhost.localdomain> <20190221183827.GA140206@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2245787.mQPMR5rap9@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Friday, February 22, 2019 12:08:28 AM IST Eric Biggers wrote:
> On Thu, Feb 21, 2019 at 07:02:03PM +0530, Chandan Rajendra wrote:
> > On Wednesday, February 20, 2019 6:11:07 AM IST Eric Biggers wrote:
> > > On Mon, Feb 18, 2019 at 03:34:23PM +0530, Chandan Rajendra wrote:
> > > > Based on the reviews provided for this patchset, I
> > > > will change F2FS to use mpage_readpage[s] and post the next version of
> > > > this patchset to linux-fsdevel mailing list.
> > > 
> > > Is that really possible?  F2FS has other functionality in its ->readpages(),
> > > such as support for filesystems that use multiple block devices.
> > > 
> > 
> > Hmm. I didn't know that. Thanks for pointing that out. I will read up that
> > code and if it isn't really possible to get F2FS to use mpage_readpage[s](),
> > then I would limit the patchset to Ext4.
> > 
> 
> But we can make F2FS use the shared bio_post_read functions even if it can't use
> mpage_readpage[s](), right?
>

Yes, that should be possible. I will include those changes in the next version
of the patchset.

-- 
chandan
