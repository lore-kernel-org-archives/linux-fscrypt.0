Return-Path: <SRS0=XLAa=OG=linux.vnet.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/7] fsverity: Remove filesystem specific build config option
Date: Tue, 27 Nov 2018 19:01:28 +0530
In-Reply-To: <20181127004530.GF11663@gmail.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com> <20181119052324.31456-8-chandan@linux.vnet.ibm.com> <20181127004530.GF11663@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <2413763.K7ZbsYlPLa@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, November 27, 2018 6:15:30 AM IST Eric Biggers wrote:
> Hi Chandan,
> 
> On Mon, Nov 19, 2018 at 10:53:24AM +0530, Chandan Rajendra wrote:
> > In order to have a common code base for fsverity "post read" processing
> > for all filesystems which support per-file verity, this commit removes
> > filesystem specific build config option (e.g. CONFIG_EXT4_FS_VERITY) and
> > replaces it with a build option (i.e. CONFIG_FS_VERITY) whose value
> > affects all the filesystems making use of fsverity.
> > 
> > Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> 
> Like the corresponding fscrypt patch, this is missing changing
> 
> #if IS_ENABLED(CONFIG_FS_VERITY)
> 
> in include/linux/fs.h to
> 
> #ifdef CONFIG_FS_VERITY
> 
> There are also references to the filesystem-specific config options in
> Documentation/filesystems/fsverity.rst that need to be updated.
> 
> I also suggest updating the Kconfig help text for CONFIG_FS_VERITY and
> CONFIG_FS_ENCRYPTION to mention the supported filesystems, similar to how
> CONFIG_QUOTA lists the filesystems it supports.
> 

I will fix this one too.

-- 
chandan
