Return-Path: <SRS0=psIF=OF=thunk.org=tytso@kernel.org>
Date: Sun, 25 Nov 2018 23:00:38 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [f2fs-dev] [PATCH 2/7] f2fs: use IS_ENCRYPTED() to check
 encryption status
Message-ID: <20181126040038.GD7904@thunk.org>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-3-chandan@linux.vnet.ibm.com>
 <20181119212332.GB33805@jaegeuk-macbookpro.roam.corp.google.com>
 <20181126034132.GC7904@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126034132.GC7904@thunk.org>
To: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, ebiggers@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Nov 25, 2018 at 10:41:32PM -0500, Theodore Y. Ts'o wrote:
> On Mon, Nov 19, 2018 at 01:23:32PM -0800, Jaegeuk Kim wrote:
> > Hi Chandan,
> > 
> > Let me try to queue and test this patch separately from the patch-set in order
> > to avoid merge conflicts. So, I think IS_ENCRYPTED should be merged in f2fs/ext4
> > branches, and the others can be applied to fscrypt and fsverity into each trees.
> 
> Hi Jaeguk,
> 
> What conflicts are you anticipating?  I can't apply the rest of
> Chandan's patches without unless we apply them in order, and I'd
> prefer to avoid cross-merging, or spreading out this series across two
> kernel releases.

Oh, I see the problem.  It's commit 79c66e7572 ("f2fs: clean up
f2fs_sb_has_##feature_name") on the f2fs dev branch.  It changes the
function signature of the f2fs_sb_has_<feature>() functions.

This is going to be a problem for merging the fsverity patch series as
well.   How stable are these patches on the f2fs dev branch?

79c66e75720c f2fs: clean up f2fs_sb_has_##feature_name
6a917e69d3b8 f2fs: remove codes of unused wio_mutex
67bdd2a68f0a f2fs: fix count of seg_freed to make sec_freed correct
a5c7029ba357 f2fs: fix to account preflush command for noflush_merge mode
83effa8865cc f2fs: avoid GC causing encrypted file corrupted

It might be that the simplest way to solve things is to merge the f2fs
dev branch up to 79c66e75720c.  This will have the net effect of
including the five patches listed above onto the fscrypt git tree.  So
long you don't plan to rebase or otherwise change these five patches,
it should avoid any merge conflicts.

						- Ted
