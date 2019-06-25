Return-Path: <SRS0=SM74=UY=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V3 0/7] Consolidate FS read I/O callbacks code
Date: Tue, 25 Jun 2019 11:54:18 +0530
In-Reply-To: <20190621221550.GF167064@gmail.com>
References: <20190616160813.24464-1-chandan@linux.ibm.com> <20190621221550.GF167064@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1680442.JJIz71cjaA@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Saturday, June 22, 2019 3:45:51 AM IST Eric Biggers wrote:
> On Sun, Jun 16, 2019 at 09:38:06PM +0530, Chandan Rajendra wrote:
> > This patchset moves the "FS read I/O callbacks" code into a file of its
> > own (i.e. fs/read_callbacks.c) and modifies the generic
> > do_mpage_readpge() to make use of the functionality provided.
> > 
> > "FS read I/O callbacks" code implements the state machine that needs
> > to be executed after reading data from files that are encrypted and/or
> > have verity metadata associated with them.
> > 
> > With these changes in place, the patchset changes Ext4 to use
> > mpage_readpage[s] instead of its own custom ext4_readpage[s]()
> > functions. This is done to reduce duplication of code across
> > filesystems. Also, "FS read I/O callbacks" source files will be built
> > only if CONFIG_FS_ENCRYPTION is enabled.
> > 
> > The patchset also modifies fs/buffer.c to get file
> > encryption/decryption to work with subpage-sized blocks.
> > 
> > The patches can also be obtained from
> > https://github.com/chandanr/linux.git at branch subpage-encryption-v3.
> > 
> 
> FWIW: while doing my review I put together an (untested) incremental patch that
> addresses my comments on the code, so I've provided it below in case you want to
> start with it when addressing my comments.
> 
> This is just a single diff against your subpage-encryption-v3 branch, so of
> course it would still need to be folded into the appropriate patches.  Also see
> my suggestions in reply to patch 2 about how to better organize the series.  I
> also left TODOs in kerneldoc comments that still need to be updated.
> 

Thanks for all your help. I will post the next version of the patchset
addressing all your review comments.

-- 
chandan
