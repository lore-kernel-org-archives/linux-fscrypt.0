Return-Path: <SRS0=mUW8=OU=thunk.org=tytso@kernel.org>
Date: Tue, 11 Dec 2018 17:27:21 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [BUG BISECT next] Files cannot be opened after "fsverity: Move
 verity status check to fsverity_file_open"
Message-ID: <20181211222721.GC4464@thunk.org>
References: <CAJKOXPdNS+Qs6t1GwrgYhWT5EbtORJwYMzSrDPf8oAxv7ndNBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJKOXPdNS+Qs6t1GwrgYhWT5EbtORJwYMzSrDPf8oAxv7ndNBg@mail.gmail.com>
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, Eric Biggers <ebiggers@kernel.org>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 11, 2018 at 03:15:53PM +0100, Krzysztof Kozlowski wrote:
> Hi,
> 
> Bisect from today's next pointed me to:
> commit 4de97efb578a094e8fbf279522d41eb9ece1e3e0
> Author: Chandan Rajendra <chandan@linux.vnet.ibm.com>
> Date:   Sat Dec 8 12:21:43 2018 +0530
>     fsverity: Move verity status check to fsverity_file_open
> 
> as a reason of "Operation not supported" when reading any file from
> mounted ext4fs (from SD card). Rootfs from nfsroot works but reading
> from /home with ext4fs fails.

Can you send me an compressed e2image of your sdcard?

	e2image -Q /dev/mmcblk0p2 sdcard.qcow2
	bzip2 -z sdcard.qcow2

Thanks!

					- Ted
