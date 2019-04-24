Return-Path: <SRS0=BOoS=S2=bombadil.srs.infradead.org=BATV+b85c7aa3a76ea8f4c774+5722+infradead.org+hch@kernel.org>
Date: Wed, 24 Apr 2019 07:24:23 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V1 02/14] Consolidate "post read processing" into a new
 file
Message-ID: <20190424142423.GA12761@infradead.org>
References: <20190424043730.13683-1-chandan@linux.ibm.com>
 <20190424043730.13683-3-chandan@linux.ibm.com>
 <20190424053544.GA12092@infradead.org>
 <6353008.fQNhCuxumZ@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6353008.fQNhCuxumZ@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 24, 2019 at 03:34:17PM +0530, Chandan Rajendra wrote:
> To clarify, Are you suggesting that a new kconfig option (say
> CONFIG_FS_READ_CALLBACKS) be provided to the user so that the following could
> occur,
> 
> 1. User selects CONFIG_FS_ENCRYPTION and/or CONFIG_FS_VERITY and this causes
> CONFIG_FS_READ_CALLBACKS to be set to 'y'.
> 2. User selects CONFIG_FS_READ_CALLBACKS explicitly.

If you don't add a user description to a Kconfig entry it won't be
visible to users, but only selectable by other options.  That is what
I suggest.
