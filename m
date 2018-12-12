Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: Re: [BUG BISECT next] Files cannot be opened after "fsverity: Move verity status check to fsverity_file_open"
Date: Wed, 12 Dec 2018 09:41:18 +0530
In-Reply-To: <20181211174116.GB221175@gmail.com>
References: <CAJKOXPdNS+Qs6t1GwrgYhWT5EbtORJwYMzSrDPf8oAxv7ndNBg@mail.gmail.com> <20181211174116.GB221175@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3791832.MWVI2j2YUV@localhost.localdomain>
Sender: linux-ext4-owner@vger.kernel.org
To: Eric Biggers <ebiggers@kernel.org>
Cc: Krzysztof Kozlowski <krzk@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, December 11, 2018 11:11:17 PM IST Eric Biggers wrote:
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
> > 
> > Mounts:
> > 192.168.1.10:/srv/nfs/odroidhc1 on / type nfs4
> > (rw,relatime,vers=4.0,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.1.12,local_lock=none,addr=192.168.1.10)
> > /dev/mmcblk0p2 on /home type ext4 (rw,relatime)
> > 
> > Configuration:
> > 1. Arch ARM Linux
> > 2. exynos_defconfig
> >   - All my Odroid boards (ARMv7, Exynos)
> >     Systemd: v239, v238
> > 3. All boards boot from TFTP with NFS root (NFSv4)
> > No specific errors in boot log:
> > https://krzk.eu/#/builders/21/builds/1034/steps/12/logs/serial0
> > 
> > Let me know if you need any more data.
> > 
> > Best regards,
> > Krzysztof
> 
> Thanks Krzysztof.  Ted, this is the same bug I pointed out in my review of this
> patch yesterday (https://patchwork.kernel.org/patch/10719197/#22371523).  Can
> you fix or revert the two broken patches?  Thanks,
> 

Hi,

I have sent version V4 of the patchset now. My plan was to include the fix for
"Kconfig recursive dependency" issue reported for IA64 architecture. But I
would need some more time to understand the problem and provide a correct
fix. Hence the V4 patchset was sent with a fix to only address the problem
reported in this mail.

-- 
chandan
