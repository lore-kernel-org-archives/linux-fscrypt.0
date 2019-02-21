Return-Path: <SRS0=Hy9y=Q4=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [RFC PATCH 00/10] Consolidate Post read processing code
Date: Thu, 21 Feb 2019 18:59:48 +0530
In-Reply-To: <20190219211715.GA12177@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com> <20190219211715.GA12177@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2497291.Oz6HVsdQeZ@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, February 20, 2019 2:47:16 AM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Mon, Feb 18, 2019 at 03:34:23PM +0530, Chandan Rajendra wrote:
> > This patchset moves the "post read processing" code into a file of its
> > own and gets the generic do_mpage_readpge() to make use of the
> > functionality provided. With these changes in place, the patchset
> > changes Ext4 to use mpage_readpage[s] instead of its own custom
> > ext4_readpages() function. This is done to reduce duplicity of code
> > across filesystems. Based on the reviews provided for this patchset, I
> > will change F2FS to use mpage_readpage[s] and post the next version of
> > this patchset to linux-fsdevel mailing list.
> > 
> > The patchset also includes patches from previous postings i.e.
> > patches to replace per-filesystem encryption config options with a
> > single config option that affects all filesystems making use of
> > fscrypt code.
> > 
> > Chandan Rajendra (10):
> >   ext4: use IS_ENCRYPTED() to check encryption status
> >   f2fs: use IS_ENCRYPTED() to check encryption status
> >   fscrypt: remove filesystem specific build config option
> >   Consolidate "post read processing" into a new file
> >   fsverity: Add call back to decide if verity check has to be performed
> >   Introduce REQ_POST_READ_PROC bio flag
> >   fsverity: Add call back to determine readpage limit
> >   fsverity: Add call back to verify file holes
> >   fs/mpage.c: Integrate post read processing
> >   ext4: Wire up ext4_readpage[s] to use mpage_readpage[s]
> > 
> 
> Thanks for working on this!  This will also make it much easier to support
> block_size != PAGE_SIZE in ext4 encryption, right?  I think this is the best
> path forward, but I'll take a closer look at your new patches.
> 
> FYI regarding practical matters, merging fs-verity was delayed due to
> disagreement about the API.  See https://lwn.net/Articles/775872/.
> 
> We don't have to wait for fs-verity for your initial fscrypt changes, though:
> 
> 	ext4: use IS_ENCRYPTED() to check encryption status
> 	f2fs: use IS_ENCRYPTED() to check encryption status
> 	fscrypt: remove filesystem specific build config option
> 
> So, a couple weeks ago Ted and I already queued those three patches in
> fscrypt.git (https://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
> branch "master", though we plan to change the repo soon) for the upcoming merge
> window, based on upstream rather than fs-verity.  Are you fine with that?

Yes, the changes looks good. Thanks for queueing them up.

> 
> I also suggest adding linux-fsdevel to the Cc given the fs/*.c changes.

Yes, I will do that.

> 
> Thanks!
> 
> - Eric
> 
> 


-- 
chandan
