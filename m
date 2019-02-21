Return-Path: <SRS0=Hy9y=Q4=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [RFC PATCH 08/10] fsverity: Add call back to verify file holes
Date: Thu, 21 Feb 2019 18:35:48 +0530
In-Reply-To: <20190220003507.GH12177@gmail.com>
References: <20190218100433.20048-1-chandan@linux.ibm.com> <20190218100433.20048-9-chandan@linux.ibm.com> <20190220003507.GH12177@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Message-Id: <3402546.YtSmlxULMa@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

On Wednesday, February 20, 2019 6:05:07 AM IST Eric Biggers wrote:
> On Mon, Feb 18, 2019 at 03:34:31PM +0530, Chandan Rajendra wrote:
> > readpage() implmentations zero out part of the page-cache page mapping a
> > file hole. This commit adds a call back to "struct fsverity_operations"
> > which readpage() can invoke to verify the file hole.
> 
> I don't see why this is needed.  Since now CONFIG_FS_VERITY will be a bool,
> can't you just call fsverity_verify_hole() directly?

Yes, I will drop this patch and replace the call back invocation (provided in
the next patch) with a call to fsverity_check_hole().

-- 
chandan
