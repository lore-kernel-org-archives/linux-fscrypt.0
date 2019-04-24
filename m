Return-Path: <SRS0=har8=S2=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V1 02/14] Consolidate "post read processing" into a new file
Date: Wed, 24 Apr 2019 20:29:10 +0530
In-Reply-To: <20190424142423.GA12761@infradead.org>
References: <20190424043730.13683-1-chandan@linux.ibm.com> <6353008.fQNhCuxumZ@localhost.localdomain> <20190424142423.GA12761@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <7402364.ucYHGh3o57@localhost.localdomain>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, April 24, 2019 7:54:23 PM IST Christoph Hellwig wrote:
> On Wed, Apr 24, 2019 at 03:34:17PM +0530, Chandan Rajendra wrote:
> > To clarify, Are you suggesting that a new kconfig option (say
> > CONFIG_FS_READ_CALLBACKS) be provided to the user so that the following could
> > occur,
> > 
> > 1. User selects CONFIG_FS_ENCRYPTION and/or CONFIG_FS_VERITY and this causes
> > CONFIG_FS_READ_CALLBACKS to be set to 'y'.
> > 2. User selects CONFIG_FS_READ_CALLBACKS explicitly.
> 
> If you don't add a user description to a Kconfig entry it won't be
> visible to users, but only selectable by other options.  That is what
> I suggest.
> 
> 

Thanks for the clarification. I will make the necessary changes.

-- 
chandan
