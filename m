Return-Path: <SRS0=BOoS=S2=bombadil.srs.infradead.org=BATV+b85c7aa3a76ea8f4c774+5722+infradead.org+hch@kernel.org>
Date: Tue, 23 Apr 2019 22:35:44 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V1 02/14] Consolidate "post read processing" into a new
 file
Message-ID: <20190424053544.GA12092@infradead.org>
References: <20190424043730.13683-1-chandan@linux.ibm.com>
 <20190424043730.13683-3-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190424043730.13683-3-chandan@linux.ibm.com>
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 24, 2019 at 10:07:18AM +0530, Chandan Rajendra wrote:
> +ifeq (y, $(firstword $(filter y,$(CONFIG_FS_ENCRYPTION) $(CONFIG_FS_VERITY))))
> +obj-y +=	post_read_process.o
> +endif

Please just add a new config option selected by the users.

Also I find the file name rather cumbersome.  Maybe just
read-callbacks.[co] ?
