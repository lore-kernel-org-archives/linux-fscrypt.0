Return-Path: <SRS0=XLAa=OG=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] ext4: use IS_VERITY() to check inode's fsverity status
Date: Tue, 27 Nov 2018 08:33:52 +0530
In-Reply-To: <20181126173615.GB22888@thunk.org>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com> <20181119052324.31456-6-chandan@linux.vnet.ibm.com> <20181126173615.GB22888@thunk.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <1994749.6ROMBDTyAZ@localhost.localdomain>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, ebiggers@kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Monday, November 26, 2018 11:06:15 PM IST Theodore Y. Ts'o wrote:
> On Mon, Nov 19, 2018 at 10:53:22AM +0530, Chandan Rajendra wrote:
> > This commit now uses IS_VERITY() macro to check if fsverity is
> > enabled on an inode.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> 
> This patch causes a massive number of fsverity tests.  I suspect it's
> due to a mismatch between the ext4's inode flags as opposed to the VFS
> inode's flags.  I'll take a closer look in the next day or two.
> 

I will check this and report back soon. 

-- 
chandan
