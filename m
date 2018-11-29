Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:56186 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725873AbeK3GLk (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Nov 2018 01:11:40 -0500
Date: Thu, 29 Nov 2018 11:05:13 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [f2fs-dev] [PATCH 2/7] f2fs: use IS_ENCRYPTED() to check
 encryption status
Message-ID: <20181129190512.GB168705@gmail.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181126040038.GD7904@thunk.org>
 <20181126173435.GA22888@thunk.org>
 <2911123.OYxvaggYeN@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2911123.OYxvaggYeN@localhost.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Thu, Nov 29, 2018 at 04:08:31PM +0530, Chandan Rajendra wrote:
> On Monday, November 26, 2018 11:04:35 PM IST Theodore Y. Ts'o wrote:
> > On Sun, Nov 25, 2018 at 11:00:38PM -0500, Theodore Y. Ts'o wrote:
> > > 
> > > It might be that the simplest way to solve things is to merge the f2fs
> > > dev branch up to 79c66e75720c.  This will have the net effect of
> > > including the five patches listed above onto the fscrypt git tree.  So
> > > long you don't plan to rebase or otherwise change these five patches,
> > > it should avoid any merge conflicts.
> > 
> > I've set up a git branch which has the f2fs dev branch, 4.20-rc4, the
> > fsverity patches, and part of Chandan's patch series here:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git test-working
> > 
> > There is a minor conflict when I did a trial merge with f2fs.git's dev
> > branch, but it's pretty obvious to how to resolve it.
> > 
> > Jaegeuk, Eric, Chandan, please take a look and let me know what you
> > think.
> 
> Ted,
> 
> I have addressed the review comments provided by Eric. Hence three out of
> the four patches in the test-working branch have new changes. I also got
> UBIFS to use CONFIG_FS_ENCRYPTION instead of the per-filesystem config
> symbol.
> 
> I am currently executing fstests to verify the changes.
> 
> 
> Eric,
> 
> When executing generic/900, I noticed that sometimes xfs_io would get stuck
> for an indefinite period. /proc/<pid of xfs_io>/stack showed that the task was
> stuck in tty_read() inside the kernel. The following change fixed it,
> 
> diff --git a/tests/generic/900 b/tests/generic/900
> index 290889ce..0831eed4 100755
> --- a/tests/generic/900
> +++ b/tests/generic/900
> @@ -83,7 +83,7 @@ _fsv_create_enable_file $fsv_file >> $seqres.full
>  echo "* reading"
>  $XFS_IO_PROG -r $fsv_file -c ''
>  echo "* xfs_io writing, should be O_RDWR"
> -$XFS_IO_PROG $fsv_file |& _filter_scratch
> +$XFS_IO_PROG -c '' $fsv_file 2>&1 | _filter_scratch
>  echo "* bash >>, should be O_APPEND"
>  bash -c "echo >> $fsv_file" |& _filter_scratch
>  echo "* bash >, should be O_WRONLY|O_CREAT|O_TRUNC"
> 
> xfs_io gets into interactive mode when invoked without a "-c cmd" string.
> 
> However, I am not able recreate the scenario once again without the above
> changes applied. I am not sure about what changed. 
> 

The test is opening a verity file for read+write access, which should fail.  But
it's incorrectly succeeding, hence the test is right to not pass.  Did you add
the missing call to ext4_set_inode_flags() in ext4_set_verity() as I suggested?

(But I'll make the suggested change to the test too, so it fails cleanly in this
case rather than hangs reading from stdin.)

- Eric
