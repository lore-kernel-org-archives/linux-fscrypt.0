Return-Path: <linux-ext4-owner@vger.kernel.org>
Date: Tue, 11 Dec 2018 14:36:20 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [BUG BISECT next] Files cannot be opened after "fsverity: Move
 verity status check to fsverity_file_open"
Message-ID: <20181211223619.GF221175@gmail.com>
References: <CAJKOXPdNS+Qs6t1GwrgYhWT5EbtORJwYMzSrDPf8oAxv7ndNBg@mail.gmail.com>
 <20181211222721.GC4464@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211222721.GC4464@thunk.org>
Sender: linux-ext4-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Krzysztof Kozlowski <krzk@kernel.org>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 11, 2018 at 05:27:21PM -0500, Theodore Y. Ts'o wrote:
> On Tue, Dec 11, 2018 at 03:15:53PM +0100, Krzysztof Kozlowski wrote:
> > Hi,
> > 
> > Bisect from today's next pointed me to:
> > commit 4de97efb578a094e8fbf279522d41eb9ece1e3e0
> > Author: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> > Date:   Sat Dec 8 12:21:43 2018 +0530
> >     fsverity: Move verity status check to fsverity_file_open
> > 
> > as a reason of "Operation not supported" when reading any file from
> > mounted ext4fs (from SD card). Rootfs from nfsroot works but reading
> > from /home with ext4fs fails.
> 
> Can you send me an compressed e2image of your sdcard?
> 
> 	e2image -Q /dev/mmcblk0p2 sdcard.qcow2
> 	bzip2 -z sdcard.qcow2
> 
> Thanks!
> 
> 					- Ted

I don't think that's necessary.  Due to the bug, ext4_file_open() and
ext4_setattr() always return -EOPNOTSUPP when !CONFIG_FS_VERITY.

I'm working on a fixed version of the two patches to replace the ones currently
in the fscrypt tree.  Will send out soon.

- Eric
