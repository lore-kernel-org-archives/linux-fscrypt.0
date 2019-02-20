Date: Tue, 19 Feb 2019 16:41:07 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 00/10] Consolidate Post read processing code
Message-ID: <20190220004107.GI12177@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218100433.20048-1-chandan@linux.ibm.com>
To: Chandan Rajendra <chandan@linux.ibm.com>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Feb 18, 2019 at 03:34:23PM +0530, Chandan Rajendra wrote:
> Based on the reviews provided for this patchset, I
> will change F2FS to use mpage_readpage[s] and post the next version of
> this patchset to linux-fsdevel mailing list.

Is that really possible?  F2FS has other functionality in its ->readpages(),
such as support for filesystems that use multiple block devices.

- Eric
